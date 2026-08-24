import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_interaction_model.dart';
import '../models/customer_model.dart';
import 'crm_remote_datasource.dart';

class CrmRemoteDataSourceImpl implements CrmRemoteDataSource {
  CrmRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CustomerModel>> getCustomers({
    String? search,
    CustomerStatus? status,
    CustomerType? type,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/crm/customers',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null)
            'status': status == CustomerStatus.new_ ? 'new' : status.name,
          if (type != null) 'type': type.name,
        },
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  @override
  Future<CustomerModel> getCustomer(String id) => _fetch('/crm/customers/$id');

  @override
  Future<CustomerModel> createCustomer(
    String farmId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/crm/customers',
        data: {'farm_id': farmId, ...data},
      );
      return CustomerModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  @override
  Future<CustomerModel> updateCustomer(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/crm/customers/$id',
        data: data,
      );
      return CustomerModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete<void>('/crm/customers/$id');
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  @override
  Future<List<CustomerInteractionModel>> getInteractions(
    String customerId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/crm/customers/$customerId/interactions',
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map(
            (json) =>
                CustomerInteractionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  @override
  Future<CustomerInteractionModel> addInteraction(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/crm/customers/$customerId/interactions',
        data: data,
      );
      return CustomerInteractionModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<CustomerModel> _fetch(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      return CustomerModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}
