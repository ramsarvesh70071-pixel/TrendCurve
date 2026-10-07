import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel> login({required String email, required String password}) =>
      _authService.login(email: email, password: password);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _authService.register(name: name, email: email, password: password);

  Future<void> forgotPassword(String email) => _authService.forgotPassword(email);

  Future<bool> verifyOtp({required String email, required String otp}) =>
      _authService.verifyOtp(email: email, otp: otp);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      _authService.resetPassword(email: email, otp: otp, newPassword: newPassword);

  Future<void> logout() => _authService.logout();

  Future<UserModel?> getCurrentUser() => _authService.getCurrentUser();

  Future<bool> isAuthenticated() => _authService.isAuthenticated();
}
