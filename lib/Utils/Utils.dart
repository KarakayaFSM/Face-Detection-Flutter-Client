import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'TextInputDialog.dart';

enum STATUS { OK, CANCELLED }

class Result {
  final STATUS status;
  dynamic response;

  Result(this.status, [this.response]);
}

Future<Result> changePage(BuildContext bContext, Widget widget) async {
  Result response = await Navigator.push(
      bContext, MaterialPageRoute(builder: (context) => widget));
  return response;
}

void closePage(BuildContext context, Result result) =>
    Navigator.of(context).pop(result);

showAlert(BuildContext context, Widget widget) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

Future<Directory> getSpecialFolder(String folderName) async {
  //TODO take enum as param. instead of string
  var externalStoragePath = (await getExternalStorageDirectory()).path;
  String dirPath = '$externalStoragePath/$folderName';
  //TODO can be made programmatic, instead of hardcoding
  //https://github.com/flutter/plugins/blob/master/packages/package_info/lib/package_info.dart
  String packageName = "com.example.flutter_app";
  dirPath = dirPath.replaceFirst("Android/data/$packageName/files/", "");
  return Directory(dirPath);
}

Future<PermissionStatus> requestPermission(Permission permission) async {
  return await permission.request();
}

Future<Result> askFolderName(BuildContext context) async {
  return changePage(context, TextInputDialog());
}

Future<Directory> createFolder(String folderName) async {
  final String specialFolderPath = (await getSpecialFolder("Pictures")).path;
  final Directory directory = Directory("$specialFolderPath/$folderName");

  return await directory.exists()
      ? directory
      : await directory.create(recursive: true);
}