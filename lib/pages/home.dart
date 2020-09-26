import 'dart:io';
import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
  //   Band(id: "1", name: "Metálica", votes: 5),
  //   Band(id: "2", name: "Queen", votes: 4),
  //   Band(id: "3", name: "Héroes del Silencio", votes: 6),
  //   Band(id: "4", name: "Pinpinela", votes: 2),
  //   Band(id: "5", name: "Sandro y los del fuego", votes: 5),
  ];

  @override
  void initState() { 
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    //print(payload);
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();
    setState(() {
      
    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[300])
            : Icon(Icons.offline_bolt, color: Colors.red)
          )
        ],
        title: Text(
        'BandNames',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: _showGraph(),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if( !snapshot.hasData ){
                return Center(child: CircularProgressIndicator());
              } else {
                return snapshot.data;
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTitle(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: Icon(Icons.add),
      ),
   );
  }

  Widget _bandTitle(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direcion: $direction');
        print('id: ${band.id}');
        socketService.socket.emit('delete-band',{"id": band.id});
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
          //print(band.id);
          socketService.socket.emit("vote-band", {'id': band.id});
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
      // this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {
        
      // });
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band',{'name': name});
    }
    Navigator.pop(context);
  }

  Future<Widget> _showGraph() async {
    // Map<String, double> dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };
    List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];
    Map<String, double> dataMap = {};
    if( bands.isNotEmpty ){
      await Future.forEach(bands, ( band )=> dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));
      return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          centerText: "VOTES",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
          ),
        )
      );
    } else {
      return null;
    }
  }


}