import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDesignScreen extends StatefulWidget {
  @override
  _MyDesignScreenState createState() => _MyDesignScreenState();
}

class _MyDesignScreenState extends State<MyDesignScreen> {
  final supabase = Supabase.instance.client;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchLogos();
  }

  Future<void> fetchLogos() async {
    try {
      final response = await supabase.storage.from('logos').list(path: 'logos');
      final urls = response.map((file) {
        return supabase.storage
            .from('logos')
            .getPublicUrl('logos/${file.name}');
      }).toList();

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print('❌ Error fetching logos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('All Logos')),
        body: imageUrls.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 images per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8, // adjust height for title
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  final fileName = imageUrls[index]
                      .split('/')
                      .last; // get file name from URL
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            fileName,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
  }
}
