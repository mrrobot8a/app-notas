import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> listarPost(http.Client client, String id) async {
  //final response =
  //    await client.get('https://desarolloweb2021a.000webhostapp.com/API/listarnotas.php');
  //var id = "2";
  final response = await http.post(
      Uri.parse(
          'https://desarolloweb2021a.000webhostapp.com/API/listarnotas.php'),
      body: {
        "idestudiante": id,
      });

  // Usa la función compute para ejecutar parsePhotos en un isolate separado
  return compute(pasaraListas, response.body);
}

// Una función que convierte el body de la respuesta en un List<Photo>
List<Post> pasaraListas(String responseBody) {
  final pasar = json.decode(responseBody).cast<Map<String, dynamic>>();

  return pasar.map<Post>((json) => Post.fromJson(json)).toList();
}

class Post {
  final String id;
  final String codigo;
  final String nombre;
  final String materia;
  final String foto;
  final String n1;
  final String n2;
  final String n3;
  final String detalle;

  Post(
      {this.id,
      this.codigo,
      this.nombre,
      this.materia,
      this.foto,
      this.n1,
      this.n2,
      this.n3,
      this.detalle});

  String get definitiva {
    var def;
    def = (double.parse(n1) * 0.30 +
            double.parse(n2) * 0.30 +
            double.parse(n3) * 0.40)
        .toStringAsFixed(2);
    return def.toString();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
      materia: json['materia'],
      foto: json['foto'],
      n1: json['n1'],
      n2: json['n2'],
      n3: json['n3'],
      detalle: json['detalle'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String id;
  TextEditingController controlcodigo = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    id = '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controlcodigo,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              filled: true,
              labelText: 'Identificacion',
              // suffix: Icon(Icons.access_alarm),
              suffix: GestureDetector(
                child: Icon(Icons.search),
                onTap: () {
                  setState(() {
                    id = controlcodigo.text;
                  });
                },
              )
              //probar suffix
              ),
        ),
      ),

      body: ListView(
        children: [
          getInfo(context, id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Refrescar',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Widget getInfo(BuildContext context, String id) {
  return FutureBuilder(
    future: listarPost(http.Client(),
        id), //En esta línea colocamos el el objeto Future que estará esperando una respuesta
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      switch (snapshot.connectionState) {

        //En este case estamos a la espera de la respuesta, mientras tanto mostraremos el loader
        case ConnectionState.waiting:
          return Center(child: CircularProgressIndicator());

        case ConnectionState.done:
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          // print(snapshot.data);
          return snapshot.data != null
              ? Vistanotas(posts: snapshot.data)
              : Text('Sin Datos');

        /*
             Text(
              snapshot.data != null ?'ID: ${snapshot.data['id']}\nTitle: ${snapshot.data['title']}' : 'Vuelve a intentar', 
              style: TextStyle(color: Colors.black, fontSize: 20),);
            */

        default:
          return Text('Presiona el boton para recargar');
      }
    },
  );
}

class Vistanotas extends StatelessWidget {
  final List<Post> posts;

  const Vistanotas({Key key, this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 50, 10, 20),
      height: 500,
      width: double.maxFinite,
      //cart
      child: Card(
        elevation: 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50,
              left: (MediaQuery.of(context).size.width / 5) - 55,
              child: Container(
                height: 100,
                width: 100,
                color: Colors.blue,
                child: Card(
                  elevation: 2,
                  child: Image.network(posts[posts.length - 1].foto),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Text(
                          posts[posts.length - 1].nombre,
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(posts[posts.length - 1].materia),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Informe de Notas'),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Nota 1'),
                                CircleAvatar(
                                    child: Text(posts[posts.length - 1].n1)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Nota 2'),
                                CircleAvatar(
                                    child: Text(posts[posts.length - 1].n2)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Nota 3'),
                                CircleAvatar(
                                    child: Text(posts[posts.length - 1].n3)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Apuntes:'),
                        Text(posts[posts.length - 1].detalle),
                        SizedBox(height: 20),
                        Text('Definitiva:'),
                        CircleAvatar(
                          radius: 40.0,
                          child: Text(
                            posts[posts.length - 1].definitiva,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
