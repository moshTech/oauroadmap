import 'package:flutter/widgets.dart';

class BaseModel extends ChangeNotifier {
  bool _busy = false;
  bool _anonyBusy = false;
  bool get busy => _busy;
  bool get anonymousBusy => _anonyBusy;
  bool _restBusy = false;
  bool get resetBusy => _restBusy;

  void loginSetBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void anonymousSetBusy(bool value) {
    _anonyBusy = value;
    notifyListeners();
  }

  void resetSetBusy(bool value) {
    _anonyBusy = value;
    notifyListeners();
  }
}
