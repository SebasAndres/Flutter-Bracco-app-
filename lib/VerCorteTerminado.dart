import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerCorteTerminado extends StatefulWidget{
  final int indexCorte;
  VerCorteTerminado({required this.indexCorte});
  @override
  _VerCorteTerminado createState() => new _VerCorteTerminado(indexCorte: indexCorte);
}


class _VerCorteTerminado extends State<VerCorteTerminado> {

  final double topMargin = 50;

  final int indexCorte;
  _VerCorteTerminado({required this.indexCorte});

  final databaseReference = FirebaseDatabase.instance.reference();

  String nombreCliente = "";
  String fecha = "";
  String trabajador = "";
  String sucursal = "";
  String paga = "";
  String servicios = "";
  String telefono = "";

  List SERVICIOS = []; // Todos
  int iCliente = -1;

  Future<String> readData (){
    int nServ;
    // LEER SERVICIOS
    setState(() => {
      databaseReference.child("Servicios").once().then((DataSnapshot snapshot){
        int nextIndex = int.parse(snapshot.value["nextIndex"].toString());
        for (int t=0; t<nextIndex; t++){
          var serv = snapshot.value[t.toString()];
          SERVICIOS.add(serv["Nombre"].toString());
        }
      })
    });

    // LEER DATOS CORTE
    setState(() => {
      databaseReference.child("Cortes").child(indexCorte.toString()).once().then((DataSnapshot snapshot){
        fecha = snapshot.value["Fecha"].toString();
        sucursal = snapshot.value["Sucursal"].toString();
        trabajador = snapshot.value["Trabajador"].toString();
        paga = snapshot.value["Pago"].toString();
        // Datos mediados
        iCliente = int.parse(snapshot.value["Cliente"].toString());
        nServ = int.parse(snapshot.value["nServ"].toString());
        if (nServ > 1) {
          for (int z=0; z<nServ; z++){
            int ruta = snapshot.value["Servicio"][z];
            servicios += SERVICIOS[ruta] + ", ";
          }
        }
        else { servicios += SERVICIOS[snapshot.value["Servicio"]]; }
      })
    });

    // LEER DATOS CLIENTE
    setState(() => {
      databaseReference.child("Clientes").once().then((DataSnapshot snapshot){
        var cliente = snapshot.value[iCliente.toString()];
        nombreCliente = cliente["Nombre"].toString();
        telefono = cliente["Contacto"].toString();
      })
    });

    return Future.value("Datos leídos");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: readData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
      return Scaffold(
        appBar: AppBar( title: Text('Cortes por fecha'), ),
        body:
        Flex (
          direction: Axis.vertical,
          children: [

            SizedBox(height: topMargin),
            SizedBox(
              child:
                RaisedButton (
                  onPressed: () {setState(()=>{});},
                  child: Text("Recargar")
                )
            ),

            // Fecha
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Fecha", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(fecha, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Cliente (Nombre)
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Cliente", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(nombreCliente, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Cliente (Teléfono)
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Teléfono", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(telefono, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Sucursal
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Sucursal", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(sucursal, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Trabajador
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Trabajador", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(trabajador, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Servicios
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Servicios", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(servicios, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
            // Paga
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text("Paga", textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(paga, textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
          ]
        ),
      );
      }
    );
  }
}