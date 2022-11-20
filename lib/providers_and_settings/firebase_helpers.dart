import 'package:firebase_database/firebase_database.dart';

void setValueToFirebase(String refPath, dynamic value) async {
  final FirebaseDatabase db = FirebaseDatabase.instance;
  final DatabaseReference dbRef = db.ref(refPath);
  dbRef.set(value);
}