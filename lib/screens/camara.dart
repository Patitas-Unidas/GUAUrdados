import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Camara extends StatefulWidget {
  const Camara({super.key});

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  bool isReady = false;
  late List<CameraDescription> camaras;
  late CameraController _controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      camaras = await availableCameras();
      if (camaras.isEmpty) return;

      _controller = CameraController(
        camaras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller.initialize();
    } on CameraException catch (_) {
      debugPrint("Error al inicializar la cámara.");
    }

    if (!mounted) return;

    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navegarADisplay(String imagePath) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DisplayPictureScreen(
          imagePath: imagePath,
        ),
      ),
    );
  }

  Future<void> _seleccionarDeGaleria() async {
    try {
      final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
      if (imagen != null && mounted) {
        await _navegarADisplay(imagen.path);
      }
    } catch (e) {
      debugPrint("Error al seleccionar de galería: $e");
    }
  }

  Future<void> _capturarFoto() async {
    try {
      final image = await _controller.takePicture();
      if (!mounted) return;
      await _navegarADisplay(image.path);
    } catch (e) {
      debugPrint("Error al capturar fotografía: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || !_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(_controller),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.10,
                color: const Color.fromRGBO(0, 0, 0, .7),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.70,
                color: Colors.transparent,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                color: const Color.fromRGBO(0, 0, 0, .7),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35, left: 16),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "btn_galeria",
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  onPressed: _seleccionarDeGaleria,
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton.large(
                  heroTag: "btn_captura",
                  shape: const CircleBorder(),
                  onPressed: _capturarFoto,
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool _isLoading = false;

  final String _apiUrl = "https://hangnail-frosty-gave.ngrok-free.dev/identificar";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _identificarPerro();
    });
  }

  Future<void> _identificarPerro() async {
    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', widget.imagePath),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      setState(() => _isLoading = false);
      if (!mounted) return;
      _gestionarRespuesta(data);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _mostrarAlerta("Error de conexión", "No se pudo comunicar con el servidor: $e");
    }
  }

  void _avisoPerfil(String nombrePerro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("El perfil de $nombrePerro estará disponible próximamente."),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _gestionarRespuesta(Map<String, dynamic> data) {
    final status = data['status'] ?? 'ERROR';

    if (status == 'MATCH') {
      final perro = data['perro'];
      _mostrarModalMatch(perro['nombre'], perro['sexo'], perro['coincidencia']);
    } else if (status == 'AMBIGUOUS') {
      final c1 = data['candidato_1'];
      final c2 = data['candidato_2'];
      _mostrarModalAmbiguo(c1, c2);
    } else {
      _mostrarAlerta(
        "Sin coincidencia",
        data['mensaje'] ?? "No se encontró ningún registro que coincida.",
      );
    }
  }

  void _mostrarModalMatch(String nombre, String sexo, String coincidencia) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Perro identificado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Es $nombre", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Sexo: $sexo"),
            Text("Similitud: $coincidencia"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _avisoPerfil(nombre);
            },
            icon: const Icon(Icons.pets),
            label: const Text("Ver perfil"),
          ),
        ],
      ),
    );
  }

  void _mostrarModalAmbiguo(Map<String, dynamic> c1, Map<String, dynamic> c2) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Doble coincidencia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("El perro podría ser alguno de los siguientes:"),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey),
              ),
              title: Text("${c1['nombre']} (${c1['sexo']})", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Similitud: ${c1['coincidencia']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _avisoPerfil(c1['nombre']);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.grey),
              ),
              title: Text("${c2['nombre']} (${c2['sexo']})", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Similitud: ${c2['coincidencia']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _avisoPerfil(c2['nombre']);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 35,
            left: 16,
            child: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Analizando rasgos...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}