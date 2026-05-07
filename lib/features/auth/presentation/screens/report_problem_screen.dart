import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/token_storage_service.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color scaffoldBg = const Color(0xFFE1F5F3);

  final TextEditingController _detailsController = TextEditingController();
  final List<String> _selectedCategories = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedFiles = [];

  final List<String> _categories = [
    'App bug',
    'Data issue',
    'Content issue',
    'Other',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Simple header with back arrow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: navyBlue, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Report a Problem',
                      style: TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Categories Section
                    const SizedBox(height: 16),

                    // Category Checkboxes - Right aligned
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: _categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: navyBlue,
                                    fontSize: 16,
                                  ),
                                ),
                                // Right-aligned checkbox
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_selectedCategories.contains(
                                        category,
                                      )) {
                                        _selectedCategories.remove(category);
                                      } else {
                                        _selectedCategories.add(category);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedCategories.contains(category)
                                          ? navyBlue
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: navyBlue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child:
                                        _selectedCategories.contains(category)
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details Section - "Write in detail"
                    Text(
                      'Write in detail',
                      style: TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Details TextField - Simple multi-line input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _detailsController,
                        maxLines: 6,
                        style: TextStyle(color: navyBlue, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Describe issue in detail...',
                          hintStyle: TextStyle(
                            color: navyBlue.withOpacity(0.5),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Light grey container with dashed border
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _selectedFiles.isNotEmpty
                          ? _buildSelectedFilesPreview()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _chooseFiles,
                                  child: Text(
                                    'Choose Files',
                                    style: TextStyle(
                                      color: navyBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Drop image/video files here',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Supported format: JPEG, PNG, mp4',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    if (_isSubmitting)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E1E5F),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Bottom padding to prevent clipping by system navigation bar
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesPreview() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: _selectedFiles.map((file) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(file.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.insert_drive_file,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFiles.remove(file);
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _chooseFiles() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedFiles.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitReport() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide details about the problem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create Dio instance
      final dio = Dio();

      // Get auth token
      final token = await TokenStorageService.instance.getToken();

      // Create FormData for multipart request
      final selectedIssueTypes = _selectedCategories
          .map((cat) => '"$cat"')
          .toList();
      final issueTypesJson = '[$selectedIssueTypes]';

      print(
        "🚀 [REPORT REQUEST] Body: ${{'issue_types': issueTypesJson, 'details': _detailsController.text.trim(), 'has_file': _selectedFiles.isNotEmpty}}",
      );

      FormData formData = FormData.fromMap({
        "issue_types": issueTypesJson,
        "details": _detailsController.text.trim(),
        if (_selectedFiles.isNotEmpty)
          "file": await MultipartFile.fromFile(
            _selectedFiles.first.path,
            filename: "report_image.jpg",
          ),
      });

      // Make API call
      final response = await dio.post(
        'https://swampurna-final-production.up.railway.app/api/v1/support/reports',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Check response status
      print("✅ [REPORT RESPONSE] Status: ${response.statusCode}");
      print("📦 [REPORT RESPONSE] Data: ${jsonEncode(response.data)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Report submitted successfully! We\'ll look into it.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
        "❌ [REPORT ERROR] DioException: ${e.response?.data?['message'] ?? e.message}",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting report: ${e.response?.data?['message'] ?? e.message}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ [REPORT ERROR] General Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
