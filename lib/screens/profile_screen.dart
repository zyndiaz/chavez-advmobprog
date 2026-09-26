import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService().getUserData();
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    context.read<CartProvider>().clearCart();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
  }

  Future<void> _editUsername(String currentUsername) async {
    final username = await showDialog<String>(
      context: context,
      builder: (_) => _UsernameDialog(initialUsername: currentUsername),
    );
    if (username == null || username.isEmpty) return;
    try {
      await UserService().updateUsername(username: username);
      if (!mounted) return;
      setState(() {
        _userFuture = UserService().getUserData();
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _changePassword(String email) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (values == null) return;
    if (values[1].length < 8 || values[1] != values[2]) {
      _showError(
        values[1] != values[2]
            ? 'The new passwords do not match.'
            : 'Use at least 8 characters for the new password.',
      );
      return;
    }
    try {
      await UserService().resetPasswordFromCurrentPassword(
        email: email,
        currentPassword: values[0],
        newPassword: values[1],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteAccount(Map<String, dynamic> userData) async {
    final isFirebase = userData['loginType'] == LoginType.firebase.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          isFirebase
              ? 'This permanently deletes your Firebase account and profile.'
              : 'This removes the local session. DummyJSON account deletion is simulated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    var password = '';
    if (isFirebase) {
      password =
          await showDialog<String>(
            context: context,
            builder: (_) => const _PasswordConfirmationDialog(),
          ) ??
          '';
      if (password.isEmpty) return;
    }

    try {
      await UserService().deleteAccount(
        email: userData['email']?.toString() ?? '',
        password: password,
      );
      if (!mounted) return;
      context.read<CartProvider>().clearCart();
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data;
        if (snapshot.hasError ||
            userData == null ||
            userData['loginType'] == null) {
          return Center(
            child: FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (_) => false,
              ),
              child: const Text('Sign in'),
            ),
          );
        }

        final isFirebase = userData['loginType'] == LoginType.firebase.name;
        final firstName = userData['firstName']?.toString() ?? '';
        final lastName = userData['lastName']?.toString() ?? '';
        final username = userData['username']?.toString() ?? '';
        final fullName = '$firstName $lastName'.trim();
        final email = userData['email']?.toString() ?? '';
        final image = userData['image']?.toString() ?? '';

        return ListView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: const Color(0xFFE8EAF6),
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 52.sp,
                            color: const Color(0xFF394A9A),
                          )
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    fullName.isEmpty ? username : fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '@$username',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isFirebase ? 'Firebase account' : 'DummyJSON account',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _ProfileRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                  ),
                  if ((userData['age']?.toString() ?? '').isNotEmpty) ...[
                    const Divider(height: 1),
                    _ProfileRow(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: userData['age'].toString(),
                    ),
                  ],
                  if ((userData['contactNo']?.toString() ?? '').isNotEmpty) ...[
                    const Divider(height: 1),
                    _ProfileRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact',
                      value: userData['contactNo'].toString(),
                    ),
                  ],
                  if (!isFirebase &&
                      (userData['gender']?.toString() ?? '').isNotEmpty) ...[
                    const Divider(height: 1),
                    _ProfileRow(
                      icon: Icons.people_outline,
                      label: 'Gender',
                      value: userData['gender'].toString(),
                    ),
                  ],
                  const Divider(height: 1),
                  _ProfileRow(
                    icon: Icons.badge_outlined,
                    label: isFirebase ? 'Firebase UID' : 'User ID',
                    value: isFirebase
                        ? userData['id'].toString()
                        : '#${userData['id']}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Update username'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editUsername(username),
                  ),
                  if (isFirebase) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_reset_outlined),
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _changePassword(email),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              onPressed: () => _deleteAccount(userData),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                minimumSize: Size.fromHeight(50.h),
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 50.h,
              child: FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6257),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UsernameDialog extends StatefulWidget {
  final String initialUsername;

  const _UsernameDialog({required this.initialUsername});

  @override
  State<_UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<_UsernameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialUsername,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close([String? value]) async {
    FocusScope.of(context).unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update username'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      actions: [
        TextButton(onPressed: () => _close(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => _close(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _close([List<String>? values]) async {
    FocusScope.of(context).unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
          TextField(
            controller: _newPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          TextField(
            controller: _confirmPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm new password',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => _close(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => _close([
            _currentPassword.text,
            _newPassword.text,
            _confirmPassword.text,
          ]),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _PasswordConfirmationDialog extends StatefulWidget {
  const _PasswordConfirmationDialog();

  @override
  State<_PasswordConfirmationDialog> createState() =>
      _PasswordConfirmationDialogState();
}

class _PasswordConfirmationDialogState
    extends State<_PasswordConfirmationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close([String? value]) async {
    FocusScope.of(context).unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm your password'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      actions: [
        TextButton(onPressed: () => _close(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => _close(_controller.text),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE0B422)),
          SizedBox(width: 12.w),
          SizedBox(
            width: 104.w,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
