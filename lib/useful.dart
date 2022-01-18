import 'package:flutter/material.dart';

class Data {
  final List servicios;
  final List precios;
  final List nMeetings;
  final String cliente;
  final List indexServicios;
  final int clIndex;
  final List intervalos;
  Data ({ required this.intervalos, required this.servicios, required this.cliente, required this.precios, required this.nMeetings, required this.clIndex,
          required this.indexServicios });
}

List<DropdownMenuItem<String>> getDropdownButtonItems (List data){
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

YesNo (context, siFuncion, noFuncion, String mss){
  Widget continueButton = FlatButton(
    child: Text("Si"),
    onPressed:  () { siFuncion(); },
  );
  Widget cancelButton = FlatButton(
    child: Text("No"),
    onPressed:  () { noFuncion(); },
  );
  AlertDialog alert = AlertDialog(
    title: Text("Gestor Bracco"),
    content: Text(mss),
    actions: [ continueButton, cancelButton ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {return alert;},
  );
}