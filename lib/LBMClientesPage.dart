import 'package:bracco_app/useful.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'BuscadorClientes.dart';

import 'BuscadorClientes.dart';

class LBMClientesPage extends StatefulWidget {
  final int index;
  final String nombre;
  final String contacto;
  final String origen;
  LBMClientesPage({required this.index, required this.nombre, required this.contacto, required this.origen});
  @override
  _LBMClientesPage createState() => _LBMClientesPage(index: index, nombre: nombre, contacto: contacto, origen: origen);
}

class _LBMClientesPage extends State<LBMClientesPage> {
  final int index;
  final String nombre;
  final String contacto;
  final String origen;
  _LBMClientesPage({required this.index, required this.nombre, required this.contacto, required this.origen});

  final containerColour = Colors.grey;

  TextEditingController inContacto = new TextEditingController();
  TextEditingController inOrigen = new TextEditingController();
  TextEditingController inNombre = new TextEditingController();

  List LIST_NOMBRES = []; String selectedNombre = "Seleccionar";
  List LIST_CONTACTOS = []; String selectedContacto = "Contacto";
  List LIST_ORIGENES = []; String selectedOrigen = "";

  List cortesConIndex = [];
  int lastIndexCliente = -2;
  var ultCliente;

  bool meBorro = false;

