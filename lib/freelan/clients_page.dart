import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_models.dart';

class ClientsPage extends StatefulWidget {
  final String? selectedClientId;
  final Function(String?) onClientSelected;

  const ClientsPage({
    Key? key,
    required this.selectedClientId,
    required this.onClientSelected,
  }) : super(key: key);

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  // Helper to convert Firestore data to ClientData
  ClientData clientFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientData.fromFirestore(doc.id, data);
  }

  ProjectData projectFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectData.fromFirestore(doc.id, data);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedClientId != null) {
      return _buildClientDetail(context, widget.selectedClientId!);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('clients').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final clientDocs = snapshot.data!.docs;
        final clientData = {
          for (var doc in clientDocs) doc.id: clientFromDoc(doc)
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'All Clients',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 768 ? 1 : 
                                 MediaQuery.of(context).size.width < 1024 ? 2 : 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.2,
                ),
                itemCount: clientData.length,
                itemBuilder: (context, index) {
                  final client = clientData.values.elementAt(index);
                  return _buildClientCard(context, client);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientCard(BuildContext context, ClientData client) {
    return InkWell(
      onTap: () => widget.onClientSelected(client.id),
      child: Container(
        // ...existing code...
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ...existing code...
            // (all your custom UI unchanged)
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color iconColor) {
    // ...existing code...
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: textWhite,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetail(BuildContext context, String clientId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('clients').doc(clientId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final client = clientFromDoc(snapshot.data!);

        // Fetch projects for this client
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('projects')
              .where('clientId', isEqualTo: clientId)
              .snapshots(),
          builder: (context, projectSnapshot) {
            final clientProjects = projectSnapshot.hasData
                ? projectSnapshot.data!.docs
                    .map((doc) => projectFromDoc(doc))
                    .toList()
                : [];

            // ...existing UI code, just replace clientData and projectData usage...
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ...existing code...
                  // Use client and clientProjects as before
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ...all other custom widgets unchanged...
  Widget _buildClientAvatar(ClientData client) => // ...existing code...
  Widget _buildClientInfo(ClientData client) => // ...existing code...
  Widget _buildClientStats(ClientData client) => // ...existing code...
  Widget _buildContactSection(ClientData client) => // ...existing code...
  Widget _buildAboutSection(ClientData client) => // ...existing code...
  Widget _buildProjectCard(BuildContext context, ProjectData project) => // ...existing code...

  void _showProjectDetail(BuildContext context, String projectId) {
    FirebaseFirestore.instance.collection('projects').doc(projectId).get().then((doc) {
      final project = projectFromDoc(doc);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // ...existing dialog code using project...
        },
      );
    });
  }
}