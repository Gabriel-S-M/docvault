import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/company_item.dart';
import '../models/document_item.dart';
import '../models/user_item.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Referências para Coleções
  // ---------------------------------------------------------
  CollectionReference<Map<String, dynamic>> get _companiesRef =>
      _firestore.collection('companies');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _documentsRef(String companyId) =>
      _companiesRef.doc(companyId).collection('documents');

  // ---------------------------------------------------------
  // Empresas (Companies)
  // ---------------------------------------------------------

  /// Escuta atualizações de todas as empresas em tempo real
  Stream<List<CompanyItem>> streamCompanies() {
    return _companiesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CompanyItem.fromFirestore(doc))
          .toList();
    });
  }

  /// Busca a lista de empresas pontualmente
  Future<List<CompanyItem>> getCompanies() async {
    try {
      final snapshot = await _companiesRef.get();
      return snapshot.docs
          .map((doc) => CompanyItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar empresas: $e');
      return [];
    }
  }

  /// Adiciona uma nova empresa e retorna seu ID gerado
  Future<String> addCompany(CompanyItem company) async {
    try {
      final docRef = await _companiesRef.add(company.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao adicionar empresa: $e');
      rethrow;
    }
  }

  /// Atualiza os dados de uma empresa existente
  Future<void> updateCompany(CompanyItem company) async {
    try {
      await _companiesRef.doc(company.id).update(company.toFirestore());
    } catch (e) {
      debugPrint('Erro ao atualizar empresa: $e');
      rethrow;
    }
  }

  /// Exclui uma empresa e seus documentos associados
  Future<void> deleteCompany(String companyId) async {
    try {
      // Exclui os documentos da subcoleção em lote
      final docsSnapshot = await _documentsRef(companyId).get();
      final batch = _firestore.batch();
      for (final doc in docsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Exclui a própria empresa
      await _companiesRef.doc(companyId).delete();
    } catch (e) {
      debugPrint('Erro ao excluir empresa: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------
  // Documentos (Documents - Subcoleção de Company)
  // ---------------------------------------------------------

  /// Escuta os documentos de uma empresa específica em tempo real
  Stream<List<DocumentItem>> streamDocuments(String companyId) {
    return _documentsRef(companyId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentItem.fromFirestore(doc))
          .toList();
    });
  }

  /// Busca os documentos de uma empresa pontualmente
  Future<List<DocumentItem>> getDocuments(String companyId) async {
    try {
      final snapshot = await _documentsRef(companyId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => DocumentItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar documentos da empresa $companyId: $e');
      return [];
    }
  }

  /// Adiciona um documento na empresa
  Future<String> addDocument(String companyId, DocumentItem document) async {
    try {
      final docRef = await _documentsRef(companyId).add(document.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao adicionar documento: $e');
      rethrow;
    }
  }

  /// Atualiza um documento existente
  Future<void> updateDocument(String companyId, DocumentItem document) async {
    try {
      await _documentsRef(companyId)
          .doc(document.id)
          .update(document.toFirestore());
    } catch (e) {
      debugPrint('Erro ao atualizar documento: $e');
      rethrow;
    }
  }

  /// Exclui um documento de uma empresa
  Future<void> deleteDocument(String companyId, String documentId) async {
    try {
      await _documentsRef(companyId).doc(documentId).delete();
    } catch (e) {
      debugPrint('Erro ao excluir documento: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------
  // Usuários (Users)
  // ---------------------------------------------------------

  /// Escuta todos os usuários em tempo real
  Stream<List<UserItem>> streamUsers() {
    return _usersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserItem.fromFirestore(doc)).toList();
    });
  }

  /// Busca todos os usuários
  Future<List<UserItem>> getUsers() async {
    try {
      final snapshot = await _usersRef.get();
      return snapshot.docs.map((doc) => UserItem.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar usuários: $e');
      return [];
    }
  }

  /// Busca um usuário pelo UID/ID
  Future<UserItem?> getUserById(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) return null;
      return UserItem.fromFirestore(doc);
    } catch (e) {
      debugPrint('Erro ao buscar usuário por ID: $e');
      return null;
    }
  }

  /// Busca um usuário pelo email
  Future<UserItem?> getUserByEmail(String email) async {
    try {
      final query = await _usersRef
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return UserItem.fromFirestore(query.docs.first);
    } catch (e) {
      debugPrint('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  /// Cria ou sobrescreve os dados de perfil do usuário (usando o UID do Firebase Auth)
  Future<void> setUser(UserItem user) async {
    try {
      await _usersRef.doc(user.id).set(user.toFirestore());
    } catch (e) {
      debugPrint('Erro ao salvar usuário: $e');
      rethrow;
    }
  }

  /// Atualiza dados de um usuário
  Future<void> updateUser(UserItem user) async {
    try {
      await _usersRef.doc(user.id).update(user.toFirestore());
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  /// Remove um usuário do Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.doc(userId).delete();
    } catch (e) {
      debugPrint('Erro ao excluir usuário: $e');
      rethrow;
    }
  }
}
