import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

import 'adminPage.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLogin createState() => _AdminLogin();
}

class _AdminLogin extends State<AdminLogin> {
  TextEditingController passwordController = new TextEditingController();
  String PASSWORD = "";
  final referenceDatabase = FirebaseDatabase.instance.reference();
  Future<String> readADMINPassword() async {
    referenceDatabase.child("Adminpass").once().then((DataSnapshot snapshot) {
       PASSWORD = snapshot.value.toString();
    });
    print ("AdminPass received: "+PASSWORD);
    return new Future.value("AdminPass recibida");
  }

  @override
  Widget build(BuildContext context) {
    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;
    final double topMargin = scrHeight * 0.022; // 20
    final double inputWidth = 0.72 * scrWidth; // 300
    final double inputHeight = 0.11 * scrHeight; // 100
    return FutureBuilder<String>(
        future: readADMINPassword(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text('Ingreso administrador')),
          body: Center(
            child:
              Column(
                children: [
                  SizedBox(height:topMargin),
                  Text ("Contraseña", style: GoogleFonts.alef(fontSize:30)),
                  SizedBox(height:topMargin),
                  SizedBox(
                      width: inputWidth,
                      height: inputHeight,
                      child:
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Contraseña'
                        ),
                      )
                  ),
                  SizedBox(
                    width: inputWidth,
                    height: inputHeight/2,
                    child:
                      RaisedButton(onPressed: () {
                        if (passwordController.text == PASSWORD) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => adminPage()),
                          );
                        } else {
                          showAlertDialog(context);
                        }
                      },
                        color: Color.fromRGBO(26, 15, 189, 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(30))),
                        child: Text("Ingresar", style: TextStyle(color: Colors.white),),
                      ),
                  ),
                ],
              )
          )
      );
    });
  }

  showAlertDialog(BuildContext context) {
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Gestor Bracco"),
      content: Text("Contraseña incorrecta ☹"),
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