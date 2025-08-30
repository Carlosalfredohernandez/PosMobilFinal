import 'package:flutter/material.dart';
import 'package:posmobil/src/pages/cliente/local/create/cliente_local_create_page.dart';


class MantenedoresLocalPage extends StatelessWidget {
  const MantenedoresLocalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClienteLocalCreatePage(),
    );
  }
}
