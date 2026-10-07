import '../local/local_storage_service.dart';
import '../models/user_model.dart';

abstract class UserService {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile({required String name, required String email});
}

class LocalUserService implements UserService {
  final LocalStorageService storage;

  LocalUserService({required this.storage});

  @override
  Future<UserModel> getUserProfile() async {
    final user = storage.getUser();
    if (user != null) return user;
    final defaultUser = UserModel(
      id: 'usr_default',
      name: 'Alex Rivera',
      email: 'alex.rivera@trendcurve.io',
      createdAt: DateTime.now(),
    );
    await storage.saveUser(defaultUser);
    return defaultUser;
  }

  @override
  Future<UserModel> updateProfile({required String name, required String email}) async {
    final current = await getUserProfile();
    final updated = current.copyWith(name: name.trim(), email: email.trim());
    await storage.saveUser(updated);
    return updated;
  }
}
