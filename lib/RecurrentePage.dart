import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bracco_app/useful.dart';

class RecurrentePage extends StatefulWidget {
  @override
  _RecurrentePage createState() => _RecurrentePage();
}

class _RecurrentePage extends State<RecurrentePage> {

  final TextStyle fontStyle = GoogleFonts.mcLaren(fontSize:16);

  final databaseReference = FirebaseDatabase.instance.reference();

  TextEditingController inContacto = new TextEditingController();
  TextEditingController inDiasIntervalo = new TextEditingController();

  List LIST_SERVICIOS = []; String selectedServicio = "Seleccionar";
  List LIST_SERVICIOS_INDEX = [];
  List Periodicidades = [0, 1, 2, 3, 4, 5, 6]; String selectedPeriodicidad = "0";

  List listaContactos = []; int nextIndex = -1;

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double top_margin_container = 0.177 * scrHeight; // 150
    final double distItem = 0.011 * scrHeight; // 10
    final double bt2Width = 0.12 * scrWidth; // 50
    final double cntWidth = 0.60 * scrWidth;
    final double inputFieldWidth = 0.85 * scrWidth;

    return FutureBuilder<String>(
        future: loadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          // DISEÑO
          return Scaffold(
              appBar: AppBar(
                title: Text('Añadir un recurrente'),
              ),
              body:
              Column(
                  children: [
                    SizedBox(height: top_margin_container),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child:
                        Center(
                            child:
                            Column(
                                children: [
                                  SizedBox(child: Text("Recurrentes: ", style: TextStyle(fontSize: 40.0)),),
                                  SizedBox(height: distItem/2),
                                  Container(
                                    width: cntWidth,
                                    child:
                                    DropdownButton(
                                      value: selectedServicio.toString(),
                                      items: getDropdownButtonItems(LIST_SERVICIOS),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedServicio = value.toString();
                                        });
                                      },
                                    ),
                                  ), // Elegir servicio
                                  SizedBox(height: distItem),
                                  Container(
                                    width: 350,
                                    child:
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Contacto del cliente",
                                      ),
                                      controller: inContacto,
                                    ),
                                  ), // Elegir cliente
                                  SizedBox(height:distItem),
                                  Row (
                                      children: [
                                          SizedBox (width:0.11*scrWidth),
                                          Text ("Periodicidad: ", style: fontStyle),
                                          Container (
                                            width: 50,
                                            height: 50,
                                            child:
                                            DropdownButton(
                                              items: getDropdownButtonItems(Periodicidades),
                                              value: selectedPeriodicidad.toString(),
                                              onChanged: (value) {
                                                setState(() { selectedPeriodicidad = value.toString(); });
                                              },
                                            ),
                                          ),
                                      ]
                                  ), // Elegir periodicidad
                                  SizedBox(height:distItem),
                                  Container(
                                    width: inputFieldWidth,
                                    child:
                                    TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Días de intervalo",
                                      ),
                                      controller: inDiasIntervalo,
                                    ),
                                  ), // Elegir plazos medios
                                  SizedBox(height:distItem*2),
                                  Row (
                                      children: [
                                        SizedBox(width:bt2Width),
                                        SizedBox(
                                            width: 300,
                                            height: 50,
                                            child:
                                            RaisedButton (onPressed: () {
                                              String contactoCliente = inContacto.text;
                                              int diasIntervalo = tryToInt(inDiasIntervalo.text);
                                              if (diasIntervalo >= 0 && selectedServicio != "Seleccionar") {
                                                if (listaContactos.contains(contactoCliente)){
                                                  // Leer nextIndex de Recurrentes
                                                  databaseReference.child("Recurrentes").once().then((DataSnapshot snapshot) {
                                                    nextIndex = int.parse(snapshot.value["nextIndex"].toString());
                                                  });
                                                  if (nextIndex > -1){
                                                    DateTime finalF = DateTime.now().add(Duration (days: diasIntervalo));
                                                    String diaFinal = finalF.day.toString() + "-" + finalF.month.toString() + "-" +finalF.year.toString();
                                                    // Asignar a Recurrentes/nextIndex los datos
                                                    databaseReference.child("Recurrentes").child(nextIndex.toString()).set(
                                                        {
                                                          "Cliente": listaContactos.indexOf(contactoCliente)+1,
                                                          "Servicio": LIST_SERVICIOS_INDEX[LIST_SERVICIOS.indexOf(selectedServicio)],
                                                          "Intervalo": diasIntervalo,
                                                          "Periodicidad": int.parse(selectedPeriodicidad),
                                                          "proxCorte": diaFinal,
                                                          "Reunion": 0,
                                                          "Noti": 0
                                                        }
                                                    );
                                                    // Asignar a nextIndex como nextIndex+1
                                                    databaseReference.child("Recurrentes").child("nextIndex").set(nextIndex+1);
                                                    // Notificar el éxito
                                                    showAlertDialog(context, "Recurrentes", "Se ha agregado el recurrente");
                                                  }
                                                }
                                                else { showAlertDialog(context, "Recurrentes", "El contacto no está registrado!");}
                                              }
                                              else { showAlertDialog(context, "Recurrentes", "El intervalo no es válido o no elegiste un servicio!"); }
                                            },
                                              color: Color.fromRGBO(26, 15, 189, 1.0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(30))),
                                              child: Text("Alta",
                                                style: TextStyle(color: Colors.white),),
                                            )
                                        ),
                                      ]
                                  ),
                                  SizedBox(height:0.011 * scrHeight),
                                  FlatButton(
                                    onPressed: () { setState( () => {} ); },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    color: Colors.lightBlue,
                                    child: Text("Recargar", style:TextStyle(color:Colors.white)),
                                  ),
                                ])
                        ) // BOTONES
                    ),
                  ]
              )
          );
        }
    );
  }

  String sumDays(int todayDay, int todayMonth, int todayYear, int interval) {
    List daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int initMonthLim = daysPerMonth[todayMonth];
    int year = todayYear;
    if (todayDay+interval > initMonthLim) {
      int remaining  =  interval - initMonthLim - todayDay;
      int nextMonth = todayMonth+1;
      int nextMonthDay = 0; // para inicializarlo
      while (remaining != 0){
        if (daysPerMonth [nextMonth] < remaining) {
          nextMonth++;
          remaining -= int.parse(daysPerMonth[nextMonth].toString());
        }
        else { // nextMonth ta bbien
          nextMonthDay = remaining;
          remaining = 0;
        }
      }

      if (nextMonth > 12){ nextMonth = nextMonth % 12; year += 1; }

      return nextMonthDay.toString() + "." + nextMonth.toString() + "." + year.toString();
    }
    else {
      return (todayDay+interval).toString() + "." + todayMonth.toString();
    }
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

  Future<String> loadData() async {
    setState((){
      databaseReference.child("Servicios").once().then((DataSnapshot snapshot) {
        int size = snapshot.value.length-1;
        LIST_SERVICIOS = []; LIST_SERVICIOS_INDEX = [];
        for (int u=0; u<size; u++) {
          var servicio = snapshot.value[u.toString()];
          if (servicio["Periodicidad"] == 1){
            LIST_SERVICIOS.add(servicio["Nombre"]);
            LIST_SERVICIOS_INDEX.add(u);
          }
        }
      });

      databaseReference.child("Clientes").once().then((DataSnapshot snapshot) {
       int size = snapshot.value.length-1; // Hay en realizad size-1 por index 0 introducción
       listaContactos = [];
       for (int p=1; p<size; p++){
         listaContactos.add(snapshot.value[p.toString()]["Contacto"].toString());
       }
      });

    });
    return Future.value("Los datos se han cargado");
  }

  int tryToInt(String text) {
    try {
      return int.parse(text);
    }
    catch (Exception) {
      return -1;
    }
  }
}