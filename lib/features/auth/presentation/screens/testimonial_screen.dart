import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/auth_service.dart';
// IMPORTANT: Replace 'my_app' with your actual project name from pubspec.yaml
import 'package:my_app/features/auth/presentation/screens/menstrual_journey_screen.dart';

class TestimonialScreen extends StatefulWidget {
  final Map<String, dynamic> onboardingData;

  const TestimonialScreen({super.key, required this.onboardingData});

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  // State management for testimonials
  List<Map<String, dynamic>> _testimonials = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Pagination variables
  int _currentPage = 0;
  final int _limit = 20;
  bool _hasMoreData = true;

  // Scroll controller for infinite scroll
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchTestimonials();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _fetchMoreTestimonials();
      }
    }
  }

  Future<void> _fetchTestimonials() async {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    try {
      final authService = AuthService();
      final response = await authService.fetchTestimonials(
        limit: _limit,
        offset: 0,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final testimonials = data['testimonials'] as List<dynamic>? ?? [];

        setState(() {
          _testimonials = testimonials
              .map((t) => t as Map<String, dynamic>)
              .toList();
          _isLoading = false;
          _currentPage = 0;
          _hasMoreData = testimonials.length == _limit;
        });
      } else {
        throw Exception(response.error ?? 'Failed to load testimonials');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load testimonials. Please try again.';
      });
      debugPrint('Error fetching testimonials: $e');
    }
  }

  Future<void> _fetchMoreTestimonials() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final authService = AuthService();
      final response = await authService.fetchTestimonials(
        limit: _limit,
        offset: nextPage * _limit,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final newTestimonials = data['testimonials'] as List<dynamic>? ?? [];

        setState(() {
          _testimonials.addAll(
            newTestimonials.map((t) => t as Map<String, dynamic>).toList(),
          );
          _isLoadingMore = false;
          _currentPage = nextPage;
          _hasMoreData = newTestimonials.length == _limit;
        });
      } else {
        throw Exception(response.error ?? 'Failed to load more testimonials');
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      debugPrint('Error fetching more testimonials: $e');
    }
  }

  Future<void> _refreshTestimonials() async {
    _currentPage = 0;
    _hasMoreData = true;
    await _fetchTestimonials();
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color _bgColor = Color(0xFFD1EDF2);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "After a long survey, What\nour user say !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E3192),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E3192),
                      ),
                    )
                  : _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshTestimonials,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3192),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTestimonials,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount:
                            _testimonials.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _testimonials.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2E3192),
                                ),
                              ),
                            );
                          }

                          bool isRightAligned = index % 2 != 0;
                          final testimonial = _testimonials[index];

                          if (index == 2) {
                            return Column(
                              children: [
                                _buildStarRating(context),
                                _buildTestimonialBubble(
                                  testimonial,
                                  isRightAligned,
                                ),
                              ],
                            );
                          }
                          return _buildTestimonialBubble(
                            testimonial,
                            isRightAligned,
                          );
                        },
                      ),
                    ),
            ),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialBubble(
    Map<String, dynamic> testimonial,
    bool isRight,
  ) {
    // Extract data from testimonial with fallbacks
    final String name =
        testimonial['user_name']?.toString() ??
        testimonial['name']?.toString() ??
        'Anonymous';
    final String text =
        testimonial['comment']?.toString() ??
        testimonial['text']?.toString() ??
        testimonial['review']?.toString() ??
        'Great experience!';
    final int rating =
        (testimonial['rating'] ?? testimonial['stars'] ?? 5) as int;

    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        constraints: const BoxConstraints(maxWidth: 270),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/whiteCircle.png'),
            fit: BoxFit.fill,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(35, 45, 35, 45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "“$text”",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2E3192),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            // Dynamic rating stars
            _buildRatingStars(rating),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/twigr.png', width: 40),
          const SizedBox(width: 10),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.asset('assets/images/star.png', width: 22),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Image.asset('assets/images/twigl.png', width: 40),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: SizedBox(
        width: 250,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF252876),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            // FIXED: Using MaterialPageRoute without 'const' if issues persist,
            // but the import fix is the real key here.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MenstrualJourneyScreen(),
              ),
            );
          },
          child: const Text(
            "Next",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
