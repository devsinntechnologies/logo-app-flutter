import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add this line
import 'package:flutter_svg/svg.dart';
import 'dart:math'; // For pi, atan2, max

// Helper class to store the full state of all logo elements
class LogoStateData {
  // Original elements
  final Offset logoPosition;
  final double logoSize;
  final double logoRotation;
  final bool isLogoVisible;

  final Offset companyNamePosition;
  final double companyNameSize;
  final double companyNameRotation;
  final bool isCompanyNameVisible;

  final Offset sloganPosition;
  final double sloganSize;
  final double sloganRotation;
  final bool isSloganVisible;

  // Duplicated elements (for 'split' functionality)
  final Offset? logo2Position;
  final double? logo2Size;
  final double? logo2Rotation;
  final bool isLogo2Visible;

  final Offset? companyName2Position;
  final double? companyName2Size;
  final double? companyName2Rotation;
  final bool isCompanyName2Visible;

  final Offset? slogan2Position;
  final double? slogan2Size;
  final double? slogan2Rotation;
  final bool isSlogan2Visible;

  LogoStateData({
    required this.logoPosition,
    required this.logoSize,
    required this.logoRotation,
    required this.isLogoVisible,
    required this.companyNamePosition,
    required this.companyNameSize,
    required this.companyNameRotation,
    required this.isCompanyNameVisible,
    required this.sloganPosition,
    required this.sloganSize,
    required this.sloganRotation,
    required this.isSloganVisible,
    this.logo2Position,
    this.logo2Size,
    this.logo2Rotation,
    this.isLogo2Visible = false,
    this.companyName2Position,
    this.companyName2Size,
    this.companyName2Rotation,
    this.isCompanyName2Visible = false,
    this.slogan2Position,
    this.slogan2Size,
    this.slogan2Rotation,
    this.isSlogan2Visible = false,
  });

  // Helper to copy and update state
  LogoStateData copyWith({
    Offset? logoPosition,
    double? logoSize,
    double? logoRotation,
    bool? isLogoVisible,
    Offset? companyNamePosition,
    double? companyNameSize,
    double? companyNameRotation,
    bool? isCompanyNameVisible,
    Offset? sloganPosition,
    double? sloganSize,
    double? sloganRotation,
    bool? isSloganVisible,
    Offset? logo2Position,
    double? logo2Size,
    double? logo2Rotation,
    bool? isLogo2Visible,
    Offset? companyName2Position,
    double? companyName2Size,
    double? companyName2Rotation,
    bool? isCompanyName2Visible,
    Offset? slogan2Position,
    double? slogan2Size,
    double? slogan2Rotation,
    bool? isSlogan2Visible,
  }) {
    return LogoStateData(
      logoPosition: logoPosition ?? this.logoPosition,
      logoSize: logoSize ?? this.logoSize,
      logoRotation: logoRotation ?? this.logoRotation,
      isLogoVisible: isLogoVisible ?? this.isLogoVisible,
      companyNamePosition: companyNamePosition ?? this.companyNamePosition,
      companyNameSize: companyNameSize ?? this.companyNameSize,
      companyNameRotation: companyNameRotation ?? this.companyNameRotation,
      isCompanyNameVisible: isCompanyNameVisible ?? this.isCompanyNameVisible,
      sloganPosition: sloganPosition ?? this.sloganPosition,
      sloganSize: sloganSize ?? this.sloganSize,
      sloganRotation: sloganRotation ?? this.sloganRotation,
      isSloganVisible: isSloganVisible ?? this.isSloganVisible,
      logo2Position: logo2Position ?? this.logo2Position,
      logo2Size: logo2Size ?? this.logo2Size,
      logo2Rotation: logo2Rotation ?? this.logo2Rotation,
      isLogo2Visible: isLogo2Visible ?? this.isLogo2Visible,
      companyName2Position: companyName2Position ?? this.companyName2Position,
      companyName2Size: companyName2Size ?? this.companyName2Size,
      companyName2Rotation: companyName2Rotation ?? this.companyName2Rotation,
      isCompanyName2Visible:
      isCompanyName2Visible ?? this.isCompanyName2Visible,
      slogan2Position: slogan2Position ?? this.slogan2Position,
      slogan2Size: slogan2Size ?? this.slogan2Size,
      slogan2Rotation: slogan2Rotation ?? this.slogan2Rotation,
      isSlogan2Visible: isSlogan2Visible ?? this.isSlogan2Visible,
    );
  }
}

