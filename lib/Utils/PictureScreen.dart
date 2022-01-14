import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'Utils.dart';

class PictureScreen extends StatelessWidget {
  final String imagePath;

  const PictureScreen(this.imagePath, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Display the Picture"),
          actions: [
            IconButton(
                onPressed: () {
                  changePage(context, HomePage());
                },
                icon: Icon(Icons.home)),
          ],
        ),
        body: Image.file(File(imagePath)));
  }
}
