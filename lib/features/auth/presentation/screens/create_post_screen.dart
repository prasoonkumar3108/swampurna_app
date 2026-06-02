import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/token_storage_service.dart';

enum PostType { recentPost, cycleSnap }

class CreatePostScreen extends StatefulWidget {
  final PostType postType;

  const CreatePostScreen({super.key, required this.postType});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const Color primaryTextColor = Color(0xFF2E3192);
  static const Color bgColor = Color(0xFFE8F4F8); // Light pastel blue

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedMedia;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isVideo = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Future<void> _pickMedia() async {
  //   try {
  //     final pickedFile = await _imagePicker.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: 1920,
  //       maxHeight: 1080,
  //       imageQuality: 85,
  //     );

  //     if (pickedFile != null) {
  //       setState(() {
  //         _selectedMedia = File(pickedFile.path);
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error picking media: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _pickMedia() async {
  try {
    // Recent Post -> only image
    if (widget.postType == PostType.recentPost) {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
          _isVideo = false;
        });
      }
      return;
    }

    // Cycle Snap -> Image or Video
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Select Image'),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _selectedMedia = File(pickedFile.path);
                      _isVideo = false;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Select Video'),
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? pickedFile =
                      await _imagePicker.pickVideo(
                    source: ImageSource.gallery,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _selectedMedia = File(pickedFile.path);
                      _isVideo = true;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<String?> _uploadToBackendAPI(File file) async {
    try {
      String? token = await TokenStorageService.instance.getToken();
      if (token == null) return null;

      // Clean the token (removing any extra quotes)
      token = token.replaceAll('"', '');
      if (!token.startsWith('Bearer ')) {
        token = 'Bearer $token';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://swampurna-final-production.up.railway.app/api/v1/posts/media/upload',
        ),
      );

      // Set headers strictly
      request.headers.addAll({
        'Authorization': token,
        'Accept': 'application/json',
      });

      final extension = path
          .extension(file.path)
          .replaceAll('.', ''); // jpg, png, etc.

      // request.files.add(
      //   await http.MultipartFile.fromPath(
      //     'file',
      //     file.path,
      //     contentType: MediaType(
      //       'image',
      //       extension == 'jpg' ? 'jpeg' : extension,
      //     ),
      //   ),
      // );

      request.files.add(
  await http.MultipartFile.fromPath(
    'file',
    file.path,
    contentType: _isVideo
        ? MediaType('video', extension)
        : MediaType(
            'image',
            extension == 'jpg' ? 'jpeg' : extension,
          ),
  ),
);

      debugPrint('--- UPLOAD ATTEMPT ---');
      debugPrint('Token used: $token');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['url'];
      } else if (response.statusCode == 400) {
        debugPrint('--- BAD REQUEST: 400 - Invalid file type ---');
        return null;
      } else {
        debugPrint('Upload Failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Upload Exception: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate image (optional for now, but recommended)
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      // Upload image first to get URL
      String? imageUrl;
      if (_selectedMedia != null) {
        imageUrl = await _uploadToBackendAPI(_selectedMedia!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Backend only accepts images (JPG/PNG). Check file extension.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
            _isUploading = false;
          });
          return;
        }
      }

      // Create post with uploaded image URL
      final authService = AuthService();
      final response = widget.postType == PostType.recentPost
          ? await authService.createRecentPost(
              title: _titleController.text.trim(),
              content: _descriptionController.text.trim(),
              imageFile: null, // Not needed since we're passing URL
              imageUrl: imageUrl, // Backend expects media_url
            )
          : await authService.createCycleSnap(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              mediaFile: null, // Not needed since we're passing URL
              mediaUrl: imageUrl, // Backend expects media_url
              mediaType: _isVideo ? 'video' : 'image',
            );

      if (mounted) {
        if (response.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.postType == PostType.recentPost
                    ? 'Post created successfully!'
                    : 'Cycle snap added successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate back with success flag to trigger refresh
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isLoading = false;
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to create post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecentPost = widget.postType == PostType.recentPost;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRecentPost ? 'Create Recent Post' : 'Create Cycle Snap',
          style: const TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Upload Box
            _buildMediaUploadBox(),
            const SizedBox(height: 24),

            // Title Field
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter your title here...',
              maxLines: 1,
            ),
            const SizedBox(height: 20),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: isRecentPost ? 'Content' : 'Description',
              hint: isRecentPost
                  ? 'Write your post content here...'
                  : 'Describe your cycle snap here...',
              maxLines: 6,
            ),
            const SizedBox(height: 30),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUploadBox() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: _selectedMedia != null
          ? _buildSelectedMediaPreview()
          : _buildEmptyMediaBox(),
    );
  }

  Widget _buildEmptyMediaBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'Choose Files',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Click to browse or drag and drop',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickMedia,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: primaryTextColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Browse Files',
              style: TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedMediaPreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(_selectedMedia!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMedia = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickMedia,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTextColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isUploading ? 'Uploading...' : 'Submitting...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
