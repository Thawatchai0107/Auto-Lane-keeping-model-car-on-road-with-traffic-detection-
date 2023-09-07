import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input Widget Flutter',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic textFieldValue = '';
  dynamic radioButtonValue = '';
  dynamic resultText1 = ''; 
  dynamic resultText2 = ''; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thawatchai Input Widget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TextField'),
            TextField(
              onChanged: (value) {
                setState(() {
                  textFieldValue = value;
                });
              },
              decoration: InputDecoration(labelText: 'Text'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  
                  resultText1 = textFieldValue;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Submit'),
                  SizedBox(width: 5),
                 
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Result : $resultText1'),
            
            SizedBox(height: 20),
            Text('RadioListTile'),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('Apple'),
                  value: 'Apple',
                  groupValue: radioButtonValue,
                  onChanged: (value) {
                    setState(() {
                      radioButtonValue = value;
                      resultText2 = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Banana'),
                  value: 'Banana',
                  groupValue: radioButtonValue,
                  onChanged: (value) {
                    setState(() {
                      radioButtonValue = value;
                      resultText2 = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Orange'),
                  value: 'Orange',
                  groupValue: radioButtonValue,
                  onChanged: (value) {
                    setState(() {
                      radioButtonValue = value;
                      resultText2 = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Watermelon'),
                  value: 'Watermelon',
                  groupValue: radioButtonValue,
                  onChanged: (value) {
                    setState(() {
                      radioButtonValue = value;
                      resultText2 = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('NaN'),
                  value: 'NaN',
                  groupValue: radioButtonValue,
                  onChanged: (value) {
                    setState(() {
                      radioButtonValue = value;
                      resultText2 = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Result : $resultText2'), 
          ],
        ),
      ),
    );
  }
}
