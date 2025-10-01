import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmobil/src/models/producto.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:posmobil/src/pages/mantenedores/productos/mantenedores_productos_controller.dart';

class MantenedoresProductosPage extends StatefulWidget {
  const MantenedoresProductosPage({super.key});

  @override
  State<MantenedoresProductosPage> createState() => _MantenedoresProductosPageState();
}

class _MantenedoresProductosPageState extends State<MantenedoresProductosPage> {
  MantenedoresProductosController controlador = Get.put(MantenedoresProductosController());
  String? categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      bottomNavigationBar: Row(
        children: [
          Expanded(child: _botonCrear()),
          Spacer(),
          Expanded(child: _botonCancelar()),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 15),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: _textFieldSearch(context)),
                        iconScan(context),
                      ],
                    ),
                  ),
                  _comboCategorias(),
                  SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: controlador.filter.length,
        itemBuilder: (_, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClienteProductosEditarPage(producto: controlador.filter[index]))
              );
            },
            title: Text(controlador.filter[index].codigoBarra.toString()),
            subtitle: Text('${controlador.filter[index].nombreProducto.toString()}\n${controlador.filter[index].descripcionProducto.toString()}'),
            leading: Icon(Icons.category),
          );
        },
      ),
    ));
  }

  Widget _comboCategorias() {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: categoriaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Buscar por Categoría',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('Todas las categorías'),
          ),
          ...controlador.categorias.map((cat) => DropdownMenuItem(
            value: cat.id,
            child: Text(cat.nombreCategoria ?? ''),
          )),
        ],
        onChanged: (value) {
          setState(() {
            categoriaSeleccionada = value;
            if (value == null) {
              controlador.filter = controlador.productos;
            } else {
              controlador.updateProductos(value);
            }
          });
        },
      ),
    );
  }

  Widget _botonCancelar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: ElevatedButton(
        onPressed: () => controlador.volver(),
        child: const Text('CANCELAR'),
      ),
    );
  }

  Widget _botonCrear() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: ElevatedButton(
          onPressed: () => controlador.goToProduct(),
          child: const Text('Crear Producto'),
        ),
      ),
    );
  }

  Widget iconScan(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 30),
      child: IconButton(
        onPressed: () async {
          final barcode = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => _BarcodeScannerView()),
          );
          if (barcode != null && barcode.isNotEmpty) {
            setState(() {
              controlador.onChangeText(barcode);
            });
          }
        },
        icon: const Icon(Icons.camera_enhance_outlined),
      ),
    );
  }

  Widget _textFieldSearch(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: TextField(
          onChanged: (texto) {
            setState(() {
              controlador.onChangeText(texto);
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: Icon(Icons.search, color: Colors.white),
            hintStyle: TextStyle(fontSize: 17, color: Colors.white),
            fillColor: Colors.blue,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue)
            ),
            contentPadding: EdgeInsets.all(15)
          ),
        ),
      ),
    );
  }
}

// Widget para escanear código de barras con mobile_scanner
class _BarcodeScannerView extends StatefulWidget {
  @override
  State<_BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<_BarcodeScannerView> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null && code.isNotEmpty) {
            _scanned = true;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}