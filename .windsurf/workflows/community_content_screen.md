---
description: Pixel-Perfect CommunityContentScreen with Robust API Error Handling
---

**Role: Expert Flutter Developer**

**Task: Fix FormatException (HTML response error) and implement a pixel-perfect CommunityContentScreen.**

## 1. Critical API Fix (Stop HTML Error)

### Locate API Calls
- Find the `initState()` or data fetching logic in CommunityContentScreen
- Look for `AuthService().getCommunityCategories()` and `AuthService().getCommunityArticles()` calls

### URL Correction
- Use the exact base URL from Postman: `https://swampurna-final-production.up.railway.app/`
- Ensure endpoints are: `/api/public/newsarticles/categories` and `/api/public/newsarticles?category_id={id}`
- Remove any extra spaces or incorrect slashes in URLs

### Add Headers
Add mandatory headers to all API requests:
```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer ${your_token}', // Use actual token from AuthService
}
```

### Robust Parsing
Before parsing JSON, always check response:
```dart
if (response.statusCode == 200 && response.headers['content-type']!.contains('json')) {
  // Parse JSON safely
  final data = jsonDecode(response.body);
  return ApiResponse.success(data);
} else {
  // Handle non-JSON response gracefully
  return ApiResponse.error('Service temporarily unavailable. Please try again.');
}
```

## 2. UI Implementation (Pixel-Perfect)

### Background Color
Use exact hex `#D1F1F4` for scaffold background:
```dart
final Color scaffoldBg = const Color(0xFFD1F1F4);
```

### Dynamic Categories
- Fetch from `/newsarticles/categories` API endpoint
- Display category names as section headers with Navy Blue color
- Use proper padding and bold typography

### Card Design Requirements
- **Rounded corners**: 16-20px `BorderRadius.circular(16)`
- **Card size**: Approximately 160x220 aspect ratio
- **Image**: Use `CachedNetworkImage` for `image_url` from API
- **Gradient overlay**: Bottom-to-top black gradient for text readability
- **Title text**: White, bold, centered over gradient

### Scroll Behavior
- **Main screen**: Vertical scrolling with `SingleChildScrollView`
- **Category rows**: Horizontal scrolling with `ListView.builder(scrollDirection: Axis.horizontal)`
- **Physics**: Use `ClampingScrollPhysics()` for smooth nested scrolling

## 3. Maintain Safety

### No Breakage Policy
- **Index 0 (Tracker)**: Keep existing functionality intact
- **Index 1 (Community)**: Implement new CommunityContentScreen
- **Index 4 (Settings)**: Preserve logout flow and session clearing
- **Other features**: "Find Nearby Medical Stores", "Report Problem" must remain functional

### Logout Flow Protection
- Keep existing logout logic in SettingsScreen unchanged
- Ensure session clearing and navigation reset works properly
- Do not modify authentication service methods

## 4. Performance Requirements

### Image Loading
- Use `CachedNetworkImage` for all article thumbnails
- Implement proper placeholder and error widgets
- Cache images to prevent flickering and reduce data usage

### Parallel Fetching
- Use `Future.wait()` to fetch articles for all categories simultaneously
- Prevent "waterfall" loading effect
- Show loading indicator during data fetching

### Error States
- Display user-friendly error messages
- Provide retry functionality
- Handle empty states gracefully

## 5. Code Structure

### State Management
```dart
class _CommunityContentScreenState extends State<CommunityContentScreen> {
  bool _isLoading = true;
  List<CommunityCategory> _categories = [];
  Map<int, List<CommunityArticle>> _articlesByCategory = {};
  String? _error;
}
```

### API Integration
```dart
// Step 1: Fetch categories
final categoriesResponse = await AuthService().getCommunityCategories();

// Step 2: Fetch articles in parallel
final articleFutures = _categories.map((category) async {
  final articlesResponse = await AuthService().getCommunityArticles(categoryId: category.id);
  return {'categoryId': category.id, 'articles': articlesResponse.data!};
}).toList();

final results = await Future.wait(articleFutures);
```

### UI Components
```dart
// Section Header
Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: navyBlue,
      ),
    ),
  );
}

// Article Card
Widget _buildArticleCard(CommunityArticle article) {
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article))),
    child: Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(flex: 3, child: CachedNetworkImage(imageUrl: article.thumbnailUrl!, fit: BoxFit.cover)),
            Expanded(flex: 1, child: _buildTitleOverlay(article.title)),
          ],
        ),
      ),
    ),
  );
}
```

## 6. Testing Checklist

### API Testing
- [ ] Categories endpoint returns valid JSON
- [ ] Articles endpoint returns valid JSON for each category
- [ ] HTML responses handled gracefully
- [ ] Authorization header works correctly
- [ ] Network errors handled properly

### UI Testing
- [ ] Background color matches #D1F1F4 exactly
- [ ] Category headers use Navy Blue color
- [ ] Cards have 16px rounded corners
- [ ] Gradient overlay works correctly
- [ ] White text is readable over gradient
- [ ] Horizontal scrolling works smoothly
- [ ] Vertical scrolling works smoothly

### Safety Testing
- [ ] Tracker tab (Index 0) works normally
- [ ] Settings tab (Index 4) logout works
- [ ] Find Nearby Medical Stores works
- [ ] Report Problem works
- [ ] No crashes or navigation issues

## 7. Implementation Notes

### Common Issues to Avoid
- **Don't hardcode category names or articles**
- **Don't use placeholder images - use actual API image_url**
- **Don't ignore content-type validation**
- **Don't break existing navigation or authentication flow**
- **Don't remove error handling or loading states**

### Best Practices
- Use proper null safety throughout
- Implement proper dispose methods if needed
- Use descriptive debug logging
- Follow Flutter naming conventions
- Keep widgets small and focused

This prompt ensures a robust, pixel-perfect CommunityContentScreen implementation with proper error handling and safety constraints.
