import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/canvas_upload_service.dart'; // import the upload service
import 'package:logo_app_flutter/services/user_design_service.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/utils/app_logger.dart';

class MyDesignScreen extends StatefulWidget {
  final GlobalKey canvasKey;

  const MyDesignScreen({super.key, required this.canvasKey});

  @override
  _MyDesignScreenState createState() => _MyDesignScreenState();
}

class _MyDesignScreenState extends State<MyDesignScreen> {
  final supabase = Supabase.instance.client;
  List<String> imageUrls = [];
  List<Map<String, dynamic>> userDesigns = [];
bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchLogos();
    fetchDesigns();
  }

  /// Fetch all logos for the current user
Future<void> fetchLogos() async {
  setState(() => isLoading = true); // start loading
  try {
    final uid = supabase.auth.currentUser!.id;
    final response = await supabase.storage.from('logos').list(path: 'logos/$uid');

    if (response.isEmpty) {
      setState(() {
        imageUrls = [];
        isLoading = false; // done loading
      });
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final urls = response.map((file) {
      final base = supabase.storage.from('logos').getPublicUrl('logos/$uid/${file.name}');
      return '$base?t=$now'; // cache-busting
    }).toList();

    setState(() {
      imageUrls = urls;
      isLoading = false; // done loading
    });
  } catch (e) {
    AppLogger.error('Error fetching logos', tag: 'MyDesignScreen', error: e);
    setState(() {
      imageUrls = [];
      isLoading = false; // done loading
    });
  }
}

  /// Upload canvas and refresh logos
  Future<void> uploadCanvas() async {
    final url = await CanvasUploadService.uploadCanvas(canvasKey: widget.canvasKey);
    if (url != null) {
      fetchLogos(); // refresh GridView
    }
  }

  Future<void> fetchDesigns() async {
    setState(() => isLoading = true);
    try {
      final svc = UserDesignService();
      final list = await svc.fetchUserDesigns();
      setState(() {
        userDesigns = list;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching designs: $e');
      setState(() {
        userDesigns = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text('All Logos'),
        actions: [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (imageUrls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No logos yet.\nUpload your first logo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    final fileName = url.split('/').last;
                    final fileBase = fileName.split('?').first; // remove cache-bust query

                    // helper to strip query params from a URL
                    String stripQuery(String? u) => (u ?? '').split('?').first;

                    // try to find a saved design that matches this image (ignore timestamps)
                    Map<String, dynamic>? matchedDesign;
                    try {
                      matchedDesign = userDesigns.firstWhere((d) {
                        final ip = (d['image_path'] ?? '') as String;
                        final iu = (d['image_url'] ?? '') as String;

                        final iuStripped = stripQuery(iu);
                        final urlStripped = stripQuery(url);

                        if (iuStripped.isNotEmpty && iuStripped == urlStripped) return true;

                        if (ip.isNotEmpty) {
                          final ipBase = ip.split('/').last;
                          if (ipBase == fileBase) return true;
                        }

                        return false;
                      });
                    } catch (_) {
                      matchedDesign = null;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (matchedDesign != null) {
                                      final d = matchedDesign;
                                      var dj = d['design_json'];
                                      if (dj is String) {
                                        try {
                                          dj = dj.isNotEmpty ? jsonDecode(dj) as Map<String, dynamic> : {};
                                        } catch (_) {
                                          dj = {};
                                        }
                                      }
                                      if (dj is Map<String, dynamic>) {
                                        final state = LogoStateData.fromJson(dj);
                                        // Debug: log design id and parsed font index before navigating
                                        // ignore: avoid_print
                                        print('NAVIGATE -> design id:${matchedDesign?["id"]} companyFont:${state.companyFontIndex} sloganFont:${state.sloganFontIndex}');
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DownloadLogo(
                                              svgLogo: state.svgLogo ?? '',
                                              companyName: state.companyName ?? '',
                                              sloganName: state.sloganName ?? '',
                                              selectedFontIndex: state.companyFontIndex,
                                              initialLogoState: state,
                                              designId: matchedDesign?['id']?.toString(),
                                            ),
                                          ),
                                        );
                                        // After editing, refresh lists and ensure image cache-busting
                                        await fetchLogos();
                                        await fetchDesigns();
                                      }
                                    }
                                  },
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.error));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                if (matchedDesign != null)
                                  Row(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.black),
                                        tooltip: 'Edit design',
                                        onPressed: () async {
                                          final d = matchedDesign!;
                                          var dj = d['design_json'];
                                          if (dj is String) {
                                            try {
                                              dj = dj.isNotEmpty ? jsonDecode(dj) as Map<String, dynamic> : {};
                                            } catch (_) {
                                              dj = {};
                                            }
                                          }
                                          if (dj is Map<String, dynamic>) {
                                            final state = LogoStateData.fromJson(dj);
                                          // Debug: log design id and parsed font index before navigating (edit button)
                                          // ignore: avoid_print
                                          print('NAVIGATE(edit) -> design id:${matchedDesign?["id"]} companyFont:${state.companyFontIndex} sloganFont:${state.sloganFontIndex}');
                                              await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => DownloadLogo(
                                                  svgLogo: state.svgLogo ?? '',
                                                  companyName: state.companyName ?? '',
                                                  sloganName: state.sloganName ?? '',
                                                  selectedFontIndex: state.companyFontIndex,
                                                  initialLogoState: state,
                                                  designId: matchedDesign?['id']?.toString(),
                                                ),
                                              ),
                                            );
                                            await fetchLogos();
                                            await fetchDesigns();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text('Delete design?'),
                                              content: const Text('This will permanently delete the design and its image.'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                                                TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete')),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            final idStr = matchedDesign?['id']?.toString();
                                            if (idStr == null || idStr.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid design id')));
                                            } else {
                                              final svc = UserDesignService();
                                              final ok = await svc.deleteDesign(idStr);
                                              if (ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Design deleted')));
                                                await fetchLogos();
                                                await fetchDesigns();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete design')));
                                              }
                                            }
                                          }
                                        },
                                      ),
                                   
                                   
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
    );
  }
}
