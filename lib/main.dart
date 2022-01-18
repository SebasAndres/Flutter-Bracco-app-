import 'package:bracco_app/RecurrentePage.dart';
import 'package:bracco_app/fecha_pendiente_no_admin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'newRequestPage.dart';
import 'newClientPage.dart';
import 'adminLoginPage.dart';
import 'ViewRecurrentePage.dart';

void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bracco Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Bracco Barbería'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;

    final double btWidth = screenW * 0.924; // 380.0;
    final double btHeight = screenH * 0.094; // 80
    final double disTitulo = screenH * 0.015; // 13
    final double interSpace = screenH * 0.011; // 10

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child:
                Text (
                  "BRACCO BARBERSHOP",
                  style: GoogleFonts.mcLaren(fontSize: 50),
                  textAlign: TextAlign.center,
                ),
            ),
            SizedBox(height: disTitulo),
            SizedBox(
              width:btWidth,
              height:btHeight,
              child:
              RaisedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => newClientPage()),
                  );
                },
                color: Color.fromRGBO(63, 60, 66, 0.1901960784313726),
                shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
                child: Text("Agregar cliente", style:TextStyle(color:Colors.white, fontSize: 20),),
              )
            ),
            SizedBox(height: interSpace),
            SizedBox(
                width:btWidth,
                height:btHeight,
                child:
                RaisedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => newRequestPage()),
                  );
                },
                  color: Color.fromRGBO(83, 60, 66, 0.1901960784313726),
                  shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
                  child: Text("Agregar pedido", style:TextStyle(color:Colors.white, fontSize: 20)),
                )
            ),
            SizedBox(height: interSpace),
            SizedBox(
                width:btWidth,
                height:btHeight,
                child:
                RaisedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => fecha_pendiente_no_admin()));
                 },
                color: Color.fromRGBO(33, 30, 96, 0.1901960784313726),
                  shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
                  child: Text("Pendientes", style:TextStyle(color:Colors.white, fontSize: 20)),
                )
            ),
            SizedBox(height: interSpace),
            SizedBox(
                width:btWidth,
                height:btHeight,
                child:
                RaisedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecurrentePage()));
                },
                  color: Color.fromRGBO(33, 60, 96, 0.1901960784313726),
                  shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
                  child: Text("Agregar recurrente", style:TextStyle(color:Colors.white, fontSize: 20)),
                )
            ),
            SizedBox(height:interSpace),
            SizedBox(
                width:btWidth,
                height:btHeight,
                child:
                RaisedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewRecurrentePage()));
                },
                  color: Color.fromRGBO(66, 60, 96, 0.1901960784313726),
                  shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
                  child: Text("Recurrentes", style:TextStyle(color:Colors.white, fontSize: 20)),
                )
            ),
            SizedBox(height:interSpace),
            SizedBox(
              width:btWidth,
              height:btHeight,
              child:
              RaisedButton(onPressed: (){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminLogin()));
              },
              shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30)), side: BorderSide(color: Colors.white)),
              child: Text("Administrador", style:TextStyle(color:Colors.white, fontSize: 20)),
              color: Color.fromRGBO(33, 70, 56, 0.1901960784313726),
              )
            )
        ]
      )
      )
    );
  }
}