import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'TextInputDialog.dart';

enum STATUS { OK, CANCELLED }

final String appRoot = "FaceDetection";
final String pictures = "Pictures";

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

Future<Result> askFolderName(BuildContext context,
    [title = "Folder Name"]) async {
  return changePage(context, TextInputDialog(title: title));
}

Future<Directory> getOrCreate(Directory directory) async {
  return await directory.exists() ? directory : await directory.create();
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
    BuildContext context, String message) {
  return ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

String getRelativePath(String path) {
  path = path.substring(path.lastIndexOf("/") + 1);
  return path;
}

Future<Directory> getFolderInPictures(String folderPath) async {
  return Directory("${(await getSpecialFolder("Pictures")).path}/$folderPath");
}

Future<Directory> createFolderInPictures(String folderPath) async {
  var directory = (await getFolderInPictures(folderPath));
  return getOrCreate(directory);
}

Future<List<String>> getItemNamesIn(String folderPath) async {
  var currentFolder = await getFolderInPictures(folderPath);
  var itemsInFolder = await currentFolder.list().map((element) {
    return getRelativePath(element.path);
  }).toList();

  return itemsInFolder;
}

List<String> removeDuplicates(List<String> items) {
  return items.toSet().toList();
}

Future createAppRootFolder() async {
  var response = await requestPermission(Permission.storage);

  if (response.isDenied) return;

  var directory = (await getFolderInPictures(appRoot));
  await getOrCreate(directory);
}

String getPathFrom(String folderName, {bool relative = false}) {
  if (folderName == appRoot) return folderName;

  final String target =
      folderName.contains(appRoot) ? folderName : "$appRoot/$folderName";

  var result = relative ? getRelativePath(target) : target;
  print("$folderName becomes $result after apply prefix");
  return result;
}

Future changeFileNameOnly(File file, String newFileName) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

bool isDirectory(String path) {
  print("path: $path");
  bool isDirectory = false;
  FileSystemEntity.isDirectory(path).then((value) => isDirectory = value);
  print("is directory: $isDirectory");
  return isDirectory;
}