// Utility to measure text size dynamically
class _TextSizeUtil {
  static Size getTextSize(String text, TextStyle? style) {
    if (text.isEmpty) return Size.zero; // Handle empty text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return textPainter.size;
  }
}

class DownloadLogo extends StatefulWidget {
  final String svgLogo;
  final String companyName;
  final String sloganName;

  const DownloadLogo({
    super.key,
    required this.svgLogo,
    required this.companyName,
    required  this.sloganName,
  });

  @override
  State<DownloadLogo> createState() => _DownloadLogoState();
}

class _DownloadLogoState extends State<DownloadLogo> {
  late LogoStateData _currentLogoState;

  final List<LogoStateData> _undoStack = [];
  final int _maxUndoHistory = 10;

  bool _showGrid = false;
  bool _isLayersRibbonExtended = false;

  bool isEditing = false;
  // Element IDs: 0: Logo, 1: Company Name, 2: Slogan,
  // 3: Logo2 (duplicate), 4: CompanyName2 (duplicate), 5: Slogan2 (duplicate)
  int? selectedElement;
  int selectedIndex = 0; // For bottom navigation bar

  int? _highlightedHorizontalGridLineIndex;
  int? _highlightedVerticalGridLineIndex;

  // Global key to get the renderbox of the canvas for global coordinates
  final GlobalKey _canvasKey = GlobalKey();

  // Variables for drag-to-resize/rotate functionality
  Offset? _initialDragPoint; // Initial touch point for resize/rotate
  double? _initialElementValue; // Initial size/rotation value

  @override
  void initState() {
    super.initState();
    _currentLogoState = LogoStateData(
      logoPosition: const Offset(150, 100),
      logoSize: 100,
      logoRotation: 0,
      isLogoVisible: true,
      companyNamePosition: const Offset(160, 200),
      companyNameSize: 20,
      companyNameRotation: 0,
      isCompanyNameVisible: true,
      sloganPosition: const Offset(150, 240),
      sloganSize: 18,
      sloganRotation: 0,
      isSloganVisible: true,
      logo2Position: const Offset(150, 100),
      logo2Size: 100,
      logo2Rotation: 0,
      isLogo2Visible: false,
      companyName2Position: const Offset(160, 200),
      companyName2Size: 20,
      companyName2Rotation: 0,
      isCompanyName2Visible: false,
      slogan2Position: const Offset(150, 240),
      slogan2Size: 18,
      slogan2Rotation: 0,
      isSlogan2Visible: false,
    );
    _saveState(); // Save initial state for undo
  }

  // --- Undo/Redo Logic ---
  void _saveState() {
    if (_undoStack.length >= _maxUndoHistory) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(_currentLogoState);
  }

