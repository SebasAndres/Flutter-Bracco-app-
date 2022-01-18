import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'LBMClientesPage.dart';

class BuscadorClientes extends StatefulWidget {
  @override
  _BuscadorClientes createState() => _BuscadorClientes();
}

class _BuscadorClientes extends State<BuscadorClientes> {

  List FoundNombres = []; List FoundTelefonos = []; List FoundOrigen = [];

  final databaseReference = FirebaseDatabase.instance.reference();

  TextEditingController inputSearcher = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double interspace = scrWidth * 0.024; // 10
    final double interspaceH = scrHeight * 0.011; // 10
    final double contWidth = scrWidth * 0.69; // 250
    final double btWidth = scrWidth * 0.243; // 100
    final double btHeight = scrHeight * 0.059; // 50

    return FutureBuilder<String>(
      future: loadData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
        return Scaffold(
            appBar: AppBar(title: Text("Administrador")),
            body: Center(
              child:
              Column(
                children: [
                  SizedBox(height:interspaceH),
                  Row (
                    children: [
                      SizedBox(width:interspace),
                      Container(
                        width: contWidth,
                        child:
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Buscador de clientes",
                          ),
                          controller: inputSearcher
                        ),
                      ),
                      SizedBox(width:interspace),
                      SizedBox(
                          width: btWidth,
                          height: btHeight,
                          child:
                          RaisedButton(onPressed: () {
                            // 1. Leer todos los usuarios y al mismo tiempo filtrar los que contengan algo del input
                            // 2. Guardarlos en FoundNombres y FoundTelefonos
                            setState((){
                              databaseReference.child("Clientes").once().then((DataSnapshot snapshot) {
                                int size = snapshot.value.length-1;
                                FoundNombres = []; FoundTelefonos = []; FoundOrigen = [];
                                for (int u=0; u<size; u++) {
                                  String refText = snapshot.value[u.toString()]["Nombre"].toString() + snapshot.value[u.toString()]["Contacto"].toString() + snapshot.value[u.toString()]["Origen"].toString();
                                  if (Contiene(refText, inputSearcher.text)) {
                                    FoundNombres.add(snapshot.value[u.toString()]["Nombre"]);
                                    FoundTelefonos.add(snapshot.value[u.toString()]["Contacto"].toString());
                                    FoundOrigen.add(snapshot.value[u.toString()]["Origen"].toString());
                                  }
                                }
                              });
                            });// 3. Actualizar pantalla
                          },
                            color: Color.fromRGBO(26, 15, 189, 1.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30))),
                            child: Text("Buscar",
                              style: TextStyle(color: Colors.white),),
                          )
                      ),
                    ]
                  ),
                  Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: FoundNombres.length,
                          itemBuilder: (BuildContext context, int index) { return devContainer(index); }
                       )
                  )
                ]
              )
            )
        );
    });
  }

  bool Contiene (String texto1, String texto2){
      if (texto1.toUpperCase().contains(texto2.toUpperCase())) { return true; }
      else { return false; }
  }

  Widget devContainer (int index){
    return Column (
        children:
        [
          SizedBox(height:10),
          InkWell(
            onTap: () {
              // Ir a la vieja página LBM_Clientes enviando como datos el index y el nombre, telefno y origen
              if (FoundNombres[index] != "Seleccionar"){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LBMClientesPage (
                      index: index, nombre: FoundNombres[index], contacto: FoundTelefonos[index], origen: FoundOrigen[index])),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text(FoundNombres[index], textAlign: TextAlign.center)),
                  Expanded(child: Text(FoundTelefonos[index], textAlign: TextAlign.center))
                ]),
              ),
            ),
          ),
        ]
    );
  }

  Future<String> loadData() async {
    setState((){});
    return Future.value("");
  }
}