import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PictureScreen extends StatelessWidget {
  final String imagePath;

  const PictureScreen({Key key, this.imagePath}) : super(key: key);

  //TODO implement save picture
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Display the Picture")),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("imagepath: $imagePath");
        },
        child: Icon(Icons.save),
      ),
    );
  }
}