import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/AnalyzeGroup.dart';
import 'package:flutter_app/Utils/Group.dart';
import 'package:flutter_app/Utils/InitializeGroup.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(HomePage());
  //runApp(AnalysisPage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    createAppRootFolder();
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
      appBar: AppBar(
        title: Text("Face Detection App"),
        actions: [
          IconButton(
              onPressed: () {
                changePage(context, HomePage());
              },
              icon: Icon(Icons.home)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            createNewGroup(context),
            SizedBox(height: 20),
            openExistingGroup(context),
            SizedBox(height: 20),
            initializeGroup(context),
            SizedBox(height: 20),
            analyzeGroup(context),
          ],
        ),
      ),
    );
  }

  Widget initializeGroup(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        changePage(context, InitializationPage());
      },
      child: Text("     Initialize Group     "),
      style: getDefaultButtonStyle(),
    );
  }

  Widget analyzeGroup(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        changePage(context, AnalysisPage());
      },
      child: Text("     Analyze Group    "),
      style: getDefaultButtonStyle(),
    );
  }

  Widget openExistingGroup(BuildContext context) {
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
      child: Text("Open Existing Group"),
      style: getDefaultButtonStyle(),
    );
  }

  Widget createNewGroup(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (await requestPermission(Permission.storage).isDenied) {
          return;
        }

        await createAppRootFolder();

        Result result = await askFolderName(context, "Group Name");

        if (result.status == STATUS.CANCELLED) return;

        var targetPath = getPathFrom(result.response);
        var folderPath = (await createFolderInPictures(targetPath)).path;

        var groupName = getRelativePath(folderPath);

        showMessage(context, "Group $groupName created");
        var items = await getItemNamesIn(targetPath);

        changePage(
            context,
            FolderView(
              items,
              folderName: groupName,
            ));
      },
      child: Text(" Create New Group "),
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
