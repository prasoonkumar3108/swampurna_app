import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/auth_service.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../models/onboarding_data.dart' as auth_model;
import '../models/onboarding_data.dart' as presentation_model;

class TestimonialScreen extends StatefulWidget {
  final presentation_model.OnboardingData onboardingData;

  const TestimonialScreen({super.key, required this.onboardingData});

  @override
  State<TestimonialScreen> createState() => _TestimonialScreenState();
}

class _TestimonialScreenState extends State<TestimonialScreen> {
  // State management for testimonials
  List<Map<String, dynamic>> _testimonials = [];

  // Convert presentation model to auth model
  auth_model.OnboardingData _convertToAuthModel(
    presentation_model.OnboardingData data,
  ) {
    return auth_model.OnboardingData(
      onboardingSource: data.source,
      birthYear: data.birthYear,
      pregnancyStatus: data.isPregnant == true
          ? 'yes_i_am'
          : data.isPregnant == false
          ? 'not_pregnant'
          : null,
      usingFor: null, // Will be set in OnboardingScreen
    );
  }

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Pagination variables
  int _currentPage = 0;
  final int _limit = 20;
  bool _hasMoreData = true;

  // Star rating selection state
  int _userRating = 0; // User's selected rating (0-5, 0 means no selection)

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
      debugPrint(
        '🌐 Fetching testimonials from: https://swampurna-final-production.up.railway.app/api/v1/testimonials?limit=$_limit&offset=0',
      );

      final response = await authService.fetchTestimonials(
        limit: _limit,
        offset: 0,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        debugPrint('📊 API Response Data: $data');

        // Fix: Extract testimonials from nested "data" key
        List<dynamic> testimonials = [];

        if (data.containsKey('data') && data['data'] is List) {
          testimonials = data['data'] as List<dynamic>;
          debugPrint(
            '✅ Found testimonials in data["data"]: ${testimonials.length} items',
          );
        } else if (data.containsKey('testimonials') &&
            data['testimonials'] is List) {
          testimonials = data['testimonials'] as List<dynamic>;
          debugPrint(
            '✅ Found testimonials in data["testimonials"]: ${testimonials.length} items',
          );
        } else {
          debugPrint(
            '⚠️ No testimonials found in response. Available keys: ${data.keys}',
          );
        }

        setState(() {
          _testimonials = testimonials
              .map((t) => t as Map<String, dynamic>)
              .toList();
          _isLoading = false;
          _currentPage = 0;
          _hasMoreData = testimonials.length == _limit;

          debugPrint(
            '📝 Updated state with ${_testimonials.length} testimonials',
          );
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
        debugPrint('📊 More testimonials API Response Data: $data');

        // Fix: Extract testimonials from nested "data" key
        List<dynamic> newTestimonials = [];

        if (data.containsKey('data') && data['data'] is List) {
          newTestimonials = data['data'] as List<dynamic>;
          debugPrint(
            '✅ Found more testimonials in data["data"]: ${newTestimonials.length} items',
          );
        } else if (data.containsKey('testimonials') &&
            data['testimonials'] is List) {
          newTestimonials = data['testimonials'] as List<dynamic>;
          debugPrint(
            '✅ Found more testimonials in data["testimonials"]: ${newTestimonials.length} items',
          );
        } else {
          debugPrint(
            '⚠️ No more testimonials found in response. Available keys: ${data.keys}',
          );
        }

        setState(() {
          _testimonials.addAll(
            newTestimonials.map((t) => t as Map<String, dynamic>).toList(),
          );
          _isLoadingMore = false;
          _currentPage = nextPage;
          _hasMoreData = newTestimonials.length == _limit;

          debugPrint(
            '📝 Added ${newTestimonials.length} more testimonials. Total: ${_testimonials.length}',
          );
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

  // Handle star rating selection
  void _onStarRatingChanged(int rating) {
    setState(() {
      _userRating = rating;
    });
    debugPrint('🌟 User selected rating: $rating');
  }

  Widget _buildRatingStars(int rating, {bool isInteractive = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive ? () => _onStarRatingChanged(index + 1) : null,
          child: Icon(
            isInteractive
                ? (index < _userRating ? Icons.star : Icons.star_border)
                : (index < rating ? Icons.star : Icons.star_border),
            color: Colors.amber,
            size: isInteractive ? 24 : 16,
          ),
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
                  : _testimonials.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Testimonials Found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share your experience!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
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
    // Debug print the testimonial data structure
    debugPrint('🔍 Processing testimonial: $testimonial');

    // Extract data from testimonial with enhanced fallbacks
    final String name =
        testimonial['user_name']?.toString() ??
        testimonial['name']?.toString() ??
        testimonial['author']?.toString() ??
        testimonial['username']?.toString() ??
        'Anonymous';

    final String text =
        testimonial['comment']?.toString() ??
        testimonial['text']?.toString() ??
        testimonial['review']?.toString() ??
        testimonial['quote']?.toString() ??
        testimonial['message']?.toString() ??
        testimonial['feedback']?.toString() ??
        'Great experience!';

    final int rating = _extractRating(testimonial);

    debugPrint(
      '📝 Mapped testimonial - Name: "$name", Text: "$text", Rating: $rating',
    );

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

  // Helper method to extract rating with multiple fallback options
  int _extractRating(Map<String, dynamic> testimonial) {
    final dynamic ratingValue =
        testimonial['rating'] ??
        testimonial['stars'] ??
        testimonial['score'] ??
        testimonial['rating_value'] ??
        5; // Default rating

    if (ratingValue is int) {
      return ratingValue.clamp(1, 5);
    } else if (ratingValue is double) {
      return ratingValue.round().clamp(1, 5);
    } else if (ratingValue is String) {
      final parsed = int.tryParse(ratingValue);
      return parsed?.clamp(1, 5) ?? 5;
    }

    return 5; // Default fallback
  }

  Widget _buildStarRating(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/twigr.png', width: 40),
          const SizedBox(width: 10),
          // Interactive star rating
          _buildRatingStars(0, isInteractive: true),
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
            // Navigate to OnboardingScreen for using_for selection
            final authData = _convertToAuthModel(widget.onboardingData);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OnboardingScreen(onboardingData: authData),
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
