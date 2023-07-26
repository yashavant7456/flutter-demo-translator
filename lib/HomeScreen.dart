import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_pickers/language_picker_cupertino.dart';
import 'package:language_pickers/languages.dart';
import 'package:language_pickers/utils/utils.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:translate/dbhelper.dart';
import 'package:translate/favorite_page.dart';
import 'package:translator/translator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _scanning = false;
  bool _icon = true;
  String _extractText = '';
  File _pickedImage;
  String selectedLanguage = "Hindi";
  String selectedLanguageCode = "hi";
  String appUrl =
      " https://play.google.com/store/apps/details?id=com.example.translate";

  Color iconColor = Colors.cyan;
  Color fontColor = Colors.black;
  Color favColor = Colors.cyan;

  GoogleTranslator translator = GoogleTranslator();

  Language _selectedCupertinoLanguage =
      LanguagePickerUtils.getLanguageByIsoCode('hi');

  Future<void> _pickImageFromCamera() async {
    setState(() {
      _scanning = true;
    });
    _pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    _extractText = await TesseractOcr.extractText(_pickedImage.path);
    translator.translate(_extractText, to: selectedLanguageCode).then((output) {
      setState(() {
        _extractText = output.toString();
        _scanning = false;
      });
    });
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _scanning = true;
    });
    _pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    _extractText = await TesseractOcr.extractText(_pickedImage.path);
    translator.translate(_extractText, to: selectedLanguageCode).then((output) {
      setState(() {
        _extractText = output.toString();
        _scanning = false;
      });
    });
  }

  void _openCupertinoLanguagePicker() => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return LanguagePickerCupertino(
          offAxisFraction: 10.0,
          pickerItemHeight: 40.0,
          pickerSheetHeight: 350,
          onValuePicked: (Language language) => setState(() {
            _selectedCupertinoLanguage = language;
            selectedLanguage = _selectedCupertinoLanguage.name;
            selectedLanguageCode = _selectedCupertinoLanguage.isoCode;
            storeName(selectedLanguage, selectedLanguageCode);
          }),
          itemBuilder: _buildCupertinoItem,
        );
      });

  Widget _buildCupertinoItem(Language language) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(" ${language.name}"),
          SizedBox(width: 8.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("${language.isoCode}")],
          )
        ],
      );

  String _lan;
  String _lanCode;
  Future<Null> storeName(String lan, String lanCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lan", lan);
    prefs.setString("lanCode", lanCode);
    print("Lan Pref set: " + lan);
    print("Code Pref set: " + lanCode);
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _lan = prefs.getString("lan");
    _lanCode = prefs.getString("lanCode");
    setState(() {
      if (_lan == null) {
        _lan = "Hindi";
        _lanCode = "hi";
        print("Lan Pref not found:" + _lan);
        print("LanCode Pref not found:" + _lanCode);
      } else {
        selectedLanguage = _lan;
        selectedLanguageCode = _lanCode;
        print("Lan Pref found: " + selectedLanguage);
        print("LanCode Pref found: " + selectedLanguageCode);
      }
    });
  }

  Widget _showDialogBox() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 0.0, right: 0.0, bottom: 0.0, top: 45.0),
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share_outlined),
                          iconSize: 30,
                          color: iconColor,
                          onPressed: () {
                            Share.share("$_extractText", subject: "Share me");
                            //Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.copy),
                          iconSize: 30,
                          color: iconColor,
                          onPressed: () {
                            FlutterClipboard.copy(_extractText)
                                .then((value) => print("Copied"));
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          iconSize: 30,
                          color: iconColor,
                          onPressed: () {
                            //Navigator.pop(context);
                            setState(() {
                              _createDialog(context);
                            });
                          },
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: favColor,
                            ),
                            iconSize: 30,
                            color: favColor,
                            onPressed: () {
                              setState(() {
                                // if (favColor == Colors.cyan) {
                                //   favColor = Colors.cyanAccent;
                                Navigator.pop(context);
                                _insertVal();
                                // }
                              });
                            }),
                        IconButton(
                          icon: Icon(Icons.delete),
                          iconSize: 30,
                          color: iconColor,
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _extractText = "";
                              _pickedImage = null;
                              favColor = Colors.cyan;
                            });
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 12.0, top: 0.0),
                      child: SizedBox(
                        child: Container(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            child: Text(
                              "$_extractText",
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<String> _createDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit data"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  nametextfield(),
                  SizedBox(
                    child: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            insetPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0, top: 0.0),
            buttonPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0, top: 0.0),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(_namec);
                },
                child: Text("Cancel"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(_namec);
                  if (_namec == "") {
                    Share.share("$_extractText", subject: "Share me");
                    print("share with null");
                  } else {
                    Share.share("$_namec", subject: "Share me");
                    print("share with editable");
                  }
                },
                child: Text("Share"),
              )
            ],
          );
        });
  }

  String _namec = "";
  Widget nametextfield() {
    return SingleChildScrollView(
      child: TextFormField(
        onChanged: (val) {
          _namec = val;

          setState(() {
            // _extractText = _namec;
          });
        },
        initialValue: _extractText,
        maxLines: null,
        // expands: true,
        keyboardType: TextInputType.multiline,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          //prefixText: _extractText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  final dbhelper = DatabaseHelper.instance;

////Insert
  void _insertData() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: "$_extractText",
    };
    final id = await dbhelper.insert(row);
    print(id);
  }

  void _insertVal() async {
    var allRows = await dbhelper.querySpecific("$_extractText");
    print(allRows.toString());
    if (allRows.isEmpty) {
      _insertData();
      print("Inserted: ");
      favColor = Colors.cyanAccent;
    } else {
      favColor = Colors.cyanAccent;
      print("Not Insert: ");
    }
  }

  @override
  void initState() {
    super.initState();
    //_name = "";
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: iconColor,
          title: Text("$selectedLanguage Lens"),
          // title: prefLan == null
          //     ? Text("$prefLan  Lens")
          //     : Text("$selectedLanguage Lens"),
          actions: [
            IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                }),
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share("Check in PlayStore: $appUrl",
                      subject: "Share me");
                }),
            IconButton(
                icon: Icon(Icons.translate),
                onPressed: () {
                  _openCupertinoLanguagePicker();
                }),
          ]),
      body: ListView(
        children: [
          _pickedImage == null
              ? Container(
                  height: 350,
                )
              : Container(
                  height: 350,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: FileImage(_pickedImage),
                        fit: BoxFit.fill,
                      )),
                ),
          _scanning
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Icon(
                      Icons.done,
                      size: 40,
                      color: Colors.green,
                    ),
                  ],
                ),
          SizedBox(height: 20),
          Center(
            child: _pickedImage != null
                ? Text(
                    _extractText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(""),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Container(
              color: Colors.white,
              height: 55.0,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _extractText = "";
                          _pickedImage = null;
                          favColor = Colors.cyan;
                          _pickImageFromGallery();
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.photo,
                                color: iconColor,
                                size: 40,
                              ),
                              Text(
                                "Gallery",
                                style: TextStyle(color: fontColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    _pickedImage != null
                        ? Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showDialogBox();
                                  });
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.note_add,
                                        color: iconColor,
                                        size: 40,
                                      ),
                                      Text(
                                        "Edit",
                                        style: TextStyle(color: fontColor),
                                      )
                                    ],
                                  ),
                                )),
                          )
                        : Text(""),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _extractText = "";
                          _pickedImage = null;
                          favColor = Colors.cyan;
                          _pickImageFromCamera();
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: iconColor,
                                size: 40,
                              ),
                              Text(
                                "Camera",
                                style: TextStyle(color: fontColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]))),
    );
  }
}
