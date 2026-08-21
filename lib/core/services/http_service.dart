import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'http_service.g.dart';

/// Singleton HTTP client shared across all services.
///
/// [dio] is the default uncached client. Use it for mutations, payment flows,
/// Cloud Functions, Stripe, booking writes, OTP writes, auth-sensitive calls,
/// and anything that must never be served from cache.
///
/// [cachedDio] is a separate client for safe read-only GET APIs such as:
/// - Nominatim search
/// - Nominatim reverse geocoding
/// - OSRM routing
class HttpService {
  HttpService._()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: AppConstants.httpConnectTimeout,
          receiveTimeout: AppConstants.httpReceiveTimeout,
        ),
      ) {
    _configureBaseDio(_dio);
  }

  static HttpService? _instance;

  static HttpService get instance {
    _instance ??= HttpService._();
    return _instance!;
  }

  final Dio _dio;

  Dio? _cachedDio;
  Future<Dio>? _cachedDioFuture;

  /// Default uncached Dio client.
  Dio get dio => _dio;

  /// Cached Dio client for safe read-only GET requests.
  ///
  /// Do not use this for payments, Stripe, Cloud Functions mutations, booking
  /// writes, OTP writes, premium checks, auth-sensitive calls, or security
  /// decisions.
  Future<Dio> get cachedDio {
    final cached = _cachedDio;
    if (cached != null) return Future.value(cached);

    return _cachedDioFuture ??= _createCachedDio();
  }

  Future<Dio> _createCachedDio() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: AppConstants.httpConnectTimeout,
          receiveTimeout: AppConstants.httpReceiveTimeout,
        ),
      );

      _configureBaseDio(dio);

      final cacheDir = await getTemporaryDirectory();

      final cacheOptions = CacheOptions(
        store: HiveCacheStore(
          cacheDir.path,
          hiveBoxName: 'sportconnect_http_cache',
        ),
        hitCacheOnNetworkFailure: true,
        hitCacheOnErrorCodes: const [500, 502, 503, 504],
        maxStale: const Duration(days: 7),
      );

      final cacheInterceptor = DioCacheInterceptor(options: cacheOptions);

      // Insert the cache interceptor after TalkerDioLogger if verbose logging is
      // enabled, otherwise insert it first.
      //
      // Verbose on:
      //   0. TalkerDioLogger
      //   1. DioCacheInterceptor
      //   2. _RetryInterceptor
      //   3. _NominatimRateLimitInterceptor
      //
      // Verbose off:
      //   0. DioCacheInterceptor
      //   1. _RetryInterceptor
      //   2. _NominatimRateLimitInterceptor
      const cacheIndex = TalkerService.isVerboseLoggingEnabled ? 1 : 0;
      dio.interceptors.insert(cacheIndex, cacheInterceptor);

      _cachedDio = dio;
      return dio;
    } on Object catch (e, st) {
      _cachedDioFuture = null;
      TalkerService.warning('cachedDio initialization failed: $e');
      TalkerService.error('cachedDio initialization error', e, st);
      rethrow;
    }
  }

  void _configureBaseDio(Dio dio) {
    if (TalkerService.isVerboseLoggingEnabled) {
      dio.interceptors.add(TalkerService.dioLogger);
    }

    dio
      ..interceptors.add(_RetryInterceptor(dio))
      ..interceptors.add(_NominatimRateLimitInterceptor());
  }
}

@Riverpod(keepAlive: true)
HttpService httpService(Ref ref) => HttpService.instance;

// ─────────────────────────────────────────────────────────────────────────────
// Retry interceptor — exponential back-off with ±25 % jitter
//
// Retries on: connection errors, send/receive/connect timeouts, 429, 5xx.
// Respects Retry-After response header, seconds only.
// Does NOT retry 4xx except 429 — those are caller errors.
// ─────────────────────────────────────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  static const _maxRetries = 3;
  static const _retryKey = '_retryCount';

  // Base back-off: 1 s → 2 s → 4 s.
  static const _baseDelaysMs = [1000, 2000, 4000];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;

    if (!_shouldRetry(err) || retryCount >= _maxRetries) {
      return handler.next(err);
    }

    final retryAfterMs = _parseRetryAfterMs(err.response?.headers);
    final baseMs =
        retryAfterMs ??
        _baseDelaysMs[retryCount.clamp(0, _baseDelaysMs.length - 1)];

    // Jitter multiplier in [0.75, 1.25] to spread concurrent retries.
    final jitter = Random().nextDouble() * 0.5 + 0.75;
    final delayMs = (baseMs * jitter).round();

    TalkerService.warning(
      'HTTP retry ${retryCount + 1}/$_maxRetries in ${delayMs}ms '
      '[${err.type.name}] ${err.requestOptions.path}',
    );

    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final opts = err.requestOptions..extra[_retryKey] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        return code == 429 || code >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
      default:
        return false;
    }
  }

  /// Parses `Retry-After: <seconds>` into milliseconds.
  ///
  /// Returns null if the header is absent or not a plain second value.
  int? _parseRetryAfterMs(Headers? headers) {
    final raw = headers?.value('retry-after');
    if (raw == null) return null;

    final seconds = int.tryParse(raw.trim());
    return seconds != null ? seconds * 1000 : null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nominatim rate-limit interceptor
//
// OSMF Nominatim public service policy caps clients at 1 request / second
// from a single IP. All Nominatim requests are serialised with a minimum
// 1.1 s gap. Non-Nominatim requests pass through immediately.
// ─────────────────────────────────────────────────────────────────────────────

class _NominatimRateLimitInterceptor extends Interceptor {
  static const _host = 'nominatim.openstreetmap.org';
  static const _minGap = Duration(milliseconds: 1100);

  DateTime? _lastCall;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.uri.host.contains(_host)) {
      handler.next(options);
      return;
    }

    final now = DateTime.now();

    if (_lastCall != null) {
      final elapsed = now.difference(_lastCall!);
      if (elapsed < _minGap) {
        await Future<void>.delayed(_minGap - elapsed);
      }
    }

    _lastCall = DateTime.now();
    handler.next(options);
  }
}
