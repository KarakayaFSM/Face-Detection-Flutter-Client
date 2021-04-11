import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

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
    print("\n\nITEM CREATED AT $path\n\n");
    items.add(path.substring(path.lastIndexOf("/") + 1));
    setState(() {});
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

    changePage(context, TakePictureScreen(camera: firstCamera));
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

class TextInputDialog extends StatefulWidget {
  TextInputDialogState createState() => TextInputDialogState();
}

class TextInputDialogState extends State {
  final inputController = TextEditingController();

  AlertDialog getAlertDialog() {
    return AlertDialog(
      title: Text('Folder Name'),
      content: TextField(controller: inputController),
      actions: <Widget>[
        onOK(),
        onCancel(),
      ],
    );
  }

  TextButton onOK() {
    return TextButton(
      child: Text("OK"),
      onPressed: () {
        closePage(context, Result(STATUS.OK, inputController.text));
      },
    );
  }

  TextButton onCancel() {
    return TextButton(
      child: Text("CANCEL"),
      onPressed: () {
        closePage(context, Result(STATUS.CANCELLED));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Folder"),
      ),
      body: Center(
        child: getAlertDialog(),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Take a picture")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          return getCameraPreview(snapshot.connectionState);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onTakePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void onTakePicture() async {
    //TODO Try removing microphone permission. (later !)
    try {
      await _initializeControllerFuture;

      changePage(
          context,
          DisplayPictureScreen(
              imagePath: (await _controller.takePicture()).path));
    } catch (e) {
      print(e);
    }
  }

  Widget getCameraPreview(ConnectionState cameraState) {
    return cameraState == ConnectionState.done
        ? CameraPreview((_controller))
        : Center(child: CircularProgressIndicator());
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  //TODO implement save picture feature
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Display the Picture")),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.save),
      ),
    );
  }
}

Future<Directory> getSpecialFolder(String folderName) async {
  var externalStoragePath = (await getExternalStorageDirectory()).path;
  String dirPath = '$externalStoragePath/$folderName';
  //TODO can be made programmatic, instead of hardcoding
  //https://github.com/flutter/plugins/blob/master/packages/package_info/lib/package_info.dart
  String packageName = "com.example.flutter_app";
  dirPath = dirPath.replaceFirst("Android/data/$packageName/files/", "");
  return Directory(dirPath);
}

class DownloadsPathProvider {
  static const MethodChannel _channel =
  const MethodChannel('downloads_path_provider');

  static Future<Directory> get downloadsDirectory async {
    final String path = await _channel
        .invokeMethod('getDownloadsDirectory')
        .onError(
            (error, stackTrace) => print("${error.toString()}\n\n$stackTrace"));
    return Directory(path);
  }
}
