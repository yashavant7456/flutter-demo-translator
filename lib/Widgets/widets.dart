import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class _Widgets extends StatefulWidget {
  const _Widgets({Key key}) : super(key: key);

  @override
  __WidgetsState createState() => __WidgetsState();
}

class __WidgetsState extends State<_Widgets> {
  Color iconColor = Colors.cyan;
  Color fontColor = Colors.black;

  Widget _d() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => DraggableScrollableSheet(
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.share_outlined),
                      iconSize: 30,
                      color: iconColor,
                      splashColor: Colors.red,
                      highlightColor: Colors.green,
                      onPressed: () {
                        Share.share("_extractText", subject: "Share me");
                        //Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_outlined),
                      iconSize: 30,
                      color: iconColor,
                      splashColor: Colors.red,
                      highlightColor: Colors.green,
                      onPressed: () {
                        FlutterClipboard.copy("_extractText")
                            .then((value) => print("Copied"));
                        //Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined),
                      iconSize: 30,
                      color: iconColor,
                      splashColor: Colors.red,
                      highlightColor: Colors.green,
                      onPressed: () {
                        //Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border_outlined),
                      iconSize: 30,
                      color: iconColor,
                      splashColor: Colors.red,
                      highlightColor: Colors.green,
                      onPressed: () {
                        // Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close_outlined),
                      iconSize: 30,
                      color: iconColor,
                      splashColor: Colors.red,
                      highlightColor: Colors.green,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                color: Colors.white,
              ),
              Container(
                height: 1,
                color: Colors.black,
              ),
              Container(
                  color: Colors.white,
                  child:
                      Text("_extractText", style: TextStyle(fontSize: 20.0))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
