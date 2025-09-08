import 'package:flutter/material.dart';

// Enums
enum ProjectStatus { todo, inProgress, overdue, completed }
enum Priority { low, medium, high }
enum TaskStatus { todo, progress, done }

// ------------------ ProjectData ------------------
class ProjectData {
  final String id;
  final String title;
  final String client;
  final String clientId;
  final ProjectStatus status;
  final Priority priority;
  final int progress;
  final String dueDate;
  final String? completedDate;
  final String description;
  final String budget;
  final String timeSpent;
  final String notes;
  final List<TaskData> tasks;

  const ProjectData({
    required this.id,
    required this.title,
    required this.client,
    required this.clientId,
    required this.status,
    required this.priority,
    required this.progress,
    required this.dueDate,
    this.completedDate,
    required this.description,
    required this.budget,
    required this.timeSpent,
    required this.notes,
    required this.tasks,
  });

  // From Firestore
  factory ProjectData.fromFirestore(String id, Map<String, dynamic> data) {
    return ProjectData(
      id: id,
      title: data['title'] ?? '',
      client: data['client'] ?? '',
      clientId: data['clientId'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'todo'),
        orElse: () => ProjectStatus.todo,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString().split('.').last == (data['priority'] ?? 'low'),
        orElse: () => Priority.low,
      ),
      progress: data['progress'] ?? 0,
      dueDate: data['dueDate'] ?? '',
      completedDate: data['completedDate'],
      description: data['description'] ?? '',
      budget: data['budget'] ?? '',
      timeSpent: data['timeSpent'] ?? '',
      notes: data['notes'] ?? '',
      tasks: (data['tasks'] as List<dynamic>? ?? [])
          .map((task) => TaskData.fromFirestore(task as Map<String, dynamic>))
          .toList(),
    );
  }

  // To Firestore
  Map<String, dynamic> toJsonFirestore() {
    return {
      'title': title,
      'client': client,
      'clientId': clientId,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'progress': progress,
      'dueDate': dueDate,
      'completedDate': completedDate,
      'description': description,
      'budget': budget,
      'timeSpent': timeSpent,
      'notes': notes,
      'tasks': tasks.map((task) => task.toJsonFirestore()).toList(),
    };
  }

  // ------------------ Helpers ------------------
  double get progressPercentage => progress / 100.0;
  bool get isOverdue => status == ProjectStatus.overdue;
  bool get isCompleted => status == ProjectStatus.completed;
  int get completedTasksCount => tasks.where((task) => task.status == TaskStatus.done).length;
  int get totalTasksCount => tasks.length;
  double get taskCompletionPercentage => totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

  ProjectData copyWith({
    String? id,
    String? title,
    String? client,
    String? clientId,
    ProjectStatus? status,
    Priority? priority,
    int? progress,
    String? dueDate,
    String? completedDate,
    String? description,
    String? budget,
    String? timeSpent,
    String? notes,
    List<TaskData>? tasks,
  }) {
    return ProjectData(
      id: id ?? this.id,
      title: title ?? this.title,
      client: client ?? this.client,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      timeSpent: timeSpent ?? this.timeSpent,
      notes: notes ?? this.notes,
      tasks: tasks ?? this.tasks,
    );
  }
}

// ------------------ TaskData ------------------
class TaskData {
  final String id;
  final String name;
  final TaskStatus status;
  final String? description;
  final String? assignee;
  final DateTime? dueDate;
  final DateTime? completedDate;

  const TaskData({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.assignee,
    this.dueDate,
    this.completedDate,
  });

