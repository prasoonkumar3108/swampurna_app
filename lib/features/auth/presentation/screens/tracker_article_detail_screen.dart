import 'package:flutter/material.dart';
import 'package:my_app/core/services/auth_service.dart';
import 'package:my_app/features/auth/models/tracker_article_detail.dart';

class TrackerArticleDetailScreen extends StatefulWidget {
  final String slug;
  const TrackerArticleDetailScreen({super.key, required this.slug});

  @override
  State<TrackerArticleDetailScreen> createState() =>
      _TrackerArticleDetailScreenState();
}

class _TrackerArticleDetailScreenState
    extends State<TrackerArticleDetailScreen> {
  TrackerArticleDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final authService = AuthService();
    final response = await authService.getArticleDetail(widget.slug);
    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _detail = response.data!;
          _isLoading = false;
        } else {
          _error = response.error;
          _isLoading = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      // ✅ Fix: Scaffold ko transparent mat rakho, gradient ko hi background banao
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4F7C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _detail!.title,
          style: const TextStyle(
            color: Color(0xFF4A4F7C),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        // ✅ Gradient ab poore Scaffold ke body ko cover karega
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDDEAF8), Color(0xFFF7F8FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _detail!.imageUrl != null &&
                            _detail!.imageUrl!.isNotEmpty
                        ? Image.network(
                            _detail!.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(Icons.image,
                                size: 60, color: Colors.blue),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Detail title
                Text(
                  _detail!.detailTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4F7C),
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Text(
                  _detail!.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
