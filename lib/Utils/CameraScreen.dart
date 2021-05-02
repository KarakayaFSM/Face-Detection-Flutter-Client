import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/PictureScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final String parentFolder;

  const CameraScreen(
    this.parentFolder, {
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState(parentFolder);
}

class CameraScreenState extends State<CameraScreen> {
  final String parentFolder;
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  CameraScreenState(this.parentFolder);

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

  void onTakePicture() async {
    try {
      await _initializeControllerFuture;

      changePage(context,
          PictureScreen(parentFolder,imagePath: (await _controller.takePicture()).path));
    } catch (e) {
    print(e);
    }
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
}
