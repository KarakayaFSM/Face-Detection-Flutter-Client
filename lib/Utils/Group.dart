import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/PictureScreen.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:flutter_app/main.dart';
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
  List<String> items;

  FolderViewState(this.folderName, this.items);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(folderName),
          actions: [
            IconButton(
                onPressed: () {
                  changePage(context, HomePage());
                },
                icon: Icon(Icons.home)),
          ],
        ),
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
        addPersonButton(),
        SizedBox(width: 50),
        addPhotoButton(context)
      ],
    );
  }

  Widget addPersonButton() {
    return Visibility(
      visible: !isInBottomFolder(),
      child: FloatingActionButton(
        heroTag: "addPerson",
        onPressed: onAddPerson,
        child: Icon(Icons.person_add),
      ),
    );
  }

  bool isInBottomFolder() => '/'.allMatches(folderName).length >= 2;

  void onAddPerson() async {
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
    showMessage(context, "$relativePath added");

    addItem(relativePath);
  }

  void addItem(String relativePath) {
    setState(() {
      items.add(relativePath);
    });
  }

  Widget addPhotoButton(BuildContext context) {
    return Visibility(
      visible: isInBottomFolder(),
      child: FloatingActionButton(
        heroTag: "addPhoto",
        onPressed: () async {
          var result = await showPicker(context);

          if (result != null && result.status != STATUS.EMPTY) {
            var imgPath = result.response;
            File(imgPath).createSync();
            var destDir = (await getFolderInPictures(folderName)).path;
            var destFileName =
                folderName.substring(folderName.lastIndexOf('/'));
            await File(imgPath).rename(
                '$destDir/$destFileName-${getRandomSuffix()}.$photoType');
            items = await getItemNamesIn(folderName);
            setState(() {});
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  int getRandomSuffix() => Random.secure().nextInt(1000);

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
      leading: Icon(Icons.person),
      trailing: Icon(Icons.navigate_next),
      title: Text('$item'),
      onTap: () {
        _itemOnTap(context, item);
      },
    );
  }

  Future<Result> _itemOnTap(BuildContext context, String item) async {
    if (isInBottomFolder()) {
      var absolutePath = (await getFolderInPictures(folderName)).path;
      print('itemPath: $absolutePath/$item');
      return changePage(context, PictureScreen('$absolutePath/$item'));
    }

    var targetPath = getPathFrom("$folderName/$item");

    return changePage(
        context,
        FolderView(
          await getItemNamesIn(targetPath),
          folderName: targetPath,
        ));
  }

  void deleteItemAt(int index) async {
    final String removedItem = items.removeAt(index);

    final String directory = (await getFolderInPictures(folderName)).path;
    var removedEntity = "$directory/$removedItem";

    await deleteFileSystemEntity(removedEntity);


    setState(() {});

    showMessage(context, "$removedItem removed");
  }

  Future deleteFileSystemEntity(String removedEntity) async {
    if (await FileSystemEntity.isDirectory(removedEntity)) {
      await Directory(removedEntity).delete(recursive: true);
    } else {
      File(removedEntity).delete();
    }
  }
}
