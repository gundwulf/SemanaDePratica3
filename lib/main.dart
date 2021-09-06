import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Login(),
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  User _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
    });
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final databaseReference = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  _getUser() async {
    Future<User> _getUser() async {
      if (_currentUser != null) {
        return _currentUser;
      }
    }

    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      final User user = userCredential.user;
      return user;
    } catch (e) {}
  }

  void _cadastrarCurso() async {
    User user = await _getUser();
    if (user == null) {
      _globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível fazer login"),
          backgroundColor: Colors.red,
        ),
      );
    }
    DocumentReference ref = await databaseReference
        .collection("curso")
        .add({'nome': 'Curso inserido com login', 'cargahoraria': 30});
    print(ref.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("Cadastro de curso"),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Cadastrar curso"),
            onPressed: _cadastrarCurso,
          ),
        ],
      ),
    );
  }
}
