import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Usuário atualmente autenticado
  User? get currentUser => _auth.currentUser;

  /// Stream com alterações de estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Realiza login com email e senha
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cria uma nova conta com email e senha
  Future<UserCredential> createAccount(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Desconecta o usuário atual
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envia email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
