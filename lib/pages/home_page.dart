import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../local_storage/entity/interest_entity.dart';
import '../local_storage/entity/school_entity.dart';
import '../local_storage/entity/user_entity.dart';
import '../local_storage/local_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<List<User>>? storageStreamSubscription;

  StreamController<List<User>> streamController = StreamController<List<User>>()..sink.add([]);
  Stream get usersDataStream => streamController.stream;
  StreamSink get usersStreamSink => streamController.sink;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    storageStreamSubscription = LocalStorage().listenUsers().listen((users) {
      usersStreamSink.add(users);
    });

    final users = await LocalStorage().getUsers();
    usersStreamSink.add(users);
  }

  Future<void> addUser() async {
    final school = School()
      ..name = 'THU'
      ..level = 1;
    final user = User()
      ..name = '${Random().nextInt(10000)}'
      ..gender = Gender.male
      ..school = school
      ..interests = [
        Interest()..name = 'Food',
        Interest()..name = 'Art',
      ];

    LocalStorage().addUser(user);
  }

  Future<void> updateUser(User user) async {
    await LocalStorage().updateUser(user..name = '${Random().nextInt(10000) + 10000}');
  }

  @override
  void dispose() {
    storageStreamSubscription?.cancel();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          GestureDetector(
            onTap: () {
              LocalStorage().clearUser();
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.delete),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: streamController.stream,
          builder: (context, data) {
            final users = data.data?.reversed.toList() ?? [];

            if (users.isEmpty) {
              return const Center(child: Text('No data.'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.id} - ${user.name}',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => updateUser(user),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text(
                          '更新',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          LocalStorage().deleteUser(user.id);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text(
                          '刪除',
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.black.withOpacity(0.5),
                ),
                itemCount: users.length,
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
