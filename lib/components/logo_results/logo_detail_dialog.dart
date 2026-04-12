import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../provider/business_info_provider.dart';

class LogoDetailDialog extends StatelessWidget {
  final String name;
  final String image;
  final List<Color> colors;

  const LogoDetailDialog({
    super.key,
    required this.name,
    required this.image,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1F1F39),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Large Logo Preview
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Consumer<BusinessInfoProvider>(
                builder: (context, info, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(
                      //   icon,
                      //   color: Colors.white,
                      //   size: 70,
                      // ),
                      Image.asset(
                        image,
                        height: 70,
                        width: 70,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info.businessName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Actions Grid (2x2)
            Row(
              children: [
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xffFE5A54),
                      Color(0xffAE2EE3),
                    ],
                    icon: Icons.folder_open_outlined,
                    label: 'Save',
                    textcolor: Colors.white,
                    color: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      // Future: Navigate to Editor
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xff00C3C0),
                      Color(0xff00C3C0),
                    ],
                    icon: Icons.edit,
                    label: 'Edit',
                    textcolor: Colors.white,
                    color: const Color(0xFFFFFFFF),
                    onTap: () {
                      Navigator.pop(context);
                      // Future: Navigate to Mockups
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFFFF),
                    ],
                    icon: Icons.file_download_outlined,
                    label: 'Download',
                    color: const Color(0xFF7C4DFF),
                    textcolor: Color(0xff9810FA),
                    onTap: () {
                      Navigator.pop(context);
                      // Future: Trigger Download
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFFFF),
                    ],
                    icon: Icons.share,
                    label: 'Share',
                    textcolor: Color(0xffE8117F),
                    color: const Color(0xFFFF6D00),
                    onTap: () {
                      Navigator.pop(context);
                      // Future: Share Logo
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> colors;
  final VoidCallback onTap;
  final Color textcolor;

  const _LogoActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.colors,
    required this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          // color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textcolor,
                //  Color(0xFF1F1F39),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
