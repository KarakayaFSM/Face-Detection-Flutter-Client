import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';

class TextInputDialog extends StatefulWidget {
  final String title;

  const TextInputDialog({Key key, this.title}) : super(key: key);
  TextInputDialogState createState() => TextInputDialogState(title);
}

class TextInputDialogState extends State {
  final String title;
  final inputController = TextEditingController();

  TextInputDialogState(this.title);

  AlertDialog getAlertDialog() {
    return AlertDialog(
      title: Text(title),
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