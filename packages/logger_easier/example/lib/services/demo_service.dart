import 'dart:math';
import '../app/log_helper.dart';

class DemoService {
  Future<void> performRiskyOperation() async {
    try {
      Log.debug('Starting risky operation');

      if (Random().nextBool()) {
        throw BusinessException('Operation failed', 500);
      }

      Log.info('Risky operation completed successfully');
    } catch (e, stack) {
      Log.error('Risky operation failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<String> fetchData() async {
    return await Log.measureAsync('fetch_data', () async {
      try {
        await Future.delayed(const Duration(seconds: 1));

        if (Random().nextBool()) {
          throw NetworkException('Network error');
        }

        return 'Data fetched successfully';
      } catch (e, stack) {
        Log.error('Failed to fetch data', error: e, stackTrace: stack);
        rethrow;
      }
    });
  }
}

class BusinessException implements Exception {
  final String message;
  final int code;

  BusinessException(this.message, this.code);

  @override
  String toString() => 'BusinessException: $message (Code: $code)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
