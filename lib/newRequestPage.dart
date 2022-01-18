import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ServiceChoosePage.dart';

class newRequestPage extends StatefulWidget {
  @override
  _newRequestPage createState() => _newRequestPage ();
}

final _referenceDatabase = FirebaseDatabase.instance.reference();

class _newRequestPage extends State<newRequestPage>{

  // IDEA TIEMPO
  /*
  static const int hora_inicio = 13; // Abre el negocio
  static const int hora_cierre = 18; // Cierra el negocio (ultima hora para pedir turno)
  static const int minutos_intervalo = 15; // Se puede pedir turno NN:0, NN:15, NN:30, NN:45
  List WORK_TIME = createWorkTimeList(hora_inicio, hora_cierre, minutos_intervalo);
  int _selectedTime = hora_inicio;
  */

  TextEditingController contacto_input = new TextEditingController();

  List CONTACTOS = readListaContactos();

  final referenceDatabase = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double topMargin = 0.296 * scrHeight;
    final double disTitulo = scrHeight * 0.011;
    final double inputWidth = 0.72 * scrWidth; // 300
    final double inputHeight = 0.11 * scrHeight; // 100

    return FutureBuilder<String>(
        future: updateLists(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          return Scaffold(
            appBar: AppBar(title: Text('Agregar pedidos')),
            body:
            Column(
               children: [
                    Center(
                      child:
                      Column(
                        children: [
                          SizedBox(height: topMargin),
                          SizedBox(
                            child:
                            Text("Cliente: ", style: GoogleFonts.mcLaren(fontSize:40.0)),
                          ),
                          SizedBox(height: disTitulo),
                          SizedBox(
                              width: inputWidth,
                              height: inputHeight,
                              child:
                              TextField(
                                controller: contacto_input,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Contacto'
                                ),
                              )
                          ),
                          SizedBox(
                              width: inputWidth,
                              height: inputHeight/2,
                              child:
                              RaisedButton(onPressed: () {
                                int index = CONTACTOS.indexOf(contacto_input.text);
                                if (index != -1)
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceChoosePage (clIndex: index)));
                                else
                                  showAlertDialog (context, "Elige al cliente", "No hay ningún cliente asociado a ese contacto");
                              },
                                color: Color.fromRGBO(26, 15, 189, 1.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(30))),
                                child: Text("Siguiente",
                                  style: TextStyle(color: Colors.white),),
                              )
                          ),
                        ]
                    ) // BOTON
                 )]
              )
          );
        }
    );
  }

  // Util fuctions
  void printFirebase(){
    referenceDatabase.once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
    });
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

  Future<String> updateLists() async {
    // A Leer contactos
    // 2. Cada contacto formal es "{Nombre}: {Contacto}"
    referenceDatabase.child("Clientes").once().then((DataSnapshot snapshot) {
      int size = snapshot.value.length-1;
      CONTACTOS = [];
      for (int x=0; x<size; x++) {
        // print ("Adding :"+snapshot.value[x]["Contacto"].toString());
        CONTACTOS.add(snapshot.value[x.toString()]["Contacto"].toString());
      }
    });
    // B Leer servicios
    /*
    // 2. Cada servicio es "Servicio: precio".
    referenceDatabase.child("Servicios").once().then((DataSnapshot snapshot){
      int size = snapshot.value.length;
      LIST_SERVICIOS = [];
      for (int x=0; x<size; x++) {
        LIST_SERVICIOS.add(snapshot.value[x]["Nombre"].toString() + ": "+snapshot.value[x]["Precio"].toString());
      }
    });
    */
    return new Future.value("Datos actualizados");
  }

  List readRealtimeDatabase(String mainPath, String attribute) {
    List retorno = [];
    referenceDatabase.child(mainPath).once().then((DataSnapshot snapshot) {
      int size = snapshot.value.length;
      for (int x=0; x<size; x++) {
        retorno.add(snapshot.value[x][attribute].toString());
      }
    });
    return retorno;
  }

}

List readListaContactos (){
  // A Leer contactos
  // 2. Cada contacto formal es "{Nombre}: {Contacto}"
  List rt = [];
  _referenceDatabase.child("Clientes").once().then((DataSnapshot snapshot) {
    int size = snapshot.value.length-1;
    for (int x=0; x<size; x++) {
      rt.add(snapshot.value[x.toString()]["Nombre"].toString() + ": "+snapshot.value[x.toString()]["Contacto"].toString());
    }
  });
  return rt;
}

List readListaServicios(){
  // B Leer servicios
  // 2. Cada servicio es "Servicio: precio".
  List rt = [];
  _referenceDatabase.child("Servicios").once().then((DataSnapshot snapshot){
    int size = snapshot.value.length;
    for (int x=0; x<size; x++) {
      rt.add(snapshot.value[x.toString()]["Nombre"].toString() + ": "+snapshot.value[x.toString()]["Precio"].toString());
    }
  });
  return rt;
}

String str_hr(int num){
  if (num < 10) {return "0"+num.toString();}
  else {return num.toString();}
}

List hacerWorkTimeList (int startTime, int endTime, int interval){
  List retorno = [];
  int quote = (60/interval).toInt();
  int diff = endTime - startTime;
  for (int q=0; q<diff; q++){
    int currHr = startTime + q; // termino(q, quote);
    for (int s=0; s<quote; s++){
      int currMin = interval*(s);
      retorno.add(
         currHr.toString() + ":" + str_hr(currMin)
      );
    }
  }
  return retorno;
}

List<DropdownMenuItem<String>> getDropDownMenuItems (List data){
  List<DropdownMenuItem<String>> retorno = [];
  for (int q=0; q<data.length; q++){
    retorno.add(
        new DropdownMenuItem(
            child: new Text(data[q], style:TextStyle(fontSize: 20.0)),
            value: q.toString(),
        ),
    );
  }
  return retorno;
}


