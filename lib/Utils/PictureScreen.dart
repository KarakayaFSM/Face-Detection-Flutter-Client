import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';

class PictureScreen extends StatelessWidget {
  final String imagePath;
  final String parentFolder;

  const PictureScreen(this.parentFolder, {Key key, this.imagePath})
      : super(key: key);

  //TODO implement save picture
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Display the Picture")),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onSave(context);
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void onSave(BuildContext context) {
    var image = File(imagePath);
    var imageName = getRelativePath(image.path);
    print("image name: $imageName");
    print("parent folder: $parentFolder");
    var imageSavePath = prepareImagePath(imageName);
    print("image will be saved to $imageSavePath");

    image
        .copy(imageSavePath)
        .then((value) => showMessage(context, "$imageName created"));
  }

  String prepareImagePath(String imageName) =>
      path.join("$parentFolder", "$imageName");
}
