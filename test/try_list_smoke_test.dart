// test/try_list_smoke_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:similar_eats_desktop/firebase_options.dart';
import 'package:similar_eats_desktop/features/try_list/try_list_repo.dart' as tr;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Init Core
    try {
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Ensure DB instance uses an explicit URL (helps on desktop/tests)
    FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL ??
          'https://similar-eats-default-rtdb.firebaseio.com',
    );
  });

  testWidgets('TryList add -> list -> delete', (tester) async {
    // Use a synthetic uid for tests so we don’t need firebase_auth
    final uid = 'test-smoke-${DateTime.now().millisecondsSinceEpoch}';
    final repo = tr.TryListRepo();

    // 1) add
    final name = 'SmokeTest ${DateTime.now().millisecondsSinceEpoch}';
    await repo.addItem(uid: uid, name: name);

    // 2) verify it appears
    final addedSeen = Completer(); // untyped to avoid type dupes
    final sub = repo.watchItems(uid).listen((items) {
      final matches = items.where((e) => e.name == name).toList();
      if (matches.isNotEmpty && !addedSeen.isCompleted) {
        addedSeen.complete(matches.first); // tr.TryItem
      }
    });
    final tr.TryItem added = (await addedSeen.future
        .timeout(const Duration(seconds: 10))) as tr.TryItem;
    expect(added.name, name);

    // 3) delete
    await repo.deleteItem(uid: uid, id: added.id);

    // 4) verify removal
    final removedSeen = Completer<void>();
    final sub2 = repo.watchItems(uid).listen((items) {
      if (!items.any((e) => e.id == added.id) && !removedSeen.isCompleted) {
        removedSeen.complete();
      }
    });
    await removedSeen.future.timeout(const Duration(seconds: 10));

    await sub.cancel();
    await sub2.cancel();
  });
}
