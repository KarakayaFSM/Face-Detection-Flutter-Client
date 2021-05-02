import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/CameraScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceDetectionProject extends StatelessWidget {
  final String folderName; // example: FaceDetection/Okul/Ahmet
  final List<String> items;

  const FaceDetectionProject(this.items, {Key key, this.folderName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Face Detection App",
        home: FolderView(
          items,
          folderName: folderName,
        ));
  }
}

class FolderView extends StatefulWidget {
  final String folderName;
  final List<String> items;

  const FolderView(this.items, {Key key, this.folderName = "folder"})
      : super(key: key);

  @override
  FolderViewState createState() => FolderViewState(folderName, items);
}

class FolderViewState extends State<FolderView> {
  final String folderName;
  final List<String> items;

  FolderViewState(this.folderName, this.items);

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

  Widget createFolderButton() {
    return Visibility(
      visible: isInBottomFolder(),
      child: FloatingActionButton(
        heroTag: "addFolder",
        onPressed: onCreateFolder,
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }

  bool isInBottomFolder() => '/'.allMatches(folderName).length < 2;

  void onCreateFolder() async {
    var permissionStatus = await requestPermission(Permission.storage);

    if (permissionStatus.isDenied) {
      return;
    }

    await createAppRootFolder();

    Result result = await askFolderName(context);

    if (result.status == STATUS.CANCELLED) {
      return;
    }

    var path = "${getPathFrom("$folderName/${result.response}")}";
    var newFolderPath = (await createFolderInPictures(path)).path;

    var relativePath = getRelativePath(newFolderPath);
    showMessage(context, "$relativePath created");

    addItem(relativePath);
  }

  void addItem(String relativePath) {
    setState(() {
      items.add(relativePath);
    });
  }

  Widget openCameraButton() {
    return Visibility(
      visible: !isInBottomFolder(),
      child: FloatingActionButton(
        heroTag: "takePhoto",
        onPressed: onOpenCamera,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> onOpenCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

    final firstCamera = cameras.first;

    var parentFolder = await getFolderInPictures(getPathFrom(folderName));
    changePage(context, CameraScreen(parentFolder.path, camera: firstCamera));
  }

  Widget buildListView() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (index < items.length) {
          return Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) => deleteItemAt(index),
              child: _buildListTile(index),
              background: Container(color: Colors.red));
        }
        return ListTile();
      },
    );
  }

  ListTile _buildListTile(int index) {
    var item = items[index];
    return ListTile(
      leading: Visibility(
        child: Icon(Icons.folder),
        visible: isInBottomFolder(),
      ),
      trailing: Icon(Icons.navigate_next),
      title: Text('$item'),
      onTap: () {
        _itemOnTap(context, item);
      },
    );
  }

  Future<Result> _itemOnTap(BuildContext context, String item) async {
    var targetPath = getPathFrom("$folderName/$item");
    return changePage(
        context,
        FolderView(
          await getItemNamesIn(targetPath),
          folderName: targetPath,
        ));
  }

  void deleteItemAt(int index) async {
    //TODO check for all folder levels, would not work for bottom folder, use getPathFrom
    final String removedItem = items.removeAt(index);

    final String directory = (await getFolderInPictures(folderName)).path;
    var removedEntity = "$directory/$removedItem";

    await deleteFileSystemEntity(removedEntity);

    setState(() {});

    showMessage(context, "$removedItem removed");
  }

  Future deleteFileSystemEntity(String removedEntity) async {
    if (await FileSystemEntity.isDirectory(removedEntity)) {
      await Directory(removedEntity).delete();
    } else {
      File(removedEntity).delete();
    }
  }
}
