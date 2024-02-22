import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compare Stock Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockInfoPage(),
    );
  }
}

class StockInfoPage extends StatefulWidget {
  @override
  _StockInfoPageState createState() => _StockInfoPageState();
}

class _StockInfoPageState extends State<StockInfoPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _stockSymbols = [];
  final Map<String, Map<String, dynamic>> _stockData = {};

  void _addStockSymbol(String stockSymbol) {
    setState(() {
      _stockSymbols.add(stockSymbol);
    });
  }

  Future<void> _fetchStockData(String stockSymbol) async {
    final apiKey = 'Y5ZT9VL6RGSKWJHT';
    final apiUrl =
        'https://www.alphavantage.co/query?function=OVERVIEW&symbol=$stockSymbol&apikey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _stockData[stockSymbol] = jsonData;
      });
    } else {
      setState(() {
        _stockData[stockSymbol] = {'error': 'Error fetching data.'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Stock Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter Stock Symbol',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final stockSymbol = _controller.text;
                    if (stockSymbol.isNotEmpty) {
                      _addStockSymbol(stockSymbol);
                      _fetchStockData(stockSymbol);
                      _controller.clear();
                    }
                  },
                  child: Text('Add Stock'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_stockSymbols.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Symbol')),
                      DataColumn(label: Text('PE Ratio')),
                      DataColumn(label: Text('PB Ratio')),
                      DataColumn(label: Text('PS Ratio')),
                    ],
                    rows: _stockSymbols.map((symbol) {
                      final data = _stockData[symbol] ?? {};
                      return DataRow(
                        cells: [
                          DataCell(Text(symbol)),
                          DataCell(Text(data['PERatio'] ?? '-')),
                          DataCell(Text(data['PriceToBookRatio'] ?? '-')),
                          DataCell(Text(data['PriceToSalesRatio'] ?? '-')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
