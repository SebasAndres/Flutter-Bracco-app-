import 'package:bracco_app/LBMCortesPage.dart';
import 'package:bracco_app/adminNewPasswordPage.dart';
import 'package:flutter/material.dart';

import 'ABMServiciosPage.dart';
import 'BuscadorClientes.dart';
// import 'LBMClientesPage.dart';
import 'SucursalPage.dart';
import 'TrabajadoresPage.dart';
import 'fechas_pendientes.dart';
import 'downloadPage.dart';
import 'AdminViewRecurrentePage.dart';

class adminPage extends StatefulWidget {
  @override
  _adminPage createState() => _adminPage();
}

class _adminPage extends State<adminPage> {
  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double btWidth = scrWidth; // 400
    final double btHeight = 0.06 * scrHeight; // 50
    final double inter_space = 0.022 * scrHeight; // 20

    return Scaffold(
      appBar: AppBar(title: Text("Administrador")),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuscadorClientes()),
                    );
                  },
                    color: Color.fromRGBO(26, 15, 189, 1.0),
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Mis Clientes", style:TextStyle(color:Colors.white, fontSize: 20),),
                  )
              ),
              SizedBox(height: inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ABMServiciosPage()),
                    );
                  },
                    color: Colors.blueAccent,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Mis Servicios", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LBMCortesPage()),
                    );
                  },
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Mis Cortes", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => fecha_pendiente()),
                    );
                  },
                    color: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Recordatorio reservas", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => adminNewPasswordPage()),
                    );
                  },
                    color: Colors.teal,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Nueva contraseña", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => downloadPage()));
                  },
                    color: Colors.greenAccent,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Descargar", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SucursalPage()));
                  },
                    color: Colors.green,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Mis Sucursales", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TrabajadoresPage()));
                  },
                    color: Colors.lightBlue,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Trabajadores", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
              SizedBox(height:inter_space),
              SizedBox(
                  width:btWidth,
                  height:btHeight,
                  child:
                  RaisedButton (
                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AdminViewRecurrentePage()));},
                    color: Colors.cyan,
                    shape: RoundedRectangleBorder (borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("Recurrentes", style:TextStyle(color:Colors.white, fontSize: 20)),
                  )
              ),
            ]
        ),
      ),
    );
  }
}