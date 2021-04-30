import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/CameraScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceDetectionProject extends StatelessWidget {
  final String folderName;

  const FaceDetectionProject({Key key, this.folderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Face Detection App",
        home: FolderView(
          folderName: folderName,
        ));
  }
}

class FolderView extends StatefulWidget {
  final String folderName;

  const FolderView({Key key, this.folderName}) : super(key: key);

  @override
  FolderViewState createState() => FolderViewState(folderName);
}

class FolderViewState extends State<FolderView> {
  final String folderName;
  List<String> items = [];

  FolderViewState(this.folderName);

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
                    onTap: () {
                      changePage(
                          context,
                          FolderView(
                            folderName: "$folderName/$item",
                          ));
                    },
                  ),
                  background: Container(color: Colors.red));
            },
          );
        },
        future: populateItems());
  }

  Future<void> populateItems() async {
    String path = folderName == appRoot ? appRoot : getCurrentPath();
    items.addAll(await getItemNamesIn(path));
  }

  String getCurrentPath() {
    final String target =
        folderName.contains(appRoot) ? folderName : "$appRoot/$folderName";
    print(target);
    return target;
  }

  void deleteItemAt(int index) async {
    final String removedItem = items.removeAt(index);

    final String directory = (await getFolderInPictures(folderName)).path;
    await Directory("$directory/$removedItem").delete(recursive: true);

    setState(() {});

    showSnackBar(context, "$removedItem removed");
  }
}
