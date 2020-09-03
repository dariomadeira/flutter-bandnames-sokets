import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: "1", name: "Metálica", votes: 5),
    Band(id: "2", name: "Queen", votes: 4),
    Band(id: "3", name: "Héroes del Silencio", votes: 6),
    Band(id: "4", name: "Pinpinela", votes: 2),
    Band(id: "5", name: "Sandro y los del fuego", votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
        'BandNames',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTitle(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: Icon(Icons.add),
      ),
   );
  }

  Widget _bandTitle(Band band) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direcion: $direction');
        print('direcion: ${band.id}');
        // TODO borrar en el server
      },
      background: Container(
        padding: EdgeInsets.only(left: 10),
        color: Colors.red[100],
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ),
      ),
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            band.name.substring(0,2),
          ),
        ),
        title: Text(
          band.name,
        ),
        trailing: Text(
        '${band.votes}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.blue[400],
          ),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  void addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'New band name',
            ),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                child: Text(
                  'Add',
                ),
                onPressed: () => addBandToList(textController.text),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context, 
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
              'New band name',
            ),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
      );
    }
  }

  void addBandToList (String name) {
    if (name.length > 1) {
      this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {
        
      });
    }
    Navigator.pop(context);
  }

}