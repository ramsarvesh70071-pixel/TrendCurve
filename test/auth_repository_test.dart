import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trend_curve/data/local/local_storage_service.dart';
import 'package:trend_curve/data/repositories/auth_repository.dart';
import 'package:trend_curve/data/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AuthService service;
  late AuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    service = LocalAuthService(storage: storage);
    repository = AuthRepository(service);
  });

  group('AuthRepository and AuthService Tests', () {
    test('login authenticates and persists user session', () async {
      expect(await repository.isAuthenticated(), isFalse);

      final user = await repository.login(
        email: 'test@trendcurve.io',
        password: 'password123',
      );

      expect(user.email, equals('test@trendcurve.io'));
      expect(await repository.isAuthenticated(), isTrue);

      final current = await repository.getCurrentUser();
      expect(current?.email, equals('test@trendcurve.io'));
    });

    test('register creates new account and logs user in', () async {
      final user = await repository.register(
        name: 'Jordan Lee',
        email: 'jordan@trendcurve.io',
        password: 'securePassword!',
      );

      expect(user.name, equals('Jordan Lee'));
      expect(user.email, equals('jordan@trendcurve.io'));
      expect(await repository.isAuthenticated(), isTrue);
    });

    test('logout clears session and resets authentication status', () async {
      await repository.login(
        email: 'test@trendcurve.io',
        password: 'password123',
      );
      expect(await repository.isAuthenticated(), isTrue);

      await repository.logout();
      expect(await repository.isAuthenticated(), isFalse);
    });

    test('verifyOtp returns true for valid test code 123456', () async {
      final result = await repository.verifyOtp(
        email: 'test@trendcurve.io',
        otp: '123456',
      );
      expect(result, isTrue);
    });
  });
}
