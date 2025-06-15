import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// string_validator 패키지를 import 합니다.
import 'package:string_validator/string_validator.dart' as validator;

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/ui_utils.dart';
import '../viewmodels/signup_viewmodel.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(signupViewModelProvider.notifier)
        .signup(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signupViewModelProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          String errorMessage =
              'An error occurred during registration. Please try again later.';
          if (error is Failure) {
            errorMessage = error.message;
          }
          showErrorSnackbar(context, message: errorMessage);
        },
      );
    });

    final signupAsyncValue = ref.watch(signupViewModelProvider);
    final isLoading = signupAsyncValue is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
                  // Username TextFormField
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: '2 to 20 characters',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter username';
                      }
                      if (value.trim().length < 2) {
                        return 'Please enter at least 2 characters for username.';
                      }
                      if (value.trim().length > 20) {
                        return 'Please enter a username up to 20 characters long.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

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
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password TextFormField
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your confirmation password.';
                      }
                      if (value != _passwordController.text) {
                        return 'The password does not match.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: isLoading ? null : (_) => _submit(),
                    enabled: signupAsyncValue is! AsyncLoading,
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
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 16),

                  // Login Navigation
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.goNamed(RouteNames.login),
                    child: const Text('Already a member? Login!'),
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
