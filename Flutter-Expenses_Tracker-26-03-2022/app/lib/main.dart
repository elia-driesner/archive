import 'models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final List<Transaction> transactions = [];

  void removeElement({required id}) {
    String removeId = id;

    for (var i = 0; i < transactions.length; i++) {
      if (removeId == transactions[i].id) {
        setState(() {
          transactions.removeAt(i);
        });
      }
    }
  }

// tests
  void addTransaction({required title, required amount}) {
    var uuid = Uuid();
    var intAmount = double.parse(amount);
    setState(() {
      transactions.add(Transaction(
          id: uuid.v4(),
          title: title,
          amount: intAmount,
          date: DateTime.now()));
    });
  }

  final titleInputController = TextEditingController();
  final amountInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Expenses Tracker'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Card(
                  child: Text('Chart'),
                ),
                height: 50,
              ),
              Card(
                  child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            decoration: InputDecoration(labelText: 'Title:'),
                            controller: titleInputController,
                            // onChanged: (val) => titleInput = val,
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Amount:'),
                            controller: amountInputController,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                addTransaction(
                                    title: titleInputController.text,
                                    amount: amountInputController.text);
                              },
                              child: Text('Add Transaction'))
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(7, 5, 7, 1))),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: transactions.map((tx) {
                    return Card(
                        child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              tx.title,
                              style: TextStyle(fontSize: 25),
                            ),
                            tx.amount < 0
                                ? Container(
                                    child: Text(
                                      (tx.amount.toString()) + ' €',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 255, 0, 0)),
                                    ),
                                    padding: EdgeInsets.fromLTRB(0, 10, 30, 5),
                                  )
                                : Container(
                                    child: Text(
                                      (tx.amount.toString()) + ' €',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 0, 185, 0)),
                                    ),
                                    padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                                  )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                child: Text(
                                  DateFormat('d MMM y  H:mm').format(tx.date),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Color.fromARGB(255, 123, 124, 133)),
                                ),
                                padding: EdgeInsets.fromLTRB(105, 0, 0, 40)),
                            Container(
                              child: ElevatedButton(
                                child: Text('Remove'),
                                onPressed: () => removeElement(id: tx.id),
                              ),
                            )
                          ],
                        )
                      ],
                    ));
                  }).toList())
            ],
          )),
    );
  }
}