  void _undo() {
    if (_undoStack.length > 1) {
      setState(() {
        _undoStack.removeLast();
        _currentLogoState = _undoStack.last;
        selectedElement = null;
        _clearGridAlignment();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undo successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to undo!')),
      );
    }
  }

  // --- Helper Methods for Element Manipulation ---

  Offset _limitOffset(
      Offset original, Offset delta, Size elementSize, Size canvasSize) {
    final newOffset = original + delta;
    final clampedDx =
    newOffset.dx.clamp(0.0, canvasSize.width - elementSize.width);
    final clampedDy =
    newOffset.dy.clamp(0.0, canvasSize.height - elementSize.height);
    return Offset(clampedDx, clampedDy);
  }

  Size _getElementRenderedSize(int elementId) {
    switch (elementId) {
      case 0: // Original Logo
        return Size(_currentLogoState.logoSize, _currentLogoState.logoSize);
      case 1: // Original Company Name
        return _TextSizeUtil.getTextSize(
          widget.companyName,
          TextStyle(
            fontSize: _currentLogoState.companyNameSize,
            fontWeight: FontWeight.bold,
          ),
        );
      case 2: // Original Slogan
        return _TextSizeUtil.getTextSize(
          widget.sloganName,
          TextStyle(
            fontSize: _currentLogoState.sloganSize,
            fontStyle: FontStyle.italic,
          ),
        );
      case 3: // Duplicated Logo
        return Size(_currentLogoState.logo2Size ?? 0,
            _currentLogoState.logo2Size ?? 0);
      case 4: // Duplicated Company Name
        return _TextSizeUtil.getTextSize(
          widget.companyName,
          TextStyle(
            fontSize: _currentLogoState.companyName2Size ?? 0,
            fontWeight: FontWeight.bold,
          ),
        );
      case 5: // Duplicated Slogan
        return _TextSizeUtil.getTextSize(
          widget.sloganName,
          TextStyle(
            fontSize: _currentLogoState.slogan2Size ?? 0,
            fontStyle: FontStyle.italic,
          ),
        );
      default:
        return Size.zero;
    }
  }

  void _deleteElement() {
    _saveState();
    setState(() {
      String message = 'Element deleted!';
      if (selectedElement == 0) {
        _currentLogoState = _currentLogoState.copyWith(isLogoVisible: false);
      } else if (selectedElement == 1) {
        _currentLogoState =
            _currentLogoState.copyWith(isCompanyNameVisible: false);
      } else if (selectedElement == 2) {
        _currentLogoState = _currentLogoState.copyWith(isSloganVisible: false);
      } else if (selectedElement == 3) {
        _currentLogoState = _currentLogoState.copyWith(
          isLogo2Visible: false,
          logo2Position: null,
          logo2Size: null,
          logo2Rotation: null,
        );
      } else if (selectedElement == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          isCompanyName2Visible: false,
          companyName2Position: null,
          companyName2Size: null,
          companyName2Rotation: null,
        );
      } else if (selectedElement == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          isSlogan2Visible: false,
          slogan2Position: null,
          slogan2Size: null,
          slogan2Rotation: null,
        );
      } else {
        message = 'No element selected to delete.';
      }
      selectedElement = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  void _splitElement() {
    _saveState();
    setState(() {
      String message = 'Element split!';
      Offset offset = const Offset(20, 20);

      if (selectedElement == 0) {
        if (_currentLogoState.isLogo2Visible == true) {
          message = 'Logo duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            logo2Position: _currentLogoState.logoPosition + offset,
            logo2Size: _currentLogoState.logoSize,
            logo2Rotation: _currentLogoState.logoRotation,
            isLogo2Visible: true,
          );
        }
      } else if (selectedElement == 1) {
        if (_currentLogoState.isCompanyName2Visible == true) {
          message = 'Company Name duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            companyName2Position: _currentLogoState.companyNamePosition + offset,
            companyName2Size: _currentLogoState.companyNameSize,
            companyName2Rotation: _currentLogoState.companyNameRotation,
            isCompanyName2Visible: true,
          );
        }
      } else if (selectedElement == 2) {
        if (_currentLogoState.isSlogan2Visible == true) {
          message = 'Slogan duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            slogan2Position: _currentLogoState.sloganPosition + offset,
            slogan2Size: _currentLogoState.sloganSize,
            slogan2Rotation: _currentLogoState.sloganRotation,
            isSlogan2Visible: true,
          );
        }
      } else if (selectedElement! >= 3 && selectedElement! <= 5) {
        message = 'Cannot split a duplicate element further.';
      } else {
        message = 'No element selected for splitting.';
      }
      selectedElement = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  // Changed to _rotateElementByTap to differentiate from drag
  void _rotateElementByTap() {
    _saveState();
    setState(() {
      // Increased rotation step for more noticeable tap changes
      const double rotationStep = 45;
      if (selectedElement == 0) {
        _currentLogoState = _currentLogoState.copyWith(
            logoRotation: (_currentLogoState.logoRotation + rotationStep) % 360);
      } else if (selectedElement == 1) {
        _currentLogoState = _currentLogoState.copyWith(
            companyNameRotation:
            (_currentLogoState.companyNameRotation + rotationStep) % 360);
      } else if (selectedElement == 2) {
        _currentLogoState = _currentLogoState.copyWith(
            sloganRotation:
            (_currentLogoState.sloganRotation + rotationStep) % 360);
      } else if (selectedElement == 3) {
        _currentLogoState = _currentLogoState.copyWith(
            logo2Rotation: (_currentLogoState.logo2Rotation! + rotationStep) % 360);
      } else if (selectedElement == 4) {
        _currentLogoState = _currentLogoState.copyWith(
            companyName2Rotation:
            (_currentLogoState.companyName2Rotation! + rotationStep) % 360);
      } else if (selectedElement == 5) {
        _currentLogoState = _currentLogoState.copyWith(
            slogan2Rotation:
            (_currentLogoState.slogan2Rotation! + rotationStep) % 360);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No element selected to rotate.')),
        );
      }
    });
  }

  // Changed to _resizeElementByTap to differentiate from drag
  void _resizeElementByTap() {
    _saveState();
    setState(() {
      // Increased resize step for more noticeable tap changes
      const double resizeStep = 20.0;
      const double minSize = 10.0;
      if (selectedElement == 0) {
        _currentLogoState = _currentLogoState.copyWith(
            logoSize: max(minSize, _currentLogoState.logoSize + resizeStep));
      } else if (selectedElement == 1) {
        _currentLogoState = _currentLogoState.copyWith(
            companyNameSize: max(minSize, _currentLogoState.companyNameSize + resizeStep));
      } else if (selectedElement == 2) {
        _currentLogoState = _currentLogoState.copyWith(
            sloganSize: max(minSize, _currentLogoState.sloganSize + resizeStep));
      } else if (selectedElement == 3) {
        _currentLogoState = _currentLogoState.copyWith(
            logo2Size: max(minSize, _currentLogoState.logo2Size! + resizeStep));
      } else if (selectedElement == 4) {
        _currentLogoState = _currentLogoState.copyWith(
            companyName2Size: max(minSize, _currentLogoState.companyName2Size! + resizeStep));
      } else if (selectedElement == 5) {
        _currentLogoState = _currentLogoState.copyWith(
            slogan2Size: max(minSize, _currentLogoState.slogan2Size! + resizeStep));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No element selected to resize.')),
        );
      }
    });
  }

