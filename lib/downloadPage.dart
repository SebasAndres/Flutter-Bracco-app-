import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:url_launcher/url_launcher.dart';

import 'useful.dart';

class downloadPage extends StatefulWidget{
  @override
  _dpage createState() => _dpage();
}

class _dpage extends State<downloadPage>{

  final databaseReference = FirebaseDatabase.instance.reference();

  var fontStyle = GoogleFonts.mcLaren(fontSize: 25);
  final double top_margin = 250;

  String NOMBRE_ARCHIVO = "DATOS ("+ DateTime.now().day.toString() +"-"+
                    DateTime.now().month.toString() +"-"+
                    DateTime.now().year.toString() + ")";

  String STATE = "";
  String CONTACTO_ADMIN = "+54 11 2295-7489";

  List _data_ = [];
  String data = "";

  List CLIENTES = [];
  List CONTACTOS = [];
  List SERVICIOS = [];
  List costosServicios = [];
  List PRECIOS = [];

  int sizeSucursal = -2;
  int sizeTrabajadores = -2;

  /*
  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/${NOMBRE_ARCHIVO}.txt'; // 3
    return filePath;
  }

  void saveFile() async {
    File file = File(await getFilePath()); // 1
    file.writeAsString("This is my demo text that will be saved to : demoTextFile.txt"); // 2
  }
   */

  Future<String> readData () {
    STATE = "DESCARGANDO DATOS";

    databaseReference.child("Clientes").once().then((DataSnapshot snapshot){
      CLIENTES = [];
      int size = snapshot.value.length-1;
      for (int t=0; t<size; t++){
        var cliente = snapshot.value[t.toString()];
        CLIENTES.add(cliente["Contacto"].toString());
      }
    });

    databaseReference.child("Servicios").once().then((DataSnapshot snapshot){
      SERVICIOS = [];
      int size = int.parse(snapshot.value["nextIndex"].toString());
      for (int u=1; u<size; u++){
        SERVICIOS.add(snapshot.value[u.toString()]["Nombre"].toString());
        costosServicios.add(int.parse(snapshot.value[u.toString()]["Costo"].toString()));
      }
    });

    databaseReference.child("Sucursales").once().then((DataSnapshot snapshot) {
      sizeSucursal = snapshot.value.length;
    });

    databaseReference.child("Trabajadores").once().then((DataSnapshot snapshot) {
      sizeTrabajadores = snapshot.value.length;
    });

    return new Future.value("Algo");
  }

  String joinList (List data){
    String ret = "";
    for (int w=0; w<data.length; w++){
      ret += data[w];
    }
    return ret;
  }

  void _launchURL(String _url) async =>
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: readData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
      return Scaffold(
        appBar: AppBar(
          title: Text('Descargar datos'),
        ),
        body:
          Center(
            child:
              Column (
                children: [
                  SizedBox(height:top_margin),
                  Text (STATE, style:fontStyle),
                  // Dtos servicios
                  SizedBox(height: 10),
                  SizedBox(
                    width:300, height:50, child:
                    RaisedButton(
                      onPressed: () {
                        setState(()=>{
                          databaseReference.child("Servicios").once().then((DataSnapshot snapshot){
                            _data_ = ["Servicios: \n"];
                            int size = int.parse(snapshot.value["nextIndex"].toString());
                            for (int u=1; u<size; u++){
                              var servicio = snapshot.value[u.toString()];
                              _data_.add(
                                "n°${u}: ${servicio["Nombre"].toString()}, precio: ${servicio["Precio"].toString()}; "
                                "periodicidad: ${servicio["Periodicidad"].toString()}.\n"
                              );
                            }
                            data = joinList(_data_); _launchURL("https://wa.me/${CONTACTO_ADMIN}?text=${data}");
                          })
                         });
                      },
                      color: Color.fromRGBO(255, 255, 255, 1.0),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                      Radius.circular(30))),
                      child: Text("Enviar datos servicios", style: TextStyle(color: Colors.black),),
                    )
                  ),

                  // Evnair datoos clientes
                  SizedBox(height: 10),
                  SizedBox(
                    width:300, height:50,
                    child:
                    RaisedButton(
                     onPressed: () {
                      setState(()=>{
                        databaseReference.child("Clientes").once().then((DataSnapshot snapshot){
                          _data_ = ["Clientes: \n"];
                          int size = snapshot.value.length-1;
                          for (int u=0; u<size; u++){
                            var cliente = snapshot.value[u.toString()];
                            _data_.add(
                                "n°${u}: ${cliente["Nombre"].toString()}, contacto: ${cliente["Contacto"].toString()}, "
                                    "origen: ${cliente["Origen"].toString()}.\n"
                            );
                          }
                          data = joinList(_data_); print (data);
                          _launchURL("https://wa.me/${CONTACTO_ADMIN}?text=${data}");
                        })
                      });
                    },
                    color: Color.fromRGBO(253, 253, 255, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(30))),
                    child: Text("Enviar datos clientes", style: TextStyle(color: Colors.black)),
                  )
                  ),

                  // Enviar datos cortes
                  SizedBox(height: 10),
                  SizedBox(
                    width:300, height:50, child:
                    RaisedButton(
                    onPressed: () {
                      setState(()=>{
                        databaseReference.child("Cortes").once().then((DataSnapshot snapshot){
                          _data_ = ["Cortes"];
                          int size = int.parse(snapshot.value["nextIndex"].toString());
                          int totalIngreso = 0; int totalEgreso = 0;
                          for (int u=0; u<size; u++){
                            var corte = snapshot.value[u.toString()];
                            print (corte.toString());
                            if (u == 0){
                              _data_.add(" (desde ${corte["Fecha"].toString()} hasta ${snapshot.value[(size-1).toString()]["Fecha"]}): \n");
                              _data_.add("----------------------------\n");
                            }
                            String fecha = corte["Fecha"].toString();
                            String cliente = CLIENTES[int.parse(corte["Cliente"].toString())];
                            String _paga = corte["Pago"].toString();
                            totalIngreso += int.parse(_paga);
                            String sucursal = corte["Sucursal"].toString();
                            String trabajador = corte["Trabajador"].toString();
                            String servicios = "";
                            int nServ = int.parse(corte["nServ"].toString());
                            if (nServ > 1){
                              for (int w=0; w<nServ; w++) {
                                if (w != 0)
                                  servicios += ", ";
                                servicios += SERVICIOS[corte["Servicio"][w]];
                                totalEgreso += int.parse(costosServicios[corte["Servicio"][w]].toString());
                              }
                            }
                            else {
                              servicios = SERVICIOS[int.parse(corte["Servicio"].toString())-1];
                              totalEgreso += int.parse(costosServicios[corte["Servicio"]].toString());
                            }
                            _data_.add(
                                "n°${u}: fecha:${fecha}, cliente:${cliente}, paga:${_paga}, sucursal:${sucursal}, "
                                 " trabajador:${trabajador}, servicios:${servicios}.\n"
                            );
                          }
                          _data_.add("----------------------------");
                          _data_.add("\nTotal Ingresos: ${totalIngreso} || Total Egresos: ${totalEgreso} || NETO: ${totalIngreso-totalEgreso}");
                          data = joinList(_data_);
                          _launchURL("https://wa.me/${CONTACTO_ADMIN}?text=${data}");
                        })
                      });
                    },
                    color: Color.fromRGBO(253, 253, 255, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                        Radius.circular(30))),
                    child: Text("Enviar datos cortes", style: TextStyle(color: Colors.black)),
                  )
                  ),

