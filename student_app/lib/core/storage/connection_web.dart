/// Web sqlite executor (sqlite3.wasm lives in web/).
library;

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnection() => DatabaseConnection.delayed(
  Future<DatabaseConnection>(() async {
    final WasmDatabaseResult result = await WasmDatabase.open(
      databaseName: 'mothakira',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  }),
);