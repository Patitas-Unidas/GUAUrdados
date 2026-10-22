import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Camara extends StatefulWidget {
  const Camara({super.key});

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  bool isReady = false;
  late List<CameraDescription> camaras;
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      camaras = await availableCameras();
      _controller = CameraController(
        camaras[0],
        ResolutionPreset.high,
      );
      await _controller.initialize();
    }
    on CameraException catch (_) {
      debugPrint("Hay un error.");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                height: MediaQuery.of(context).size.height * .10,
                color: Color.fromRGBO(0, 0, 0, .7),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .70,
                color: Colors.transparent,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .20,
                color: Color.fromRGBO(0, 0, 0, .7),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, left: 10,),
            child: IconButton.filledTonal(
              icon: Icon(Icons.arrow_back),
              iconSize: 20,
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        shape: CircleBorder(),
        onPressed: () async {
          try {
            await _controller.initialize();
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          }
          catch (e) {
            return;
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, left: 10, bottom: 10,),
            child: IconButton.filledTonal(
              icon: Icon(Icons.arrow_back),
              iconSize: 20,
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Image.file(File(imagePath)),
        ],
      ),
    );
  }
}