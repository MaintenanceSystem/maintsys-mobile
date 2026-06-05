import '../network/api_client.dart';
import '../../shared/models/all_models.dart';

export '../../shared/models/all_models.dart';

// =====================================================
//  MACHINES SERVICE
// =====================================================
class MachinesService {
  final _dio = ApiClient.instance.dio;

  Future<PaginatedResponse<MachineModel>> index({int page = 1}) async {
    final res = await _dio.get('/machines', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(res.data, MachineModel.fromJson);
  }

  Future<MachineModel> show(int id) async {
    final res = await _dio.get('/machines/$id');
    return MachineModel.fromJson(res.data['data'] ?? res.data);
  }

  /// GET /machine-readings?machine_id=X  (EAV pattern)
  Future<List<MachineReadingModel>> readings(int machineId) async {
    final res = await _dio.get(
      '/machine-readings',
      queryParameters: {'machine_id': machineId},
    );
    final data = res.data;
    final list = data is List ? data : ((data as Map)['data'] as List? ?? []);
    return list
        .map<MachineReadingModel>(
            (e) => MachineReadingModel.fromJson(e as Map<String, dynamic>))
        .where((r) => r.machineId == machineId) // garante filtragem mesmo se API retornar todos
        .toList();
  }
}

// =====================================================
//  SERVICE ORDERS SERVICE
// =====================================================
class ServiceOrdersService {
  final _dio = ApiClient.instance.dio;

  Future<PaginatedResponse<ServiceOrderModel>> index({
    int page = 1,
    String? status,
    int? machineId,
  }) async {
    final res = await _dio.get('/service-orders', queryParameters: {
      'page': page,
      if (status != null) 'status': status,
      if (machineId != null) 'machine_id': machineId,
    });
    return PaginatedResponse.fromJson(res.data, ServiceOrderModel.fromJson);
  }

  Future<ServiceOrderModel> show(int id) async {
    final res = await _dio.get('/service-orders/$id');
    return ServiceOrderModel.fromJson(res.data['data'] ?? res.data);
  }

  Future<ServiceOrderModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/service-orders/$id', data: data);
    return ServiceOrderModel.fromJson(res.data['data'] ?? res.data);
  }
}

// =====================================================
//  MAINTENANCE LOGS SERVICE
// =====================================================
class MaintenanceLogsService {
  final _dio = ApiClient.instance.dio;

  Future<PaginatedResponse<MaintenanceLogModel>> index({
    int page = 1,
    int? machineId,
  }) async {
    final res = await _dio.get('/maintenance-logs', queryParameters: {
      'page': page,
      if (machineId != null) 'machine_id': machineId,
    });
    return PaginatedResponse.fromJson(res.data, MaintenanceLogModel.fromJson);
  }
}

// =====================================================
//  STATUS ALERTS SERVICE
// =====================================================
class StatusAlertsService {
  final _dio = ApiClient.instance.dio;

  Future<PaginatedResponse<StatusAlertModel>> index({int page = 1}) async {
    final res = await _dio.get('/status-alerts', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(res.data, StatusAlertModel.fromJson);
  }

  /// PUT /status-alerts/{id}  body: {is_read: true}
  Future<StatusAlertModel> markAsRead(int id) async {
    final res = await _dio.put('/status-alerts/$id', data: {'is_read': true});
    return StatusAlertModel.fromJson(res.data['data'] ?? res.data);
  }
}

// =====================================================
//  USERS SERVICE  (admin only)
// =====================================================
class UsersService {
  final _dio = ApiClient.instance.dio;

  Future<PaginatedResponse<UserModel>> index({int page = 1}) async {
    final res = await _dio.get('/users', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(res.data, UserModel.fromJson);
  }
}
