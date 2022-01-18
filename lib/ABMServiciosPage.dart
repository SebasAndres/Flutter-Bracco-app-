import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'useful.dart';

class ABMServiciosPage extends StatefulWidget {
  @override
  _ABMServiciosPage createState() => _ABMServiciosPage();
}

class _ABMServiciosPage extends State<ABMServiciosPage>{

  final double top_margin_container = 50;
  final TextStyle fontStyle = GoogleFonts.mcLaren(fontSize:16);

  TextEditingController inPrecio = new TextEditingController();
  TextEditingController inNombre = new TextEditingController();
  TextEditingController inCosto = new TextEditingController();
  TextEditingController inDiasIntervalo = new TextEditingController();

  List LIST_SERVICIOS = []; String selectedServicio = "Seleccionar";
  List LIST_PRECIOS = []; String selectedPrecio = "Precio";
  List LIST_PERIODICIDAD = []; String selectedPeriodicidad = "1";
  List LIST_COSTOS = []; String selectedCosto = "Costo";
  List LIST_INTERVALOS = []; String selectedIntervalo = "0";
  int index = -1;

  final databaseReference = FirebaseDatabase.instance.reference();

  int nextIndex = -1;
  int ultIndex = -2;
  var ultServicio;
  List cortesConIndex = [];
  List servSubIndex = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          // DISEÑO
          return Scaffold(
              appBar: AppBar(
                title: Text('Mis Servicios'),
              ),
              body:
              Column(
                  children: [
                    SizedBox(height: top_margin_container),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child:
                      Center(
                          child:
                          Column(
                              children: [
                                SizedBox(
                                  child:
                                  Text("Servicios: ", style: TextStyle(fontSize: 40.0)),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 250,
                                  child:
                                  DropdownButton(
                                    value: selectedServicio.toString(),
                                    items: getDropDownMenuItems(LIST_SERVICIOS),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedServicio = value.toString();
                                        index = LIST_SERVICIOS.indexOf(selectedServicio);
                                        selectedPrecio = LIST_PRECIOS[index];
                                        selectedPeriodicidad = LIST_PERIODICIDAD[index].toString();
                                        selectedCosto = LIST_COSTOS[index].toString();
                                        selectedIntervalo = LIST_INTERVALOS[index].toString();
                                        inPrecio.text = selectedPrecio;
                                        inNombre.text = selectedServicio;
                                        inCosto.text = selectedCosto;
                                        inDiasIntervalo.text = selectedIntervalo;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 350,
                                  child:
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Nombre del servicio",
                                    ),
                                    controller: inNombre,
                                  ),
                                ),
                                SizedBox(height:10),
                                Container(
                                  width: 350,
                                  child:
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Precio",
                                    ),
                                    controller: inPrecio,
                                  ),
                                ),
                                SizedBox(height:10),
                                Container(
                                  width: 350,
                                  child:
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Costo",
                                    ),
                                    controller: inCosto,
                                  ),
                                ),
                                Row(
                                    children: [
                                      SizedBox (width:100),
                                      Text ("Periodicidad: ", style: fontStyle),
                                      Container (
                                        width: 100,
                                        height: 50,
                                        child:
                                        DropdownButton(
                                          items: getDropDownMenuItems([1, 2, 3, 4]),
                                          value: selectedPeriodicidad.toString(),
                                          onChanged: (value) {
                                            setState(() { selectedPeriodicidad = value.toString(); });
                                          },
                                        ),
                                      ),
                                    ]
                                ),
                                Container(
                                  width: 350,
                                  child:
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Dias de intervalo",
                                    ),
                                    controller: inDiasIntervalo,
                                  ),
                                ),

                                SizedBox(height: 20),
                                Row (
                                    children: [
                                      SizedBox(width:30),
                                      // Modificar
                                      SizedBox(
                                          width: 100,
                                          height: 50,
                                          child:
                                          RaisedButton(onPressed: () {
                                            if (index > 0) {
                                              String nombre = inNombre.text;
                                              String precio = inPrecio.text;
                                              String periodicidad = selectedPeriodicidad;
                                              String costo = inCosto.text;
                                              String intervalo = inDiasIntervalo.text;
                                              bool anyMistake = true;
                                              int _precio = -1;
                                              int _costo = -1;
                                              int _periodicidad = -1;
                                              int _intervalo = -1;
                                              if (nombre == "") { anyMistake = false; showAlertDialog(context, "Mis Servicios", "El nombre es incorrecto");}
                                              try {
                                                _precio = int.parse(precio);
                                                _costo = int.parse(costo);
                                                _periodicidad = int.parse(periodicidad);
                                                _intervalo = int.parse(intervalo);
                                              }
                                              catch (Exception) {
                                                anyMistake = false;
                                              }
                                              if (anyMistake) {
                                                if (_periodicidad > 1){
                                                  databaseReference.child("Servicios").child(index.toString()).set(
                                                      {
                                                        "Nombre": nombre,
                                                        "Precio": _precio,
                                                        "Costo": _costo,
                                                        "Periodicidad": _periodicidad,
                                                        "Intervalo": _intervalo
                                                      }
                                                  );
                                                }
                                                else {
                                                  databaseReference.child("Servicios").child(index.toString()).set(
                                                      {
                                                        "Nombre": nombre,
                                                        "Precio": _precio,
                                                        "Costo": _costo,
                                                        "Periodicidad": _periodicidad,
                                                       }
                                                  );
                                                }
                                                showAlertDialog(context, "Servicios", "Se ha modificado el servicio.");
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
                                      SizedBox(width:15),
                                      // Alta
                                      SizedBox(
                                          width: 100,
                                          height: 50,
                                          child:
                                          RaisedButton(onPressed: () {
                                            String nombre = inNombre.text;
                                            String precio = inPrecio.text;
                                            String periodicidad = selectedPeriodicidad;
                                            String costo = inCosto.text;
                                            String intervalo = inDiasIntervalo.text;

                                            bool anyMistake = true;

                                            int _precio = -1;
                                            int _costo = -1;
                                            int _periodicidad = -1;
                                            int _intervalo = -1;
                                            if (nombre == "") { anyMistake = false; showAlertDialog(context, "Mis Servicios", "El nombre es incorrecto");}
                                            try {
                                              _precio = int.parse(precio);
                                              _costo = int.parse(costo);
                                              _periodicidad = int.parse(periodicidad);
                                              _intervalo = int.parse(intervalo);
                                            }
                                            catch (Exception) {
                                              anyMistake = false;
                                            }

                                            if (anyMistake) {
                                              // Agregar a Servicios/nextIndex la data
                                              if (_periodicidad > 1){
                                                databaseReference.child("Servicios").child(nextIndex.toString()).set(
                                                    {
                                                      "Nombre": nombre,
                                                      "Precio": _precio,
                                                      "Costo": _costo,
                                                      "Periodicidad": _periodicidad,
                                                      "Intervalo": _intervalo
                                                    }
                                                );
                                              }
                                              else {
                                                databaseReference.child("Servicios").child(nextIndex.toString()).set(
                                                    {
                                                      "Nombre": nombre,
                                                      "Precio": _precio,
                                                      "Costo": _costo,
                                                      "Periodicidad": _periodicidad,
                                                    }
                                                );
                                              }
                                              // Actualizar nextIndex a nextIndex+1
                                              databaseReference.child("Servicios").child("nextIndex").set(nextIndex+1);
                                              // Alertar lo sucedido en pantalla
                                              showAlertDialog(context, "Mis Servicios", "Se ha agregado el servicio");
                                            }
                                            else {
                                              showAlertDialog(context, "Mis Servicios", "Revisa los campos, los has llenado incorrectamente");
                                            }
                                          },
                                            color: Color.fromRGBO(26, 15, 189, 1.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: Text("Alta",
                                              style: TextStyle(color: Colors.white),),
                                          )
                                      ),
                                      SizedBox(width:15),
                                      // Borrar
                                      SizedBox(
                                          width: 100,
                                          height: 50,
                                          child:
                                          RaisedButton(onPressed: () {
                                            var ref = databaseReference.child("Servicios");
                                            // leer compras de cortes
                                            setState(()=>{
                                              databaseReference.child("Cortes").once().then((DataSnapshot sn) {
                                                int size = sn.value.length - 1; cortesConIndex = [];
                                                for (int w = 0; w < size; w++) {
                                                  var corte = sn.value[w.toString()];
                                                  if (corte["Servicio"].toString() == index.toString()) { cortesConIndex.add(corte);}
                                                }
                                              })
                                            });

                                            if (cortesConIndex.length>0) {
                                              showAlertDialog(context, "Servicios", "El servicio está involucrado en al menos un corte! No se puede borrar.");
                                            }
                                            else {
                                              // Leer ultIndex y ultObject
                                              setState(()=>{
                                                databaseReference.child("Servicios").once().then((DataSnapshot sn) {
                                                  ultIndex = sn.value["nextIndex"]-1;
                                                  if (index < ultIndex) { ultServicio = sn.value[ultIndex.toString()]; }
                                                })
                                              });
                                              if (ultIndex > 0) {
                                                if (ultIndex > index) {
                                                  // Pasar todas las referencias de ultIndex a index
                                                  databaseReference.child("Cortes").once().then((DataSnapshot sn){
                                                    int size = sn.value.length-1;
                                                    cortesConIndex = []; servSubIndex = [];
                                                    for (int w=0; w<size; w++) {
                                                      var corte = sn.value[w.toString()];
                                                      int nServ = corte["nServ"];
                                                      if (nServ > 1){
                                                        for (int c=0; c<nServ; c++){
                                                          if (corte["Servicio"][c.toString()].toString() == index.toString()){
                                                            servSubIndex.add(c);
                                                          }
                                                        }
                                                        if (servSubIndex.length > 0) { cortesConIndex.add(w); }
                                                      }
                                                      else {
                                                        if (corte["Servicio"] == ultIndex){ cortesConIndex.add(w); servSubIndex.add(-1); }
                                                      }
                                                    }
                                                  });

                                                  // Pasar de ultIndex (el q se borra) a index
                                                  for (int u=0; u<cortesConIndex.length; u++) {
                                                    if (servSubIndex[u] == -1)
                                                      databaseReference.child("Cortes").child(cortesConIndex[u].toString()).child("Servicio").set(index);
                                                    else
                                                      databaseReference.child("Cortes").child(cortesConIndex[u].toString())
                                                          .child("Servicio").child(servSubIndex[u].toString()).set(index);
                                                  }
                                                  // Ref/index = ultObject
                                                  ref.child(index.toString()).set(ultServicio);
                                                }
                                                ref.child(ultIndex.toString()).set(null);
                                                ref.child("nextIndex").set(ultIndex);
                                                showAlertDialog(context, "Servicios", "El servicio se ha eliminado.");
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

                                    ]
                                ),
                                SizedBox(height:10),
                                FlatButton(
                                  onPressed: () {reload();},
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  color: Colors.lightBlue,
                                  child: Text("Recargar", style:TextStyle(color:Colors.white)),
                                ),
                              ])
                      ) // BOTONES
                    ),
                  ]
              )
          );
        }
    );
  }

  Future<String> loadData() async {
    setState((){
      databaseReference.child("Servicios").once().then((DataSnapshot snapshot) {
        int size = snapshot.value.length-1;
        if (size > 0)
          nextIndex = int.parse(snapshot.value["nextIndex"].toString());
        else
          nextIndex = 1;
        LIST_SERVICIOS = []; LIST_PRECIOS = [];
        LIST_PERIODICIDAD = []; LIST_COSTOS = [];
        LIST_INTERVALOS = [];
        for (int u=0; u<size; u++) {
          LIST_SERVICIOS.add(snapshot.value[u.toString()]["Nombre"]);
          LIST_PRECIOS.add(snapshot.value[u.toString()]["Precio"].toString());
          LIST_COSTOS.add(snapshot.value[u.toString()]["Costo"].toString());
          int periodicidad = snapshot.value[u.toString()]["Periodicidad"];
          LIST_PERIODICIDAD.add(periodicidad);
          if (periodicidad > 1)
            LIST_INTERVALOS.add(snapshot.value[u.toString()]["Intervalo"]);
          else
            LIST_INTERVALOS.add(0);
        }
      });
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
        child: new Text(data[q].toString(), style:TextStyle(fontSize: 20.0)),
        value: data[q].toString(),
      ),
    );
  }
  return retorno;
}