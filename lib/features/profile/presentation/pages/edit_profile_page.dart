import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../domain/entities/profile.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameConroller = TextEditingController();
  File? _selectedImage;
  String? _existingImageUrl;
  bool _imageWasRemoved = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileViewModelProvider).valueOrNull;
    if (profile != null) {
      _usernameConroller.text = profile.username;
      _existingImageUrl = profile.avatarUrl;
    }
  }

  @override
  void dispose() {
    _usernameConroller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageWasRemoved = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(
          username: _usernameConroller.text.trim(),
          newAvatarFile: _selectedImage,
          avatarWasRemoved: _imageWasRemoved,
        );
  }

  Widget _buildAvatar() {
    Widget imageWidget;
    // 사용자가 image를 선택
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    // 사용자의 profile image가 이미 있고,
    else if (_existingImageUrl != null && !_imageWasRemoved) {
      imageWidget = Image.network(_existingImageUrl!, fit: BoxFit.cover);
    }
    // 사용자의 profile image가 없고,
    else {
      imageWidget = const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    return CircleAvatar(
      radius: 60,
      child: ClipOval(
        child: SizedBox.fromSize(
          size: const Size.fromRadius(60),
          child: imageWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Profile?>>(profileViewModelProvider, (prev, next) {
      next.mapOrNull(
        error: (e) {
          final message = (e is Failure)
              ? (e as Failure).message
              : 'An unknown error occurred';
          showErrorSnackbar(context, message: message);
        },
        data: (_) {
          if (context.canPop()) context.pop();
        },
      );
    });

    final profileState = ref.watch(profileViewModelProvider);
    final isLoading = profileState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatar(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: isLoading ? null : _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Change'),
                  ),
                  TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => setState(() {
                            _selectedImage = null;
                            _imageWasRemoved = true;
                          }),
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameConroller,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
