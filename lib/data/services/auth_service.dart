import 'package:uuid/uuid.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../local/local_storage_service.dart';
import '../models/user_model.dart';

/// Abstract Authentication Service layer.
abstract class AuthService {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> forgotPassword(String email);
  Future<bool> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}

/// Implementation using local storage with seamless future API hookup.
class LocalAuthService implements AuthService {
  final LocalStorageService storage;
  final ApiClient? apiClient;
  final _uuid = const Uuid();

  LocalAuthService({
    required this.storage,
    this.apiClient,
  });

  @override
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate brief network latency for authentic UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationException('Email and password are required');
    }

    if (password.length < 6) {
      throw const ValidationException('Invalid credentials');
    }

    var user = storage.getUser();
    if (user == null || user.email.toLowerCase() != email.toLowerCase().trim()) {
      user = UserModel(
        id: _uuid.v4(),
        name: email.split('@').first.replaceFirst(
              email[0],
              email[0].toUpperCase(),
            ),
        email: email.trim(),
        avatarUrl: null,
        createdAt: DateTime.now(),
      );
    }

    final token = 'tc_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    await storage.setAuthToken(token);
    await storage.saveUser(user);
    return user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty) {
      throw const ValidationException('Name is required');
    }
    if (email.trim().isEmpty) {
      throw const ValidationException('Email is required');
    }
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      avatarUrl: null,
      createdAt: DateTime.now(),
    );

    final token = 'tc_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    await storage.setAuthToken(token);
    await storage.saveUser(user);
    return user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.trim().isEmpty) {
      throw const ValidationException('Email is required');
    }
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (otp.trim().length != 6) {
      throw const ValidationException('Please enter a valid 6-digit code');
    }
    // Accept valid 6-digit OTP (e.g. 123456 or any 6 digits for testing)
    return true;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (newPassword.length < 6) {
      throw const ValidationException('Password must be at least 6 characters');
    }
  }

  @override
  Future<void> logout() async {
    await storage.setAuthToken(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await storage.getAuthToken();
    if (token == null) return null;
    return storage.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
