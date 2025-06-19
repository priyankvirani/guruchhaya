import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/responsive.dart';
import 'package:guruchaya/helper/string.dart';
import 'package:guruchaya/provider/auth_provider.dart';
import 'package:guruchaya/widgets/app_button.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:provider/provider.dart';

import '../language/localization/language/languages.dart';
import '../provider/booking_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController emailController =
  //     TextEditingController(text: 'cvirani218@gmail.com');
  // TextEditingController passwordController =
  //     TextEditingController(text: 'Chirag@123\$');

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(builder: (context, authStore, snapshot) {
        return Stack(
          children: [
            Center(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.padding_20),
                  child: SizedBox(
                    width: Responsive.isDesktop(context) ? Dimens.dimen_400 : MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: Responsive.isDesktop(context) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Languages.of(context)!.login,
                          style: TextStyle(
                              color: Theme.of(context).textTheme.labelSmall!.color,
                              fontSize: Dimens.fontSize_32,
                              fontFamily: Fonts.bold),
                        ),
                        SizedBox(
                          height: Dimens.height_12,
                        ),
                        Text(
                          Languages.of(context)!.loginContent,
                          textAlign: Responsive.isDesktop(context) ? TextAlign.center : TextAlign.start,
                          style: TextStyle(
                              color: Theme.of(context).textTheme.labelLarge!.color,
                              fontSize: Dimens.fontSize_14,
                              fontFamily: Fonts.regular),
                        ),
                        SizedBox(
                          height: Dimens.height_48,
                        ),
                        AppTextField(
                          controller: emailController,
                          titleText: Languages.of(context)!.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Languages.of(context)!.emailRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        AppTextField(
                          controller: passwordController,
                          titleText: Languages.of(context)!.password,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Languages.of(context)!.passwordRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: Dimens.height_30,
                        ),
                        AppButton(
                          label: Languages.of(context)!.submit,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await authStore.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              getBookingStore(NavigationService.context)
                                  .getAllBusNumber();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            LoadingWithBackground(authStore.loading)
          ],
        );
      }),
    );
  }
}
