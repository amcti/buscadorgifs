import 'dart:async';
import 'dart:convert';
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

enum LangAvaliable { en, pt }
//import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LangAvaliable _langChoose = LangAvaliable.en;
  String _search;
  int _offset = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Map> _getGifs() async {
    http.Response response;
    print("Valor de search para busca: " + _search);
    if (_search == null || _search.isEmpty) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=WFjbWDb7BffqMqOiVHnwJ2XYEPPNKPc2&limit=18&offset=0&rating=G");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=WFjbWDb7BffqMqOiVHnwJ2XYEPPNKPc2&q=$_search&limit=20&offset=$_offset&rating=G&lang=en");
    }
    print("Corpo da resposta: " + response.body.toString());
    return json.decode(response.body);
  }

/*
  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }
*/

  Future<void> _getResult(String text) async {
    _search = text;
    print("buscando erro 03");
    Map mapTemp = await _getGifs();
    int total = mapTemp["pagination"]["total_count"];
    if (total > 0) {
      setState(() {
        _search = text;
        _offset = 0;
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Não foi encontrada nenhuma imagem com o parâmetros selecionados!",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    }
    print("buscando erro 04");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                ListTile(
                  title: const Text("Inglês",
                      style: TextStyle(color: Colors.white)),
                  leading: Radio(
                    value: LangAvaliable.en,
                    groupValue: _langChoose,
                    onChanged: (LangAvaliable value) {
                      print("buscando erro 05");
                      setState(() {
                        _langChoose = value;
                      });
                    },
                  ),
                ),
                Expanded(
                    child: ListTile(
                  title: const Text("Português",
                      style: TextStyle(color: Colors.white)),
                  leading: Radio(
                    value: LangAvaliable.pt,
                    groupValue: _langChoose,
                    onChanged: (LangAvaliable value) {
                      print("buscando erro 06");
                      setState(() {
                        _langChoose = value;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: _getResult,
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  print("Tentando construir os gifs");
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        print("Houve erro na busca pelos gifs");
                        return new Container(
                          height: 0.0,
                          width: 0.0,
                        );
                      } else {
                        print("O gifs serão exibidos");
                        return _createGifTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    print("buscando erro 08");
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    print("buscando erro 09");
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        //scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          print("buscando erro 10");
          if (_search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.assetNetwork(
                fadeInCurve: Curves.elasticIn,
                placeholder: "images/loading.gif",
                image: snapshot.data["data"][index]["images"]["fixed_height"]
                    ["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 50.0,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 20;
                  });
                },
              ),
            );
        });
  }
}
