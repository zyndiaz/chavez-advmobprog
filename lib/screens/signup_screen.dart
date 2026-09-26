import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _contactNo = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _contactNo.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null;

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    var didNavigate = false;
    try {
      await UserService().createAccount(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        age: int.parse(_age.text.trim()),
        contactNo: _contactNo.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      didNavigate = true;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account creation failed: $message')),
      );
    } finally {
      if (mounted && !didNavigate) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 28.h),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 560.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your account',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Create a Firebase account to continue.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      SizedBox(height: 22.h),
                      _field(
                        controller: _firstName,
                        label: 'First name',
                        capitalization: TextCapitalization.words,
                        validator: (value) =>
                            _required(value, 'your first name'),
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _lastName,
                        label: 'Last name',
                        capitalization: TextCapitalization.words,
                        validator: (value) =>
                            _required(value, 'your last name'),
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _age,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final age = int.tryParse(value?.trim() ?? '');
                          if (age == null || age < 13 || age > 120) {
                            return 'Enter an age from 13 to 120';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _contactNo,
                        label: 'Contact number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final contact = (value ?? '').replaceAll(
                            RegExp(r'[\s()-]'),
                            '',
                          );
                          if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(contact)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _username,
                        label: 'Username',
                        validator: (value) {
                          if (value == null ||
                              !RegExp(
                                r'^[a-zA-Z0-9_.]{3,20}$',
                              ).hasMatch(value.trim())) {
                            return 'Use 3-20 letters, numbers, dots or underscores';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _email,
                        label: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              !RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _password,
                        label: 'Password',
                        obscureText: _hidePassword,
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value) ||
                              !RegExp(r'[a-z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Include uppercase, lowercase and a number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 13.h),
                      _field(
                        controller: _confirmPassword,
                        label: 'Confirm password',
                        obscureText: _hideConfirmPassword,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          tooltip: _hideConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) => value != _password.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      SizedBox(height: 22.h),
                      SizedBox(
                        height: 52.h,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _createAccount,
                          icon: _isLoading
                              ? SizedBox.square(
                                  dimension: 19.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1),
                          label: Text(
                            _isLoading ? 'Creating account' : 'Create account',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Back to sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
