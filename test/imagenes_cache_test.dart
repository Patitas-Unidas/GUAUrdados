import 'dart:io' as io;
import 'package:file/file.dart' as files;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:guaurdados_oficial/services/imagenes_cache.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Disco extends FileSystem {
  _Disco(this.path);
  final String path;
  @override
  Future<files.File> createFile(String name) async =>
      const LocalFileSystem().file('$path/$name');
}

void main() {
  late io.Directory directory;
  late MockClient client;
  late ImagenesCache cache;
  late int requests;
  late int downloads;
  late String version;
  late bool expired;
  late bool offline;

  ImagenesCache openCache() => ImagenesCache(config: Config(
        'guaurdados_imagenes_v1',
        repo: JsonCacheInfoRepository(path: '${directory.path}/cache.json'),
        fileSystem: _Disco(directory.path),
        fileService: HttpFileService(httpClient: client),
      ));

  setUp(() async {
    directory = await io.Directory.systemTemp.createTemp('guau_cache_test_');
    requests = downloads = 0;
    version = 'v1';
    expired = offline = false;
    client = MockClient((request) async {
      requests++;
      if (offline) throw const io.SocketException('Sin conexión');
      final headers = {
        'cache-control': expired ? 'no-cache' : 'max-age=3600',
        'etag': '"$version"',
        'content-type': 'image/jpeg',
      };
      if (request.headers['if-none-match'] == '"$version"') {
        return http.Response('', 304, headers: headers);
      }
      downloads++;
      return http.Response(version, 200, headers: headers);
    });
    cache = openCache();
  });
  tearDown(() async {
    await cache.dispose();
    client.close();
    await directory.delete(recursive: true);
  });

  const url = 'https://example.test/foto.jpg?token=original';

  test('depuración distingue red, caché y 304 sin exponer tokens', () async {
    final messages = <String>[];
    final previousPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = previousPrint);

    expired = true;
    await cache.getFileStream(url).toList();
    expect(messages.any((m) => m.contains('RED: archivo recibido')), isTrue);
    await cache.dispose();
    cache = openCache();
    await cache.getFileStream(url).toList();
    expect(messages.any((m) => m.contains('CACHÉ DEL DISPOSITIVO')), isTrue);
    expect(messages.any((m) => m.contains('REVALIDACIÓN HTTP 304')), isTrue);
    expect(messages.every((m) => !m.contains('token=original')), isTrue);
    expect(messages.every((m) => !m.contains('https://')), isTrue);
    expect(downloads, 1);
  });

  test('reutiliza el archivo en disco después de reiniciar y sin conexión', () async {
    final first = await cache.getSingleFile(url);
    expect(await first.readAsString(), 'v1');
    await cache.dispose();
    cache = openCache();
    offline = true;
    final second = await cache.getSingleFile(url);
    expect(second.path, first.path);
    expect(await second.readAsString(), 'v1');
    expect(requests, 1);
  });

  test('una URL nueva descarga la imagen nueva', () async {
    await cache.getSingleFile(url);
    version = 'v2';
    final file = await cache.getSingleFile('$url&v=2');
    expect(await file.readAsString(), 'v2');
    expect(downloads, 2);
  });

  test('al caducar usa ETag y descarga solo si cambió el contenido', () async {
    expired = true;
    await cache.getSingleFile(url);
    await cache.dispose();
    cache = openCache();
    expect(await (await cache.getSingleFile(url)).readAsString(), 'v1');
    expect(requests, 2);
    expect(downloads, 1); // 304: el servidor no reenvía la imagen.
    await cache.dispose();
    cache = openCache();
    version = 'v2';
    expect(await (await cache.getSingleFile(url)).readAsString(), 'v2');
    expect(downloads, 2);
  });
}
