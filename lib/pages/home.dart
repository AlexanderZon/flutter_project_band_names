import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:project_band_names/models/band.dart';
import 'package:project_band_names/services/socket_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
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
        title:
            const Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: ServerStatusWidget(status: socketService.serverStatus))
        ],
      ),
      body: Column(
        children: [
          if (bands.length > 0) _showGraphs(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>
                  _bandTitle(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTitle(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) =>
          socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.only(left: 8.0),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        onTap: () => socketService.emit('vote-band', {'id': band.id}),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            band.name.substring(0, 2),
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New Band Name'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: () => addBandToList(textController.text),
              elevation: 5,
              textColor: Colors.blue,
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('New Band Name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => addBandToList(textController.text),
              isDefaultAction: true,
              child: const Text('Add'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              isDestructiveAction: true,
              child: const Text('Dismiss'),
            )
          ],
        ),
      );
    }
  }

  addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  _showGraphs() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap),
    );
  }
}

class ServerStatusWidget extends StatelessWidget {
  final ServerStatus status;
  const ServerStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == ServerStatus.Online) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else if (status == ServerStatus.Connecting) {
      return const Icon(
        Icons.check_circle,
        color: Colors.amber,
      );
    } else {
      return const Icon(
        Icons.offline_bolt,
        color: Colors.red,
      );
    }
  }
}
