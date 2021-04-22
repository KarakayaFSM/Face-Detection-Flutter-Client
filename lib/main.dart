import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_app/Utils/Utils.dart';
import 'package:flutter_app/Utils/CameraScreen.dart';
import 'package:flutter_app/Utils/TextInputDialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainWidget());
  }
}

class MainWidget extends StatefulWidget {
  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  final List<String> items = ["a", "b", "c", "d"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Folder List")),
        body: buildListView(),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: bottomRightButtons(),
        ));
  }

  Column bottomRightButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        createFolderButton(),
        SizedBox(width: 50),
        openCameraButton()
      ],
    );
  }

  FloatingActionButton createFolderButton() {
    return FloatingActionButton(
      heroTag: "addFolder",
      onPressed: onCreateFolder,
      child: Icon(Icons.create_new_folder_outlined),
    );
  }

  void onCreateFolder() async {
    var permissionStatus = await requestPermission(Permission.storage);

    if (permissionStatus.isDenied) {
      return;
    }

    Result result = await askFolderName(context);

    if (result.status == STATUS.CANCELLED) {
      return;
    }

    var path = (await createFolder(result.response)).path;

    items.add(getRelativePath(path));
    setState(() {});
  }

  String getRelativePath(String path) =>
      path.substring(path.lastIndexOf("/") + 1);

  FloatingActionButton openCameraButton() {
    return FloatingActionButton(
      heroTag: "takePhoto",
      onPressed: onOpenCamera,
      child: Icon(Icons.camera_alt),
    );
  }

  Future<void> onOpenCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

    final firstCamera = cameras.first;

    changePage(context, CameraScreen(camera: firstCamera));
  }

  void addItem(String itemName) {
    setState(() {
      items.add(itemName);
    });
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
            key: Key(item),
            onDismissed: (direction) => deleteItemAt(index),
            child: ListTile(
              leading: Icon(Icons.folder),
              title: Text('${items[index]}'),
            ),
            background: Container(color: Colors.red));
      },
    );
  }

  void deleteItemAt(int index) async {
    final String removedItem = items.removeAt(index);
    setState(() {});

    final String directory = (await getApplicationDocumentsDirectory()).path;
    await Directory("$directory/$removedItem").delete(recursive: true);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$removedItem removed")));
  }
}
