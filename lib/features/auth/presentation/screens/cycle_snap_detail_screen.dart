import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:my_app/features/auth/models/cycle_snap_detail.dart';
import '../../../../core/services/auth_service.dart';

class CycleSnapDetailScreen extends StatefulWidget {
  final String snapId;
  const CycleSnapDetailScreen({super.key, required this.snapId});

  @override
  State<CycleSnapDetailScreen> createState() => _CycleSnapDetailScreenState();
}

class _CycleSnapDetailScreenState extends State<CycleSnapDetailScreen> {
  CycleSnapDetail? snapDetail;
  bool isLoading = true;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final response = await AuthService().fetchCycleSnapDetail(widget.snapId);

    if (response.success && response.data != null) {
      final detail = response.data!;
      if (detail.mediaType == 'video') {
        _videoController = VideoPlayerController.network(detail.mediaUrl)
          ..initialize().then((_) {
            _videoController!.setLooping(true);
            _videoController!.play();
            setState(() {
              snapDetail = detail;
              isLoading = false;
            });
          });
      } else {
        setState(() {
          snapDetail = detail;
          isLoading = false;
        });
      }
    } else {
      debugPrint("Error: ${response.error}");
      setState(() {
        snapDetail = null;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 196, 233, 236),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapDetail == null) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 196, 233, 236),
        body: Center(child: Text('Failed to load snap detail')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 196, 233, 236),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 196, 233, 236),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Snap Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // ✅ YAHA SE CHANGE HAI: Scaffold ke andar pure body ko SafeArea aur Column se stretch kiya hai
      body: SafeArea(
        top: false, 
        bottom: true, 
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // 1. Media Component Layer
                      Positioned.fill(
                        child: snapDetail!.mediaType == 'video'
                            ? (_videoController != null && _videoController!.value.isInitialized
                                ? SizedBox.expand(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _videoController!.value.size.width,
                                        height: _videoController!.value.size.height,
                                        child: VideoPlayer(_videoController!),
                                      ),
                                    ),
                                  )
                                : const Center(child: CircularProgressIndicator()))
                            : Image.network(
                                snapDetail!.mediaUrl,
                                fit: BoxFit.cover,
                              ),
                      ),

                      // 2. Translucent Text Background Gradient Shadow
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.65, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // 3. Right Aligned Overlay Control Dashboard
                      Positioned(
                        right: 12,
                        bottom: 30,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                              onPressed: () => debugPrint("More clicked"),
                            ),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: const Icon(Icons.thumb_up, color: Colors.white, size: 28),
                              onPressed: () => debugPrint("Like clicked"),
                            ),
                            const Text("245K", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: const Icon(Icons.thumb_down, color: Colors.white, size: 28),
                              onPressed: () => debugPrint("Dislike clicked"),
                            ),
                            const Text("Dislike", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: const Icon(Icons.comment, color: Colors.white, size: 28),
                              onPressed: () => debugPrint("Comment clicked"),
                            ),
                            const Text("952", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                        ),
                      ),

                      // 4. Bottom Text Elements (Title + Author Name Info Row)
                      Positioned(
                        bottom: 24,
                        left: 16,
                        right: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${snapDetail!.title} | ${snapDetail!.description}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(blurRadius: 3, color: Colors.grey, offset: Offset(1, 1)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: snapDetail!.authorPicUrl != null 
                                      ? NetworkImage(snapDetail!.authorPicUrl!) 
                                      : null,
                                  child: snapDetail!.authorPicUrl == null 
                                      ? const Icon(Icons.person, color: Colors.black, size: 15)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    snapDetail!.authorEmail ?? "Unknown User",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(blurRadius: 3, color: Colors.grey, offset: Offset(1, 1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}