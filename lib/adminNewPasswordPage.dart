import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

class adminNewPasswordPage extends StatefulWidget {
  @override
  _adminNewPasswordPage createState() => _adminNewPasswordPage();
}


class _adminNewPasswordPage extends State<adminNewPasswordPage> {

  TextEditingController passwordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();

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

    return FutureBuilder<String>(
        future: readADMINPassword(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Contraseña del administrador'),
              ),
              body: Center(
                  child:
                  Column(
                    children: [
                      SizedBox(height:150),
                      Text (
                          "Antigua contraseña",
                          style: GoogleFonts.alef(fontSize:30)
                      ),
                      SizedBox(height:20),
                      SizedBox(
                          width: 300,
                          height: 100,
                          child:
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Contraseña'
                            ),
                          )
                      ),
                      Text (
                          "Nueva contraseña",
                          style: GoogleFonts.alef(fontSize:30)
                      ),
                      SizedBox(height:20),
                      SizedBox(
                          width: 300,
                          height: 100,
                          child:
                          TextField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Nueva contraseña'
                            ),
                          )
                      ),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child:
                        RaisedButton(onPressed: () {
                          if (passwordController.text == PASSWORD) {
                            if (newPasswordController.text != ""){
                              referenceDatabase.child("Adminpass").set(newPasswordController.text);
                              showAlertDialog(context,"Contraseña del administrador", "Contraseña cambiada");
                            }
                            else {
                              showAlertDialog(context,"Contraseña del administrador", "La contraseña no puede ser nula");
                            }
                          } else {
                            showAlertDialog(context,"Contraseña del administrador", "La contraseña que ingresaste no es la antigua!");
                          }
                        },
                          color: Color.fromRGBO(26, 15, 189, 1.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30))),
                          child: Text("Cambiar contraseña",
                            style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  )
              )
          );
        });
  }

  showAlertDialog(BuildContext context, String title, String content) {
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {Navigator.of(context).pop();},
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
    showDialog (
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}