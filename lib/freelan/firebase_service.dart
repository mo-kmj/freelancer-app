import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- PROJECTS ---
  Stream<List<ProjectData>> getProjects() {
    return _firestore.collection('projects').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProjectData.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addProject(ProjectData project) {
    return _firestore.collection('projects').add(project.toJson());
  }

  Future<void> updateProject(ProjectData project) {
    return _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }

  Future<void> deleteProject(String id) {
    return _firestore.collection('projects').doc(id).delete();
  }

  // --- CLIENTS ---
  Stream<List<ClientData>> getClients() {
    return _firestore.collection('clients').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => ClientData.fromJson(doc.data(), doc.id)).toList(),
        );
  }

  Future<void> addClient(ClientData client) {
    return _firestore.collection('clients').add(client.toJson());
  }

  Future<void> updateClient(ClientData client) {
    return _firestore.collection('clients').doc(client.id).update(client.toJson());
  }

  Future<void> deleteClient(String id) {
    return _firestore.collection('clients').doc(id).delete();
  }

  // --- USERS ---
  Stream<UserSettings> getUserSettings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserSettings.fromJson(doc.data()!));
  }

  Future<void> updateUserSettings(String userId, UserSettings settings) {
    return _firestore
        .collection('users')
        .doc(userId)
        .update(settings.toJson());
  }
}
