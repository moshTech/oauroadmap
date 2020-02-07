import 'package:flutter/material.dart';
import 'package:oauroadmap/ui/shared/ui_helpers.dart';
import 'package:oauroadmap/ui/widgets/busy_button.dart';
import 'package:oauroadmap/ui/widgets/input_field.dart';
import 'package:oauroadmap/viewmodels/signup_view_model.dart';
import 'package:provider_architecture/provider_architecture.dart';

class SignUpView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final matricController = TextEditingController();

  final matricFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OAU Road Map"),
      ),
      body: ViewModelProvider<SignUpViewModel>.withConsumer(
        viewModel: SignUpViewModel(),
        builder: (context, model, child) => Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 38,
                      ),
                    ),
                    verticalSpaceLarge,
                    InputField(
                      textInputAction: TextInputAction.next,
                      nextFocusNode: matricFocusNode,
                      placeholder: 'Email',
                      controller: emailController,
                    ),
                    verticalSpaceSmall,
                    InputField(
                      textInputAction: TextInputAction.next,
                      nextFocusNode: passwordFocusNode,
                      placeholder: 'Matric no',
                      controller: matricController,
                    ),
                    verticalSpaceSmall,
                    InputField(
                      textInputAction: TextInputAction.done,
                      // nextFocusNode: confirmPasswordFocusNode,
                      placeholder: 'Password',
                      password: true,
                      controller: passwordController,
                      additionalNote:
                          'Password has to be a minimum of 6 characters.',
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BusyButton(
                          title: 'Sign Up',
                          busy: model.busy,
                          onPressed: () {
                            model.register(
                              email: emailController.text,
                              password: passwordController.text,
                              matricNo: matricController.text,
                            );
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
