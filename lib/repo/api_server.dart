import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jarvis/helper/constant.dart';
import 'package:jarvis/helper/env.dart';
import 'package:jarvis/helper/error.dart';
import 'package:jarvis/helper/event.dart';
import 'package:jarvis/helper/http.dart';
import 'package:jarvis/helper/logger.dart';
import 'package:jarvis/helper/platform.dart';
import 'package:jarvis/page/component/global_alert.dart';
import 'package:jarvis/repo/setting_repo.dart';

class APIServer {
  // Singleton
  static final APIServer _instance = APIServer._internal();
  APIServer._internal();

  factory APIServer() {
    return _instance;
  }

  GlobalAlertEvent _globalAlertEvent = GlobalAlertEvent(id: '', type: 'info', pages: [], message: '');

  GlobalAlertEvent get globalAlertEvent => _globalAlertEvent;

  late String url;
  late String apiToken;
  late String language;

  init(SettingRepository setting) {
    apiToken = setting.stringDefault(settingAPIServerToken, '');
    language = setting.stringDefault(settingLanguage, 'zh');
    url = setting.stringDefault(settingServerURL, apiServerURL);

    Logger.instance.d('API Server URL: $url');

    setting.listen((settings, key, value) {
      if (key == settingAPIServerToken) {
        apiToken = settings.getDefault(settingAPIServerToken, '');
      }

      if (key == settingLanguage) {
        language = settings.getDefault(settingLanguage, 'zh');
      }

      if (key == settingServerURL) {
        url = settings.getDefault(settingServerURL, apiServerURL);
        Logger.instance.d('API Server URL Changed: $url');
      }
    });
  }

  final List<DioExceptionType> _retryableErrors = [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  ];

  // Handling exceptions
  Object _exceptionHandle(Object e, Object? stackTrace) {
    Logger.instance.e(e, stackTrace: stackTrace as StackTrace?);

    if (e is DioException) {
      if (e.response != null) {
        final resp = e.response!;

        if (resp.data is Map &&
            resp.data['error'] != null &&
            resp.statusCode != 402 &&
            resp.statusCode != 401) {
          return resp.data['error'] ?? e.toString();
        }

        if (resp.statusCode != null) {
          final ret = resolveHTTPStatusCode(resp.statusCode!);
          if (ret != null) {
            return ret;
          }
        }

        return resp.statusMessage ?? e.toString();
      }

      if (_retryableErrors.contains(e.type)) {
        return 'Request Timeout, please try again';
      }
    }

    return e.toString();
  }

  Options _buildRequestOptions({int? requestTimeout = 10000}) {
    return Options(
      headers: _buildAuthHeaders(),
      receiveDataWhenStatusError: true,
      sendTimeout: requestTimeout != null
          ? Duration(milliseconds: requestTimeout)
          : null,
      receiveTimeout: requestTimeout != null
          ? Duration(milliseconds: requestTimeout)
          : null,
    );
  }

  Map<String, dynamic> _buildAuthHeaders() {
    final headers = <String, dynamic>{
      'X-CLIENT-VERSION': clientVersion,
      'X-PLATFORM': PlatformTool.operatingSystem(),
      'X-PLATFORM-VERSION': PlatformTool.operatingSystemVersion(),
      'X-LANGUAGE': language,
    };

    if (apiToken == '') {
      return headers;
    }

    headers['Authorization'] = 'Bearer $apiToken';

    return headers;
  }

  /// Get the user ID, return null if not logged in
  int? localUserID() {
    if (apiToken == '') {
      return null;
    }

    // Get user ID from Jwt Token
    final parts = apiToken.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final resp = utf8.decode(base64.decode(normalized));
    final data = jsonDecode(resp);
    return data['id'];
  }

  Future<T> sendGetRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Map<String, dynamic>? queryParameters,
        int? requestTimeout = 10000,
      }) async {
    return request(
      HttpClient.get(
        '$url$endpoint',
        queryParameters: queryParameters,
        options: _buildRequestOptions(requestTimeout: requestTimeout),
      ),
      parser,
    );
  }

  Future<T> sendCachedGetRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        String? subKey,
        Duration duration = const Duration(days: 1),
        Map<String, dynamic>? queryParameters,
        bool forceRefresh = false,
      }) async {
    return request(
      HttpClient.getCached(
        '$url$endpoint',
        queryParameters: queryParameters,
        subKey: subKey,
        duration: duration,
        forceRefresh: forceRefresh,
        options: _buildRequestOptions(),
      ),
      parser,
    );
  }

  Future<T> sendPostRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? formData,
        VoidCallback? finallyCallback,
      }) async {
    return request(
      HttpClient.post(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPostJSONRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? data,
        VoidCallback? finallyCallback,
      }) async {
    return request(
      HttpClient.postJSON(
        '$url$endpoint',
        queryParameters: queryParameters,
        data: data,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPutRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        String? subKey,
        Duration duration = const Duration(days: 1),
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? formData,
        bool forceRefresh = false,
        VoidCallback? finallyCallback,
      }) async {
    return request(
      HttpClient.put(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendPutJSONRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        String? subKey,
        Duration duration = const Duration(days: 1),
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? data,
        bool forceRefresh = false,
        VoidCallback? finallyCallback,
      }) async {
    return request(
      HttpClient.putJSON(
        '$url$endpoint',
        queryParameters: queryParameters,
        data: data,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> sendDeleteRequest<T>(
      String endpoint,
      T Function(dynamic) parser, {
        String? subKey,
        Duration duration = const Duration(days: 1),
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? formData,
        bool forceRefresh = false,
        VoidCallback? finallyCallback,
      }) async {
    return request(
      HttpClient.delete(
        '$url$endpoint',
        queryParameters: queryParameters,
        formData: formData,
        options: _buildRequestOptions(),
      ),
      parser,
      finallyCallback: finallyCallback,
    );
  }

  Future<T> request<T>(
      Future<Response<dynamic>> respFuture,
      T Function(dynamic) parser, {
        VoidCallback? finallyCallback,
      }) async {
    try {
      final resp = await respFuture;
      if (resp.statusCode != 200 && resp.statusCode != 304) {
        return Future.error(resp.data['error']);
      }

      try {
        var msg = resp.headers.value('jarvis-global-alert-msg');
        if (msg != null) {
          msg = utf8.decode(base64Decode(msg));
        }

        // Logger.instance.d("API Response: ${resp.data}");
        final globalAlertEvent = GlobalAlertEvent(
          id: resp.headers.value('jarvis-global-alert-id') ?? '',
          type: resp.headers.value('jarvis-global-alert-type') ?? 'info',
          pages: (resp.headers.value('jarvis-global-alert-pages') ?? '')
              .split(',')
              .where((e) => e != '')
              .toList(),
          message: msg,
        );

        if (globalAlertEvent.id != '' &&
            globalAlertEvent.id != _globalAlertEvent.id) {
          _globalAlertEvent = globalAlertEvent;
          GlobalEvent().emit('global-alert', _globalAlertEvent);
        }
      } catch (e) {
        Logger.instance.e(e);
      }

      return parser(resp);
    } catch (e, stackTrace) {
      return Future.error(_exceptionHandle(e, stackTrace));
    } finally {
      finallyCallback?.call();
    }
  }

  String? _cacheSubKey() {
    final localUserId = localUserID();
    if (localUserId == null) {
      return null;
    }

    return 'local-uid=$localUserId';
  }

}