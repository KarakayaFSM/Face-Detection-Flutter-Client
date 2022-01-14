import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/Utils.dart';
import 'package:flutter_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InitializationPage extends StatefulWidget {
  @override
  _ComboBoxDemoState createState() => _ComboBoxDemoState();
}

class _ComboBoxDemoState extends State<InitializationPage> {
  String selected;
  final String initializeGroupEndPoint = "/analysis/initializeGroup";
  final String familyPhoto = "familyPhoto";
  final String COMBOBOX_HINT = "SELECT A GROUP";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Initialize Group"),
        actions: [
          IconButton(
              onPressed: () {
                changePage(context, HomePage());
              },
              icon: Icon(Icons.home)),
        ],
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildDropdownButton(snapshot.data),
                  SizedBox(height: 20),
                  uploadButton(context)
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
        future: getItemNamesIn(appRoot),
      ),
    );
  }

  DropdownButton<String> buildDropdownButton(List<String> data) {
    return DropdownButton(
        autofocus: true,
        isExpanded: true,
        value: selected,
        onChanged: (selectedItem) {
          setState(() {
            if (selectedItem == null) return;
            selected = selectedItem;
          });
        },
        items: buildMenuItems(data));
  }

  List<DropdownMenuItem<String>> buildMenuItems(List<String> data) {
    if (data.isEmpty)
      return [
        DropdownMenuItem(value: COMBOBOX_HINT, child: Text(COMBOBOX_HINT))
      ];
    return data.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();
  }

  Widget uploadButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (selected == null) return;
        var status = await initializeGroup(selected);
        await markInitialized(status);
      },
      child: Text("Upload"),
      style: getDefaultButtonStyle(),
    );
  }

  Future<void> markInitialized(STATUS status) async {
    var prefs = await SharedPreferences.getInstance();

    if (status == STATUS.OK) {
      prefs.setString(selected, "OK");
      print("$selected marked as initialized");
    }
  }

  Future<STATUS> initializeGroup(String itemName) async {
    var zipFile = await compress(itemName);

    var request = await prepareMultipartRequest(zipFile.path);

    var httpResponse = await request.send();

    var responseBody = (await httpResponse.stream.bytesToString());

    var isError = responseBody.toLowerCase().contains("error");
    var responseMessage = isError
        ? "An error occurred while uploading your files, please try again later "
        : "group $itemName has been successfully initialized";

    showMessage(context, responseMessage);
    return isError ? STATUS.CANCELLED : STATUS.OK;
  }

  Future<http.MultipartRequest> prepareMultipartRequest(String filePath) async {
    var uri = Uri.http(authority, initializeGroupEndPoint);
    var request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('namedPhotos', filePath));
    return request;
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
