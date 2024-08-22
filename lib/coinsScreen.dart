// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CoinsScreen extends StatefulWidget {
  @override
  _CoinsScreenState createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  WebSocketChannel? channel;
  List<Map<String, dynamic>> allCoinData = [];

  String searchText = "";

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://prereg.ex.api.ampiy.com/prices'),
    );

    channel?.sink.add(jsonEncode({
      "method": "SUBSCRIBE",
      "params": ["all@ticker"],
      "cid": 1,
    }));

    channel?.stream.listen((message) {
      final data = jsonDecode(message);

      if (data['stream'] == 'all@fpTckr') {
        setState(() {
          allCoinData = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: allCoinData.isNotEmpty
              ? ListView.builder(
                  itemCount: allCoinData.length,
                  itemBuilder: (context, index) {
                    final coin = allCoinData[index];

                    if (!coin['s'].toLowerCase().contains(searchText)) {
                      return SizedBox.shrink();
                    }
                    String symbol = coin['s'].replaceAll("INR", "");
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: _getIconForSymbol(coin['s']),
                      ),
                      title: Text(symbol),
                      subtitle: Text(symbol.toLowerCase() + "coin"),
                      trailing: SizedBox(
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                '₹ ${coin['c']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Container(
                                width: 98,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(width: 2)),
                                child: Row(
                                  children: [
                                    Text(
                                      '${double.parse(coin['p']) >= 0 ? '▲' : '▼'}',
                                      style: TextStyle(
                                        color: double.parse(coin['p']) >= 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '${double.parse(coin['p']).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: double.parse(coin['p']) >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Icon _getIconForSymbol(String symbol) {
    switch (symbol) {
      case "BTCINR":
        return Icon(Icons.currency_bitcoin, color: Colors.orange);
      case "ETHINR":
        return Icon(Icons.currency_exchange, color: Colors.blue);
      default:
        return Icon(Icons.currency_lira, color: Colors.green);
    }
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          'Placeholder Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
