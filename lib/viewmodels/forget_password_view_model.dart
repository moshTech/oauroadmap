import 'package:flutter/foundation.dart';
import 'package:oauroadmap/locator.dart';
import 'package:oauroadmap/services/authentication_service.dart';
import 'package:oauroadmap/services/dialog_service.dart';

import 'base_model.dart';

class ForgetPasswordViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final DialogService _dialogService = locator<DialogService>();

  Future resetPassword({
    @required String email,
  }) async {
    resetSetBusy(true);

    var result = await _authenticationService.recoverPasswordWithEmail(
      email: email,
    );

    resetSetBusy(false);
    if (result == null) {
      await _dialogService.showDialog(
        title: 'Password Reset Success',
        description:
            'A password reset link has been sent to the email provided. Check your mail',
      );
    } else if (result.toString().contains('An internal error has occurred.')) {
      await _dialogService.showDialog(
        title: 'Reset Failure',
        description:
            "No internet connection. Check your internet connection and try again.",
      );
    } else {
      await _dialogService.showDialog(
        title: 'Reset Failure',
        description: result,
      );
    }
  }
}
