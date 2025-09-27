import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart' show UndoProvider;
import 'package:provider/provider.dart';

class LayersPanel extends StatelessWidget {
  final LogoStateData logoState;
  final String svgLogo;
  final VoidCallback onClose;
  final ValueChanged<int> onToggleLock;
  final ValueChanged<bool> onToggleLockAll;
  final Function(int, bool) onReorder; // id, moveUp

  const LayersPanel({
    super.key,
    required this.logoState,
    required this.svgLogo,
    required this.onClose,
    required this.onToggleLock,
    required this.onToggleLockAll,
    required this.onReorder,
  });

  void _saveLayerState(BuildContext context, String action) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
    }
  }

  Widget _buildLayerPreview(BuildContext context, int id) {
    final theme = Theme.of(context);
    Widget child;
    String text = '';

    final textStyle = TextStyle(color: theme.colorScheme.onSurface);

    switch (id) {
      case 0:
      case 3:
        child = SvgPicture.string(
          svgLogo,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        );
        text = 'Logo';
        break;
      case 1:
      case 4:
        child = Text(
          logoState.companyName ?? '',
          style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        );
        text = 'Company';
        break;
      case 2:
      case 5:
        child = Text(
          logoState.sloganName ?? '',
          style: textStyle.copyWith(fontSize: 18, fontStyle: FontStyle.italic),
        );
        text = 'Slogan';
        break;
      default:
        if (id >= 100) {
          final index = id - 100;
          if (index >= 0 && index < logoState.customTexts.length) {
            final customText = logoState.customTexts[index];
            child = Text(
              customText.text,
              style: textStyle.copyWith(fontSize: 18),
            );
            text = customText.text;
          } else {
            child = Icon(Icons.error, color: theme.colorScheme.error);
            text = 'Invalid CustomText';
          }
        } else {
          child = Icon(Icons.error, color: theme.colorScheme.error);
          text = 'Unknown';
        }
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            // color: Colors.white.withOpacity(0.5),
          ),
          child: FittedBox(child: child),
        ),
        const SizedBox(width: 12),
        // Expanded(
        //   child: Text(
        //     text,
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.w500,
        //     ),
        //     overflow: TextOverflow.ellipsis,
        //   ),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderedVisibleIds =
        logoState.elementOrder
            .where((id) => logoState.visibleElementIds.contains(id))
            .toList();
    final areAllLocked =
        logoState.lockedElements.length == logoState.visibleElementIds.length &&
        logoState.visibleElementIds.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // Allow the panel to take up to 70% of the screen height
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 236,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // --- Header ---
              Stack(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: areAllLocked,
                        onChanged: (val) => onToggleLockAll(val ?? false),
                        checkColor: theme.colorScheme.onPrimary,
                        activeColor: theme.colorScheme.primary,
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        'Lock All',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      //   onPressed: onClose, // same function rahega panel close karne ke liye
                      // ),
                    ],
                  ),
                ],
              ),

              Divider(color: theme.dividerColor, height: 1),
              if (orderedVisibleIds.isEmpty)
                Expanded(
                  // Use expanded to center the text vertically
                  child: Center(
                    child: Text(
                      'No layers found.',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
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
                      final isLocked = logoState.lockedElements.contains(id);
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        title: _buildLayerPreview(context, id),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isLocked ? Icons.lock : Icons.lock_open,
                                color:
                                    isLocked
                                        ? theme.colorScheme.primary
                                        : theme.iconTheme.color,
                              ),
                              onPressed: () {
                                _saveLayerState(context, 'Lock element $id');
                                onToggleLock(id);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_upward,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                Provider.of<SelectedColorProvider>(
                                  context,
                                  listen: false,
                                ).moveElementUp(id);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_downward,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                Provider.of<SelectedColorProvider>(
                                  context,
                                  listen: false,
                                ).moveElementDown(id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
