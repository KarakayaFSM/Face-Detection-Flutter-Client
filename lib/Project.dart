import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/CameraScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceDetectionProject extends StatelessWidget {
  final String folderName;

  const FaceDetectionProject({Key key, this.folderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Face Detection App",
        home: Folder(
          folderName: folderName,
        ));
  }
}

class Folder extends StatefulWidget {
  final String folderName;

  const Folder({Key key, this.folderName}) : super(key: key);

  @override
  FolderState createState() => FolderState(folderName);
}

class FolderState extends State<Folder> {
  final String folderName;
  List<String> items = [];

  FolderState(this.folderName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(folderName)),
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

    var path = (await createFolderInProject(folderName, result.response)).path;

    setState(() {
      items.add(getRelativePath(path));
    });
  }

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

  Widget buildListView() {
    return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
        },
        future: populateItems());
  }

  Future<void> populateItems() async {
    items.addAll(await getItemsInFolder(this.folderName));
  }

  List<String> removeDuplicates(List<String> items) {
    return items.toSet().toList();
  }

  void deleteItemAt(int index) async {
    final String removedItem = items.removeAt(index);
    setState(() {});

    final String directory = (await getApplicationDocumentsDirectory()).path;
    await Directory("$directory/$removedItem").delete(recursive: true);

    showSnackBar(context, "$removedItem removed");
  }

  Future<List<String>> getItemsInFolder(String folderName) async {
    var currentFolder = await getFolderInPictures(folderName);

    var itemsInFolder = await currentFolder.list().map((element) {
      return getRelativePath(element.path);
    }).toList();

    return itemsInFolder;
  }
}