  void _showSaveOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Logo'),
          content: const Text('Choose format to save:'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveAsSVG();
                  },
                  child: const Text('Save as SVG'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveAsPNG();
                  },
                  child: const Text('Save as PNG'),
                ),
              ],
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveAsSVG() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logo saved as SVG!')));
  }

  void _saveAsPNG() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logo saved as PNG!')));
  }

  Widget _buildCornerIcon({
    required IconData icon,
    required VoidCallback onTap, // For simple tap actions
    required Alignment alignment,
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(alignment.x * 15, alignment.y * 15),
        child: GestureDetector(
          onTap: onTap,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // --- Grid Alignment Logic ---
  void _checkGridAlignment(
      Offset elementPosition, Size elementSize, Size canvasSize) {
    int? newHighlightedHorizontal;
    int? newHighlightedVertical;

    if (!_showGrid) {
      _clearGridAlignment();
      return;
    }

    const double tolerance = 10.0;
    final double centerX = elementPosition.dx + elementSize.width / 2;
    final double centerY = elementPosition.dy + elementSize.height / 2;

    final double colStep = canvasSize.width / 4;
    final double rowStep = canvasSize.height / 4;

    for (int i = 0; i <= 4; i++) {
      final double gridX = i * colStep;
      if ((centerX - gridX).abs() < tolerance) {
        newHighlightedVertical = i;
        break;
      }
    }

    for (int i = 0; i <= 4; i++) {
      final double gridY = i * rowStep;
      if ((centerY - gridY).abs() < tolerance) {
        newHighlightedHorizontal = i;
        break;
      }
    }

    if (newHighlightedHorizontal != _highlightedHorizontalGridLineIndex ||
        newHighlightedVertical != _highlightedVerticalGridLineIndex) {
      setState(() {
        _highlightedHorizontalGridLineIndex = newHighlightedHorizontal;
        _highlightedVerticalGridLineIndex = newHighlightedVertical;
      });
    }
  }

  void _clearGridAlignment() {
    if (_highlightedHorizontalGridLineIndex != null ||
        _highlightedVerticalGridLineIndex != null) {
      setState(() {
        _highlightedHorizontalGridLineIndex = null;
        _highlightedVerticalGridLineIndex = null;
      });
    }
  }

  // --- Pan gesture handlers for Resize and Rotate icons ---

  void _onResizePanStart(DragStartDetails details, int id) {
    _saveState(); // Save state at the beginning of the drag
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getCurrentElementSize(id);
  }

  void _onResizePanUpdate(DragUpdateDetails details, int id, Size canvasSize) {
    if (_initialDragPoint == null || _initialElementValue == null) return;

    // Get the global position of the element's top-left corner
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? canvasOffset = renderBox?.localToGlobal(Offset.zero);

    if (canvasOffset == null) return;

    // Calculate the element's center in global coordinates
    final Offset elementCurrentPosition = _getCurrentElementPosition(id);
    final Size elementCurrentSize = _getElementRenderedSize(id);
    final Offset elementCenterGlobal = Offset(
      canvasOffset.dx + elementCurrentPosition.dx + elementCurrentSize.width / 2,
      canvasOffset.dy + elementCurrentPosition.dy + elementCurrentSize.height / 2,
    );

    // Calculate initial distance from center to drag point
    final double initialDistance = (_initialDragPoint! - elementCenterGlobal).distance;

    // Calculate current distance from center to drag point
    final double currentDistance = (details.globalPosition - elementCenterGlobal).distance;

    // Calculate the scale factor based on distance change
    final double scaleFactor = currentDistance / initialDistance;

    // Apply sensitivity to make resizing more or less aggressive
    const double sensitivity = 0.5; // Adjust this value to control responsiveness
    double newSize = _initialElementValue! * scaleFactor;
    newSize = _initialElementValue! + (newSize - _initialElementValue!) * sensitivity;


    // Clamp the new size
    const double minSize = 10.0;
    const double maxSize = 300.0; // Prevent elements from becoming too large
    newSize = newSize.clamp(minSize, maxSize);

    setState(() {
      // Update the size for the selected element
      _updateElementSize(id, newSize);
      // Recalculate and update grid alignment (optional, but good for real-time feedback)
      _checkGridAlignment(_getCurrentElementPosition(id), _getElementRenderedSize(id), canvasSize);
    });
  }

  void _onResizePanEnd(DragEndDetails details) {
    _initialDragPoint = null;
    _initialElementValue = null;
    _clearGridAlignment();
  }

  void _onRotatePanStart(DragStartDetails details, int id) {
    _saveState(); // Save state at the beginning of the drag
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getCurrentElementRotation(id);
  }

  void _onRotatePanUpdate(DragUpdateDetails details, int id, Size canvasSize) {
    if (_initialDragPoint == null || _initialElementValue == null) return;

    // Get the global position of the element's top-left corner
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? canvasOffset = renderBox?.localToGlobal(Offset.zero);

    if (canvasOffset == null) return;

    // Calculate the element's center in global coordinates
    final Offset elementCurrentPosition = _getCurrentElementPosition(id);
    final Size elementCurrentSize = _getElementRenderedSize(id);
    final Offset elementCenterGlobal = Offset(
      canvasOffset.dx + elementCurrentPosition.dx + elementCurrentSize.width / 2,
      canvasOffset.dy + elementCurrentPosition.dy + elementCurrentSize.height / 2,
    );

    // Vector from center to initial drag point
    final Offset v1 = _initialDragPoint! - elementCenterGlobal;
    // Vector from center to current drag point
    final Offset v2 = details.globalPosition - elementCenterGlobal;

    // Calculate angle between the two vectors using atan2
    double angle1 = atan2(v1.dy, v1.dx);
    double angle2 = atan2(v2.dy, v2.dx);

    // Calculate the difference in angles (in radians)
    double angleDeltaRadians = angle2 - angle1;

    // Convert to degrees and normalize to 0-360
    double angleDeltaDegrees = angleDeltaRadians * 180 / pi;
    double newRotation = (_initialElementValue! + angleDeltaDegrees) % 360;
    if (newRotation < 0) {
      newRotation += 360;
    }

    setState(() {
      _updateElementRotation(id, newRotation);
    });
  }

  void _onRotatePanEnd(DragEndDetails details) {
    _initialDragPoint = null;
    _initialElementValue = null;
  }

  // Helper to get current size by ID for resize pan
  double _getCurrentElementSize(int id) {
    switch (id) {
      case 0:
        return _currentLogoState.logoSize;
      case 1:
        return _currentLogoState.companyNameSize;
      case 2:
        return _currentLogoState.sloganSize;
      case 3:
        return _currentLogoState.logo2Size!;
      case 4:
        return _currentLogoState.companyName2Size!;
      case 5:
        return _currentLogoState.slogan2Size!;
      default:
        return 0;
    }
  }

  // Helper to update size by ID
  void _updateElementSize(int id, double newSize) {
    if (id == 0) {
      _currentLogoState = _currentLogoState.copyWith(logoSize: newSize);
    } else if (id == 1) {
      _currentLogoState = _currentLogoState.copyWith(companyNameSize: newSize);
    } else if (id == 2) {
      _currentLogoState = _currentLogoState.copyWith(sloganSize: newSize);
    } else if (id == 3) {
      _currentLogoState = _currentLogoState.copyWith(logo2Size: newSize);
    } else if (id == 4) {
      _currentLogoState = _currentLogoState.copyWith(companyName2Size: newSize);
    } else if (id == 5) {
      _currentLogoState = _currentLogoState.copyWith(slogan2Size: newSize);
    }
  }

  // Helper to get current rotation by ID for rotate pan
  double _getCurrentElementRotation(int id) {
    switch (id) {
      case 0:
        return _currentLogoState.logoRotation;
      case 1:
        return _currentLogoState.companyNameRotation;
      case 2:
        return _currentLogoState.sloganRotation;
      case 3:
        return _currentLogoState.logo2Rotation!;
      case 4:
        return _currentLogoState.companyName2Rotation!;
      case 5:
        return _currentLogoState.slogan2Rotation!;
      default:
        return 0;
    }
  }

  // Helper to update rotation by ID
  void _updateElementRotation(int id, double newRotation) {
    if (id == 0) {
      _currentLogoState = _currentLogoState.copyWith(logoRotation: newRotation);
    } else if (id == 1) {
      _currentLogoState =
          _currentLogoState.copyWith(companyNameRotation: newRotation);
    } else if (id == 2) {
      _currentLogoState = _currentLogoState.copyWith(sloganRotation: newRotation);
    } else if (id == 3) {
      _currentLogoState = _currentLogoState.copyWith(logo2Rotation: newRotation);
    } else if (id == 4) {
      _currentLogoState =
          _currentLogoState.copyWith(companyName2Rotation: newRotation);
    } else if (id == 5) {
      _currentLogoState = _currentLogoState.copyWith(slogan2Rotation: newRotation);
    }
  }

  // Helper to get current position by ID (needed for center calculation)
  Offset _getCurrentElementPosition(int id) {
    switch (id) {
      case 0:
        return _currentLogoState.logoPosition;
      case 1:
        return _currentLogoState.companyNamePosition;
      case 2:
        return _currentLogoState.sloganPosition;
      case 3:
        return _currentLogoState.logo2Position!;
      case 4:
        return _currentLogoState.companyName2Position!;
      case 5:
        return _currentLogoState.slogan2Position!;
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Text(
          'Logo Maker',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, size: 40),
            onPressed: _undo,
            tooltip: 'Undo last change',
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 40),
            onPressed: _showSaveOptions,
            tooltip: 'Save Logo',
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 40),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                selectedElement = null;
                _clearGridAlignment(); // Clear highlights when toggling edit mode
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? 'Editing mode enabled'
                        : 'Editing mode disabled',
                  ),
                ),
              );
            },
            tooltip: 'Toggle Edit Mode',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(height: 500, width: double.infinity, color: Colors.white),
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final Size canvasSize = constraints.biggest;
                    return Stack(
                      key: _canvasKey, // Assign GlobalKey to the canvas Stack
                      children: [
                        if (_showGrid)
                          CustomPaint(
                            painter: _GridPainter(
                              gridColor: Colors.black,
                              highlightedHorizontalLine:
                              _highlightedHorizontalGridLineIndex,
                              highlightedVerticalLine:
                              _highlightedVerticalGridLineIndex,
                            ),
                            size: Size.infinite,
                          ),
                        Positioned(
                          top: 20,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showGrid = !_showGrid;
                                if (!_showGrid) {
                                  _clearGridAlignment();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25.0),
                                  bottomLeft: Radius.circular(25.0),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(-2, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _showGrid ? Icons.grid_off : Icons.grid_on,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLayersRibbonExtended =
                                !_isLayersRibbonExtended;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _isLayersRibbonExtended ? 180.0 : 60.0,
                              height: 44.0,
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(25.0),
                                  bottomRight: Radius.circular(25.0),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Icon(
                                      _isLayersRibbonExtended
                                          ? Icons.arrow_back_ios
                                          : Icons.layers,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  if (_isLayersRibbonExtended)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 16.0),
                                        child: Text(
                                          'No Layers Found',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Logo (Original)
                        if (_currentLogoState.isLogoVisible)
                          _buildEditableElement(
                            id: 0,
                            position: _currentLogoState.logoPosition,
                            size: _currentLogoState.logoSize,
                            rotation: _currentLogoState.logoRotation,
                            canvasSize: canvasSize,
                            child: SvgPicture.string(
                              widget.svgLogo,
                              height: _currentLogoState.logoSize,
                              width: _currentLogoState.logoSize,
                            ),
                          ),

                        // Company Name (Original)
                        if (_currentLogoState.isCompanyNameVisible)
                          _buildEditableElement(
                            id: 1,
                            position: _currentLogoState.companyNamePosition,
                            size: _currentLogoState.companyNameSize,
                            rotation: _currentLogoState.companyNameRotation,
                            canvasSize: canvasSize,
                            child: Text(
                              widget.companyName,
                              style: TextStyle(
                                fontSize: _currentLogoState.companyNameSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Slogan (Original)
                        if (_currentLogoState.isSloganVisible)
                          _buildEditableElement(
                            id: 2,
                            position: _currentLogoState.sloganPosition,
                            size: _currentLogoState.sloganSize,
                            rotation: _currentLogoState.sloganRotation,
                            canvasSize: canvasSize,
                            child: Text(
                              widget.sloganName,
                              style: TextStyle(
                                fontSize: _currentLogoState.sloganSize,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        // Logo (Duplicate)
                        if (_currentLogoState.isLogo2Visible)
                          _buildEditableElement(
                            id: 3,
                            position: _currentLogoState.logo2Position!,
                            size: _currentLogoState.logo2Size!,
                            rotation: _currentLogoState.logo2Rotation!,
                            canvasSize: canvasSize,
                            child: SvgPicture.string(
                              widget.svgLogo,
                              height: _currentLogoState.logo2Size!,
                              width: _currentLogoState.logo2Size!,
                            ),
                          ),

                        // Company Name (Duplicate)
                        if (_currentLogoState.isCompanyName2Visible)
                          _buildEditableElement(
                            id: 4,
                            position: _currentLogoState.companyName2Position!,
                            size: _currentLogoState.companyName2Size!,
                            rotation: _currentLogoState.companyName2Rotation!,
                            canvasSize: canvasSize,
                            child: Text(
                              widget.companyName,
                              style: TextStyle(
                                fontSize: _currentLogoState.companyName2Size!,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Slogan (Duplicate)
                        if (_currentLogoState.isSlogan2Visible)
                          _buildEditableElement(
                            id: 5,
                            position: _currentLogoState.slogan2Position!,
                            size: _currentLogoState.slogan2Size!,
                            rotation: _currentLogoState.slogan2Rotation!,
                            canvasSize: canvasSize,
                            child: Text(
                              widget.sloganName,
                              style: TextStyle(
                                fontSize: _currentLogoState.slogan2Size!,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Column(
                children: [
                  Container(height: 300, color: Colors.grey.shade200)
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomAppBar(
          color: Colors.black,
          child: Row(
            children: List.generate(5, (index) {
              IconData iconData;
              String label;
              VoidCallback onTap;

              switch (index) {
                case 0:
                  iconData = Icons.layers;
                  label = 'Background';
                  onTap = () {
                    setState(() {
                      isEditing = false;
                      selectedIndex = 0;
                      selectedElement = null;
                    });
                  };
                  break;
                case 1:
                  iconData = Icons.article_rounded;
                  label = 'Art';
                  onTap = () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  };
                  break;
                case 2:
                  iconData = Icons.text_fields_outlined;
                  label = 'Text';
                  onTap = () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  };
                  break;
                case 3:
                  iconData = Icons.edit;
                  label = 'Effects';
                  onTap = () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  };
                  break;
                case 4:
                default:
                  iconData = Icons.image;
                  label = 'Images';
                  onTap = () {
                    setState(() {
                      selectedIndex = 4;
                    });
                  };
                  break;
              }

              final isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: SizedBox.expand(
                    child: Container(
                      color: isSelected ? Colors.white : Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData,
                            color: isSelected ? Colors.black : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // --- Widget Builder for Editable Elements ---
  Widget _buildEditableElement({
    required int id,
    required Offset position,
    required double size,
    required double rotation,
    required Widget child,
    required Size canvasSize,
  }) {
    Size elementSize = _getElementRenderedSize(id);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedElement = id;
            _clearGridAlignment();
          });
        },
        onPanStart: (details) {
          _saveState();
        },
        onPanUpdate: isEditing && selectedElement == id
            ? (details) {
          setState(() {
            Offset newPosition = _limitOffset(
                position, details.delta, elementSize, canvasSize);

            if (id == 0) {
              _currentLogoState =
                  _currentLogoState.copyWith(logoPosition: newPosition);
            } else if (id == 1) {
              _currentLogoState = _currentLogoState.copyWith(
                  companyNamePosition: newPosition);
            } else if (id == 2) {
              _currentLogoState =
                  _currentLogoState.copyWith(sloganPosition: newPosition);
            } else if (id == 3) {
              _currentLogoState =
                  _currentLogoState.copyWith(logo2Position: newPosition);
            } else if (id == 4) {
              _currentLogoState = _currentLogoState.copyWith(
                  companyName2Position: newPosition);
            } else if (id == 5) {
              _currentLogoState = _currentLogoState.copyWith(
                  slogan2Position: newPosition);
            }
            _checkGridAlignment(newPosition, elementSize, canvasSize);
          });
        }
            : null,
        onPanEnd: (details) {
          _clearGridAlignment();
        },
        child: Container(
          decoration: selectedElement == id && isEditing
              ? BoxDecoration(
            border: Border.all(
              color: Colors.black38,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(6),
          )
              : null,
          padding: const EdgeInsets.all(2),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: rotation * pi / 180,
                child: child,
              ),
              if (selectedElement == id && isEditing) ...[
                Positioned(
                  bottom: 0,
                  right: 0,
                  top: 0,
                  left: 0,
                  child: _buildCornerIcon(
                    icon: Icons.close,
                    onTap: _deleteElement,
                    alignment: Alignment.topLeft,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  top: 0,
                  left: 0,
                  child: _buildCornerIcon(
                    icon: Icons.call_split,
                    onTap: _splitElement,
                    alignment: Alignment.topRight,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  top: 0,
                  left: 0,
                  child: _buildCornerIcon(
                    icon: Icons.rotate_right,
                    onTap: _rotateElementByTap, // Tap to rotate
                    onPanStart: (details) => _onRotatePanStart(details, id),
                    onPanUpdate: (details) =>
                        _onRotatePanUpdate(details, id, canvasSize),
                    onPanEnd: _onRotatePanEnd,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  top: 0,
                  left: 0,
                  child: _buildCornerIcon(
                    icon: Icons.open_in_full,
                    onTap: _resizeElementByTap, // Tap to resize
                    onPanStart: (details) => _onResizePanStart(details, id),
                    onPanUpdate: (details) =>
                        _onResizePanUpdate(details, id, canvasSize),
                    onPanEnd: _onResizePanEnd,
                    alignment: Alignment.bottomRight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// CustomPainter for drawing the fixed 4x4 dotted grid
class _GridPainter extends CustomPainter {
  final Color gridColor;
  final int? highlightedHorizontalLine;
  final int? highlightedVerticalLine;

  _GridPainter({
    required this.gridColor,
    this.highlightedHorizontalLine,
    this.highlightedVerticalLine,
  });

  final double _dashWidth = 4.0;
  final double _dashSpace = 4.0;
  final double _strokeWidth = 2.0;
  final double _highlightStrokeWidth = 3.0;
  final Color _highlightColor = Colors.redAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = gridColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint highlightPaint = Paint()
      ..color = _highlightColor
      ..strokeWidth = _highlightStrokeWidth
      ..style = PaintingStyle.stroke;

    final double colStep = size.width / 4;
    final double rowStep = size.height / 4;

    for (int i = 0; i <= 4; i++) {
      final double y = i * rowStep;
      double currentX = 0;
      final Paint currentPaint =
      i == highlightedHorizontalLine ? highlightPaint : paint;
      while (currentX < size.width) {
        double segmentEnd = currentX + _dashWidth;
        if (segmentEnd > size.width) {
          segmentEnd = size.width;
        }
        canvas.drawLine(
            Offset(currentX, y), Offset(segmentEnd, y), currentPaint);
        currentX += _dashWidth + _dashSpace;
      }
    }

    for (int i = 0; i <= 4; i++) {
      final double x = i * colStep;
      double currentY = 0;
      final Paint currentPaint =
      i == highlightedVerticalLine ? highlightPaint : paint;
      while (currentY < size.height) {
        double segmentEnd = currentY + _dashWidth;
        if (segmentEnd > size.height) {
          segmentEnd = size.height;
        }
        canvas.drawLine(
            Offset(x, currentY), Offset(x, segmentEnd), currentPaint);
        currentY += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.highlightedHorizontalLine != highlightedHorizontalLine ||
        oldDelegate.highlightedVerticalLine != highlightedVerticalLine;
  }
}