import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'useful.dart';

class ConfirmarServicioPage extends StatefulWidget {
  final Data data;
  ConfirmarServicioPage({required this.data});
  @override
  _ConfirmarServicioPage createState() => _ConfirmarServicioPage(data: data);
}

class _ConfirmarServicioPage extends State<ConfirmarServicioPage>{

  var data;
  _ConfirmarServicioPage({required this.data});

  List states = []; // Estados de los inkwell
  List<int> numMeetings = []; // Número de encuentros que necesita cada servicio que llegó acá

  int trabCortes = -1;

  final databaseReference = FirebaseDatabase.instance.reference();

  //region VARIABLES DE DISEÑO
  var titleTextStyle = GoogleFonts.mcLaren(fontSize: 25);
  Color doneColor = Colors.lightBlueAccent;
  var container_decoration = BoxDecoration(
      color: Colors.black,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(8))
  );
  //endregion

  String FECHA = "";
  String CLIENTE = "";
  String TOTAL = "0";

  int nContainers = 0;
  List SERVICIOS = [];
  List PRECIOS = [];
  List nMeetings = [];
  List intervalos = [];

  List SUCURSALES = [];
  String selectedSucursal = "Holiday Inn";
  List TRABAJADORES = [];
  String selectedTrabajador = "Mateo";

  int nCortes = -1;
  int PendientesNextIndex = -1;

  Future<String> readData (){

    // Leer index N
    databaseReference.child("Cortes").once().then((DataSnapshot snapshot) {
      nCortes = int.parse(snapshot.value["nextIndex"].toString());
    });
    print ("nCortes: "+nCortes.toString());

    FECHA = DateTime.now().toString();
    FECHA = FECHA.replaceRange(16, FECHA.length, "");

    CLIENTE = data.cliente;

    SERVICIOS = data.servicios;
    int nServ = SERVICIOS.length;

    PRECIOS = data.precios;

    int int_total = 0;
    for (int u=0; u<PRECIOS.length; u++){ int_total += int.parse(PRECIOS[u]);}
    TOTAL = int_total.toString();

    nMeetings = data.nMeetings;
    for (int serv=0; serv<nServ; serv++) {
      int nVisitasPServ = nMeetings[serv];
      numMeetings.add(nVisitasPServ);
      List addingList = [true];
      for (int visitas = 0; visitas < nVisitasPServ - 1; visitas++)
        addingList.add(false);
      states.add(addingList); // servicio parte 1 y parte 2 ¿hechos?
    }

    // Leer sucursales y trbajadores
    databaseReference.child("Sucursales").once().then((DataSnapshot snapshot) {
      int nSucursales = snapshot.value.length;
      SUCURSALES = [];
      for (int w = 0; w < nSucursales; w++) {
        SUCURSALES.add(snapshot.value[w]["Nombre"].toString());
      }
    });

    databaseReference.child("Trabajadores").once().then((DataSnapshot snapshot) {
      int nTrabajadores = snapshot.value.length;
      TRABAJADORES = [];
      for (int w = 0; w < nTrabajadores; w++) {
        TRABAJADORES.add(snapshot.value[w.toString()]["Nombre"].toString());
      }
    });

    return Future.value("Datos leídos");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: readData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
        return Scaffold(
          appBar: AppBar(
            title: Text('Confirmar Servicio'),
          ),
          body:
            Column(
              children:[
                SizedBox(height: 8),
                Text("Pedido", style: titleTextStyle, textAlign: TextAlign.center),
                RaisedButton(onPressed: (){
                  setState(()=>{

                  });
                  },
                  child: Text("Recargar")
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: ListTile(
                    title: Row(children: [
                      Expanded(child: Text("Fecha & hora: ", textAlign: TextAlign.center)),
                      Expanded(child: Text(FECHA, textAlign: TextAlign.center)),
                    ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: ListTile(
                    title: Row(children: [
                      Expanded(child: Text("Cliente: ", textAlign: TextAlign.center)),
                      Expanded(child: Text(CLIENTE, textAlign: TextAlign.center)),
                    ]),
                  ),
                ),

                Container(
                 width: MediaQuery.of(context).size.width,
                 decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                 child: Column( children: [
                  Text("Sucursal", style:GoogleFonts.mcLaren(fontSize:20)),
                  DropdownButton(
                    items: getDropdownButtonItems(SUCURSALES),
                    value: selectedSucursal.toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedSucursal = value.toString();
                      });
                    },
                  ),
                  ]
                )
                ),

                SizedBox(height: 5),

                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column( children: [
                      Text("Trabajador", style:GoogleFonts.mcLaren(fontSize:20)),
                      DropdownButton(
                        items: getDropdownButtonItems(TRABAJADORES),
                        value: selectedTrabajador.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedTrabajador = value.toString();
                          });
                        },
                      ),
                    ]
                    )
                ),

                Expanded(
                  child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: SERVICIOS.length,
                  itemBuilder: (BuildContext context, int index) {
                    return devContainer(index);
                  })
                ),

                Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: ListTile(
                        title: Row(children: [
                          Expanded(child: Text("TOTAL A PAGAR: ", textAlign: TextAlign.center)),
                          Expanded(child: Text(TOTAL, textAlign: TextAlign.center)),
                        ]),
                      ),
                    ),
                SizedBox(height: 5),
                SizedBox(
                    width:300, height:50, child:
                    RaisedButton(
                      onPressed: () {
                        // Revisar la existencia de neuvos pendientes
                        bool goneWell = true; // false if input invalido
                        for (int s=0; s<SERVICIOS.length; s++) {
                          if (nMeetings[s] > 1){
                            databaseReference.child("Pendientes").once().then((DataSnapshot snapshot){
                              PendientesNextIndex = int.parse(snapshot.value["nextIndex"].toString());
                            });
                            DateTime qfecha = DateTime.now();
                            for (int k=0; k<nMeetings[s]; k++){
                              // leer nextIndex Pendientes
                              if (!states[s][k]){
                                if (PendientesNextIndex != -1){
                                  // Agregar a pendientes\nextIndex data de la forma
                                  /*
                                {
                                  Cliente: nCliente,
                                  Servicio: nServicio,
                                  DiaFin: 04.07
                                  Reunion: nReunion (k)
                                }
                                * */
                                  DateTime diaFin = qfecha.add(Duration(days:data.intervalos[s]));
                                  String strFecha = diaFin.day.toString()+"-"+diaFin.month.toString()+"-"+diaFin.year.toString();
                                  databaseReference.child("Pendientes").child(PendientesNextIndex.toString()).set(
                                      {
                                        "Cliente": data.clIndex,
                                        "Servicio": data.indexServicios[s],
                                        "diaFin": strFecha,
                                        "Reunion": k+1,
                                        "Noti": 0
                                      }
                                  );
                                  databaseReference.child("Pendientes").child("nextIndex").set(PendientesNextIndex+1);
                                  qfecha = diaFin; PendientesNextIndex++;
                                }
                                else { goneWell = false; }
                              }
                            }
                          }
                          if (goneWell){
                            // Agregar en Cortes/N+1 toda la data, N = nCortes = [Último index de corte]
                            if (SERVICIOS.length > 1) {
                              // Agregar data pero con servicios como lista
                              databaseReference.child("Cortes").child((nCortes).toString()).set(
                                {
                                    "Cliente": data.clIndex,
                                    "Fecha": FECHA,
                                    "Pago": TOTAL,
                                    "Sucursal": selectedSucursal,
                                    "Trabajador": selectedTrabajador,
                                    "nServ": SERVICIOS.length
                                  }
                              );
                              Map<String, int> mapServicios = {};
                              for (int serv=0; serv<data.indexServicios.length; serv++){
                                mapServicios.addAll({serv.toString(): int.parse(data.indexServicios[serv].toString())});
                              }
                              databaseReference.child("Cortes").child((nCortes).toString()).child("Servicio").set(mapServicios);
                            }
                            else {
                              databaseReference.child("Cortes").child((nCortes).toString()).set(
                                  {
                                    "Cliente": data.clIndex,
                                    "Fecha": FECHA,
                                    "Pago": TOTAL,
                                    "Servicio": data.indexServicios[0],
                                    "Sucursal": selectedSucursal,
                                    "Trabajador": selectedTrabajador,
                                    "nServ": 1
                                  }
                              );
                            }
                            // Actualizar nextIndex
                            databaseReference.child("Cortes").child("nextIndex").set(nCortes+1);
                            // Sumar 1 corte en la sucursal
                            databaseReference.child("Cortes").child("nextIndex").set(nCortes+1);
                            // Sumar 1 corte en el trabajador
                            databaseReference.child("Trabajadores").child(TRABAJADORES.indexOf(selectedTrabajador).toString())
                                .once().then((DataSnapshot snapshot){
                              trabCortes = int.parse(snapshot.value["nCortes"].toString());
                            });
                            databaseReference.child("Trabajadores").child(TRABAJADORES.indexOf(selectedTrabajador).toString())
                                .child("nCortes").set(trabCortes+1);
                            // Alertar
                            showAlertDialog (context, "Nuevo Corte", "Se ha añadido el corte 🤝😃");
                          }
                        }
                      },
                      color: Color.fromRGBO(26, 15, 189, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(30))),
                      child: Text("Siguiente", style: TextStyle(color: Colors.white)),
                    )
                )
              ]
          )
        );
      });
  }

  Color StateColor (bool state){
    if (state) return Colors.indigoAccent;
    else return Colors.grey;
  }

  List<Widget> getChildren (int index){
    List<Widget> list = [];
    list.add(Container(
      margin: EdgeInsets.all(5),
      decoration: container_decoration,
      child: ListTile(
        title: Row(children: [
          Expanded(child: Text("${SERVICIOS[index]}: ", textAlign: TextAlign.center)),
          Expanded(child: Text(PRECIOS[index], textAlign: TextAlign.center)),
        ]),
      ),
    ));
    for (int num=1; num<numMeetings[index]; num++){
      list.add(
          InkWell(
          onTap: () {
            setState((){
              states[index][num] = !states[index][num];
            });
          },
          child:
          Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: StateColor(states[index][num]),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: ListTile(
              title: Row(children: [
                Expanded(child: Text("${SERVICIOS[index]} (Parte ${(num+1).toString()}): ", textAlign: TextAlign.center)),
                Expanded(child: Text("=> ${states[index][num]?'Reservado':'Sin reservar'}", textAlign: TextAlign.center)),
              ]),
            ),
          ),
        ));
    }
    return list;
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

  Widget devContainer(int index) {
    if (numMeetings[index] > 1){
      // Return 1 container + (numMeetings[index]-1)
      return Column(children: getChildren(index));
    } else {
      // Return 1 container
      return Container(
        margin: EdgeInsets.all(5),
        decoration: container_decoration,
        child: ListTile(
          title: Row(children: [
            Expanded(child: Text("${SERVICIOS[index]}: ", textAlign: TextAlign.center)),
            Expanded(child: Text(PRECIOS[index], textAlign: TextAlign.center)),
          ]),
        ),
      );
    }
  }

  List strFechaToList (String fecha){
    // print ("strFechaToList (input): "+fecha);
    List nFecha = [-1, -1, -1]; // [dia, mes, año]
    int currIndex = 0;
    String accum = "";
    bool done = false;
    fecha += ".";
    for (int char=0; char<fecha.length; char++){
      if (fecha[char] == "-" || fecha[char] == " " || fecha[char] == ".") {
        nFecha[currIndex] = int.parse(accum); currIndex++; accum = "";
        if (currIndex > 2)
          done = true;
      }
      else if (char == fecha.length-1 && !done){
        accum += fecha[char];
        nFecha[2] = int.parse(accum);
      }
      else { accum += fecha[char]; }
    }
    return nFecha;
  }

  String sumDays(int todayDay, int todayMonth, int todayYear, int interval) {
    DateTime iTime = DateTime.now();
    DateTime fTime = iTime.add(Duration(days: interval));
    return fTime.day.toString() + "." + fTime.month.toString() + "." + fTime.year.toString();
    /**
     *    List daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        int initMonthLim = daysPerMonth[todayMonth];
        int year = todayYear;
        if (todayDay+interval > initMonthLim) {
        int remaining  =  interval - initMonthLim - todayDay;
        int nextMonth = todayMonth+1;
        int nextMonthDay = 0; // para inicializarlo
        while (remaining > 0){
        if (daysPerMonth [nextMonth] < remaining) {
        nextMonth++;
        remaining -= int.parse(daysPerMonth[nextMonth].toString());
        }
        else { // nextMonth ta bbien
        nextMonthDay = remaining;
        remaining = 0;
        }

        if (nextMonthDay == 0){
        nextMonth--;
        nextMonthDay = daysPerMonth[nextMonth];
        }
        }

        if (nextMonth > 12){ nextMonth = nextMonth % 12; year += 1; }

        return nextMonthDay.toString() + "." + nextMonth.toString() + "." + year.toString();
        }
        else {
        return (todayDay+interval).toString() + "." + todayMonth.toString() + "." + year.toString();
        }

     */
  }
}