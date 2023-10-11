import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

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

class DatabaseHelper {
  static Database? _database;
  String termTable = 'term';
  String subjectTable = 'subject';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'gpa.db');
    var database = await openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $termTable(id INTEGER PRIMARY KEY AUTOINCREMENT, gpa REAL)');
    await db.execute(
        'CREATE TABLE $subjectTable(id INTEGER PRIMARY KEY AUTOINCREMENT, termId INTEGER, name TEXT, credit INTEGER, grade TEXT)');
  }

  // เพิ่ม Term และ Subjects ลงในฐานข้อมูล
  Future<void> addTermAndSubjects(Term term) async {
    final db = await database;

    await db.transaction((txn) async {
      term.id = await txn.insert(termTable, term.toMap());
      for (Subject subject in term.subjects) {
        subject.termId = term.id!;
        await txn.insert(subjectTable, subject.toMap());
      }
    });
  }

  // โหลด Term และ Subjects จากฐานข้อมูล
  Future<List<Term>> getTerms() async {
    final db = await database;

    final List<Map<String, dynamic>> termMaps = await db.query(termTable);

    final List<Term> terms = [];

    for (Map<String, dynamic> termMap in termMaps) {
      final List<Map<String, dynamic>> subjectMaps = await db.query(
        subjectTable,
        where: 'termId = ?',
        whereArgs: [termMap['id']],
      );

      final List<Subject> subjects = subjectMaps.map((s) {
        return Subject.fromMap(s);
      }).toList();

      final Term term = Term.fromMap(termMap);
      term.subjects = subjects;
      terms.add(term);
    }

    return terms;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPA Calculator',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'คำนวณเกรดเฉลี่ย'),
      theme: ThemeData(
        primarySwatch: customRed, // ใช้สีแดงที่คุณสร้างเอง
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Term> terms = [];
  double overallGPA = 0.0;

  TextEditingController nameController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  String selectedGrade = 'A';
  int editingIndex = -1;
  int currentTermIndex = 0;

  List<String> gradeOptions = ['A', 'B', 'C', 'D', 'F'];

  @override
  void initState() {
    super.initState();
    // โหลด Term และ Subjects จากฐานข้อมูลใน initState ทันทีเมื่อหน้าจอถูกสร้าง
    _loadData();
  }

  void _loadData() async {
    final terms = await _databaseHelper.getTerms();
    if (terms.isNotEmpty) {
      setState(() {
        this.terms = terms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ระหว่างการสร้าง Widget ที่แสดง Term และ Subjects ในหน้าจอ
    // คุณสามารถใช้ this.terms ได้เพื่อแสดงข้อมูลที่มีในฐานข้อมูล
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://raw.githubusercontent.com/Thawatchai0107/Thawatchai-Resume/main/BG3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'ชื่อวิชา'),
                      ),
                      TextField(
                        controller: creditController,
                        decoration: InputDecoration(labelText: 'หน่วยกิจ'),
                        keyboardType: TextInputType.number,
                      ),
                      Row(
                        children: [
                          Text('เลือกผลการเรียน'),
                          SizedBox(width: 40),
                          DropdownButton<String>(
                            value: selectedGrade,
                            items: gradeOptions.map((String grade) {
                              return DropdownMenuItem<String>(
                                value: grade,
                                child: Text(grade),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGrade = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (editingIndex == -1) {
                                addSubject();
                              } else {
                                updateSubject(currentTermIndex, editingIndex);
                              }
                            },
                            child: Text(
                                editingIndex == -1 ? 'เพิ่มวิชา' : 'แก้ไขวิชา'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: () {
                              addTerm();
                            },
                            child: Text('เพิ่มเทอม'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: terms.length,
                itemBuilder: (context, termIndex) {
                  Term term = terms[termIndex];
                  return Card(
                    elevation: 4.0,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('เทอม ${termIndex + 1}'),
                          subtitle: Text('GPA: ${term.gpa.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  calculateTermGPA(termIndex);
                                },
                                child: Text('คำนวณ GPA'),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  addSubjectToTerm(termIndex);
                                },
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: term.subjects.length,
                          itemBuilder: (context, subjectIndex) {
                            Subject subject = term.subjects[subjectIndex];
                            return ListTile(
                              title: Text('ชื่อวิชา: ${subject.name}'),
                              subtitle: Text(
                                  'หน่วยกิจ: ${subject.credit}  เกรด: ${subject.grade}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      editSubject(termIndex, subjectIndex);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteSubject(termIndex, subjectIndex);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'GPA รวม: ${overallGPA.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      calculateOverallGPA();
                    },
                    child: Text('คำนวณ GPA รวม'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GradeDisplayPage(terms),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  void addSubject() {
    String name = nameController.text;
    int credit = int.tryParse(creditController.text) ?? 0;

    if (name.isNotEmpty && credit > 0) {
      setState(() {
        if (terms.isEmpty) {
          terms.add(Term(id: 0, gpa: 0.0));
        }
        terms[currentTermIndex]
            .subjects
            .add(Subject(name, credit, selectedGrade));
        nameController.clear();
        creditController.clear();
        selectedGrade = 'A';
      });
    }
  }

  void deleteSubject(int termIndex, int subjectIndex) {
    setState(() {
      terms[termIndex].subjects.removeAt(subjectIndex);
    });
  }

  void editSubject(int termIndex, int subjectIndex) {
    setState(() {
      editingIndex = subjectIndex;
      nameController.text = terms[termIndex].subjects[subjectIndex].name;
      creditController.text =
          terms[termIndex].subjects[subjectIndex].credit.toString();
      selectedGrade = terms[termIndex].subjects[subjectIndex].grade;
    });
  }

  void updateSubject(int termIndex, int subjectIndex) {
    String name = nameController.text;
    int credit = int.tryParse(creditController.text) ?? 0;

    if (name.isNotEmpty && credit > 0) {
      setState(() {
        terms[termIndex].subjects[subjectIndex] =
            Subject(name, credit, selectedGrade);
        editingIndex = -1;
        nameController.clear();
        creditController.clear();
        selectedGrade = 'A';
      });
    }
  }

  void addSubjectToTerm(int termIndex) {
    String name = nameController.text;
    int credit = int.tryParse(creditController.text) ?? 0;

    if (name.isNotEmpty && credit > 0) {
      setState(() {
        if (terms.length <= termIndex) {
          terms.add(Term(id: 0, gpa: 0.0));
        }
        terms[termIndex].subjects.add(Subject(name, credit, selectedGrade));
        nameController.clear();
        creditController.clear();
        selectedGrade = 'A';
      });
    }
  }

  void calculateOverallGPA() {
    double totalOverallGradePoints = 0.0;
    int totalOverallCredits = 0;

    for (Term term in terms) {
      double totalGradePoints = 0.0;
      int totalCredits = 0;

      for (Subject subject in term.subjects) {
        totalGradePoints += (subject.gradePoints * subject.credit);
        totalCredits += subject.credit;
      }

      if (totalCredits > 0) {
        totalOverallGradePoints += totalGradePoints;
        totalOverallCredits += totalCredits;
      }
    }

    setState(() {
      if (totalOverallCredits > 0) {
        overallGPA = totalOverallGradePoints / totalOverallCredits;
      } else {
        overallGPA = 0.0;
      }
    });
  }

  void addTerm() {
    setState(() {
      terms.add(Term(id: 0, gpa: 0.0));
      currentTermIndex = terms.length - 1;
    });
  }

  void calculateTermGPA(int termIndex) {
    Term term = terms[termIndex];
    double totalGradePoints = 0.0;
    int totalCredits = 0;

    for (Subject subject in term.subjects) {
      totalGradePoints += (subject.gradePoints * subject.credit);
      totalCredits += subject.credit;
    }

    setState(() {
      if (totalCredits > 0) {
        term.gpa = totalGradePoints / totalCredits;
      } else {
        term.gpa = 0.0;
      }
    });
  }
}

class Term {
  int? id;
  List<Subject> subjects = [];
  double gpa = 0.0;

  Term({
    required this.id, // ใส่ required เพื่อระบุว่าจำเป็นต้องรับค่า id
    required this.gpa,
  }); // คอนสตรักเตอร์เริ่มต้น (unnamed constructor) ที่ไม่รับพารามิเตอร์

  // เพิ่มเมธอด toMap และ factory constructor เพื่อทำการแปลงข้อมูลเป็น Map และจาก Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gpa': gpa,
    };
  }

  factory Term.fromMap(Map<String, dynamic> map) {
    return Term(
      id: map['id'],
      gpa: map['gpa'],
    );
  }
}

class Subject {
  int? id;
  int? termId;
  final String name;
  final int credit;
  final String grade;

  Subject(this.name, this.credit, this.grade);

  // เพิ่มเมธอด toMap และ factory constructor เพื่อทำการแปลงข้อมูลเป็น Map และจาก Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'termId': termId,
      'name': name,
      'credit': credit,
      'grade': grade,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      map['name'],
      map['credit'],
      map['grade'],
    )
      ..id = map['id']
      ..termId = map['termId'];
  }

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
        title: Text('แสดงเกรด'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'รายชื่อวิชาและเกรด',
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
                          'เทอม ${termIndex + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'รายชื่อวิชาและเกรด:',
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
