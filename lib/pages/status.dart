import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    void sendData() {
      socketService.socket.emit('emitir-mensaje', {'nombre': "Darío", 'apellido': 'Madeira'});
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
            'Server status: ${socketService.serverStatus}',
            ),
          ],
        )
     ),
     floatingActionButton: FloatingActionButton(
       elevation: 1,
        onPressed: () => sendData(),
        child: Icon(Icons.send),
    ),
   );
  }
}