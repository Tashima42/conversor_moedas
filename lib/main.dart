import 'package:flutter/material.dart'; //Biblioteca dos Widgets Material
import 'dart:async'; //Biblioteca para funcoes asincronas
import 'package:http/http.dart' as http; //Biblioteca para requests http
import 'dart:convert'; //Biblioteca para conversoes

//URL da API usada para as requests
const request = "https://api.hgbrasil.com/finance/quotations?key=1079fd34";

void main() async {
  runApp(MaterialApp(
    home: Conversor(),
    theme: ThemeData(
        hintColor: Colors.blue,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          hintStyle: TextStyle(color: Colors.blue),
        )),
  ));
}

class Conversor extends StatefulWidget {
  Conversor({Key key}) : super(key: key);

  @override
  _ConversorState createState() => _ConversorState();
}

class _ConversorState extends State<Conversor> {
  //Controladores dos fields de input
  final reaisController = TextEditingController();
  final dolaresController = TextEditingController();
  final bitcoinController = TextEditingController();

  //Variaveis que guardarao os dados das moedas
  double dolar;
  double bitcoin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Retorna um Scaffold para utilizar a AppBar
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "\$ Conversor \$",
          //Estilizacao do texto da AppBar
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        //Estilizacao da AppBar
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      //Coloca um FutureBuilder no corpo para carregar dados dependentes do request
      body: FutureBuilder(
          future: getData(), //Os dados que ele vai utilizar no futuro
          builder: (context, snapshot) {
            //O que ele vai construir
            switch (snapshot.connectionState) {
              //Mudar casos de acordo com o estado da requisicao
              case ConnectionState.none: //Caso nao tenha requisicao
              case ConnectionState
                  .waiting: //Enquanto a requisicao esta acontecendo
                //Retornar um icone de refresh e um texto dizendo carregando
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.refresh,
                        color: Colors.blue,
                        size: 60.0,
                      ),
                      Text(
                        "Carregando",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 25.0,
                        ),
                      ),
                    ],
                  ),
                );
              //No caso padrao, verifica se houve erro na requisicao
              default:
                if (snapshot.hasError) {
                  return Container(
                    color: Colors.red,
                  );
                }
                //Se nao ha erro, retorna esta tela
                else {
                  //Atribui valor as variaveis das moedas
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  bitcoin =
                      snapshot.data["results"]["currencies"]["BTC"]["buy"];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        //Icone no topo da pagina
                        Icon(
                          Icons.monetization_on,
                          color: Colors.blue,
                          size: 150.0,
                        ),
                        //Input de Reais
                        buildInputField("Reais", "R\$", reaisController),
                        Divider(),
                        //Input de Dolares
                        buildInputField("Dolares", "US\$", dolaresController),
                        Divider(),
                        //Input de Bitcoin
                        buildInputField("Bitcoin", "₿ ", bitcoinController),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildInputField(String currencie, String prefix, TextEditingController controller) {
  return TextField(
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: currencie,
        labelStyle: TextStyle(fontSize: 20.0, color: Colors.blue),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
      color: Colors.blue,
      fontSize: 25.0,
    ),
  );
}

//Mapa que recebe os valores asincronamente
Future<Map> getData() async {
  //Recebe as requests http
  http.Response response = await http.get(request);
  //Retorna a String recebida como um JSON
  return json.decode(response.body);
}
