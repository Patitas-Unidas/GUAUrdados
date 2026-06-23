import 'package:flutter/material.dart';

class Foro extends StatelessWidget {
  const Foro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Align(
          alignment: Alignment(-.98, 0),
          child: IconButton.filledTonal(
            icon: Icon(Icons.arrow_back),
            iconSize: 20,
            color: Colors.grey,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}