import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    var isLoggedIn = false;
    try {
      isLoggedIn = await UserService().isLoggedIn().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 245, 245, 246),
                Color.fromARGB(255, 27, 42, 109),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 22.h),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 142.w,
                    height: 142.w,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: const Color(0xFFE7C342),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/nubdexchange_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 190.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Color(0x55FFFFFF),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFE7C342),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Welcome to NU Bulldogs Exchange!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  Text(
                    'NU Bulldogs Exchange',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 42.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7C342),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
