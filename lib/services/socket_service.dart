import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  // GET
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  // contructor
  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    this._socket = IO.io('http://192.168.0.50:3000', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'foo': 'bar'},
      'autoConnect': true
    });
    this._socket.on('connect', (_) {
     print('Conectado');
     this._serverStatus = ServerStatus.Online;
     notifyListeners();
    });
    this._socket.on('disconnect', (_) {
      print('Desconectado');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });


    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje:');
    //   print('nombre: ' + payload["nombre"]);
    //   print('apellido: ' + payload["apellido"]);
    //   print(payload.containsKey("mensaje2") ? "valor3 " + payload["mensaje2"] : "no hay ese dato");
    // });


  }

}