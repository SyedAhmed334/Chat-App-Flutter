import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier {
  List<Map<String, String>> _users = [];
  List<Map<String, String>> _filteredUsers = [];

  List<Map<String, String>> get filteredUsers => _filteredUsers;

  void getUsers(List<Map<String, String>> users) {
    _users = users;
    _filteredUsers = _users;
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = _users;
    } else {
      _filteredUsers = _users.where((user) =>
          user['username']!.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }
}