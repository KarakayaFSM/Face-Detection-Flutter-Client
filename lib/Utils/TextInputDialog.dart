import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';

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