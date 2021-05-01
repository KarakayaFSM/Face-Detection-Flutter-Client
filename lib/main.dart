import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///D:/AndroidStudioProjects/flutter_app/lib/Utils/Project.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Face Detection App",
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Detection App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            createNewProject(context),
            SizedBox(height: 20),
            openExistingProject(context),
            SizedBox(height: 20),
            openSettings(),
          ],
        ),
      ),
    );
  }

  ElevatedButton openSettings() {
    return ElevatedButton(
      onPressed: () {},
      child: Text("          Settings          "),
      style: getDefaultButtonStyle(),
    );
  }

  Widget openExistingProject(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        List<String> items = await getItemNamesIn(appRoot);
        changePage(
            context,
            FolderView(
              items,
              folderName: appRoot,
            ));
      },
      child: Text("Open Existing Project"),
      style: getDefaultButtonStyle(),
    );
  }

  ElevatedButton createNewProject(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (await requestPermission(Permission.storage).isDenied) {
          return;
        }

        await createAppRootFolder();

        Result result = await askFolderName(context, "Project Name");

        if (result.status == STATUS.CANCELLED) return;

        var targetPath = getPathFrom(result.response);
        var folderPath = (await createFolderInPictures(targetPath)).path;

        var projectName = getRelativePath(folderPath);

        showMessage(context, "Project $projectName created");
        var items = await getItemNamesIn(targetPath);

        changePage(
            context,
            FolderView(
              items,
              folderName: projectName,
            ));
      },
      child: Text("Create New Project"),
      style: getDefaultButtonStyle(),
    );
  }

  ButtonStyle getDefaultButtonStyle() {
    return ButtonStyle(
        minimumSize:
            MaterialStateProperty.resolveWith<Size>((states) => Size(70, 40)),
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(fontSize: 20)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))));
  }

  MaterialStateProperty<Size> setButtonSize() =>
      MaterialStateProperty.resolveWith<Size>((states) => Size(50, 50));

  MaterialStateProperty<Color> setButtonColor(BuildContext context) {
    return MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed))
          return Theme.of(context).colorScheme.primary.withOpacity(0.5);
        return null; // Use the component's default.
      },
    );
  }
}
