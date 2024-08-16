import 'package:flutter/material.dart';
import 'package:user_management/src/features/users/controllers/user_controller.dart';
import 'package:user_management/src/features/users/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> users = [];
  String errorString = '';
  bool isLoading = false;
  bool ageAsending = true;
  bool nameAsending = true;

  Future<void> getUsers() async {
    isLoading = true;
    notifyListeners();
    var result = await UserController().getUsers();
    result.fold(
      (l) {
        errorString = l.failure.toString();
        notifyListeners();
      },
      (r) {
        users = r;
        users.sort((a, b) => a.age!.compareTo(b.age!));
        users.sort((a, b) => a.gender!.compareTo(b.gender!));
        notifyListeners();
      },
    );
    isLoading = false;
    notifyListeners();
  }

  void orderByAge() {
    ageAsending = !ageAsending;
    if (ageAsending) {
      users.sort((a, b) => a.age!.compareTo(b.age!));
    } else {
      users.sort((b, a) => a.age!.compareTo(b.age!));
    }

    notifyListeners();
  }

  void orderByName() {
    nameAsending = !nameAsending;
    if (nameAsending) {
      users.sort((a, b) => "${a.firstName![0]} ${a.lastName![0]}"
          .compareTo("${b.firstName![0]} ${b.lastName![0]}"));
    } else {
      users.sort((b, a) => "${a.firstName![0]} ${a.lastName![0]}"
          .compareTo("${b.firstName![0]} ${b.lastName![0]}"));
    }

    notifyListeners();
  }
}
