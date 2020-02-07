import 'package:flutter/foundation.dart';
import 'package:oauroadmap/locator.dart';
import 'package:oauroadmap/services/authentication_service.dart';
import 'package:oauroadmap/services/dialog_service.dart';

import 'base_model.dart';

class SignUpViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final DialogService _dialogService = locator<DialogService>();

  Future register(
      {@required String email,
      @required String matricNo,
      @required String password}) async {
    loginSetBusy(true);
    var result = await _authenticationService.registerWithEmail(
        email: email, matricNo: matricNo, password: password);

    loginSetBusy(false);
    if (result is bool) {
      if (result) {
        await _dialogService.showDialog(
          title: 'Sign Up Success',
          description:
              'Your account has been created successfully. You can now login.',
        );
      } else {
        await _dialogService.showDialog(
          title: 'Sign Up Failure',
          description: 'General sign up failure. Please try again later',
        );
      }
    } else if (matricNo.isEmpty || matricNo == null) {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: "Given String is empty or null",
      );
    } else {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: result,
      );
    }
  }
}
