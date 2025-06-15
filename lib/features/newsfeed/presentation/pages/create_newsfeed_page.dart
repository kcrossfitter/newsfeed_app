import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../domain/entities/newsfeed_display.dart';
import '../viewmodels/create_newsfeed_viewmodel.dart';
import '../viewmodels/edit_newsfeed_viewmodel.dart';
import '../viewmodels/newsfeed_list_viewmodel.dart';

class CreateNewsfeedPage extends ConsumerStatefulWidget {
  const CreateNewsfeedPage({super.key, this.newsfeedToEdit});

  final NewsfeedDisplay? newsfeedToEdit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewsfeedPageState();
}

class _CreateNewsfeedPageState extends ConsumerState<CreateNewsfeedPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  File? _selectedImage;
  // 기존 image URL을 저장할 변수
  String? _existingImageUrl;
  bool _imageWasRemoved = false; // 이미지 제거 여부를 추적하는 flag

  // 수정 모드인지 확인하는 getter
  bool get isEditMode => widget.newsfeedToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.newsfeedToEdit!.title;
      _contentController.text = widget.newsfeedToEdit!.content;
      _existingImageUrl = widget.newsfeedToEdit!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        // 새 이미지를 선택하면, '제거' 상태는 해제
        _imageWasRemoved = false;
      });
    }
  }

  void _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    final goRouter = GoRouter.of(context);

    if (isEditMode) {
      final notifier = ref.read(editNewsfeedViewModelProvider.notifier);
      final updatedNewsfeed = await notifier.updateNewsfeed(
        originalNewsfeed: widget.newsfeedToEdit!,
        newTitle: title,
        newContent: content,
        newImageFile: _selectedImage,
        imageWasRemoved: _imageWasRemoved, // UI 상태를 ViewModel에 전달
      );
      if (updatedNewsfeed != null && context.mounted) {
        // 목록 상태를 '아이템 단위'로 업데이트
        ref
            .read(newsfeedListViewModelProvider.notifier)
            .updateNewsfeedInState(updatedNewsfeed);
        // 상세 페이지로 돌아가기
        goRouter.pop();
      }
    } else {
      final notifier = ref.read(createNewsfeedViewModelProvider.notifier);
      await notifier.createNewsfeed(
        title: title,
        content: content,
        imageFile: _selectedImage,
      );
    }
  }

  Widget _buildImagePreview() {
    Widget? imageWidget;

    // 1. 새로 선택한 이미지가 있으면 표시
    if (_selectedImage != null) {
      imageWidget = Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    // 2. 기존 이미지가 있고, '제거' 버튼을 누르지 않았을 때 표시
    else if (_existingImageUrl != null && !_imageWasRemoved) {
      imageWidget = Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // 이미지가 있는 경우 (imageWidget이 null이 아님)
    if (imageWidget != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () {
                setState(() {
                  // 새로 선택한 이미지 취소
                  _selectedImage = null;
                  // 기존 이미지 제거 flag 활성화
                  _imageWasRemoved = true;
                });
              },
              tooltip: 'Remove Image',
              icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text('Tap to add an image'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createNewsfeedViewModelProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          ref.invalidate(newsfeedListViewModelProvider);
          if (context.canPop()) context.pop();
        },
        error: (error, stackTrace) {
          final message = error is Failure
              ? error.message
              : 'An unknown error occurred.';
          showErrorSnackbar(context, message: message);
        },
      );
    });

    // '수정' 작업 시 에러 스낵바 표시를 위한 리스너 추가
    ref.listen<AsyncValue<void>>(editNewsfeedViewModelProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          final message = error is Failure
              ? error.message
              : 'An unknown error occurred.';
          showErrorSnackbar(context, message: message);
        },
      );
    });

    final createLoading =
        ref.watch(createNewsfeedViewModelProvider) is AsyncLoading;
    final editLoading =
        ref.watch(editNewsfeedViewModelProvider) is AsyncLoading;
    final isLoading = isEditMode ? editLoading : createLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Newsfeed' : 'Create Newsfeed'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이미지 선택 UI
              Container(
                height: 200,
                // Stack의 자식이 Container 경계를 넘지 않도록
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: InkWell(
                  onTap: isLoading ? null : _pickImage,
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // For multiline text fields
                ),
                maxLines: 10,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content.';
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                // textInputAction: TextInputAction.done,
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isEditMode ? 'Update' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
