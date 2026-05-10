import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobilfinal/src/models/local.dart';
import 'package:posmobilfinal/src/models/producto.dart';
import 'package:posmobilfinal/src/models/proveedores.dart';
import 'package:posmobilfinal/src/pages/inventarios/create/inventarios_create_controller.dart';
import 'package:posmobilfinal/src/pages/inventarios/search/inventario_search_page.dart';

class InventarioCreatePage extends StatefulWidget {
  const InventarioCreatePage({super.key});

  @override
  State<InventarioCreatePage> createState() => _InventarioCreatePageState();
}

class _InventarioCreatePageState extends State<InventarioCreatePage> {
  InventariosCreateController controlador = Get.put(InventariosCreateController());

  Producto? productoSeleccionado;
  final TextEditingController cantidadController = TextEditingController(text: '1');

  @override
  Future<DateTime?> getDatePickerWidget() {
    return showDatePicker(
        context: context,
        initialDate: controlador.currentSelectedDate,
        lastDate: DateTime.now(),
        firstDate: DateTime(2022),
        builder: (context, child){
          return Theme(data: ThemeData.dark(), child: child!);
        }
    );
  }

  void searchDateBegin() async {
    controlador.fecha = (await getDatePickerWidget())!;
    setState(() {
      controlador.currentSelectedDate = controlador.fecha;
    });
  }

  Future<void> _agregarProductoPorCodigo(String codigo) async {
    final producto = await controlador.getProductByCodigoBarra(codigo);
    if (producto != null) {
      setState(() {
        productoSeleccionado = producto;
        cantidadController.text = '1';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado')),
      );
    }
  }

 // ...código existente...

  Future<void> _buscarProducto(BuildContext context) async {
    final producto = await showSearch<Producto>(
      context: context,
      delegate: InventarioSearchPage(controlador.productos),
    );
    if (producto != null) {
      setState(() {
        // Solo selecciona el producto y espera que el usuario ingrese cantidad y presione "Agregar"
        productoSeleccionado = producto;
        cantidadController.text = '1';
      });
      // No lo agregues directamente a la lista aquí
    }
  }

// ...código existente...

  void _agregarProductoSeleccionado() {
    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un producto')),
      );
      return;
    }
    final cantidad = int.tryParse(cantidadController.text) ?? 1;
    final productoSimple = Producto(
      nombreProducto: productoSeleccionado!.nombreProducto,
      cantidad: cantidad,
      codigoBarra: productoSeleccionado!.codigoBarra,
      id: productoSeleccionado!.id,
      precioVenta: productoSeleccionado!.precioVenta,
      // Puedes agregar aquí otros campos si el backend los requiere
    );
    controlador.addOrUpdateSelectedProduct(productoSimple);
    setState(() {
      productoSeleccionado = null;
      cantidadController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: _totalToPay(context),
        ),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: _campoCodigoBarra()),
            _iconSearch(context),
          ],
        ),
        actions: [
          _iconScan(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Fecha:',style: TextStyle(color: Colors.black,)),
                      TextButton(
                        onPressed: searchDateBegin,
                        child: Text('${controlador.fecha}'.substring(0,10),style: const TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                  _dropDownLocales(controlador.locales),
                  _dropDownProveedores(controlador.proveedores),
                  _campoDocumento(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Text(
                            productoSeleccionado?.nombreProducto ?? 'Seleccione un producto',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: cantidadController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cant.',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: productoSeleccionado != null ? _agregarProductoSeleccionado : null,
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1,thickness: 1),
            Container(
              margin: const EdgeInsets.only(top: 1),
              height: MediaQuery.of(context).size.height * 0.55,
              child: controlador.selectedProducts.isNotEmpty
                  ? ListView(
                      children: controlador.selectedProducts.map((Producto product) {
                        return _cardProduct(product);
                      }).toList(),
                    )
                  : const Center(child: Text('No hay ningun producto agregado aun')),
            )
          ],
        ),
      ),
    );
  }

  Widget _totalToPay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(height: 1, color: Colors.grey[300]),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                    onPressed: () => controlador.createInventario(onSuccess: () {
                      setState(() {
                        productoSeleccionado = null;
                        cantidadController.text = '1';
                      });
                    }),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15)
                    ),
                    child: const Text(
                      'GRABAR TRANSACCION',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconScan() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: () => controlador.scanBarcodeNormal(context, onProductAdded: () {
          setState(() {});
        }),
        icon: const Icon(
          Icons.qr_code_scanner,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _iconSearch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: IconButton(
        onPressed: () => _buscarProducto(context),
        icon: const Icon(
          Icons.search,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }

  // Este input solo se usa en la fila de arriba, no en la lista
  Widget _productoCantidad(Producto producto, BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _cardProduct(Producto product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              product.nombreProducto ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Cant: ${product.cantidad ?? 1}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              setState(() {
                controlador.deleteItem(product);
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoCodigoBarra() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 5),
      child: Column(
        children: [
          SizedBox(
            width: 180.0,
            height: 40.0,
            child: TextField(
              controller: controlador.codigoBarraController,
              keyboardType: TextInputType.text,
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  await _agregarProductoPorCodigo(value.trim());
                  controlador.codigoBarraController.clear();
                }
              },
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Codigo de barra',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final value = controlador.codigoBarraController.text.trim();
                      if (value.isNotEmpty) {
                        await _agregarProductoPorCodigo(value);
                        controlador.codigoBarraController.clear();
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                  hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Colors.grey
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Colors.grey
                      )
                  ),
                  contentPadding: const EdgeInsets.all(7)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoDocumento() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.1,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: controlador.guiaController,
        keyboardType: TextInputType.number,
        obscureText: false,
        decoration: const InputDecoration(
          hintText: 'Nº Documento',
        ),
      ),
    );
  }

  Widget _dropDownLocales(List<Local> locales) {
    return Obx(() => SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.1,
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
        ),
        elevation: 3,
        isExpanded: true,
        hint: const Text(
          'Locales',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: _dropDownItems(locales),
        value: controlador.localAsignado.value == '' ? null : controlador.localAsignado.value,
        onChanged: (option) {
          controlador.localAsignado.value = option.toString();
        },
      ),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItems(List<Local> locales) {
    List<DropdownMenuItem<String>> list = [];
    for (var local in locales) {
      list.add(DropdownMenuItem(
        value: local.id!,
        child: Text('${local.nombreLocal}'),
      ));
    }
    return list;
  }

  Widget _dropDownProveedores(List<Proveedor> proveedores) {
    return Obx(() => SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.05,
      child: DropdownButton(
        underline: Container(
          alignment: Alignment.centerRight,
        ),
        elevation: 3,
        isExpanded: true,
        hint: const Text(
          'Proveedores',
          style: TextStyle(
              fontSize: 15
          ),
        ),
        items: dropDownItems(proveedores),
        value: controlador.prove.value == '' ? null : controlador.prove.value,
        onChanged: (option) {
          controlador.prove.value = option.toString();
        },
      ),
    ));
  }

  List<DropdownMenuItem<String>> dropDownItems(List<Proveedor> proveedores) {
    List<DropdownMenuItem<String>> list = [];
    for (var proveedor in proveedores) {
      list.add(DropdownMenuItem(
        value: proveedor.id!,
        child: Text(proveedor.nombre!),
      ));
    }
    return list;
  }
}