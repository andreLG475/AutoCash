import 'dart:io';

import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key, this.radius = 18, this.fallbackColor});

  final double radius;
  final Color? fallbackColor;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _avatarPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final userId = DatabaseHelper.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final user = await DatabaseHelper.instance.getUserById(userId);
    if (!mounted) return;

    setState(() {
      _avatarPath = user?.photoPath;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: widget.fallbackColor ?? Colors.white24,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final avatarPath = _avatarPath;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final file = File(avatarPath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.fallbackColor ?? Colors.white24,
          backgroundImage: FileImage(file),
        );
      }
    }

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.fallbackColor ?? Colors.white24,
      child: const Icon(Icons.account_circle, color: Colors.white, size: 30),
    );
  }
}
