import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  /// singleton
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();

  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no";
  static const String COLUMN_NOTE_TITLE = "title";
  static const String COLUMN_NOTE_DISC = "desc";

  Database? myDB;

  /// db open() if exist then open else create ( all queries )
  Future<Database> getDB() async {
    myDB = myDB ?? await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE $TABLE_NOTE ("
              "$COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$COLUMN_NOTE_TITLE TEXT, "
              "$COLUMN_NOTE_DISC TEXT)"
      );
      Fluttertoast.showToast(msg: "Table created successfully"); // Show toast after table creation
    }, version: 1);
  }

  /// ALL QUERIES
  Future<bool> addNote(String myTitle, String myDesc) async {
    try {
      var db = await getDB();
      int rowsAffected = await db.insert(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: myTitle,
          COLUMN_NOTE_DISC: myDesc,
        },
      );
      return rowsAffected > 0;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding note: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getallNotes() async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
      return mData;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching notes: $e");
      return [];
    }
  }

  /// update data function
  Future<bool> updateNote({required String title, required String desc, required int sno}) async {
    try {
      var db = await getDB();
      int rowsAffected = await db.update(TABLE_NOTE, {
        COLUMN_NOTE_TITLE: title,
        COLUMN_NOTE_DISC: desc,
      }, where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
      return rowsAffected > 0;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating note: $e");
      return false;
    }
  }

  /// delete function
  Future<bool> deleteNote({required int sno}) async {
    try {
      var db = await getDB();
      int rowsAffected = await db.delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
      return rowsAffected > 0;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting note: $e");
      return false;
    }
  }
}
