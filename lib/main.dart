import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'model/Ticker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'BTC Ticker - Coinbase WebSocket Flutter Demo';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('wss://ws-feed.pro.coinbase.com'));

  final _subscribe =
      '{"type": "subscribe", "channels": [{"name": "ticker","product_ids": ["BTC-USD"]}]}';

  final _unsubscribe = '{"type": "unsubscribe","channels": ["ticker"]}';
  var _subscribed = false;

  Ticker? ticker;

  _MyHomePageState() {
    _channel.stream.listen((message) {
      debugPrint('${message.runtimeType} : $message');
      if (message.isNotEmpty) {
        var parsedJson = json.decode(message);
        String type = parsedJson['type'];
        if (type == 'ticker') {
          setState(() => ticker = Ticker.fromJson(parsedJson));
        } else if (type == 'subscriptions') {
          setState(() => _subscribed =
              Subscriptions.fromJson(parsedJson).channels.isNotEmpty);
        }
      }
    });

    _channel.sink.add(_subscribe);
  }

  void subscribe() {
    if (_subscribed) {
      _channel.sink.add(_unsubscribe);
    } else {
      _channel.sink.add(_subscribe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'BTC-USD from Coinbase',
              style: Theme.of(context).textTheme.caption,
            ),
            Text(ticker != null ? '\$ ${ticker?.price}' : 'No data',
                style: Theme.of(context).textTheme.headline3),
            SizedBox(height: 24),
            Text(
              ticker?.side ?? '',
              style: TextStyle(
                  color: ticker?.side == 'sell' ? Colors.red : Colors.green),
            ),
            Text(ticker != null ? 'Last Size ${ticker?.lastSize}' : ''),
            SizedBox(height: 24),
            Text(ticker != null ? 'Low 24h ${ticker?.low24h}' : ''),
            Text(
              ticker != null ? 'High 24h ${ticker?.high24h}' : '',
            ),
            Text(ticker?.time ?? ''),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: subscribe,
        tooltip: _subscribed ? 'Unsubscribe' : 'Subscribe',
        child: Icon(_subscribed ? Icons.pause : Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
