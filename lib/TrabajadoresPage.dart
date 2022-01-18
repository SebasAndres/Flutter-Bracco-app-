import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrabajadoresPage extends StatefulWidget {
  @override
  _TrabajadoresPage createState() => _TrabajadoresPage();
}

class _TrabajadoresPage extends State<TrabajadoresPage> {

  final double margin = 10;
  final double topMargin = 30;

  final databaseReference = FirebaseDatabase.instance.reference();

  String selectedTrabajador = "Mateo";
  TextEditingController inTrabajador = new TextEditingController();

  List Trabajadores = [];
  int index = -1;
  int ultIndex = -2;
  List cortesConIndex = [];
  var ultObject;

  @override
  Widget build(BuildContext context) {

    Future<String> loadData() async {
      setState((){
        databaseReference.child("Trabajadores").once().then((DataSnapshot snapshot) {
          int size = snapshot.value.length-1;
          Trabajadores = [];
          for (int u=0; u < size; u++) {
            Trabajadores.add(snapshot.value[u.toString()]["Nombre"].toString());
          }
        });
      });
      selectedTrabajador = Trabajadores[0];
      return Future.value("");
    }

    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
              appBar: AppBar (title: Text('Trabajadores')),
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
                            Text ("Trabajadores", style: GoogleFonts.mcLaren(fontSize:30)),
                            SizedBox(height:margin),
                            Container(
                              width: 300,
                              height: 50,
                              child:
                              DropdownButton(
                                value: selectedTrabajador.toString(),
                                items: getDropDownMenuItems(Trabajadores),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTrabajador = value.toString(); inTrabajador.text = value.toString();
                                    index = Trabajadores.indexOf(value.toString());
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
                                    controller: inTrabajador
                                )
                            ),
                            SizedBox(height:margin),
                            Row(children:
                            [
                              SizedBox(width: margin*6),
                              RaisedButton(onPressed: () {
                                // 1. Chequear si el nombre ya ta en Bdatos[Sucursales]
                                if (!Trabajadores.contains(inTrabajador.text)){ // Agregar a Base de Datos
                                  databaseReference.child("Trabajadores").child(Trabajadores.length.toString()).set(
                                      {
                                        "Nombre": inTrabajador.text,
                                        "nCortes": 0
                                      }
                                  );
                                  showAlertDialog(context, "Trabajadores", "Se ha agregado al trabajador");
                                } else {
                                  showAlertDialog(context, "Trabajadores", "El trabajador ya existe");
                                }
                                // 2. Si no está -> Agregarlo a Sucursales\N+1 (siendo N la cantidad de sucursales), seteandole nCorte a 0
                              }, child: Text("Alta")),
                              SizedBox(width:margin),
                              RaisedButton(onPressed: () {
                                // 1. Identificar index de esa sucursal, --> global index
                                // 2. Establecer que Sucursal\index tenga index.nombre = inputNombre.text
                                if (inTrabajador.text != "" && index > 0){
                                  databaseReference.child("Trabajadores").child(index.toString()).child("Nombre").set(inTrabajador.text);
                                  showAlertDialog(context, "Trabajadores", "El trabajador ha sido modificada");
                                }
                              }, child: Text("Mod")),
                              SizedBox(width:margin),
                              RaisedButton(onPressed: () {
                                // 0. Si no es el cliente primitivo "Mateo" (necesaria), entonces:
                                if (index > 0){
                                  // 1. Revisar si hay cortes con esta sucursal
                                  setState(()=>{
                                    databaseReference.child("Cortes").once().then((DataSnapshot sn){
                                      int size = sn.value.length-1; cortesConIndex = [];
                                      for (int w=0; w<size; w++) {
                                        var corte = sn.value[w.toString()];
                                        if (corte["Trabajador"].toString() == index.toString()) { cortesConIndex.add(corte); }
                                      }
                                    })
                                  });
                                  // 2. Leer ultimo index
                                  setState(()=>{
                                    databaseReference.child("Trabajadores").once().then((DataSnapshot sn){
                                      ultIndex = sn.value.length-1;
                                      ultObject = sn.value[ultIndex];
                                    })
                                  });

                                  if (cortesConIndex.length > 0) {
                                    // Si hay --> No borrar
                                    showAlertDialog(context, "Trabajadores", "Este trabajador tiene cortes asociados! No se puede borrar");
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
                                            if (corte["Trabajador"] == ultIndex){ cortesConIndex.add(w);}
                                          }
                                        });
                                        // Pasar de ultIndex (el q se borra) a index
                                        for (int u=0; u<cortesConIndex.length; u++) {
                                          databaseReference.child("Cortes").child(cortesConIndex[u].toString()).child("Trabajador").set(index);
                                        }
                                        // Setear en index a la ultSucursal objeto
                                        databaseReference.child("Trabajadores").child(index.toString()).set(ultObject);
                                      }
                                      // Setear al ultimo index como nulo y (si tiene nextIndex, restarle 1)
                                      databaseReference.child("Trabajadores").child(ultIndex.toString()).set(null);
                                      showAlertDialog(context, "Trabajadores", "Se ha eliminado el/la trabajador/a.");
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