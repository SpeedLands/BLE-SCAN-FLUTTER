import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{

  FlutterBluePlus flutterBlue = FlutterBluePlus();

  Future scanDevices() async{
    var blePermission = await Permission.bluetoothScan.status;
    if(blePermission.isDenied){
      if(await Permission.bluetoothScan.request().isGranted){
        if(await Permission.bluetoothConnect.request().isGranted){
          FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

          FlutterBluePlus.stopScan();

          FlutterBluePlus.scanResults.listen((results) {
  // Procesa los resultados del escaneo aquí
  print("Dispositivos encontrados: $results");
});

        }
      }
    }else{
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      FlutterBluePlus.stopScan();
      FlutterBluePlus.scanResults.listen((results) {
  // Procesa los resultados del escaneo aquí
  print("Dispositivos encontrados: $results");
});

    }
  }
 Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}