  List toChangeIndex = [];

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double container_top_margin = 0.2 * scrHeight; // 250
    final double distItems = scrHeight * 0.011; // 10
    final double inputWidth = 0.85 * scrWidth; //350
    final double btWidth = 0.36 * scrWidth; // 150
    final double btHeight = 0.059 * scrHeight; // 50

    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          // DISEÑO
          return Scaffold(
              appBar: AppBar(title: Text('Mis Clientes')),
              body:
                  Column(
                    children: [
                      SizedBox(height: container_top_margin),
                      Container (
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          child:
                          Column(
                              children: [
                                Center(
                                  child:
                                  Column(
                                    children: [
                                      SizedBox(child: Text("Clientes: ", style: GoogleFonts.mcLaren(fontSize: 40.0))),
                                      SizedBox(height: distItems),
                                      Container(
                                        width: inputWidth,
                                        child:
                                        TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: "Nombre",
                                          ),
                                          controller: inNombre,
                                        ),
                                      ),
                                      SizedBox(height: distItems),
                                      Container(
                                        width: inputWidth,
                                        child:
                                        TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: "Contacto",
                                          ),
                                          controller: inContacto,
                                        ),
                                      ),
                                      SizedBox(height: distItems),
                                      Container(
                                          width: inputWidth,
                                          child:
                                          TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: "Origen",
                                            ),
                                            controller: inOrigen,
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                    children: [
                                      SizedBox(height: distItems*2),
                                      Row (
                                          children: [
                                            SizedBox(width:distItems*4),
                                            SizedBox(
                                                width: btWidth,
                                                height: btHeight,
                                                child:
                                                RaisedButton(onPressed: () {
                                                  if (!meBorro){
                                                    // 1. Revisar si algun corte tiene este index
                                                    setState(()=>{
                                                      databaseReference.child("Cortes").once().then((DataSnapshot sn){
                                                        int size = sn.value.length-1; cortesConIndex = [];
                                                        for (int w=0; w<size; w++) {
                                                          var corte = sn.value[w.toString()];
                                                          if (corte["Cliente"].toString() == index.toString()) { cortesConIndex.add(corte); }
                                                        }
                                                      })
                                                    });
                                                    // 1b Leer ultimo index de clientes
                                                    setState(()=>{
                                                      databaseReference.child("Clientes").once().then((DataSnapshot sn){
                                                        lastIndexCliente = int.parse(sn.value["nextIndex"].toString())-1; // porque empieza en 0 y hay un nextIndex
                                                        ultCliente = sn.value[lastIndexCliente.toString()];
                                                      })
                                                    });
                                                    // 2. Si lo tiene -> no borrar, sino borrar
                                                    if (cortesConIndex.length > 0){ // No borrar
                                                      showAlertDialog(context, "Clientes", "El cliente tiene cortes asociados! No se ha borrado");
                                                    }
                                                    else { // 3. Si se va a borrar:
                                                      if (lastIndexCliente != -2) {
                                                        if (index < lastIndexCliente) {
                                                          // 3B. (Si no es el ultimo cliente)
                                                          // 3B.1 Leer todos los cortes que involucran al ultimo cliente registrado y pasarle el Cliente a este index que se va a borrar
                                                          databaseReference.child("Cortes").once().then((DataSnapshot sn){
                                                            int size = sn.value.length-1; toChangeIndex = [];
                                                            for (int w=0; w<size; w++) {
                                                              var corte = sn.value[w.toString()];
                                                              if (corte["Cliente"] == lastIndexCliente){ toChangeIndex.add(w);}
                                                            }
                                                          });
                                                          for (int u=0; u<toChangeIndex.length; u++) {
                                                            databaseReference.child("Cortes").child(toChangeIndex[u].toString()).child("Cliente").set(index);
                                                          }
                                                          // vaciar en ultimo index
                                                          databaseReference.child("Clientes").child(lastIndexCliente.toString()).set(null);
                                                          // 3B.2 Pasar todos los datos del último cliente registrado a este index por borrar.
                                                          databaseReference.child("Clientes").child(index.toString()).set(ultCliente);
                                                        }
                                                        else {
                                                          // Eliminar desde la llave
                                                          databaseReference.child("Clientes").child(lastIndexCliente.toString()).set(null);
                                                          showAlertDialog(context, "Clientes", "Se ha eliminado al cliente");
                                                        }
                                                        // 3b Si es el ultimo cliente -> no hacer nada
                                                        // Pasar nextIndex a el index del ultimo cliente (nextIndex-=1)
                                                        databaseReference.child("Clientes").child("nextIndex").set(lastIndexCliente);
                                                        setState(()=>{meBorro = true});
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => BuscadorClientes())
                                                        );
                                                      }
                                                      else {
                                                        print ("lic: " +lastIndexCliente.toString());
                                                      }
                                                    }
                                                  }
                                                },
                                                  color: Color.fromRGBO(26, 15, 189, 1.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(30))),
                                                  child: Text("Borrar",
                                                    style: TextStyle(color: Colors.white),),
                                                )
                                            ),
                                            SizedBox(width:distItems*2.5),
                                            SizedBox(
                                                width: btWidth,
                                                height: btHeight,
                                                child:
                                                RaisedButton(onPressed: () {
                                                  if (!meBorro && index > 0){
                                                    if (inNombre.text != "" && inContacto.text != "" && inOrigen != ""){
                                                      databaseReference.child("Clientes").child(index.toString()).set(
                                                          {
                                                            "Nombre": inNombre.text,
                                                            "Contacto": inContacto.text,
                                                            "Origen": inOrigen.text
                                                          }
                                                      );
                                                      showAlertDialog(context, "Clientes", "Se han realizado los cambios");
                                                    }
                                                    else {
                                                      showAlertDialog(context, "Clientes", "Los campos se han rellenado de forma incorrecta");
                                                    }
                                                  }
                                                },
                                                  color: Color.fromRGBO(26, 15, 189, 1.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(30))),
                                                  child: Text("Modificar",
                                                    style: TextStyle(color: Colors.white),),
                                                )
                                            ),
                                          ]
                                      ),
                                      SizedBox(height:distItems),
                                      FlatButton(
                                        onPressed: () {reload();},
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        color: Colors.lightBlue,
                                        child: Text("Recargar", style:TextStyle(color:Colors.white)),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          _launchURL("https://wa.me/${contacto}?text=");
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        color: Colors.lightBlue,
                                        child: Text("Mensaje", style:TextStyle(color:Colors.white)),
                                      ),
                                    ]
                                ) // BOTONES
                              ]
                          )
                      )
                    ]
                  )
          );
        }
    );
  }

  void _launchURL(String _url) async =>
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

  Future<String> loadData() async {
    setState((){
      inNombre.text = nombre;
      inOrigen.text = origen;
      inContacto.text = contacto;
    });
    return Future.value("Los datos se han cargado");
  }

  void reload (){
    setState((){});
  }

}

List<DropdownMenuItem<String>> getDropDownMenuItems (List data){
  List<DropdownMenuItem<String>> retorno = [];
  for (int q=0; q<data.length; q++){
    retorno.add(
      new DropdownMenuItem(
        child: new Text(data[q], style:TextStyle(fontSize: 20.0)),
        value: data[q],
      ),
    );
  }
  return retorno;
}