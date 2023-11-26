import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  Function get emit => _socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    _socket = IO.io(
        'http://10.0.2.2:3001',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.onReconnect((_) {
      print('reconnected');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // Eventos
    // _socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje: ');
    //   print('nombre: ' + payload['nombre']);
    //   print('mensaje: ' + payload['mensaje']);
    //   if (payload.containsKey('mensaje2')) {
    //     print('mensaje2: ' + payload['mensaje2']);
    //   }
    // });
  }
}
