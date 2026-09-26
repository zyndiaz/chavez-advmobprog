import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  LoginType _loginType = LoginType.dummyJson;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Activity 4 Enhancement 2: authenticate, persist the returned user, then enter home.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    var didNavigate = false;
    try {
      if (_loginType == LoginType.firebase) {
        await UserService().signIn(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await UserService().loginUser(
          _usernameController.text.trim(),
          _passwordController.text,
        );
      }
      if (!mounted) return;
      didNavigate = true;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in failed: $message')));
    } finally {
      if (mounted && !didNavigate) setState(() => _isLoading = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide.none,
    );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF394A9A)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.r),
        borderSide: const BorderSide(color: Color(0xFF394A9A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.r),
        borderSide: const BorderSide(color: Color(0xFFD94C47)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.r),
        borderSide: const BorderSide(color: Color(0xFFD94C47), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFDCE3F6)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 520.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                26.w,
                                30.h,
                                26.w,
                                8.h,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/nubdexchange_logo.jpg',
                                    width: 82.w,
                                    height: 82.w,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Sign in to continue shopping.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                26.w,
                                24.h,
                                26.w,
                                30.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SegmentedButton<LoginType>(
                                    showSelectedIcon: false,
                                    segments: const [
                                      ButtonSegment(
                                        value: LoginType.dummyJson,
                                        label: Text('DummyJSON'),
                                      ),
                                      ButtonSegment(
                                        value: LoginType.firebase,
                                        label: Text('Firebase'),
                                      ),
                                    ],
                                    selected: {_loginType},
                                    onSelectionChanged: _isLoading
                                        ? null
                                        : (selection) => setState(
                                            () => _loginType = selection.first,
                                          ),
                                  ),
                                  SizedBox(height: 18.h),
                                  TextFormField(
                                    controller: _usernameController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType:
                                        _loginType == LoginType.firebase
                                        ? TextInputType.emailAddress
                                        : TextInputType.text,
                                    decoration: _fieldDecoration(
                                      label: _loginType == LoginType.firebase
                                          ? 'Email address'
                                          : 'Username',
                                      icon: _loginType == LoginType.firebase
                                          ? Icons.email_outlined
                                          : Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return _loginType == LoginType.firebase
                                            ? 'Enter your email address'
                                            : 'Enter your username';
                                      }
                                      if (_loginType == LoginType.firebase &&
                                          !RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          ).hasMatch(value.trim())) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 14.h),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    onFieldSubmitted: (_) => _login(),
                                    decoration: _fieldDecoration(
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        tooltip: _obscurePassword
                                            ? 'Show password'
                                            : 'Hide password',
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Enter your password'
                                        : null,
                                  ),
                                  SizedBox(height: 22.h),
                                  SizedBox(
                                    height: 56.h,
                                    child: FilledButton.icon(
                                      onPressed: _isLoading ? null : _login,
                                      icon: _isLoading
                                          ? SizedBox.square(
                                              dimension: 20.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                            )
                                          : const Icon(Icons.login),
                                      label: Text(
                                        _isLoading ? 'Signing in' : 'Sign In',
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE7C342,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF17235F,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_loginType == LoginType.firebase) ...[
                                    SizedBox(height: 10.h),
                                    TextButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : () => Navigator.pushNamed(
                                              context,
                                              '/signup',
                                            ),
                                      icon: const Icon(Icons.person_add_alt_1),
                                      label: const Text('Create an account'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
