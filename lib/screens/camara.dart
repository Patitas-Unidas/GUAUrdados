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
        onPressed: (){},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}