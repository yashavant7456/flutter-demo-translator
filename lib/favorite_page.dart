import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate/dbhelper.dart';

import 'Model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String selectedLanguage = "Hindi";
  String selectedLanguageCode = "hi";
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  Color iconColor = Colors.cyan;
  Color fontColor = Colors.black;
  Color favColor = Colors.cyan;

  String _lan;
  String _lanCode;
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

  Widget appBarTitle = new Text(
    "Hindi Lens",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();

  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  bool _IsSearching;
  String _searchText = "";

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
          _searchQuery.clear();
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(
        centerTitle: true,
        backgroundColor: Colors.cyan,
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(
                    Icons.close,
                    color: Colors.white,
                  );
                  this.appBarTitle = new TextField(
                    cursorColor: Colors.white,
                    autofocus: true,
                    controller: _searchQuery,
                    style: new TextStyle(
                      color: Colors.white,
                    ),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        // prefixIcon: new Icon(Icons.search, color: Colors.white),
                        hintText: "Search",
                        hintStyle: new TextStyle(color: Colors.white)),
                    onChanged: searchOperation,
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
        ]);
  }

  searchOperation(String searchText) {
    if (_searchText == null) {
      return _buildList();
    } else {
      _searchList = List();
      _searchList.clear();
      for (int i = 0; i < _list.length; i++) {
        String name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
          //print(_searchList.toString());
        }
      }
    }
  }

  searchOperations(String searchText) {
    if (_searchText == null) {
      return _buildList();
    } else {
      _searchList = List();
      _searchList.clear();
      for (int i = 0; i < _list.length; i++) {
        String name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
          //print(_searchList.toString());
        }
      }
    }
  }

  void _handleSearchStart() {
    setState(() {
      if (futureList.hashCode == null) {
        _IsSearching = false;
        _SearchListState();
        _searchQuery.clear();
      } else {
        _IsSearching = true;
        _SearchListState();
        _searchQuery.clear();
      }
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "$selectedLanguage Lens",
        style: new TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }

  @override
  Future<void> initState() {
    super.initState();
    getSharedPrefs();
    _IsSearching = false;
    init();
    //refreshSearch();
    refreshList();
  }

  void init() {
    _list = List();
    _list.clear();
    //_list.add("Hindi Lens");
  }

  Future<List> futureList = DatabaseHelper.instance.getAllRecords();
  refreshList() {
    setState(() {
      futureList = dbHelper.getAllRecords();
    });
  }

  refreshSearch() {
    _searchList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: key,
        appBar: buildBar(context),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Flexible(
                  child: !_IsSearching
                      ? _buildList()
                      : _searchList == null
                          ? Center(child: CircularProgressIndicator())
                          : FutureBuilder<List>(
                              future: futureList,
                              initialData: List(),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _searchList.length,
                                        itemBuilder: (_, int position) {
                                          var listData = _searchList[position];
                                          var _id;
                                          var _name;
                                          if (_searchList.length != 0) {
                                            try {
                                              _id = snapshot
                                                  .data[position].row[0]
                                                  .toString();
                                              _name = snapshot
                                                  .data[position].row[1];
                                            } catch (e) {
                                              print(
                                                  "Exxxxxxxxxxxxxxxxxxxxxxxxx :$e");
                                            }
                                          }
                                          return Card(
                                            margin: EdgeInsets.all(8.0),
                                            shadowColor: Colors.grey,
                                            child: Column(
                                              children: [
                                                // ListTile(title: Text("Id: $_id")),
                                                ListTile(
                                                  // title: Text(
                                                  //     _searchList[position]),
                                                  title: Text(listData),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.edit),
                                                      iconSize: 20,
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        refreshList();
                                                        setState(() {
                                                          _createDialog(context,
                                                                  _name)
                                                              .then((value) {
                                                            if (value != null) {
                                                              DatabaseHelper
                                                                  .instance
                                                                  .update({
                                                                DatabaseHelper
                                                                        .columnId:
                                                                    _id,
                                                                DatabaseHelper
                                                                        .columnName:
                                                                    value,
                                                              });
                                                              refreshList();
                                                            }
                                                          });
                                                          print("Update Id: " +
                                                              _id);
                                                        });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete),
                                                      iconSize: 20,
                                                      color: Colors.black,
                                                      onPressed: () {
                                                        setState(() {
                                                          _handleSearchEnd();
                                                          dbHelper.delete(_id);
                                                          print(
                                                              "Delete Position: " +
                                                                  _id);
                                                          if (_searchList
                                                                  .length ==
                                                              1) {
                                                            _list.clear();
                                                            // print("refresh List call:" +
                                                            //     refreshSearch());
                                                            refreshSearch();
                                                            print(
                                                                "IN Clear : $_searchList");
                                                          }
                                                          _IsSearching = false;
                                                          refreshList();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              },
                            )),
            ],
          ),
        ));
  }

  List<String> _searchList;
  _buildSearchList() {}

  Widget _buildList() {
    return FutureBuilder<List>(
      future: futureList,
      initialData: List(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, int position) {
                  final item = snapshot.data[position];
                  final _id = snapshot.data[position].row[0];
                  final _name = snapshot.data[position].row[1];
                  //_list.add(_name);
                  _list.clear();
                  if (!_list.contains(_name)) {
                    _list.add(_name);
                    //_list.setAll(_id, _name);
                    // _list.insert(_id, _name);
                  }
                  // for (int i = 0; i < _list.length; i++) {
                  //   String name = _list.elementAt(i);
                  //   _list.add(name);
                  // }

                  //get your item data here ...
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    shadowColor: Colors.grey,
                    child: Column(
                      children: [
                        // ListTile(title: Text("Id: $_id")),
                        ListTile(
                          title: Text("$_name"),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              iconSize: 20,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  _createDialog(context, _name).then((value) {
                                    if (value != null) {
                                      DatabaseHelper.instance.update({
                                        DatabaseHelper.columnId: _id,
                                        DatabaseHelper.columnName: value,
                                      });
                                      refreshList();
                                    }
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              iconSize: 20,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  dbHelper.delete("$_id");
                                  refreshList();
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
//buildList Method over

  String _namec = "";
  Future<String> _createDialog(BuildContext context, String val) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit data"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  nametextfield(val),
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
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).pop(_namec);
                  setState(() {
                    //Navigator.of(context).pop(refreshList());
                    refreshList();
                  });
                },
                child: Text("Update"),
              ),
            ],
          );
        });
  }

  Widget nametextfield(String val) {
    return SingleChildScrollView(
      child: TextFormField(
        onChanged: (text) {
          _namec = text;
          setState(() {
            // _extractText = _namec;
            print("Onchange EditText :$_namec");
          });
        },
        initialValue: val,
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
}
