import 'package:isar/isar.dart';

import 'entity/user_entity.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() => _instance;

  LocalStorage._internal();

  late Isar isar;

  Future<Isar> init() async {
    isar = await Isar.open(
      [UserSchema],
      inspector: true,
    );

    return isar;
  }

  Future<List<User>> getUsers() async {
    return isar.users.where().findAll();
  }

  Stream<List<User>> listenUsers() {
    Stream<void> usersUpdatedStream = isar.users.watchLazy();
    usersUpdatedStream.listen((voidEvent) {});

    return isar.users.where().watch();
  }

  Future<void> addUser(User user) async {
    await isar.writeTxn(() => isar.users.put(user));
  }

  Future<void> updateUser(User user) async {
    await isar.writeTxn(() => isar.users.put(user));
  }

  Future<void> deleteUser(int userId) async {
    await isar.writeTxn(() => isar.users.delete(userId));
  }

  Future<void> clearUser() async {
    await isar.writeTxn(() => isar.users.clear());
  }
}
