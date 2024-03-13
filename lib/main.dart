import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';

import 'package:http/http.dart' as http;

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundImage(),
          LoginForm(),
        ],
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/a.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            width: double.infinity, // Ancho igual al ancho máximo disponible
            decoration: BoxDecoration(
              color: Colors.white, // Color de fondo del formulario
              borderRadius: BorderRadius.circular(10), // Bordes redondeados del formulario
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Sombra del formulario
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Cambia la posición de la sombra
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Logo(),
                  SizedBox(height: 20,),
                  Text('SLTRECBA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Color.fromRGBO(81, 171, 216, 1))),
                  Text('Bienvenido de vuelta', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  EmailTextField(),
                  SizedBox(height: 10),
                  PasswordTextField(),
                  SizedBox(height: 40),
                  LoginButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/l.png', width: 80,),
      ],
    );
  }
}

class EmailTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(62, 255, 255, 255), // Color de fondo del contenedor
        ),
        child: TextField(
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(Icons.person),
            contentPadding: EdgeInsets.all(10),
            hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(62, 255, 255, 255), // Color de fondo del contenedor
        ),
        child: TextField(
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.security),
            contentPadding: EdgeInsets.all(10),
            hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      ),
    );
  }
}


class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aquí se navega a la otra actividad
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlutterBlueApp()),
        );
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(81, 171, 216, 1),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}

//
// Este widget muestra BluetoothOffScreen o
// ScanScreen según el estado del adaptador
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> { 
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// Este observador escucha si Bluetooth está apagado y descarta la pantalla del dispositivo.
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Comience a escuchar los cambios de estado de Bluetooth cuando se presiona una nueva ruta
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Muestra la ruta actual si Bluetooth está desactivado
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancelar la suscripción cuando aparezca la ruta.
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}