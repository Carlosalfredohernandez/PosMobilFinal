import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/proveedores.dart';
import 'package:posmobilfinal/src/pages/mantenedores/proveedores/crear/crear/mantenedores_proveedores_controlador.dart';

class MantenedoresProveedoresPage extends StatefulWidget {
  const MantenedoresProveedoresPage({super.key});

  @override
  State<MantenedoresProveedoresPage> createState() => _MantenedoresProveedoresPageState();
}

class _MantenedoresProveedoresPageState extends State<MantenedoresProveedoresPage> {
    String _busqueda = '';

  final MantenedoresProveedoresControlador controlador = Get.put(MantenedoresProveedoresControlador());
  late Future<List<Proveedor>> _proveedoresFuture;

  @override
  void initState() {
    super.initState();
    _refreshProveedores();
  }

  void _refreshProveedores() {
    setState(() {
      _proveedoresFuture = controlador.proveedorProvider.getProveedor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header degradado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: const Text(
                'MANTENCIÓN DE PROVEEDORES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar proveedor por nombre',
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Color(0xFFF0F4FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _busqueda = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            // Lista de proveedores en Card
            Expanded(
              child: FutureBuilder<List<Proveedor>>(
                future: _proveedoresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar proveedores'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay proveedores registrados'));
                  }
                  final proveedores = snapshot.data!;
                  final proveedoresFiltrados = _busqueda.isEmpty
                      ? proveedores
                      : proveedores.where((p) => (p.nombre ?? '').toLowerCase().contains(_busqueda)).toList();
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: proveedoresFiltrados.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: Text('No se encontraron proveedores con ese nombre')),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemCount: proveedoresFiltrados.length,
                            itemBuilder: (context, index) {
                              final proveedor = proveedoresFiltrados[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  proveedor.nombre ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(proveedor.email ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () {
                                        _mostrarDialogoEditarProveedor(context, proveedor);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Eliminar',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar eliminación'),
                                            content: Text('¿Estás seguro de que deseas eliminar el proveedor "${proveedor.nombre ?? ''}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  await controlador.eliminarProveedor(proveedor);
                                                  Navigator.of(context).pop();
                                                  _refreshProveedores();
                                                },
                                                child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoCrearProveedor(context);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Agregar proveedor',
      ),
    );
  }

  void _mostrarDialogoCrearProveedor(BuildContext context) {
    // Limpiar los campos antes de mostrar el diálogo
    controlador.nombreController.clear();
    controlador.telefonoController.clear();
    controlador.emailController.clear();
    controlador.direccionController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nuevo Proveedor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _campoTextoNombre(),
                  _campoTextoTelefono(),
                  _campoTextoEmail(),
                  _campoTextoDireccion(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await controlador.crearProveedor();
                      controlador.nombreController.clear();
                      controlador.telefonoController.clear();
                      controlador.emailController.clear();
                      controlador.direccionController.clear();
                      Navigator.of(context).pop();
                      _refreshProveedores();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('GUARDAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarProveedor(BuildContext context, Proveedor proveedor) {
    controlador.nombreController.text = proveedor.nombre ?? '';
    controlador.telefonoController.text = proveedor.telefono ?? '';
    controlador.emailController.text = proveedor.email ?? '';
    controlador.direccionController.text = proveedor.direccion ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Editar Proveedor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _campoTextoNombre(),
                  _campoTextoTelefono(),
                  _campoTextoEmail(),
                  _campoTextoDireccion(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await controlador.actualizarProveedor(proveedor);
                      Navigator.of(context).pop();
                      _refreshProveedores();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _campoTextoNombre() {
    return TextField(
      controller: controlador.nombreController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Nombre de Proveedor',
        prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoTextoTelefono() {
    return TextField(
      controller: controlador.telefonoController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Teléfono',
        prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoTextoEmail() {
    return TextField(
      controller: controlador.emailController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.alternate_email_outlined, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoTextoDireccion() {
    return TextField(
      controller: controlador.direccionController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Dirección',
        prefixIcon: const Icon(Icons.add, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
