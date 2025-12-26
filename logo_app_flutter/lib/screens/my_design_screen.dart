import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'canvas_upload_service.dart'; // import the upload service

class MyDesignScreen extends StatefulWidget {
  final GlobalKey canvasKey;

  const MyDesignScreen({super.key, required this.canvasKey});

  @override
  _MyDesignScreenState createState() => _MyDesignScreenState();
}

class _MyDesignScreenState extends State<MyDesignScreen> {
  final supabase = Supabase.instance.client;
  List<String> imageUrls = [];
bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchLogos();
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

    final urls = response.map((file) {
      return supabase.storage.from('logos').getPublicUrl('logos/$uid/${file.name}');
    }).toList();

    setState(() {
      imageUrls = urls;
      isLoading = false; // done loading
    });
  } catch (e) {
    print('❌ Error fetching logos: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('All Logos'),
        
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
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        fileName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
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
