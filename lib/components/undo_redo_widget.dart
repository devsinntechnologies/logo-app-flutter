import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';

class UndoRedoWidget extends StatelessWidget {
  final bool showLabels;
  final bool isCompact;
  final Color? iconColor;
  final double iconSize;

  const UndoRedoWidget({
    Key? key,
    this.showLabels = false,
    this.isCompact = true,
    this.iconColor,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UndoProvider>(
      builder: (context, undoProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4.0 : 8.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Undo Button
              _buildUndoRedoButton(
                context: context,
                icon: Icons.undo,
                isEnabled: undoProvider.canUndo,
                onPressed:
                    undoProvider.canUndo ? () => _performUndo(context) : null,
                tooltip:
                    undoProvider.canUndo
                        ? 'Undo: ${undoProvider.getLastAction()}'
                        : 'No actions to undo',
                label: showLabels ? 'Undo' : null,
              ),

              if (!isCompact) SizedBox(width: 8),

              // Redo Button
              _buildUndoRedoButton(
                context: context,
                icon: Icons.redo,
                isEnabled: undoProvider.canRedo,
                onPressed:
                    undoProvider.canRedo ? () => _performRedo(context) : null,
                tooltip:
                    undoProvider.canRedo
                        ? 'Redo: ${undoProvider.getNextAction()}'
                        : 'No actions to redo',
                label: showLabels ? 'Redo' : null,
              ),

              if (!isCompact) ...[
                SizedBox(width: 8),
                // State Counter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${undoProvider.currentStateIndex}/${undoProvider.totalStates}',
                    style: TextStyle(
                      fontSize: 10,
                      color: iconColor ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUndoRedoButton({
    required BuildContext context,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onPressed,
    required String tooltip,
    String? label,
  }) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isEnabled ? (iconColor ?? Colors.blue) : Colors.grey,
        size: iconSize,
      ),
      tooltip: tooltip,
      padding: EdgeInsets.all(isCompact ? 4 : 8),
      constraints: BoxConstraints(
        minWidth: isCompact ? 28 : 36,
        minHeight: isCompact ? 28 : 36,
      ),
    );

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isEnabled ? (iconColor ?? Colors.blue) : Colors.grey,
            ),
          ),
        ],
      );
    }

    return button;
  }

  void _performUndo(BuildContext context) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    final previousState = undoProvider.undo();
    if (previousState != null) {
      colorProvider.restoreFromState(previousState.data);

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undid: ${previousState.action}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }

  void _performRedo(BuildContext context) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    final redoState = undoProvider.redo();
    if (redoState != null) {
      colorProvider.restoreFromState(redoState.data);

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redid: ${redoState.action}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }
}
