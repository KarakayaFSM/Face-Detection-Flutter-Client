import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:flutter_app/main.dart';
import 'package:http/http.dart' as http;

class AnalysisPage extends StatefulWidget {
  @override
  _ComboBoxState createState() => _ComboBoxState();
}

class _ComboBoxState extends State<AnalysisPage> {
  final String initializeGroupEndPoint = "/analysis/group/listMembers";
  final String familyPhoto = "familyPhoto";
  final String COMBOBOX_HINT = "SELECT A GROUP";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Analyze Group"),
          actions: [
            IconButton(
                onPressed: () {
                  changePage(context, HomePage());
                },
                icon: Icon(Icons.home)),
          ],
        ),
        body: Center(
          child: analyzeButton(context),
        ));
  }

  List<DropdownMenuItem<String>> buildMenuItems(List<String> data) {
    if (data.isEmpty)
      return [
        DropdownMenuItem(value: COMBOBOX_HINT, child: Text(COMBOBOX_HINT))
      ];
    return data.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }

  Widget analyzeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var result = await analyzeGroup();
        if (result.status == STATUS.EMPTY) {
          showMessage(context, "An error occurred, please try again later");
          return;
        }
        showAnalysisResult(context, result.response);
      },
      child: Text("Select Image To Analyze"),
      style: getDefaultButtonStyle(),
    );
  }

  Future<Result> analyzeGroup() async {
    STATUS status = STATUS.EMPTY;
    var responseBody = "";
    var result = await showPicker(context);

    if (result != null && result.status != STATUS.EMPTY) {
      var imagePath = result.response;
      var request = await prepareMultipartRequest(imagePath);

      var httpResponse = await request.send();
      responseBody = (await httpResponse.stream.bytesToString());

      Map<String, dynamic> response = jsonDecode(responseBody);

      var isError = responseBody.toLowerCase().contains("error");

      if (!isError) {
        status = STATUS.OK;
        return Result(status, response['response']);
      }

      var errorMessage =
          "An error occurred while uploading your files, please try again later";
      showMessage(context, errorMessage);
    }

    return Result();
  }

  void showAnalysisResult(BuildContext context, response) {
    String resultText = response == "[]"
        ? "No people from group found in this image"
        : "People in this image:\n\n$response";

    AlertDialog alert = AlertDialog(
      title: Text("Analysis Result"),
      content: Text(resultText),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"))
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<http.MultipartRequest> prepareMultipartRequest(String filePath) async {
    var uri = Uri.http(authority, initializeGroupEndPoint);
    var request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('groupPhoto', filePath));
    return request;
  }

  Future<File> compress(String folderName) async {
    var directory = await getFolderInPictures(getPathFrom(folderName));
    try {
      var picturesFolder = await getSpecialFolder("Pictures");

      var zipFileName = "${picturesFolder.path}/$folderName.$zipType";

      ZipFileEncoder().zipDirectory(directory, filename: zipFileName);

      return File(zipFileName);
    } catch (e) {
      print(e);
      throw new Exception("An error occured, zip file could not be created");
    }
  }

  ButtonStyle getDefaultButtonStyle() {
    return ButtonStyle(
        minimumSize:
            MaterialStateProperty.resolveWith<Size>((states) => Size(200, 50)),
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(fontSize: 20)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))));
  }
}
