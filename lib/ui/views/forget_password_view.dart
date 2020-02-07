import 'package:flutter/material.dart';
import 'package:oauroadmap/ui/shared/ui_helpers.dart';
import 'package:oauroadmap/ui/widgets/busy_button.dart';
import 'package:oauroadmap/ui/widgets/input_field.dart';
import 'package:oauroadmap/viewmodels/forget_password_view_model.dart';
import 'package:provider_architecture/viewmodel_provider.dart';

class ForgetPasswordView extends StatelessWidget {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OAU Road Map"),
      ),
      body: ViewModelProvider<ForgetPasswordViewModel>.withConsumer(
        viewModel: ForgetPasswordViewModel(),
        builder: (context, model, child) => Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/oaulogo.png',
                      ),
                      InputField(
                        textInputAction: TextInputAction.next,
                        placeholder: 'Email (e.g - test@gmail.com)',
                        controller: emailController,
                      ),
                      verticalSpaceMedium,
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BusyButton(
                            title: 'Reset',
                            busy: model.busy,
                            onPressed: () {
                              model.resetPassword(
                                email: emailController.text,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
