import 'package:bracco_app/VerCorteTerminado.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerCortesPorMesYear extends StatefulWidget{
  final DateTime fecha; final String type;
  VerCortesPorMesYear({required this.fecha, required this.type});
  @override
  _VerCortesPorMesYear createState() => new _VerCortesPorMesYear (fecha: fecha, tipo:type);
}


class _VerCortesPorMesYear extends State<VerCortesPorMesYear> {

  var fecha; String tipo;
  _VerCortesPorMesYear({required this.fecha, required this.tipo});

  String fecha_str = "";
  int nCortesFecha = 0;

  final double yMargin = 10;

  final databaseReference = FirebaseDatabase.instance.reference();

  List indexCortesPorFecha = [];
  List Horarios = []; // solo de crtes con = fecha
  List Clientes = []; // Solo de cortes con = fecha
  List Fechas = [];

  List Nombres = [];

  void numCortesPorFecha (String fecha){
    List nFecha = strFechaToList(fecha);
    databaseReference.child("Cortes").once().then((DataSnapshot snapshot) {
      indexCortesPorFecha = []; Fechas = []; Horarios = []; Clientes = [];
      int nCortes = snapshot.value.length-1;
      for (int n=0; n<nCortes; n++){
        var corte = snapshot.value[n.toString()];
        String strFecha = corte["Fecha"].toString();
        // InvertirOrden fecha corte
        List _fechaCorte = strFechaToList(strFecha);
        List fechaCorte = [];
        fechaCorte.add(_fechaCorte[2]);
        fechaCorte.add(_fechaCorte[1]);
        fechaCorte.add(_fechaCorte[0]);
        // Chequeaer si son iguales
        if (SonIgualesListSeg (nFecha, fechaCorte, tipo)) {
          indexCortesPorFecha.add(n);
          // Agregar horario corte
          String horaCorte = fromTo(11, 15, strFecha);
          Horarios.add(horaCorte);
          Fechas.add(fromTo(0, 10, strFecha));
          Clientes.add(Nombres[int.parse(corte["Cliente"].toString())]);
        }
      }
      setState (() => { nCortesFecha = indexCortesPorFecha.length });
    });
  }

  Future<String> readData (){
    fecha_str = fecha.day.toString() + "-" + fecha.month.toString() + "-" + fecha.year.toString();
    setState(()=>{
      databaseReference.child("Clientes").once().then((DataSnapshot snapshot){
        Nombres = [];
        int size = snapshot.value.length;
        for (int t=0; t<size; t++){
          var cliente = snapshot.value[t.toString()];
          Nombres.add(cliente["Nombre"].toString());
        }
      })
    });
    numCortesPorFecha(fecha_str);
    // print ("nCortesFecha: "+nCortesFecha.toString());
    return Future.value("Datos leídos");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: readData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
          return Scaffold(
              appBar: AppBar(
                title: Text('Cortes por fecha'),
              ),
              body:
              Flex (
                  direction: Axis.vertical,
                  children:
                  [
                    SizedBox(height:30),
                    Center (
                      child:
                      Text("Fecha: ${fecha_str}", style: GoogleFonts.pacifico (fontSize:30)),
                    ),
                    Expanded (
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: nCortesFecha,
                            itemBuilder: (BuildContext context, int index) {
                              return devContainer(index);
                            })
                    )
                  ]
              )
          );
        }
    );
  }

  List strFechaToList (String fecha){
    List nFecha = [-1, -1, -1]; // [dia, mes, año]
    int currIndex = 0;
    String accum = "";
    bool done = false;
    for (int char=0; char<fecha.length; char++){
      if (fecha[char] == "-" || fecha[char] == " ") {
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

  Widget devContainer(int index) {
    return Column(
        children: [
          InkWell (
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VerCorteTerminado(indexCorte: indexCortesPorFecha[index])));
            },
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: ListTile(
                title: Row(children: [
                  Expanded(child: Text(Fechas[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(Horarios[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.white))),
                  Expanded(child: Text(Clientes[index], textAlign: TextAlign.center, style: TextStyle(color:Colors.white)))
                ]),
              ),
            ),
          ),
          SizedBox(height: yMargin)
        ]
    );
  }

}

bool SonIgualesListSeg(List nFecha, List fechaCorte, String tipo) {
  int index;
  if (tipo == "mes") { index = 1; }
  else { index = 2; }
  if (nFecha[index] == fechaCorte[index]){return true;}
  else { return false; }
}

String fromTo(int i, int j, String text) {
  if (text.length >= j){
    String acc = "";
    for (int z=i; z<=j; z++){ acc += text[z]; }
    return acc;
  }
  else {
    return "";
  }
}

bool SonIgualesList(List nFecha, List fechaCorte) {
  bool rt = true;
  if (nFecha.length == fechaCorte.length){
    for (int w=0; w<nFecha.length; w++){
      if (nFecha[w] != fechaCorte[w]) { rt = false; }
    }
  }
  else { rt = false; }
  return rt;
}
