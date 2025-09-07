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
  // Helpers
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

        final clients = snapshot.data!.docs.map(clientFromDoc).toList();

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
                  crossAxisCount: MediaQuery.of(context).size.width < 768
                      ? 1
                      : MediaQuery.of(context).size.width < 1024
                          ? 2
                          : 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.2,
                ),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
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
            // Avatar + name
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: client.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client.avatar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.contact,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contact
            _buildContactRow(Icons.email, client.email, accentCyan),
            const SizedBox(height: 3),
            _buildContactRow(Icons.phone, client.phone, accentCyan),
            const SizedBox(height: 3),
            _buildContactRow(Icons.business, client.industry, accentCyan),
            const Spacer(),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${client.activeProjects} Active Projects',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.totalRevenue,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: accentPink,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color iconColor) {
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clients').doc(clientId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final client = clientFromDoc(snapshot.data!);

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
                .cast<ProjectData>()   // 👈 ensures correct type
              : <ProjectData>[];

            // ⬇️ Use your OLD UI code here ⬇️
            return _buildClientDetailUI(context, client, clientProjects);
          },
        );
      },
    );
  }

  Widget _buildClientDetailUI(
    BuildContext context, ClientData client, List<ProjectData> clientProjects) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildClientAvatar(client),
            const SizedBox(width: 16),
            Expanded(child: _buildClientInfo(client)),
          ],
        ),
        const SizedBox(height: 24),
        _buildClientStats(client, clientProjects),
        const SizedBox(height: 24),
        _buildContactSection(client),
        const SizedBox(height: 24),
        _buildAboutSection(client),
        const SizedBox(height: 32),
        const Text(
          "Projects",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clientProjects.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 768
                ? 1
                : MediaQuery.of(context).size.width < 1024
                    ? 2
                    : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final project = clientProjects[index];
            return _buildProjectCard(context, project);
          },
        ),
      ],
    ),
  );
}


  // Other helper widgets same as your old code:
  Widget _buildClientAvatar(ClientData client) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: client.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          client.avatar,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textWhite,
          ),
        ),
      ),
    );
  }
  Widget _buildClientInfo(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          client.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textWhite,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Text(
          '${client.contact} • ${client.industry}',
          style: TextStyle(
            color: Colors.grey[400],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Client since ${client.joinDate} • Last contact: ${client.lastContact}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildClientStats(ClientData client, List<ProjectData> clientProjects) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        children: [
          Text(
            clientProjects.length.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentCyan,
            ),
          ),
          Text(
            'Total Projects',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
      const SizedBox(width: 24),
      Column(
        children: [
          Text(
            client.totalRevenue,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Revenue',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget _buildContactSection(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        _buildContactRow(Icons.email, client.email, accentCyan),
        const SizedBox(height: 4),
        _buildContactRow(Icons.phone, client.phone, accentCyan),
        const SizedBox(height: 4),
        _buildContactRow(Icons.business, client.industry, accentCyan),
      ],
    );
  }

  Widget _buildAboutSection(ClientData client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          client.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[300],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ],
    );
  }

    Widget _buildProjectCard(BuildContext context, ProjectData project) {
    return InkWell(
      onTap: () => _showProjectDetail(context, project.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentCyan.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textWhite,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: getPriorityColor(project.priority).withOpacity(0.2),
                    border: Border.all(color: getPriorityColor(project.priority)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getPriorityText(project.priority),
                    style: TextStyle(
                      fontSize: 9,
                      color: getPriorityColor(project.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.status == ProjectStatus.completed 
                        ? 'Completed: ${project.completedDate}' 
                        : 'Due: ${project.dueDate}',
                    style: TextStyle(
                      fontSize: 10,
                      color: project.status == ProjectStatus.overdue 
                          ? Colors.red 
                          : Colors.grey[400],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: getStatusColor(project.status).withOpacity(0.2),
                    border: Border.all(color: getStatusColor(project.status)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getStatusText(project.status),
                    style: TextStyle(
                      fontSize: 9,
                      color: getStatusColor(project.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: project.progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: project.status == ProjectStatus.completed 
                        ? const LinearGradient(colors: [Colors.green, Colors.green])
                        : const LinearGradient(colors: [accentCyan, accentPink]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${project.progress}% Complete',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  project.budget,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetail(BuildContext context, String projectId) {
    FirebaseFirestore.instance.collection('projects').doc(projectId).get().then((doc) {
      final project = projectFromDoc(doc);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: bgPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 800,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[400]),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Project details for ${project.title}',
                        style: const TextStyle(color: textWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
