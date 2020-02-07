import 'package:flutter/material.dart';
import 'package:oauroadmap/ui/shared/ui_helpers.dart';
import 'package:oauroadmap/ui/views/forget_password_view.dart';
import 'package:oauroadmap/ui/views/signup_view.dart';
import 'package:oauroadmap/ui/widgets/busy_button.dart';
import 'package:oauroadmap/ui/widgets/input_field.dart';
import 'package:oauroadmap/ui/widgets/text_link.dart';
import 'package:oauroadmap/viewmodels/login_view_model.dart';
import 'package:provider_architecture/provider_architecture.dart';

class LoginView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final matricController = TextEditingController();

  final matricFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<LoginViewModel>.withConsumer(
      viewModel: LoginViewModel(),
      builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text("OAU Road Map"),
          ),
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
                      nextFocusNode: matricFocusNode,
                      placeholder: 'Email (e.g - test@gmail.com)',
                      controller: emailController,
                    ),
                    verticalSpaceSmall,
                    InputField(
                      textInputAction: TextInputAction.next,
                      nextFocusNode: passwordFocusNode,
                      placeholder: 'Matric no (e.g - CSC/2014/077)',
                      controller: matricController,
                    ),
                    verticalSpaceSmall,
                    InputField(
                      textInputAction: TextInputAction.done,
                      placeholder: 'Password',
                      password: true,
                      controller: passwordController,
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BusyButton(
                            title: 'Anonymous',
                            busy: model.anonymousBusy,
                            onPressed: () {
                              model.loginAnonymously();
                            }),
                        BusyButton(
                          title: 'Login',
                          busy: model.busy,
                          onPressed: () {
                            model.login(
                              email: emailController.text,
                              password: passwordController.text,
                              matricNo: matricController.text,
                            );
                          },
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    TextLink(
                      'Create an Account if you\'re new.',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpView()));
                      },
                    ),
                    verticalSpaceMedium,
                    TextLink(
                      'Forget password?',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPasswordView()));
                      },
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
