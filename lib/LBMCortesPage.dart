import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'VerCortePorMesYear.dart';
import 'VerCortesPorFechaPage.dart';
import 'fuente_ventas.dart';

class LBMCortesPage extends StatefulWidget {
  @override
  _LBMCortesPage createState() => _LBMCortesPage();
}

class _LBMCortesPage extends State<LBMCortesPage>{

  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<String> loadData (){ return Future.value("FFF"); }

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double topMargin = 0.11 * scrHeight; //
    final double top_down_margin = 0.017 * scrHeight; // 15
    final double tenMargin = 0.011 * scrHeight;
    final double button_width = 0.6 * scrWidth; // 250
    final double button_height = 0.059 * scrHeight;
    final double container_size = 0.85 * scrWidth; // 350;
    final double midMargin = 0.035 * scrHeight; // 30

    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          // DISEÑO
          return Scaffold(
              appBar: AppBar(title: Text('Mis Cortes')),
              body:
              Column(
                  children: [
                    SizedBox(height:topMargin),
                    SizedBox(
                        width: button_width,
                        height: button_height,
                        child:
                        RaisedButton(onPressed: () {
                          Navigator.push(
                            context, MaterialPageRoute(builder: (context) => fuenteVentasPage()),
                          );
                        },
                        color: Color.fromRGBO(95, 88, 222, 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                        child: Text("Fuentes", style: TextStyle(color: Colors.white),),
                        )
                    ),
                    SizedBox(height:midMargin),
                    SizedBox(
                        width: button_width,
                        height: button_height,
                        child:
                        RaisedButton(onPressed: () {
                          DateTime fecha = selectedDate;
                          Navigator.push (
                            context,
                            MaterialPageRoute(builder: (context) => VerCortesPorMesYear(fecha: fecha, type:"año")),
                          );
                        },
                          color: Color.fromRGBO(60, 238, 217, 1.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30))),
                          child: Text("Ver anual", style: TextStyle(color: Colors.white),),
                        )
                    ),
                    SizedBox(height:midMargin),
                    SizedBox(
                        width: button_width,
                        height: button_height,
                        child:
                        RaisedButton(onPressed: () {
                          DateTime fecha = selectedDate;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VerCortesPorMesYear(fecha: fecha, type:"mes")),
                          );
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   },
                          color: Color.fromRGBO(41, 210, 204, 1.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30))),
                          child: Text("Ver mensual", style: TextStyle(color: Colors.white),),
                        )
                    ),
                    SizedBox(height: topMargin),
                    Center(
                      child:
                      Container(
                        width: container_size,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        child:
                        Column(
                        children: [
                          Text("Cortes: ", style: GoogleFonts.mcLaren(fontSize: 40.0)),
                          SizedBox(height: top_down_margin),
                          Container(
                            child:
                            Column(
                              children: [
                                Text(
                                  "${selectedDate.toLocal()}".split(' ')[0],
                                  style: GoogleFonts.mcLaren(fontSize: 30),
                                ),
                                SizedBox(height: tenMargin,),
                                SizedBox(
                                width: button_width,
                                height: button_height,
                                child:
                                RaisedButton(onPressed: () {
                                   _selectDate(context);
                                },
                                color: Color.fromRGBO(69, 60, 238, 1.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(30))),
                                child: Text("Cambiar fecha",
                                  style: TextStyle(color: Colors.white),),
                                )
                              ),
                              SizedBox(height:tenMargin),
                              SizedBox(
                                  width: button_width,
                                  height: button_height,
                                  child:
                                  RaisedButton(onPressed: () {
                                    DateTime fecha = selectedDate;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VerCortesPorFechaPage(fecha: fecha)),
                                    );
                                  },
                                  color: Color.fromRGBO(26, 15, 189, 1.0),
                                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: Text("Buscar", style: TextStyle(color: Colors.white)))
                              ),
                              SizedBox(height:top_down_margin),
                            ])
                          )
                        ],
                      ),
                    ),
                    ) // BOTON
                  ]
              )
          );
        }
    );
}}