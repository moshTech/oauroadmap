import 'package:flutter/foundation.dart';
import 'package:oauroadmap/constants/route_names.dart';
import 'package:oauroadmap/locator.dart';
import 'package:oauroadmap/services/authentication_service.dart';
import 'package:oauroadmap/services/dialog_service.dart';
import 'package:oauroadmap/services/navigation_service.dart';

import 'base_model.dart';

class LoginViewModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Future login(
      {@required String email,
      @required String matricNo,
      @required String password}) async {
    loginSetBusy(true);

    var result = await _authenticationService.loginWithEmail(
        email: email, password: password, matricNo: matricNo);

    loginSetBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService.navigateTo(HomeViewUserRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Login Failure',
          description: 'Couldn\'t login at this moment. Please try again later',
        );
      }
    } else if (matricNo.isEmpty || matricNo == null) {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description: "Given String is empty or null",
      );
    } else if (result.toString().contains('An internal error has occurred.')) {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description:
            "No internet connection. Check your internet connection and try again.",
      );
    } else {
      await _dialogService.showDialog(
        title: 'Login Failure',
        description: result,
      );
    }
  }

  Future loginAnonymously() async {
    anonymousSetBusy(true);

    var result = await _authenticationService.signInAnonymously();

    anonymousSetBusy(false);

    if (result is bool) {
      if (result) {
        _navigationService.navigateTo(HomeViewRoute);
      } else {
        await _dialogService.showDialog(
          title: 'Login Failure',
          description: 'Couldn\'t login at this moment. Please try again later',
        );
      }
    } else if (result
        .toString()
        .contains('An internal error has occurred. [7:]')) {
      await _dialogService.showDialog(
        title: 'Sign Up Failure',
        description:
            "No internet connection. Check your internet connection and try again.",
      );
    } else {
      await _dialogService.showDialog(
        title: 'Login Failure',
        description: result,
      );
    }
  }

  Future logout() async {
    // anonymousSetBusy(true);

    await _authenticationService.signOut();

    // anonymousSetBusy(false);

    _navigationService.navigateTo(LoginViewRoute);

    await _dialogService.showDialog(
      title: 'Logout',
      description: 'Logout successful',
    );
  }
}
