import 'package:projectx/constants/db_constants/constants.dart';

class UserDB {
  final int id;
  final String email;
  const UserDB({
    required this.id,
    required this.email,
  });
  UserDB.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'email : $email, id: $id';
  }
}
