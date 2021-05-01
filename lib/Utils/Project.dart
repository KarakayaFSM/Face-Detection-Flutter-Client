import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/CameraScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceDetectionProject extends StatelessWidget {
  final String folderName;
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
        body: buildMyList(),
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
      visible: '/'.allMatches(folderName).length < 2,
      child: FloatingActionButton(
        heroTag: "addFolder",
        onPressed: onCreateFolder,
        child: Icon(Icons.create_new_folder_outlined),
      ),
    );
  }

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

    print(newFolderPath + " created");

    var relativePath = getRelativePath(newFolderPath);
    addItem(relativePath);
  }

  void addItem(String relativePath) {
    setState(() {
      items.add(relativePath);
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

  Widget buildMyList() {
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

  // Widget buildListView() {
  //   return FutureBuilder(
  //       builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
  //         return ListView.builder(
  //           itemCount: items.length,
  //           itemBuilder: (context, index) {
  //             return Dismissible(
  //                 key: UniqueKey(),
  //                 onDismissed: (direction) => deleteItemAt(index),
  //                 child: _buildListTile(index),
  //                 background: Container(color: Colors.red));
  //           },
  //         );
  //       },
  //       future: _populateItems());
  // }

  ListTile _buildListTile(int index) {
    return ListTile(
      leading: Icon(Icons.folder),
      trailing: Icon(Icons.navigate_next),
      title: Text('${items[index]}'),
      onTap: () {
        _itemOnTap(context, items[index]);
      },
    );
  }

  Future<Result> _itemOnTap(BuildContext context, String item) async {
    var targetPath = getPathFrom(item);
    (await getItemNamesIn(targetPath)).forEach((element) {print(element);});
    return changePage(
        context,
        FolderView(
          await getItemNamesIn(targetPath),
          folderName: targetPath,
        ));
  }

  void deleteItemAt(int index) async {
    //TODO check in all folder levels, would not work for bottom folder, use getPathFrom
    final String removedItem = items.removeAt(index);

    final String directory = (await getFolderInPictures(folderName)).path;
    showMessage(context, "$directory/$removedItem will be deleted");
    await Directory("$directory/$removedItem").delete(recursive: true);

    setState(() {});

    showMessage(context, "$removedItem removed");
  }
}
