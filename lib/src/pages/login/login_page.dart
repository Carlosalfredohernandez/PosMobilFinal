import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:posmobilfinal/src/pages/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController controlador;
  bool _isAutocompletadoDetected = false;
  DateTime? _lastInputTime;

  @override
  void initState() {
    super.initState();
    controlador = Get.put(LoginController());
    controlador.rutController.text = '';
    controlador.passwordController.text = '';
    
    // 🔍 DEBUGGING: Rastrear cambios en los campos con lógica inteligente
    controlador.rutController.addListener(() {
      String currentValue = controlador.rutController.text;
      DateTime now = DateTime.now();
      
      print('🔍 RUT CAMPO CAMBIADO: "$currentValue"');
      
      // Solo actuar si es el patrón exacto de autocompletado Y cambió muy rápido
      if (currentValue == '00.000.000-0') {
        // Verificar si el cambio fue muy rápido (indicativo de autocompletado)
        if (_lastInputTime != null && now.difference(_lastInputTime!).inMilliseconds < 100) {
          print('🚨 DETECTADO AUTOCOMPLETADO AUTOMÁTICO (cambio muy rápido)');
          _isAutocompletadoDetected = true;
          
          Future.delayed(Duration(milliseconds: 200), () {
            if (_isAutocompletadoDetected) {
              controlador.rutController.clear();
              controlador.passwordController.clear();
              print('✅ Campos limpiados por autocompletado automático');
              _isAutocompletadoDetected = false;
            }
          });
        } else {
          print('ℹ️ RUT 00.000.000-0 ingresado manualmente (OK)');
        }
      }
      
      _lastInputTime = now;
    });
    
    controlador.passwordController.addListener(() {
      String currentValue = controlador.passwordController.text;
      print('🔍 PASSWORD CAMPO CAMBIADO: "$currentValue"');
      
      // Solo limpiar si detectamos autocompletado Y ambos campos tienen los valores sospechosos
      if (currentValue == '1234' && 
          controlador.rutController.text == '00.000.000-0' && 
          _isAutocompletadoDetected) {
        print('🚨 DETECTADO AUTOCOMPLETADO COMPLETO - Limpiando campos...');
        Future.delayed(Duration(milliseconds: 200), () {
          controlador.rutController.clear();
          controlador.passwordController.clear();
          print('✅ Autocompletado malicioso limpiado');
          _isAutocompletadoDetected = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: _textoPoweredby()
      ),
      body: AutofillGroup(
        child: Stack(
          children: [
            _imagenPortadaFondo(),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: [
                      _cajaFormulario(context),
                      SizedBox(height: 30),
                      _textoNombreApp(),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenPortadaFondo() {
    return SizedBox.expand(
      child: Image.asset(
        //'android/assets/img/cashier2_118071.png',
        'android/assets/img/Imagen_portada.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _cajaFormulario(BuildContext context){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blueGrey,
            blurRadius:  15,
            offset: Offset(0, 0.75)
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _textoIngresaInformacion(),
          _campoTextoRut(),
          _campoTextoClave(),
          _botonAcceder(),
          _botonSalir(),
        ],
      ),
    );
  }

  Widget _textoIngresaInformacion(){
    return Container(
      margin: const EdgeInsets.only(top:30, bottom:17),
      child: const Text(
        'INGRESA INFORMACION EMPRESA',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _campoTextoRut() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        key: const Key('rut_field_unique_key_v2'),
        controller: controlador.rutController,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 16),
        // 🚫 DESHABILITAR COMPLETAMENTE EL AUTOCOMPLETADO
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const <String>[],
        autofocus: false,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(
          hintText: 'Rut',
          prefixIcon: Icon(Icons.account_box_outlined),
        ),
      ),
    );
  }

  Widget _campoTextoClave() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      child: TextField(
        key: const Key('password_field_unique_key_v2'),
        controller: controlador.passwordController,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 16),
        obscureText: true,
        // 🚫 DESHABILITAR COMPLETAMENTE EL AUTOCOMPLETADO
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const <String>[],
        autofocus: false,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(
          hintText: 'Contraseña',
          prefixIcon: Icon(Icons.lock_outline),
        ),
      ),
    );
  }

  Widget _botonAcceder(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.login(),
          child: const Text(
            'ACCEDER'
          )
      ),
    );
  }

  Widget _botonSalir(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Mostrar diálogo de confirmación
            Get.dialog(
              AlertDialog(
                title: const Text('Salir de la aplicación'),
                content: const Text('¿Estás seguro de que quieres cerrar la aplicación?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Cerrar la aplicación de manera segura para Windows
                      if (Platform.isWindows) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                    child: const Text('Salir', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          child: const Text(
            'SALIR DE LA APP'
          )
      ),
    );
  }

  Widget _textoNombreApp(){
    return const Text(
      'PUNTO DE VENTA',
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
    );
  }

  Widget _textoPoweredby(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Powered by',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12
          ),
        ),
        Text(
          'Tecnoalsa',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}