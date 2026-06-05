// =====================================================
//  AUTH MODELS
// =====================================================

class UserModel {
  final int id;
  final String name;
  final String email;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  bool get isAdmin => roles.contains('admin');
}

class AuthResponse {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'],
        user: UserModel.fromJson(json['user']),
      );
}

// =====================================================
//  MACHINE MODEL
// =====================================================

class MachineModel {
  final int id;
  final String serialNumber;
  final String name;
  final String model;
  final String? location;
  final String status; // active | inactive | maintenance
  final String? installedAt;

  const MachineModel({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.model,
    this.location,
    required this.status,
    this.installedAt,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
        id: json['id'],
        serialNumber: json['serial_number'] ?? '',
        name: json['name'] ?? '',
        model: json['model'] ?? '',
        location: json['location'],
        status: json['status'] ?? 'inactive',
        installedAt: json['installed_at'],
      );
}

// =====================================================
//  MACHINE READING MODEL  (EAV pattern)
// =====================================================

class MachineReadingModel {
  final int id;
  final int machineId;
  final String sensorKey; // temperatura | rpm | vibracao | eficiencia | corrente | pressao
  final double value;
  final String unit;
  final String? readAt;

  const MachineReadingModel({
    required this.id,
    required this.machineId,
    required this.sensorKey,
    required this.value,
    required this.unit,
    this.readAt,
  });

  factory MachineReadingModel.fromJson(Map<String, dynamic> json) =>
      MachineReadingModel(
        id: json['id'],
        machineId: json['machine_id'],
        sensorKey: json['sensor_key'] ?? '',
        value: _toDouble(json['value']),
        unit: json['unit'] ?? '',
        readAt: json['read_at'],
      );

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
}

// =====================================================
//  SERVICE ORDER MODEL
// =====================================================

class ServiceOrderModel {
  final int id;
  final int machineId;
  final String type;   // preventive | corrective
  final String status; // open | in_progress | completed | cancelled
  final String? startedAt;
  final String? completedAt;
  final UserModel? technician;
  final UserModel? creator;

  const ServiceOrderModel({
    required this.id,
    required this.machineId,
    required this.type,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.technician,
    this.creator,
  });

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) =>
      ServiceOrderModel(
        id: json['id'],
        machineId: json['machine_id'],
        type: json['type'] ?? 'corrective',
        status: json['status'] ?? 'open',
        startedAt: json['started_at'],
        completedAt: json['completed_at'],
        technician: json['technician'] != null
            ? UserModel.fromJson(json['technician'])
            : null,
        creator: json['creator'] != null
            ? UserModel.fromJson(json['creator'])
            : null,
      );
}

// =====================================================
//  MAINTENANCE LOG MODEL
// =====================================================

class MaintenanceLogModel {
  final int id;
  final int machineId;
  final String action;
  final String? defectType;
  final UserModel? user;
  final String? createdAt;

  const MaintenanceLogModel({
    required this.id,
    required this.machineId,
    required this.action,
    this.defectType,
    this.user,
    this.createdAt,
  });

  factory MaintenanceLogModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceLogModel(
        id: json['id'],
        machineId: json['machine_id'],
        action: json['action'] ?? '',
        defectType: json['defect_type'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        createdAt: json['created_at'],
      );
}

// =====================================================
//  STATUS ALERT MODEL
// =====================================================

class StatusAlertModel {
  final int id;
  final int machineId;
  final String previousStatus;
  final String newStatus;
  final String message;
  final bool isRead;
  final String? triggeredAt;

  const StatusAlertModel({
    required this.id,
    required this.machineId,
    required this.previousStatus,
    required this.newStatus,
    required this.message,
    required this.isRead,
    this.triggeredAt,
  });

  factory StatusAlertModel.fromJson(Map<String, dynamic> json) =>
      StatusAlertModel(
        id: json['id'],
        machineId: json['machine_id'],
        previousStatus: json['previous_status'] ?? '',
        newStatus: json['new_status'] ?? '',
        message: json['message'] ?? '',
        isRead: json['is_read'] == true || json['is_read'] == 1,
        triggeredAt: json['triggered_at'],
      );
}

// =====================================================
//  PAGINATION WRAPPER
// =====================================================

class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int currentPage;
  final int lastPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // API can return either a plain array or a paginated {data, meta} object.
    if (json is List) {
      final items = json
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        data: items,
        total: items.length,
        currentPage: 1,
        lastPage: 1,
      );
    }
    final rawData = json['data'] as List? ?? [];
    return PaginatedResponse(
      data: rawData
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['meta']?['total'] ?? json['total'] ?? 0,
      currentPage:
          json['meta']?['current_page'] ?? json['current_page'] ?? 1,
      lastPage: json['meta']?['last_page'] ?? json['last_page'] ?? 1,
    );
  }
}
