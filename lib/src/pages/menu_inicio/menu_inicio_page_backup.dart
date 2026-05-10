import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posmobilfinal/src/models/navigation_bar.dart';
import 'package:posmobilfinal/src/models/response_api.dart';
import 'package:posmobilfinal/src/models/usuario.dart';
import 'package:posmobilfinal/src/providers/usuarios_empresa_provider.dart';
import 'package:posmobilfinal/src/models/usuario_empresa.dart';
import 'package:posmobilfinal/src/pages/ventas/ventas_page.dart';
import 'package:posmobilfinal/src/pages/mantenedores/usuarios/usuarios_list_page.dart';

// Usuario sesionUsuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});
Usuario? sesionUsuario;

class MenuInicioPage extends StatefulWidget {
  const MenuInicioPage({super.key});

  @override
  State<MenuInicioPage> createState() => _MenuInicioPageState();
}

class _MenuInicioPageState extends State<MenuInicioPage>
    with TickerProviderStateMixin {
  // Botón para acceder al mantenedor de usuarios
  Widget _buildUsuariosButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          final claveCorrecta = await _mostrarDialogoClave(context);
          if (claveCorrecta == true) {
            Get.to(() => const UsuariosListPage());
          }
        },
        icon: const Icon(Icons.people, color: Colors.white),
        label: const Text(
          'Mantenedor Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getSafeUserName() {
    final usuarioEmpresa = GetStorage().read('usuarioempresa');
    if (usuarioEmpresa is Map) {
      if (usuarioEmpresa['nombre_empresa'] != null) {
        return usuarioEmpresa['nombre_empresa'].toString();
      } else if (usuarioEmpresa['nombre_usuario'] != null) {
        return usuarioEmpresa['nombre_usuario'].toString();
      } else if (usuarioEmpresa['empresa'] != null) {
        return usuarioEmpresa['empresa'].toString();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hola, ${_getSafeUserName()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.indigo.shade700,
              Colors.purple.shade600,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWelcomeSection(),
                _buildLoginCard(context),
                _buildUsuariosButton(),
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  late AnimationController _fadeController;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
  }

  final UsuariosEmpresaProvider usuariosEmpresaProvider =
      UsuariosEmpresaProvider();
  bool _obscurePassword = true;
  TextEditingController rutController = TextEditingController();
  TextEditingController claveController = TextEditingController();
  bool _isLoading = false;

  void login() async {
    // ...existing code...
    // Solo login de usuario empresa: validar usuario/clave y navegar según rol
    String rut = rutController.text.trim();
    String clave = claveController.text.trim();

    if (!validador(clave, rut)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      ResponseApi responseApi = await usuariosEmpresaProvider.login(rut, clave);
      print('🟦 ResponseApi completo: ${responseApi.toJson()}');
      print('🟦 responseApi.data: ${responseApi.data}');
      // 👇 Print mejorado para mostrar el JSON recibido de forma clara
      if (responseApi.data != null) {
        if (responseApi.data is Map) {
          print('🟩 JSON recibido en login (formateado):');
          (responseApi.data as Map).forEach((k, v) {
            print('   $k: $v');
          });
        } else {
          print(
            '🟩 JSON recibido en login: ${responseApi.data.runtimeType} -> ${responseApi.data}',
          );
        }
      } else {
        print('🟥 responseApi.data es null');
      }
      if (responseApi.success == true) {
        dynamic data = responseApi.data;
        String? sessionToken;
        final userId = GetStorage().read('usuario')?['id']?.toString();
        UsuarioEmpresa? usuarioEmpresa;
        if (data is List) {
          // Si el backend retorna una lista, filtrar por id
          final lista = data.map<UsuarioEmpresa>((e) => UsuarioEmpresa.fromJson(e as Map<String, dynamic>)).toList();
          usuarioEmpresa = lista.firstWhereOrNull((u) => u.id == userId);
        } else if (data is Map) {
          sessionToken =
              data['session_token']?.toString() ??
              data['sessionToken']?.toString();
          print('🟦 sessionToken extraído: ' + sessionToken.toString());
          usuarioEmpresa = UsuarioEmpresa.fromJson(data as Map<String, dynamic>);
        } else {
          print('❗ data no es un Map ni List, es: \'${data.runtimeType}\'');
        }
        if (usuarioEmpresa != null) {
          usuarioEmpresa.sessionToken = sessionToken;
          GetStorage().write('usuarioempresa', usuarioEmpresa.toJson());
          // Guardar también el usuario para POS (con local_asignado)
          final usuarioSesion = Usuario(
            id: usuarioEmpresa.id,
            nombre: usuarioEmpresa.nombreUsuario,
            rut: usuarioEmpresa.rut,
            region: usuarioEmpresa.region,
            comuna: usuarioEmpresa.comuna,
            calle: usuarioEmpresa.calle,
            numero: usuarioEmpresa.numero,
            localOficina: usuarioEmpresa.localAsignado,
            telefono: usuarioEmpresa.telefono,
            clave: usuarioEmpresa.password,
            tipoContrato: usuarioEmpresa.tipoContrato,
            email: usuarioEmpresa.email,
            sessionToken: sessionToken,
            roles: [],
          );
          // No sobrescribir el usuario real en el storage:
          // GetStorage().write('usuario', usuarioSesion.toJson());
        }
        // No sobrescribir el usuario real en el storage:
        // GetStorage().write('usuario', usuarioSesion.toJson());
        // print('--- DATOS GUARDADOS EN GetStorage (usuario) ---');
        // print(usuarioSesion.toJson());
        // print('Campo localOficina guardado: [33m${usuarioSesion.localOficina}[0m');
        // print('Campo empresa guardado: [33m${usuarioEmpresa.empresa}[0m');
        // print("Valor de rol recibido: '[33m${usuarioEmpresa.rol}[0m' tipo: '[33m${usuarioEmpresa.rol.runtimeType}[0m'");
        // final rolStr = usuarioEmpresa.rol?.toString() ?? '';
        // final rolInt = int.tryParse(usuarioEmpresa.rol?.toString() ?? '');
        // if (rolInt == null) {
        //   print('❗ Error: rol no es un número válido. Valor recibido: [33m${usuarioEmpresa.rol}[0m');
        //   Get.snackbar(
        //     '❌ Error de datos',
        //     'El rol recibido no es válido: [33m${usuarioEmpresa.rol}[0m',
        //     backgroundColor: Colors.red.shade100,
        //     colorText: Colors.red.shade800,
        //     borderRadius: 12,
        //     margin: const EdgeInsets.all(16),
        //     snackPosition: SnackPosition.TOP,
        //   );
        //   return;
        // }
        // Navegación según el rol recibido
        final rolStr = usuarioEmpresa?.rol?.toString() ?? '';
        final rolInt = int.tryParse(rolStr);
        if (rolInt == 1) {
          Get.toNamed('/menugeneral');
        } else if (rolInt == 2) {
          Get.offAll(() => VentasPage());
        } else if (rolInt == 3) {
          Get.toNamed('/cliente_caja_antiguo');
        } else {
          Get.snackbar('Rol desconocido', 'No se reconoce el rol del usuario.');
        }
      } else {
        Get.snackbar(
          '❌ Error de Autenticación',
          responseApi.message ?? 'Credenciales incorrectas',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e, stack) {
      print('❗ Excepción en login usuario empresa: $e');
      print('❗ Stacktrace: $stack');
      Get.snackbar(
        '⚠️ Error de Conexión',
        'No se pudo conectar con el servidor. Detalle: $e',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void irAHomePage() {
    // Navegar a la nueva página de ventas tras login exitoso
    Get.offAll(() => VentasPage());
  }

  bool validador(String clave, String rut) {
    if (rut.isEmpty) {
      Get.snackbar(
        '📝 Campo requerido',
        'Debes ingresar el RUT de tu empresa o usuario',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade800,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (clave.isEmpty) {
      Get.snackbar(
        '🔐 Campo requerido',
        'Debes ingresar tu clave',
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade800,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  Future<bool> _mostrarDialogoClave(BuildContext context) async {
    TextEditingController claveController = TextEditingController();
    bool claveCorrecta = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clave requerida'),
          content: TextField(
            controller: claveController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Ingrese la clave de acceso',
            ),
            autofocus: true,
            onSubmitted: (_) {
              if (claveController.text == 'cahi1961') {
                claveCorrecta = true;
                Navigator.of(context).pop();
              } else {
                Get.snackbar(
                  'Clave incorrecta',
                  'La clave ingresada no es válida.',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(16),
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (claveController.text == 'cahi1961') {
                  claveCorrecta = true;
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    'Clave incorrecta',
                    'La clave ingresada no es válida.',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade800,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return claveCorrecta;
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        // Solo texto, icono de maletín eliminado
        Text(
          'Autenticación de Usuario',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: rutController,
              label: 'RUT o Usuario',
              hint: 'Ingresa tu RUT ',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: claveController,
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 32),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? _obscurePassword : false,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: null,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue.shade600, size: 20),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ACCEDER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        Get.offNamed('/login');
      },
      icon: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
        size: 18,
      ),
      label: const Text(
        'Volver al Login Principal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }
}
