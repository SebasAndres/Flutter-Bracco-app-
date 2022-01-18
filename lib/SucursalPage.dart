import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SucursalPage extends StatefulWidget {
  @override
  _SucursalPage createState() => _SucursalPage();
}

class _SucursalPage extends State<SucursalPage> {

  final double margin = 10;
  final double topMargin = 30;

  final databaseReference = FirebaseDatabase.instance.reference();

  List Sucursales = [];
  String selectedSucursal = "Holiday Inn";
  TextEditingController inSucursal = new TextEditingController();

  int index = -1;
  List cortesConIndex = [];
  int ultIndex = -2;
  var ultSucursalObject;

  @override
  Widget build(BuildContext context) {

    Future<String> loadData() async {
      setState((){
        databaseReference.child("Sucursales").once().then((DataSnapshot snapshot) {
          int size = snapshot.value.length;
          Sucursales = [];
          for (int u = 0; u < size; u++) {
            Sucursales.add(snapshot.value[u]["Nombre"].toString());
          }
        });
      });
      selectedSucursal = Sucursales[0];
      return Future.value("");
    }
    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
        appBar: AppBar (title: Text('Sucursales')),
        body:Column(
          children: [
            SizedBox(height: topMargin),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child:
              Column(
                  children: [
                    Text ("Sucursales", style: GoogleFonts.mcLaren(fontSize:30)),
                    SizedBox(height:margin),
                    Container(
                      width: 300,
                      height: 50,
                      child:
                      DropdownButton(
                        value: selectedSucursal.toString(),
                        items: getDropDownMenuItems(Sucursales),
                        onChanged: (value) {
                          setState(() {
                            selectedSucursal = value.toString(); inSucursal.text = value.toString();
                            index = Sucursales.indexOf(value.toString());
                          });
                        },
                      ),
                    ),
                    SizedBox(height:margin),
                    SizedBox(
                        width: 300,
                        height: 60,
                        child:
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Nombre'
                          ),
                          controller: inSucursal
                        )
                    ),
                    SizedBox(height:margin),
                    Row(children:
                    [
                      SizedBox(width: margin*6),
                      RaisedButton(onPressed: () {
                        // 1. Chequear si el nombre ya ta en Bdatos[Sucursales]
                        if (!Sucursales.contains(inSucursal.text)){ // Agregar a Base de Datos
                            databaseReference.child("Sucursales").child(Sucursales.length.toString()).set(
                            {
                              "Nombre": inSucursal.text,
                              "nCortes": 0
                            }
                            );
                            showAlertDialog(context, "Sucursal", "Se ha agregado la sucursal");
                        } else {
                          showAlertDialog(context, "Sucursal", "La sucursal ya existe");
                        }
                        // 2. Si no está -> Agregarlo a Sucursales\N+1 (siendo N la cantidad de sucursales), seteandole nCorte a 0
                      }, child: Text("Alta")),
                      SizedBox(width:margin),
                      RaisedButton(onPressed: () {
                        // 1. Identificar index de esa sucursal, --> global index
                        // 2. Establecer que Sucursal\index tenga index.nombre = inputNombre.text
                        if (index > 0) {
                          databaseReference.child("Sucursales").child(index.toString()).child("Nombre").set(inSucursal.text);
                          showAlertDialog(context, "Sucursal", "La sucursal ha sido modificada");
                        }
                      }, child: Text("Mod")),
                      SizedBox(width:margin),
                      RaisedButton(onPressed: () {
                        // 0. Si no es la sucursal primitiva "Holiday Inn" (necesaria), entonces:
                        if (index > 0) {
                          // 1. Revisar si hay cortes con esta sucursal
                          setState(()=>{
                            databaseReference.child("Cortes").once().then((DataSnapshot sn){
                              int size = sn.value.length-1; cortesConIndex = [];
                              for (int w=0; w<size; w++) {
                                var corte = sn.value[w.toString()];
                                if (corte["Sucursal"].toString() == index.toString()) { cortesConIndex.add(corte); }
                              }
                            })
                          });
                          // 2. Leer ultimo index
                          setState(()=>{
                            databaseReference.child("Sucursales").once().then((DataSnapshot sn){
                              ultIndex = sn.value.length-1;
                              ultSucursalObject = sn.value[ultIndex];
                            })
                          });

                          if (cortesConIndex.length > 0) {
                            // Si hay --> No borrar
                            showAlertDialog(context, "Sucursales", "Esta sucursal tiene cortes asociados! No se puede borrar");
                          }
                          else {
                            // Si no hay --> Borrar
                            if (ultIndex > -2) { // Si leyó bien el ultimo index
                              if (ultIndex > index) {
                                // Ver cortes q involucran a la ultima sucursal (que va a pasar al index q se borraría)
                                databaseReference.child("Cortes").once().then((DataSnapshot sn){
                                  int size = sn.value.length-1; cortesConIndex = [];
                                  for (int w=0; w<size; w++) {
                                    var corte = sn.value[w.toString()];
                                    if (corte["Sucursal"] == ultIndex){ cortesConIndex.add(w);}
                                  }
                                });
                                // Pasar de ultIndex (el q se borra) a index
                                for (int u=0; u<cortesConIndex.length; u++) {
                                  databaseReference.child("Cortes").child(cortesConIndex[u].toString()).child("Sucursal").set(index);
                                }
                                // Setear en index a la ultSucursal objeto
                                databaseReference.child("Sucursales").child(index.toString()).set(ultSucursalObject);
                              }
                              /*
                              print (ultSucursalObject.toString());
                              print (ultIndex.toString () + " vs " + index.toString());
                              */
                              // Setear al ultimo index como nulo y (si tiene nextIndex, restarle 1)
                              databaseReference.child("Sucursales").child(ultIndex.toString()).set(null);
                              showAlertDialog(context, "Sucursales", "Se ha eliminado la sucursal");
                            }
                          }

                        }
                      }, child: Text("Baja")),
                      SizedBox(width:margin),
                    ]
                    ),
                  ]
              ),
            ),
          ]
        )
    );
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems (List data){
    List<DropdownMenuItem<String>> retorno = [];
    for (int q=0; q<data.length; q++){
      retorno.add(
        new DropdownMenuItem(
          child: new Text(data[q], style:TextStyle(fontSize: 18.0)),
          value: data[q],
        ),
      );
    }
    return retorno;
  }

  showAlertDialog(BuildContext context, String title, String content) {
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}