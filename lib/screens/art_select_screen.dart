import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArtSelectScreen extends StatelessWidget {
  final List<String> images; // ✅ Pass image paths here (e.g., assets/icons/...)
  const ArtSelectScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // adjust tabs count as needed
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Art Select',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          // Remove the bottom TabBar from here
          // bottom: ...
        ),
        body: TabBarView(
          children: List.generate(5, (_) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context,
                                images[index]); // ✅ Return selected image path
                          },
                          child: images[index].endsWith('.svg')
                              ? SvgPicture.asset(
                                  images[index],
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      if (index.isEven) // crown icon for demo
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          }),
        ),
        bottomNavigationBar: Container(
          height: 100,
          color: Theme.of(context).cardColor,
          child: TabBar(
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Theme.of(context).textTheme.labelLarge?.color,
            unselectedLabelColor: Theme.of(context).hintColor,
            tabs: [
              Tab(text: 'ANIMAL'),
              Tab(text: 'ARCHITECTURE'),
              Tab(text: 'BEAUTY'),
              Tab(text: 'BUSINESS'),
              Tab(text: 'TECH'),
            ],
          ),
        ),
      ),
    );
  }
}
