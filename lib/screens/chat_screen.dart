import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  late Stream<List<Map<String, dynamic>>> _usersStream;
  String? _currentUserEmail;
  String? _currentUserId;
  String _searchText = '';
  bool _isLoadingCurrentUser = true;

  @override
  void initState() {
    super.initState();
    _usersStream = _createUsersStream();
    _loadCurrentUserEmail();
  }

  Stream<List<Map<String, dynamic>>> _createUsersStream() {
    return _chatService.getUsersStream().timeout(
      const Duration(seconds: 12),
      onTimeout: (sink) => sink.addError(
        TimeoutException(
          'Firestore did not return chat users within 12 seconds.',
        ),
      ),
    );
  }

  void _retryUsers() {
    setState(() => _usersStream = _createUsersStream());
  }

  Future<void> _loadCurrentUserEmail() async {
    try {
      final userData = await userService.value.getUserData();
      if (!mounted) return;

      final userId = userData['uid']?.toString() ?? '';
      setState(() {
        _currentUserEmail = userData['email']?.toString();
        _currentUserId = userId;
        _isLoadingCurrentUser = false;
      });

      if (userId.isNotEmpty) {
        try {
          await userService.value.syncChatDirectory();
        } catch (error) {
          debugPrint('Could not sync chat directory: $error');
        }
      }
    } catch (error) {
      debugPrint('Could not load current chat user: $error');
      if (!mounted) return;
      setState(() => _isLoadingCurrentUser = false);
    }
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCurrentUser) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return const Center(
        child: CustomText(
          text: 'Sign in with a registered Firebase account to use chat.',
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: (_searchChatController.text.isNotEmpty)
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Users Stream
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _usersStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(24.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 36),
                        SizedBox(height: 12.h),
                        CustomText(
                          text: 'Could not load chat users',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        SelectableText(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        TextButton.icon(
                          onPressed: _retryUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(text: 'No users found', fontSize: 16.sp),
                  ),
                );
              }

              final users = snapshot.data!;

              // Filter users based on search text and exclude current user
              final filteredUsers = users.where((user) {
                final email = (user['email'] ?? '').toString();
                final uid = (user['uid'] ?? '').toString();
                final name =
                    [user['firstName'], user['lastName'], user['username']]
                        .whereType<String>()
                        .where((part) => part.isNotEmpty)
                        .join(' ');

                if (uid.isNotEmpty && uid == _currentUserId) return false;
                if (email.isNotEmpty &&
                    email.toLowerCase() == _currentUserEmail?.toLowerCase()) {
                  return false;
                }

                final query = _searchText.trim().toLowerCase();
                return query.isEmpty ||
                    name.toLowerCase().contains(query) ||
                    email.toLowerCase().contains(query);
              }).toList();

              if (filteredUsers.isEmpty) {
                return Container(
                  height: ScreenUtil().screenHeight * 0.6,
                  padding: EdgeInsets.all(16.sp),
                  child: Center(
                    child: CustomText(
                      text: _searchText.trim().isEmpty
                          ? 'No other users found'
                          : 'No users match your search',
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return GestureDetector(
                    onTap: () {
                      if (_currentUserEmail == null ||
                          _currentUserEmail!.isEmpty ||
                          _currentUserId == null ||
                          _currentUserId!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Sign in with a registered account to chat.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            currentUserEmail: _currentUserEmail!,
                            tappedUser: user,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: CustomText(
                            text: _displayName(user).isNotEmpty
                                ? _displayName(user)[0].toUpperCase()
                                : '?',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: CustomText(
                          text: _displayName(user),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        subtitle: CustomText(
                          text: user['email']?.toString() ?? 'No email',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _displayName(Map<String, dynamic> user) {
    final fullName = [
      user['firstName'],
      user['lastName'],
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
    return fullName.isNotEmpty
        ? fullName
        : (user['username'] ?? 'Unknown').toString();
  }
}