                  // Reiniciar datos cortes
                  SizedBox(height: 10),
                  SizedBox(
                    width:300, height:50, child:
                    RaisedButton(
                    onPressed: () {
                      bool getConfirmed = true;
                      if (getConfirmed){

                        setState(()=>{
                          databaseReference.child("Cortes").once().then((DataSnapshot snapshot){
                            _data_ = ["Cortes"];
                            int size = int.parse(snapshot.value["nextIndex"].toString());
                            int totalIngreso = 0; int totalEgreso = 0;
                            for (int u=0; u<size; u++){
                              var corte = snapshot.value[u.toString()];
                              print (corte.toString());
                              if (u == 0){
                                _data_.add(" (desde ${corte["Fecha"].toString()} hasta ${snapshot.value[(size-1).toString()]["Fecha"]}): \n");
                                _data_.add("----------------------------\n");
                              }
                              String fecha = corte["Fecha"].toString();
                              String cliente = CLIENTES[int.parse(corte["Cliente"].toString())];
                              String _paga = corte["Pago"].toString();
                              totalIngreso += int.parse(_paga);
                              String sucursal = corte["Sucursal"].toString();
                              String trabajador = corte["Trabajador"].toString();
                              String servicios = "";
                              int nServ = int.parse(corte["nServ"].toString());
                              if (nServ > 1){
                                for (int w=0; w<nServ; w++) {
                                  if (w != 0)
                                    servicios += ", ";
                                  servicios += SERVICIOS[corte["Servicio"][w]];
                                  totalEgreso += int.parse(costosServicios[corte["Servicio"][w]].toString());
                                }
                              }
                              else {
                                servicios = SERVICIOS[int.parse(corte["Servicio"].toString())-1];
                                totalEgreso += int.parse(costosServicios[corte["Servicio"]].toString());
                              }
                              _data_.add(
                                  "n°${u}: fecha:${fecha}, cliente:${cliente}, paga:${_paga}, sucursal:${sucursal}, "
                                      " trabajador:${trabajador}, servicios:${servicios}.\n"
                              );
                            }
                            _data_.add("----------------------------");
                            _data_.add("\nTotal Ingresos: ${totalIngreso} || Total Egresos: ${totalEgreso} || NETO: ${totalIngreso-totalEgreso}");
                            data = joinList(_data_);
                          })
                        });
                        databaseReference.child("Cortes").set({"nextIndex": 0});
                        databaseReference.child("Pendientes").set({"nextIndex": 0});
                        databaseReference.child("Recurrentes").set({"nextIndex": 0});

                        _launchURL("https://wa.me/${CONTACTO_ADMIN}?text=${data}");

                        for (int index=0; index<sizeSucursal; index++)
                          databaseReference.child("Sucursales").child(index.toString()).child("nCortes").set(0);
                        for (int index=0; index<sizeTrabajadores-1; index++)
                          databaseReference.child("Trabajadores").child(index.toString()).child("nCortes").set(0);
                        showAlertDialog(context, "Manejo de datos", "Se han reiniciado los datos ");
                      }
                    },
                    color: Color.fromRGBO(253, 253, 255, 1.0),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Reiniciar datos cortes", style: TextStyle(color: Colors.black)),
                  )
                  )
                ]
              )
          )
      );
    });
  }
}