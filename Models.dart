import 'package:flutter/material.dart';

MaterialColor customRed = MaterialColor(
  0xFFB71C1C,
  <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFF800000),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  },
);

class Term {
  List<Subject> subjects = [];
  double gpa = 0.0;
}

class Subject {
  final String name;
  final int credit;
  final String grade;

  Subject(this.name, this.credit, this.grade);

  double get gradePoints {
    if (grade == 'A') {
      return 4.0;
    } else if (grade == 'B') {
      return 3.0;
    } else if (grade == 'C') {
      return 2.0;
    } else if (grade == 'D') {
      return 1.0;
    } else {
      return 0.0;
    }
  }
}

class GradeDisplayPage extends StatelessWidget {
  final List<Term> terms;

  GradeDisplayPage(this.terms);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Display'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Subject Names and Grades',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: terms.length,
              itemBuilder: (context, termIndex) {
                Term term = terms[termIndex];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Term ${termIndex + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Subject Names and Grades:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: term.subjects.length,
                          itemBuilder: (context, subjectIndex) {
                            Subject subject = term.subjects[subjectIndex];
                            return Text(
                              '${subject.name}: ${subject.grade}',
                              style: TextStyle(fontSize: 16),
                            );
                          },
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'GPA : ${term.gpa.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
