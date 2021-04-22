import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.high,
        enableAudio: false);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Take a picture")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          return getCameraPreview(snapshot.connectionState);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onTakePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget getCameraPreview(ConnectionState cameraState) {
    try {
      return cameraState == ConnectionState.done
          ? CameraPreview(_controller)
          : Center(child: CircularProgressIndicator());
    } catch (e) {
      print(e);
    }
    return Center(child: CircularProgressIndicator());
  }

  void onTakePicture() async {
    try {
      await _initializeControllerFuture;

      changePage(context,
          PictureScreen(imagePath: (await _controller.takePicture()).path));
    } catch (e) {
      print(e);
    }
  }
}

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