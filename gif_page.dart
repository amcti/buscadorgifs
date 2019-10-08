import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  String _dataFormatada(String text) {
    String ano;
    String hora;

    ano = text.substring(8, 10) +
        "/" +
        text.substring(5, 7) +
        "/" +
        text.substring(0, 4);
    hora = text.substring(11, 19);
    return ano + " às " + hora;
  }

  GifPage(this._gifData);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "GIF selecionado",
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(_gifData["images"]["fixed_height"]["url"]);
                })
          ],
        ),
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Nome da figura:",
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _gifData["title"].toString().trim().isNotEmpty
                            ? _gifData["title"]
                            : "indefinido",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Text(
                    "Data da figura:",
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _gifData["import_datetime"]
                                    .toString()
                                    .substring(0, 2) !=
                                "00"
                            ? _dataFormatada(_gifData["import_datetime"])
                            : "sem informação",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              buildImage(),
              Padding(padding: EdgeInsets.only(top: 100.0)),
            ],
          ),
        ));
  }

  Container buildImage() {
    if (_gifData["trending_datetime"].toString().substring(0, 2) != "00") {
      return Container(
        color: Colors.redAccent,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            child: Image.network(_gifData["images"]["fixed_height"]["url"]),
          ),
        ),
      );
    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          child: Image.network(_gifData["images"]["fixed_height"]["url"]),
        ),
      ),
    );
  }
}