  // From Firestore
  factory TaskData.fromFirestore(Map<String, dynamic> data) {
    return TaskData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'todo'),
        orElse: () => TaskStatus.todo,
      ),
      description: data['description'],
      assignee: data['assignee'],
      dueDate: data['dueDate'] != null ? DateTime.tryParse(data['dueDate']) : null,
      completedDate: data['completedDate'] != null ? DateTime.tryParse(data['completedDate']) : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toJsonFirestore() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
      'description': description,
      'assignee': assignee,
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  // ------------------ Helpers ------------------
  bool get isCompleted => status == TaskStatus.done;
  bool get isInProgress => status == TaskStatus.progress;
  bool get isOverdue => dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate!);

  TaskData copyWith({
    String? id,
    String? name,
    TaskStatus? status,
    String? description,
    String? assignee,
    DateTime? dueDate,
    DateTime? completedDate,
  }) {
    return TaskData(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

// ------------------ ClientData ------------------
class ClientData {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String phone;
  final String industry;
  final String avatar;
  final LinearGradient avatarColor;
  final String totalRevenue;
  final List<String> projects;
  final int activeProjects;
  final String description;
  final String joinDate;
  final String lastContact;
  final String? address;
  final String? website;
  final String? notes;

  const ClientData({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.phone,
    required this.industry,
    required this.avatar,
    required this.avatarColor,
    required this.totalRevenue,
    required this.projects,
    required this.activeProjects,
    required this.description,
    required this.joinDate,
    required this.lastContact,
    this.address,
    this.website,
    this.notes,
  });

  // From Firestore
  factory ClientData.fromFirestore(String id, Map<String, dynamic> data) {
    return ClientData(
      id: id,
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      industry: data['industry'] ?? '',
      avatar: data['avatar'] ?? '',
      avatarColor: AppUtils.getAvatarGradient(data['name'] ?? ''),
      totalRevenue: data['totalRevenue'] ?? '',
      projects: (data['projects'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      activeProjects: data['activeProjects'] ?? 0,
      description: data['description'] ?? '',
      joinDate: data['joinDate'] ?? '',
      lastContact: data['lastContact'] ?? '',
      address: data['address'],
      website: data['website'],
      notes: data['notes'],
    );
  }

  // To Firestore
  Map<String, dynamic> toJsonFirestore() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'phone': phone,
      'industry': industry,
      'avatar': avatar,
      'totalRevenue': totalRevenue,
      'projects': projects,
      'activeProjects': activeProjects,
      'description': description,
      'joinDate': joinDate,
      'lastContact': lastContact,
      'address': address,
      'website': website,
      'notes': notes,
    };
  }

  // ------------------ Helpers ------------------
  int get totalProjectsCount => projects.length;
  bool get hasActiveProjects => activeProjects > 0;
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  ClientData copyWith({
    String? id,
    String? name,
    String? contact,
    String? email,
    String? phone,
    String? industry,
    String? avatar,
    LinearGradient? avatarColor,
    String? totalRevenue,
    List<String>? projects,
    int? activeProjects,
    String? description,
    String? joinDate,
    String? lastContact,
    String? address,
    String? website,
    String? notes,
  }) {
    return ClientData(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      industry: industry ?? this.industry,
      avatar: avatar ?? this.avatar,
      avatarColor: avatarColor ?? this.avatarColor,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      projects: projects ?? this.projects,
      activeProjects: activeProjects ?? this.activeProjects,
      description: description ?? this.description,
      joinDate: joinDate ?? this.joinDate,
      lastContact: lastContact ?? this.lastContact,
      address: address ?? this.address,
      website: website ?? this.website,
      notes: notes ?? this.notes,
    );
  }
}

// ------------------ UserModel ------------------
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  // From Firestore
  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      avatar: data['avatar'],
      phone: data['phone'],
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
      lastLoginAt: data['lastLoginAt'] != null ? DateTime.tryParse(data['lastLoginAt']) : null,
      isActive: data['isActive'] ?? true,
    );
  }

  // To Firestore
  Map<String, dynamic> toJsonFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // ------------------ Helpers ------------------
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ------------------ Utilities ------------------
class AppUtils {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String formatDate(DateTime date) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} year${diff.inDays > 730 ? 's' : ''} ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} month${diff.inDays > 60 ? 's' : ''} ago';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }


  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Get gradient for avatar based on name
  static LinearGradient getAvatarGradient(String name) {
    final hash = name.hashCode;
    final gradients = [
      const LinearGradient(colors: [accentCyan, accentPink]),
      const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
      const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
      const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
      const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
      const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
      const LinearGradient(colors: [Color(0xFFa8edea), Color(0xFFfed6e3)]),
      const LinearGradient(colors: [Color(0xFFffecd2), Color(0xFFfcb69f)]),
    ];
    return gradients[hash.abs() % gradients.length];
  }
}

// Theme-related constants
class AppTheme {
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 80.0;
}
