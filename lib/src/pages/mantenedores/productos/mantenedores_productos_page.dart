import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/pages/cliente/productos/editar/cliente_productos_editar_page.dart';
import 'package:posmobil/src/pages/mantenedores/productos/mantenedores_productos_controller.dart';
class MantenedoresProductosPage extends StatefulWidget {
  const MantenedoresProductosPage({super.key});


  @override
  State<MantenedoresProductosPage> createState() => _MantenedoresProductosPageState();
}

class _MantenedoresProductosPageState extends State<MantenedoresProductosPage> {

  MantenedoresProductosController controlador = Get.put(MantenedoresProductosController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        bottomNavigationBar: Row(
          children: [
            _botonCrear(),
            Spacer(),
            _botonCancelar()
          ],
        ),
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              margin: EdgeInsets.only(top: 15),
              alignment: Alignment.topCenter,
              child: Wrap(
                direction: Axis.horizontal,
                children: [
                  _textFieldSearch(context),
                  iconScan(context)
                ],
              ),
            ),
          ),
        ),
      drawer: Drawer(
        child: ListView.builder(
            itemCount: controlador.categorias.length + 1,
            itemBuilder: (context, index) {
              return index == controlador.categorias.length
                  ? ListTile(
                title: Text(
                    'Todos',
                ),
                onTap: () {
                  setState(() {
                    controlador.filter = controlador.productos;
                  });
                },
              )
                  : ListTile(
                title: Text(
                    '${controlador.categorias[index].nombreCategoria}'
                ),
                onTap: () {
                  setState(() {
                    controlador.updateProductos(controlador.categorias[index].id);
                  });
                  // controlador.idCategory = controlador.categorias[index].id!;
                },
              );
            }
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

  Widget _botonCancelar(){
    return Container(
      //width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: ElevatedButton(
          onPressed: () => controlador.volver(),
          child: const Text(
              'CANCELAR'
          )
      ),
    );
  }
  Widget _botonCrear(){
    return SafeArea(
      child: Container(
        //width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: ElevatedButton(
            onPressed: () => controlador.goToProduct(),
            child: const Text(
                'Crear Producto'
            )
        ),
      ),
    );
  }
  Widget iconScan(BuildContext context){
    return Container(
      margin: EdgeInsets.only(left: 10,top: 30),
      child: IconButton(
        onPressed: () {
          controlador.scanBarcodeNormal(context);
        },
        icon: const Icon(Icons.camera_enhance_outlined),
      ),
    );
  }

  Widget _textFieldSearch(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: TextField(
          onChanged: (texto) {
            setState(() {
              controlador.onChangeText(texto);
            });
          },
          decoration: InputDecoration(
              hintText: 'Buscar',
              suffixIcon: Icon(Icons.search, color: Colors.white),
              hintStyle: TextStyle(
                  fontSize: 17,
                  color: Colors.white
              ),
              fillColor: Colors.blue,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.white
                  )
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Colors.blue
                  )
              ),
              contentPadding: EdgeInsets.all(15)
          ),
        ),
      ),
    );
  }

}

