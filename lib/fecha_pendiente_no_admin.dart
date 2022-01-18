import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class fecha_pendiente_no_admin extends StatefulWidget {
  @override
  _fpnoadmin createState() => _fpnoadmin();
}

class Pendiente {
  // Cliente, noti, diaFin, Reunion, Servicio
  var cliente; var noti; var diaFin; var reunion; var servicio;
  bool read = false;
}

class _fpnoadmin extends State<fecha_pendiente_no_admin> {

  final TextStyle fontStyle = GoogleFonts.mcLaren(fontSize:16);
  final titleStyle = GoogleFonts.mcLaren(fontSize: 30);
  final double yMargin = 10;
  final Color billbColour = Colors.white12;
  final double boxWidth = 200;

  final int D = 2; // Máximo de días a futura q aparece en pendientes
  List PENDIENTES = []; // Lista con todos los index de los pendientes de hasta D dias de diferencia
  List ClientesIndex = [];
  List SERVICIOS = []; // index
  List Servicios = []; // nombre
  List diasFaltantes = [];
  List Telefonos = [];
  List Clientes = [];
  List nReunion = [];

  int pendientesNextIndex = -1;
  int ultIndex = -2;
  Pendiente ultPendiente = Pendiente();

  final databaseReference = FirebaseDatabase.instance.reference();

  Future<String> readData () {
    // Leer pendientes
    setState(()=>{
      databaseReference.child("Pendientes").once().then((DataSnapshot snapshot){
        ultIndex = int.parse(snapshot.value["nextIndex"].toString())-1;
        int size = snapshot.value.length-1;
        PENDIENTES = []; SERVICIOS = []; diasFaltantes = []; nReunion = [];
        for (int z=0; z<size; z++){
          var pendiente = snapshot.value[z.toString()];
          String strFecha = pendiente["diaFin"].toString();
          List fechaFin = strFechaToList(strFecha);
          List fechaHoy = [DateTime.now().day, DateTime.now().month, DateTime.now().year];
          int Dif = diferencia(fechaFin, fechaHoy);
          if (Dif < D+1) { // Si hay una distancia entre las fechas menor igual a D días
            PENDIENTES.add(z);
            ClientesIndex.add(int.parse(pendiente["Cliente"].toString()));
            SERVICIOS.add(int.parse(pendiente["Servicio"].toString()));
            diasFaltantes.add(Dif);
            nReunion.add(pendiente["Reunion"].toString());
          }
        }
      })
    });
    // Agregar teléfonos
    setState(()=>{
      databaseReference.child("Clientes").once().then((DataSnapshot snapshot){
        Telefonos = []; Clientes = [];
        for (int t=0; t<ClientesIndex.length; t++) {
          int index = int.parse(ClientesIndex[t].toString());
          Telefonos.add(snapshot.value[index.toString()]["Contacto"].toString());
          Clientes.add(snapshot.value[index.toString()]["Nombre"].toString());
        }
      })
    });
    // Leer servicios
    setState(()=>{
      databaseReference.child("Servicios").once().then((DataSnapshot snapshot) {
      Servicios = [];
      for (int w=0; w<SERVICIOS.length; w++) {
        int index = SERVICIOS[w];
        Servicios.add(snapshot.value[index.toString()]["Nombre"].toString());
      }
      })
    });
    return Future.value("");
  }

  int diferencia (List fechaFinal, List fechaInicio){
    List daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int mesInicio = int.parse(fechaInicio[1].toString());
    int sumInicio = SumTill(daysPerMonth, mesInicio) + int.parse(fechaInicio[0].toString());
    int mesFinal = int.parse(fechaFinal[1].toString());
    int sumFinal = SumTill(daysPerMonth, mesFinal) + int.parse(fechaFinal[0].toString());
    // print ("${fechaFinal.toString()} - ${fechaInicio.toString()} = ${sumFinal} - ${sumInicio} = ${sumFinal-sumInicio}");
    return sumFinal - sumInicio;
  }

  int SumTill(List daysPerMonth, int mes) {
    int rr = 0;
    for (int z=0; z<mes; z++){ rr += int.parse(daysPerMonth[z].toString()); }
    return rr;
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

  Widget devContainer (int index){
    return InkWell(
      onTap: () { // YA SE CORTO EL PELO
        if (ultIndex > 0){
          if (index < ultIndex) {
            databaseReference.child("Pendientes").once().then((DataSnapshot sn){
              var value = sn.value[ultIndex.toString()];
              ultPendiente.cliente = value["Cliente"];
              ultPendiente.servicio = value["Servicio"];
              ultPendiente.noti = value["Noti"];
              ultPendiente.reunion = value["Reunion"];
              ultPendiente.diaFin = value["diaFin"];
              ultPendiente.read = true;
            });
            if (ultPendiente.read)
              databaseReference.child("Pendientes").child(index.toString()).set({
                  "Cliente": ultPendiente.cliente,
                  "Servicio": ultPendiente.servicio,
                  "Noti": ultPendiente.noti,
                  "Reunion": ultPendiente.reunion,
                  "diaFin": ultPendiente.diaFin
                });
          }
          if (ultPendiente.read){
            databaseReference.child("Pendientes").child(ultIndex.toString()).set(null);
            databaseReference.child("Pendientes").child("nextIndex").set(ultIndex);
            showAlertDialog(context, "Se ha eliminado de la lista de pendientes 😁");
          }
        }
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: ListTile(
          title: Row(children: [
            Expanded(child: Text(Clientes[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
            Expanded(child: Text(Servicios[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
            Expanded(child: Text("Reunión: "+nReunion[index].toString(), textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
            Expanded(child: Text("Restan: "+diasFaltantes[index].toString(), textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: readData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          return Scaffold(
              appBar: AppBar(
                title: Text('Pendientes'),
              ),
              body:
              Flex(
                  direction: Axis.vertical,
                  children: [
                    SizedBox(height:5),
                    RaisedButton(onPressed: () => {setState(()=>{ })},
                      child: Text("Recargar"),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: PENDIENTES.length,
                            itemBuilder: (BuildContext context, int index) { return devContainer(index); }
                        )
                    )
                  ]
              )
          );
        }
    );
  }

  showAlertDialog(BuildContext context, String mss) {
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Gestor Bracco"),
      content: Text(mss),
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

