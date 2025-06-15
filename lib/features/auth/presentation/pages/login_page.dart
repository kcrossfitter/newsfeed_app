import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// string_validator 패키지를 import 합니다.
import 'package:string_validator/string_validator.dart' as validator;

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/ui_utils.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(loginViewModelProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginViewModelProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          String errorMessage =
              'An error occurred during login. Please try again later.';
          if (error is Failure) {
            errorMessage = error.message;
          }
          showErrorSnackbar(context, message: errorMessage);
        },
      );
    });

    final loginAsyncValue = ref.watch(loginViewModelProvider);
    final isLoading = loginAsyncValue is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 로고나 앱 이름 (선택 사항)
                  Text(
                    'NewsFeed App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),

                  // Email TextFormField
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email.';
                      }
                      if (!validator.isEmail(value.trim())) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password TextFormField
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: '6 to 20 characters',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password.';
                      }
                      if (value.length < 6) {
                        return 'Please enter at least 6 characters for password.';
                      }
                      if (value.length > 20) {
                        return 'Please enter a password up to 20 characters long.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: isLoading ? null : (_) => _submit(),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // Signup Navigation
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.goNamed(RouteNames.signup),
                    child: const Text('Not a member? Sign Up!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
