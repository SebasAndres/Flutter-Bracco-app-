import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class newClientPage extends StatefulWidget {
  @override
  _newClientPage createState() => _newClientPage();
}

class _newClientPage extends State<newClientPage> {

  TextEditingController inContacto = new TextEditingController();
  TextEditingController inNombre = new TextEditingController();

  final databaseReference = FirebaseDatabase.instance.reference();
  List Origenes = ["Redes Sociales", "Recomendación familiar/amigos", "Cercanía", "Hotel"];
  List telefonoClientes = [];
  String selectedOrigen = "Redes Sociales";
  int nextIndex = 0;

  Future<String> loadData () async {
    setState((){
      databaseReference.child("Clientes").once().then((DataSnapshot snapshot) {
        int size = snapshot.value.length-1; telefonoClientes = [];
        nextIndex = int.parse(snapshot.value["nextIndex"].toString());
        for (int u=0; u<size; u++) {
          telefonoClientes.add(snapshot.value[u.toString()]["Contacto"].toString());
        }
      });
    });
    return Future.value("");
  }

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double disTitulo = 0.015 * scrHeight; // 13
    final double disButton = 0.035 * scrHeight; // 30
    final double inputWidth = 0.72 * scrWidth; // 300
    final double inputHeight = 0.11 * scrHeight; // 100

    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text('Agregar clientes')),
          body: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text ("Nuevo Cliente", style: GoogleFonts.alef(fontSize:30)),
              SizedBox(height:disTitulo),
              SizedBox(
              width: inputWidth,
              height: inputHeight,
              child:
              TextField(
                decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Código y Nombre',
                ),
                controller: inNombre,
              )
              ),
              SizedBox(
              width: inputWidth,
              height: inputHeight,
              child:
              TextField(
                decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '+54 11 NNNN-NNNN'
                ),
                controller: inContacto
              )
              ),
              Container(
              width: inputWidth,
              height: inputHeight/2,
              child:
              DropdownButton(
              value: selectedOrigen.toString(),
              items: getDropDownMenuItems(Origenes),
              onChanged: (value) {
              setState(() { selectedOrigen = value.toString(); });
              },
              ),
              ),
              SizedBox(height: disButton),
              SizedBox(
              width: 300,
              height: 50,
              child:
              RaisedButton(onPressed: () {
                // 1. Si el telefono no esta en la b de datos -> agregar
                if (inContacto.text != "" && inNombre.text != ""){
                  if (!telefonoClientes.contains(inContacto.text)){ // Agregar
                    var ref = databaseReference.child("Clientes").child(nextIndex.toString());
                    ref.child("Nombre").set(inNombre.text);
                    ref.child("Contacto").set(inContacto.text);
                    ref.child("Origen").set(selectedOrigen);
                    databaseReference.child("Clientes").child("nextIndex").set(nextIndex+1);
                    showAlertDialog(context, "Agregar Cliente", "Se ha agregado el cliente");
                  }
                  else { // No agregar
                    showAlertDialog(context, "Agregar Cliente", "Ese teléfono ya está asociado a un cliente");
                  }
                } else {
                  showAlertDialog(context, "Agregar Cliente", "No has rellenado todos los campos");
                }
              },
              color: Color.fromRGBO(26, 15, 189, 1.0),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Text(
              "Agregar cliente", style: TextStyle(color: Colors.white),),
              )
              ),
            ],
            ),
          ),
        );
    }
    );
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
}
