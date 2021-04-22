import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text("Folder List")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            createNewProject(),
            SizedBox(height: 20),
            openExistingProject(),
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

  ElevatedButton openExistingProject() {
    return ElevatedButton(
      onPressed: () {},
      child: Text("Open Existing Project"),
      style: getDefaultButtonStyle(),
    );
  }

  ElevatedButton createNewProject() {
    return ElevatedButton(
      onPressed: () {},
      child: Text("Create New Project"),
      style: getDefaultButtonStyle(),
    );
  }

  ButtonStyle getDefaultButtonStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.resolveWith<Size>((states) => Size(70, 40)),
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
