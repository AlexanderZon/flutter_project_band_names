import 'package:flutter/material.dart';
import 'package:project_band_names/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server Status: ${socketService.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TAREA:
          // emitir: emitir-mensaje
          // { nombre: 'Flutter', mensaje: 'Hola desde Flutter' }
          socketService.emit("emitir-mensaje",
              {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'});
        },
        child: Icon(Icons.message),
      ),
    );
  }
}
