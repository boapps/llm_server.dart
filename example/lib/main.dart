import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:llm_server_dart/llm_server_dart.dart' as llm_server_dart;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _data = 'Fetching data...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPeriodicFetch();
  }

  void _startPeriodicFetch() {
    _fetchData();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _fetchData());
  }

  Future<void> _fetchData() async {
    const url = 'http://localhost:8080/health';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData['status'].toString();
        });
      } else {
        setState(() {
          _data = 'Not running';
        });
      }
    } catch (e) {
      setState(() {
        _data = 'Not running';
      });
    }
  }

  void startServer() {
    llm_server_dart.start("gemma-2.gguf");
  }

  void stopServer() {
    llm_server_dart.quit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                MaterialButton(onPressed: startServer, child: Text('start'),),
                MaterialButton(onPressed: stopServer, child: Text('stop'),),
                Text(
                  _data,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
