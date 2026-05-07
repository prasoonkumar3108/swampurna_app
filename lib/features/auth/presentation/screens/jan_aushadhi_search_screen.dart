import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/auth_service.dart';

class JanAushadhiSearchScreen extends StatefulWidget {
  const JanAushadhiSearchScreen({super.key});

  @override
  State<JanAushadhiSearchScreen> createState() =>
      _JanAushadhiSearchScreenState();
}

class _JanAushadhiSearchScreenState extends State<JanAushadhiSearchScreen> {
  final Color navyBlue = const Color(0xFF1E1E5F);
  final Color scaffoldBg = const Color(0xFFE1F5F3);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _kendras = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchKendras();
  }

  Future<void> _fetchKendras() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await AuthService().getJanAushadhiKendras(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        district: _districtController.text.isNotEmpty
            ? _districtController.text
            : null,
        pin: _pinController.text.isNotEmpty ? _pinController.text : null,
        limit: 20,
        offset: 0,
      );

      if (response.success && response.data != null) {
        // AuthService already returns the correct data['data'] which is the List
        final List<dynamic> kendras = List<dynamic>.from(response.data ?? []);

        setState(() {
          _kendras = kendras
              .map((item) => item as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to fetch Kendras';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching Kendras: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: navyBlue, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Find Nearby Kendra',
                        style: TextStyle(
                          color: navyBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.clear_all, color: navyBlue, size: 24),
                    onPressed: _clearSearch,
                    tooltip: 'Clear Search',
                  ),
                ],
              ),
            ),

            // Search Filters
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Name or Kendra Code Search
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Name or Kendra Code',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: navyBlue),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // District and Pin Code Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _districtController,
                            decoration: InputDecoration(
                              hintText: 'District',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: navyBlue),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _pinController,
                            decoration: InputDecoration(
                              hintText: 'Pin Code',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: navyBlue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _fetchKendras,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Results List
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E1E5F),
                          ),
                        ),
                      )
                    else if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_kendras.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Kendra found in your area.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _kendras.length,
                        itemBuilder: (context, index) {
                          final kendra = _kendras[index];
                          return _buildKendraCard(kendra);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKendraCard(Map<String, dynamic> kendra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Code Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    kendra['name'] ?? 'Unknown Kendra',
                    style: TextStyle(
                      color: navyBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: navyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    kendra['kendra_code'] ?? 'N/A',
                    style: TextStyle(
                      color: navyBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Address with Location Icon
            InkWell(
              onTap: () {
                final address = kendra['address'] ?? 'Address not available';
                if (address.isNotEmpty && address != 'Address not available') {
                  _openMap(address);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      kendra['address'] ?? 'Address not available',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 14, color: navyBlue),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Pin Code
            Row(
              children: [
                Icon(Icons.pin_drop, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Pin: ${kendra['pin_code'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(String address) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _clearSearch() {
    setState(() {
      _nameController.clear();
      _districtController.clear();
      _pinController.clear();
      _kendras = [];
      _error = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
