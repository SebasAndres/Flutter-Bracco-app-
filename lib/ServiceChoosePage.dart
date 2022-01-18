import 'package:bracco_app/useful.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'ConfirmarServicioPage.dart';

class ServiceChoosePage extends StatefulWidget {
  @override
  final int clIndex;
  ServiceChoosePage({required this.clIndex});

  _ServiceChoosePage createState() => _ServiceChoosePage(clIndex: clIndex);
}

class _ServiceChoosePage extends State<ServiceChoosePage>{

  final int clIndex;
  _ServiceChoosePage({required this.clIndex});

  final databaseReference = FirebaseDatabase.instance.reference();

  String clNombre = "";

  List states = []; // true en N si el servicio en N (N+1 en la BDD) está elegido
  List SERVICIOS = [];
  List PRECIOS = [];
  List MEETINGS = [];
  List INTERVALOS = [];

  Future<String> readData (){
    databaseReference.child("Servicios").once().then((DataSnapshot snapshot) {
      int nServicios = int.parse(snapshot.value["nextIndex"].toString());
      SERVICIOS = []; PRECIOS = []; MEETINGS = []; INTERVALOS = [];
      for (int w=1; w<nServicios; w++) {
         var servicio = snapshot.value[w.toString()];
         SERVICIOS.add(servicio["Nombre"].toString());
         PRECIOS.add(servicio["Precio"].toString());
         MEETINGS.add(int.parse(servicio["Periodicidad"].toString()));
         if (int.parse(servicio["Periodicidad"].toString()) > 1) {
           int val = int.parse(servicio["Intervalo"].toString());
           INTERVALOS.add(val);
         }
         else { INTERVALOS.add(0); }
         states.add(false);
      }
    });
    for (int w=0; w<SERVICIOS.length; w++) { states.add(false); }
    return Future.value("Datos leídos");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: readData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          return Scaffold(
              appBar: AppBar(
                title: Text('Paso 2 - Elegir servicios'),
              ),
              body:
                  Flex(
                    direction: Axis.vertical,
                    children: [
                      SizedBox(height:5),
                      RaisedButton(onPressed: () => {setState(()=>{ })},
                        child: Text("Recargar"),
                      ),
                      Expanded(
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: SERVICIOS.length+1,
                              itemBuilder: (BuildContext context, int index) {
                                return devContainer(index);
                              })
                      )
                    ]
                  )
          );
        }
      );
   }

  Widget devContainer(int index) {

    List ServiciosElegidos = []; List PreciosElegidos = [];
    List nMeetingsElegidos = []; List IndexServElegidos = [];
    List intervalos = [];

    for (int h=0; h<SERVICIOS.length; h++){
      if (states[h]) {
        ServiciosElegidos.add(SERVICIOS[h]);
        IndexServElegidos.add(h+1);
        PreciosElegidos.add(PRECIOS[h]);
        nMeetingsElegidos.add(MEETINGS[h]);
        intervalos.add(INTERVALOS[h]);
      }
    }

    if (index == SERVICIOS.length){
      return RaisedButton(
        onPressed: () {
          if (ServiciosElegidos.length > 0){
            databaseReference.child("Clientes").once().then((DataSnapshot snapshot) {
              print("ISB: " + snapshot.value[clIndex.toString()]["Nombre"].toString());
              clNombre = snapshot.value[clIndex.toString()]["Nombre"].toString();
            });
            Data data = new Data(
                intervalos: intervalos,
                cliente: clNombre,
                clIndex: clIndex,
                servicios: ServiciosElegidos,
                indexServicios: IndexServElegidos,
                precios: PreciosElegidos,
                nMeetings: nMeetingsElegidos
            );
            Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmarServicioPage(data: data)));
          } else {
            showAlertDialog(context, "Elegir Servicios", "Debes elegir al menos 1 servicio :)");
          }
        },
        color: Color.fromRGBO(26, 15, 189, 1.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(30))),
        child: Text("Siguiente",
          style: TextStyle(color: Colors.white),),
      );
    }
    else {
      return Column (
        children:
        [
          SizedBox(height:10),
          InkWell(
            onTap: () {
              setState((){
                states[index] = !states[index];
              });
            },
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: StateColor(states[index]),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text(SERVICIOS[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.black))),
                  Expanded(child: Text(PRECIOS[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.black)))
                ]),
              ),
            ),
          ),
        ]

      );
    }
  }

  Color StateColor (bool state){
    if (state) return Colors.lightBlueAccent;
    else return Colors.white;
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

