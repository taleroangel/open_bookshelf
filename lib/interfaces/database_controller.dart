import 'package:hive/hive.dart';

abstract class IDatabaseController {
  /// Get the database size in KiB
  Future<double> get databaseSize;

  /// Get ammount of entries in database
  Future<int> get length;

  /// Get access to the underlying Hive database
  Box get database;

  /// Delete all contents in database
  Future<void> deleteDatabase();

  /// Import data into databse in the specified data format
  void import<DataFormat>(DataFormat data);

  /// Export data from database in specified DataFormat
  Future<DataFormat> export<DataFormat>();
}
