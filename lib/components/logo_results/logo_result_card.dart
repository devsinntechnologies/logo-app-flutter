import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/business_info_provider.dart';

class LogoResultCard extends StatelessWidget {
  final String name;
  final String image;
  final List<Color> colors;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const LogoResultCard({
    super.key,
    required this.name,
    required this.image,
    required this.colors,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isInteracting = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isInteracting,
      builder: (context, interacting, child) {
        return MouseRegion(
          onEnter: (_) => isInteracting.value = true,
          onExit: (_) => isInteracting.value = false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTapDown: (_) => isInteracting.value = true,
                onTapUp: (_) => isInteracting.value = false,
                onTapCancel: () => isInteracting.value = false,
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, interacting ? -12.0 : 0.0)
                    ..scale(interacting ? 1.02 : 1.0),
                  width: double.infinity,
                  height: 152, // Reduced from 165 to fix overflow
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color:
                          //  interacting
                          //     ? const Color(0xFFFF4081).withOpacity(0.5)
                          //     :
                          Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: interacting
                            ? const Color(0xFFFF4081).withOpacity(0.15)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: interacting ? 30 : 20,
                        offset: Offset(0, interacting ? 18 : 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gradient Result Display
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Consumer<BusinessInfoProvider>(
                          builder: (context, info, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   image,
                                //   color: Colors.white,
                                //   size: 35, // Slightly smaller to fit text in grid
                                // ),
                                Image.asset(
                                  image,
                                  height: 35,
                                  width: 35,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  info.businessName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Favorite Button
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF1F1F39),
                  fontSize: 12,
                  fontWeight: interacting ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
