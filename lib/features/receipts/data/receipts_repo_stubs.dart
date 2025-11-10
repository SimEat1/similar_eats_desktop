import 'dart:io';
import 'package:similar_eats_desktop/features/receipts/data/receipts_repository.dart';

extension ReceiptsRepositoryStubs on ReceiptsRepository {
  Future<void> uploadImage(File file) async {
    // TODO: real upload+parse implementation.
  }

  Stream<List<dynamic>> streamAll() async* {
    // TODO: real Firestore stream.
    yield const [];
  }
}
