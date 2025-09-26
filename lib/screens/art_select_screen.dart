import 'package:flutter/material.dart';
import 'package:logo_app_flutter/fragments/theme_toggle_widget.dart';

class ArtSelectScreen extends StatelessWidget {
  final List<String> images; // ✅ Pass image paths here (e.g., assets/icons/...)
  const ArtSelectScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'Art Select',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          actions: [const ThemeToggleWidget(), const SizedBox(width: 8)],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
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
                          color: isDark ? Colors.grey[850] : Colors.white,
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
                            Navigator.pop(
                              context,
                              images[index],
                            ); // ✅ Return selected image path
                          },
                          child: Image.asset(
                            images[index],
                            fit: BoxFit.contain,
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
          color: Colors.white,
          child: TabBar(
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
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
