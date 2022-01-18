import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class fuenteVentasPage extends StatefulWidget {
  @override
  _fuenteVentasPage createState() => _fuenteVentasPage();
}

class _fuenteVentasPage extends State<fuenteVentasPage> {

  final databaseReference = FirebaseDatabase.instance.reference();

  List Servicios = [];
  List NombresServicios = [];
  List ServiciosContador = [];

  List Sucursales = [];
  List ContadorSucursales = [];

  List Trabajadores = [];
  List TrabajadoresContador = [];

  late Map<String, double> SERVICIOS_dataMap = { "Sin datos": 0.0 };
  late Map<String, double> SUCURSALES_dataMap = { "Sin datos": 0.0 };
  late Map<String, double> TRABAJADORES_dataMap = { "Sin datos": 0.0 };

  Future<String> readData (){

    databaseReference.child("Servicios").once().then((DataSnapshot snapshot) {
      int long = int.parse(snapshot.value["nextIndex"].toString());
      for (int t=0; t<long; t++) { NombresServicios.add (snapshot.value[t.toString()]["Nombre"].toString()); }
    });

    databaseReference.child("Cortes").once().then((DataSnapshot snapshot) {
      SERVICIOS_dataMap = {}; SUCURSALES_dataMap = {}; TRABAJADORES_dataMap = {};
      int nCortes = snapshot.value.length-1;
      for (int n=0; n<nCortes; n++){
        var corte = snapshot.value[n.toString()];

        // OBTENER DATOS PARA SERVICIOS MAP
        int nServ = int.parse(corte["nServ"].toString());
        if (nServ > 1){
          for (int q=0; q<nServ; q++){
            String servicio = corte["Servicio"][q].toString();
            if (!Servicios.contains(servicio)){ Servicios.add(servicio); ServiciosContador.add(1); }
            else { ServiciosContador[Servicios.indexOf(servicio)]++; }
          }
        }
        else {
          String servicio = corte["Servicio"].toString();
          if (!Servicios.contains(servicio)){ Servicios.add(servicio); ServiciosContador.add(0); }
          else { ServiciosContador[Servicios.indexOf(servicio)] += 1; }
        }

        // OBTENER DATOS PARA SUCURSALES MAP
        String corteSucursal = corte["Sucursal"].toString();
        if (Sucursales.contains(corteSucursal)) { ContadorSucursales[Sucursales.indexOf(corteSucursal)] += 1; }
        else { Sucursales.add(corteSucursal); ContadorSucursales.add(1); }

        // OBTENER DATOS PARA TRABAJADORES MAP
        String trabajador = corte["Trabajador"].toString();
        if (Trabajadores.contains(trabajador)){ TrabajadoresContador[Trabajadores.indexOf(trabajador)] += 1; }
        else { Trabajadores.add(trabajador); TrabajadoresContador.add(1); }
      }
    });

    // Crear ServiciosMap
    for (int u=0; u<Servicios.length; u++){
      String nombreServicio = NombresServicios[int.parse(Servicios[u])];
      double val = double.parse(ServiciosContador[u].toString());
      SERVICIOS_dataMap.addAll({nombreServicio: val});
    }

    // Crear SucursalesMap
    for (int w=0; w<Sucursales.length; w++){
      String sucursal = Sucursales[w];
      double val = double.parse(ContadorSucursales[w].toString());
      SUCURSALES_dataMap.addAll({sucursal:val});
    }

    // Crear TrabajadoresMap
    for (int y=0; y<Trabajadores.length; y++){
      String trabajador = Trabajadores[y];
      double val = double.parse(TrabajadoresContador[y].toString());
      TRABAJADORES_dataMap.addAll({trabajador:val});
    }

    return Future.value("");
  }

  @override
  Widget build(BuildContext context) {

    final double scrWidth = MediaQuery.of(context).size.width;
    final double scrHeight = MediaQuery.of(context).size.height;

    final double topMargin = scrHeight * 0.011;
    final double midMargin = 0.035 * scrHeight; // 30
    final double mid2Margin = 0.047 * scrHeight; // 40
    final double mid3Margin = 0.054 * scrHeight; // 40

    return FutureBuilder<String>(
    future: readData(), // function where you call your api
    builder: (BuildContext context,
    AsyncSnapshot<String> snapshot) { // AsyncSnapshot<Your object type>
    return Scaffold(
      appBar: AppBar(title: Text('Fuente de ventas')),
      body:
      Column(
        children: [
          SizedBox(height:topMargin),
          RaisedButton (
            onPressed: () {
              setState(()=>{
              });
            },
            child: Text("Recargar")
          ),
          SizedBox(height:topMargin),
          Text("Fuente de Ventas", style: GoogleFonts.mcLaren(fontSize: 30)),
          SizedBox(height:midMargin),
          PieChart(
            dataMap: SUCURSALES_dataMap,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "Sucursal",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
          SizedBox(height:mid2Margin),
          PieChart(
            dataMap: SERVICIOS_dataMap,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "Servicio",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
          SizedBox(height:mid3Margin),
          PieChart(
            dataMap: TRABAJADORES_dataMap,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 3.2,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "Trabajadores",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
        ],
      ),
    );
    });
  }
}