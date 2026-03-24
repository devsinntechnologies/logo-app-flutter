import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class LayersPanel extends StatefulWidget {
  final LogoStateData logoState;
  final String svgLogo;
  final VoidCallback onClose;
  final ValueChanged<int> onToggleLock;
  final ValueChanged<bool> onToggleLockAll;
  final Function(int, bool) onReorder; // id, moveUp

  const LayersPanel({
    required this.logoState,
    required this.svgLogo,
    required this.onClose,
    required this.onToggleLock,
    required this.onToggleLockAll,
    required this.onReorder,
  });

  @override
  State<LayersPanel> createState() => _LayersPanelState();
}

class _LayersPanelState extends State<LayersPanel> {
  bool _moveUp = true;
Widget _buildLayerPreview(BuildContext context, int id) {
  Widget child;
  String text = '';

  // Handle custom images (IDs 200-299)
  if (id >= 200 && id < 300) {
    final index = id - 200;
    if (index < widget.logoState.customImages.length) {
      final image = widget.logoState.customImages[index];
      child = Icon(Icons.image, color: Colors.white, size: 28);
      text = 'Image ${index + 1}';
    } else {
      child = const Icon(Icons.error);
      text = 'Unknown Image';
    }
  } 
 // Handle custom images (IDs 200-299)
if (id >= 200 && id < 300) {
  final index = id - 200;
  if (index < widget.logoState.customImages.length) {
    final image = widget.logoState.customImages[index];
    
    // Try to display the actual image as thumbnail
    try {
      if (image.path.startsWith('assets/')) {
        child = Image.asset(
          image.path,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        );
      } else {
        child = Image.file(
          File(image.path),
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      // Fallback to icon if image loading fails
      child = Icon(Icons.image, color: Colors.white, size: 20);
    }
    text = 'Image ${index + 1}';
  } else {
    child = const Icon(Icons.error);
    text = 'Unknown Image';
  }
}
  // Handle existing cases
  else {
    switch (id) {
      case 0:
      case 3:
        child = SvgPicture.string(
          widget.svgLogo,
          width: 28, // Increased size
          height: 28, // Increased size
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
        text = 'Logo';
        break;
      case 1:
      case 4:
        child = Text(
          widget.logoState.companyName ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
        text = 'Company';
        break;
      case 2:
      case 5:
        child = Text(
          widget.logoState.sloganName ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        );
        text = 'Slogan';
        break;
      default:
        if (id >= 100 && id < 200) {
          final customText = widget.logoState.customTexts[id - 100];
          child = Text(
            customText.text, 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          );
          text = customText.text;
        } else {
          child = const Icon(Icons.error);
          text = 'Unknown';
        }
    }
  }

  return Row(
    children: [
      SizedBox(width: 5),
      Container(
        width: 60,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: FittedBox(child: child),
      ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    final orderedVisibleIds =
        widget.logoState.elementOrder
            .where((id) => widget.logoState.visibleElementIds.contains(id))
            .toList();
    final areAllLocked =
        widget.logoState.lockedElements.length ==
            widget.logoState.visibleElementIds.length &&
        widget.logoState.visibleElementIds.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // Allow the panel to take up to 70% of the screen height
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 210,
          height: 260,
          // padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.95),
            borderRadius: BorderRadius.circular(0),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: areAllLocked,
                        onChanged:
                            (val) => widget.onToggleLockAll(val ?? false),
                        checkColor: Colors.black,
                        activeColor: Colors.white,
                        side: const BorderSide(color: Colors.black),
                      ),
                       Text(
                        S.of(context).lockAll,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const Spacer(),
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      //   onPressed: onClose, // same function rahega panel close karne ke liye
                      // ),
                    ],
                  ),
                ],
              ),

              Divider(),
              // --- Layer List ---
              if (orderedVisibleIds.isEmpty)
                const Expanded(
                  // Use expanded to center the text vertically
                  child: Center(
                    child: Text(
                      'No layers found.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                // This Expanded now works correctly because the Column fills its parent
                Expanded(
                  child: ListView.builder(
                    itemCount: orderedVisibleIds.length,
                    itemBuilder: (context, index) {
                      final id = orderedVisibleIds[index];
                      final isLocked = widget.logoState.lockedElements.contains(
                        id,
                      );
                      return Column(
                        children: [
                          ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -4),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            title: _buildLayerPreview(context, id),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLocked ? Icons.lock : Icons.lock_open,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => widget.onToggleLock(id),
                                ),
                                // const SizedBox(width: 2),
                                IconButton(
                                  icon: const Icon(
                                    Icons.import_export,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_moveUp && index > 0) {
                                        widget.onReorder(id, true); // move up
                                      } else if (!_moveUp &&
                                          index <
                                              orderedVisibleIds.length - 1) {
                                        widget.onReorder(
                                          id,
                                          false,
                                        ); // move down
                                      }
                                      _moveUp = !_moveUp; // toggle direction
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: ThemeColors.textGradient
                ),
                child: ListTile(
                  dense: true,
                  // visualDensity: const VisualDensity(vertical: -4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  title: const SizedBox.shrink(), // no title
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          areAllLocked ? Icons.lock : Icons.lock_open,
                          size: 22,
                          color: Colors.white,
                        ),
                        onPressed: () => widget.onToggleLockAll(!areAllLocked),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.import_export,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_moveUp) {
                              for (int id in orderedVisibleIds) {
                                widget.onReorder(id, true);
                              }
                            } else {
                              for (int id in orderedVisibleIds.reversed) {
                                widget.onReorder(id, false);
                              }
                            }
                            _moveUp = !_moveUp;
                          });
                        },
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
