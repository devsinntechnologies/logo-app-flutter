import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart'; // Added for layer preview
import 'package:logo_app_flutter/components/logo_bottom_nav_bar.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';

import '../components/logoBottomNavbarItems/drop_up_panel.dart';
import '../components/logo_canvas.dart';
import '../utils/text_size_util.dart';
import 'text_screen.dart';

class DownloadLogo extends StatefulWidget {
  final String svgLogo;
  final String companyName;
  final String sloganName;

  const DownloadLogo({
    super.key,
    required this.svgLogo,
    required this.companyName,
    required this.sloganName,
  });

  @override
  State<DownloadLogo> createState() => _DownloadLogoState();
}

class _DownloadLogoState extends State<DownloadLogo> {
  // --- State Management ---
  late LogoStateData _currentLogoState;
  final List<LogoStateData> _undoStack = [];
  final int _maxUndoHistory = 10;

  // --- UI Toggles ---
  bool _showGrid = false;
  bool _isLayersPanelVisible = false; // Changed from _isLayersRibbonExtended
  bool showDropUp = false;

  // --- Background Toggles ---
  bool isCheckerboardActive = false;
  bool isCheckerboardVisible = false;
  double checkerboardOpacity = 1.0;

  // --- Editing State ---
  bool isEditing = false;
  int? selectedElement;
  int selectedIndex = 0;

  // --- Grid & Canvas Keys for Coordinates ---
  int? _highlightedHorizontalGridLineIndex;
  int? _highlightedVerticalGridLineIndex;
  final GlobalKey _canvasKey = GlobalKey();

  // --- Drag State ---
  Offset? _initialDragPoint;
  double? _initialElementValue;

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
      companyName: widget.companyName,
      sloganName: widget.sloganName,
      sloganPosition: const Offset(150, 240),
      sloganSize: 18,
      sloganRotation: 0,
      isSloganVisible: true,
      isLogo2Visible: false,
      isCompanyName2Visible: false,
      isSlogan2Visible: false,
      customTexts: [],
      // ✅ Set initial layer state
      lockedElements: {},
      elementOrder: [0, 1, 2], // Default render order
    );
    _saveState();
  }

  // --- State Save/Undo ---
  void _saveState() {
    if (_undoStack.length >= _maxUndoHistory) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(_currentLogoState);
    if (mounted) setState(() {});
  }

  void _undo() {
    if (_undoStack.length > 1) {
      setState(() {
        _undoStack.removeLast();
        _currentLogoState = _undoStack.last;
        selectedElement = null;
        _clearGridAlignment();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Undo successful!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to undo!')));
    }
  }

  // --- Navigation & Element Creation ---
  void _handleBottomNavTap(int index) async {
    setState(() {
      selectedIndex = index;
      showDropUp = index == 0 ? !showDropUp : false;
    });

    if (index == 2) {
      final result = await Navigator.of(context).push<String>(_createSlideRoute());
      if (result != null && result.isNotEmpty) {
        _saveState();
        setState(() {
          final newTextElement = CustomTextElement(
            text: result,
            position: _getCanvasCenter() ?? const Offset(150, 150),
            size: 22,
            rotation: 0,
          );
          final updatedCustomTexts = List<CustomTextElement>.from(_currentLogoState.customTexts)..add(newTextElement);
          final newElementId = 100 + _currentLogoState.customTexts.length;
          final updatedElementOrder = List<int>.from(_currentLogoState.elementOrder)..add(newElementId);

          _currentLogoState = _currentLogoState.copyWith(
            customTexts: updatedCustomTexts,
            elementOrder: updatedElementOrder,
          );
        });
      }
    }
  }

  Route<String> _createSlideRoute() {
    return PageRouteBuilder<String>(
      pageBuilder: (context, animation, secondaryAnimation) => const TextScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  // --- Element Selection & Deletion ---
  void _elementSelect(int id) {
    setState(() {
      selectedElement = id;
      _clearGridAlignment();
    });
  }

  void _deleteElement(int id) {
    _saveState();
    setState(() {
      String message = 'Element deleted!';
      LogoStateData newState = _currentLogoState;

      // Remove from collections first
      final newOrder = List<int>.from(newState.elementOrder)..remove(id);
      final newLocked = Set<int>.from(newState.lockedElements)..remove(id);
      newState = newState.copyWith(elementOrder: newOrder, lockedElements: newLocked);

      if (id >= 100) {
        final index = id - 100;
        if (index < _currentLogoState.customTexts.length) {
          final updatedCustomTexts = List<CustomTextElement>.from(_currentLogoState.customTexts)..removeAt(index);
          newState = newState.copyWith(customTexts: updatedCustomTexts);
        }
      } else if (id == 0) {
        newState = newState.copyWith(isLogoVisible: false);
      } else if (id == 1) {
        newState = newState.copyWith(isCompanyNameVisible: false);
      } else if (id == 2) {
        newState = newState.copyWith(isSloganVisible: false);
      } else if (id == 3) {
        newState = newState.copyWith(isLogo2Visible: false);
      } else if (id == 4) {
        newState = newState.copyWith(isCompanyName2Visible: false);
      } else if (id == 5) {
        newState = newState.copyWith(isSlogan2Visible: false);
      } else {
        message = 'No element selected to delete.';
      }

      _currentLogoState = newState;
      selectedElement = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  // --- Element Transformations (respecting lock) ---

  bool _isElementLocked(int id) {
    final isLocked = _currentLogoState.lockedElements.contains(id);
    if (isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Element is locked.'), duration: Duration(seconds: 1)));
    }
    return isLocked;
  }

  void _splitElement(int id) {
    if (_isElementLocked(id)) return;
    if (id >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot split custom text elements.')));
      return;
    }
    _saveState();
    setState(() {
      String message = 'Element split!';
      Offset offset = const Offset(20, 20);
      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(logo2Position: _currentLogoState.logoPosition + offset, logo2Size: _currentLogoState.logoSize, logo2Rotation: _currentLogoState.logoRotation, isLogo2Visible: true);
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(companyName2Position: _currentLogoState.companyNamePosition + offset, companyName2Size: _currentLogoState.companyNameSize, companyName2Rotation: _currentLogoState.companyNameRotation, isCompanyName2Visible: true);
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(slogan2Position: _currentLogoState.sloganPosition + offset, slogan2Size: _currentLogoState.sloganSize, slogan2Rotation: _currentLogoState.sloganRotation, isSlogan2Visible: true);
      } else {
        message = 'Cannot split this element.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _rotateElementByTap(int id) {
    if (_isElementLocked(id)) return;
    _saveState();
    setState(() {
      const double rotationStep = 45.0;
      if (id >= 100) {
        _updateElementRotation(id, _getElementRotation(id) + rotationStep);
      } else if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(logoRotation: (_currentLogoState.logoRotation + rotationStep) % 360);
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(companyNameRotation: (_currentLogoState.companyNameRotation + rotationStep) % 360);
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(sloganRotation: (_currentLogoState.sloganRotation + rotationStep) % 360);
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(logo2Rotation: ((_currentLogoState.logo2Rotation ?? 0) + rotationStep) % 360);
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(companyName2Rotation: ((_currentLogoState.companyName2Rotation ?? 0) + rotationStep) % 360);
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(slogan2Rotation: ((_currentLogoState.slogan2Rotation ?? 0) + rotationStep) % 360);
      }
    });
  }

  void _resizeElementByTap(int id) {
    if (_isElementLocked(id)) return;
    _saveState();
    setState(() {
      const double resizeStep = 20.0;
      const double minSize = 10.0;
      if (id >= 100) {
        _updateElementSize(id, max(minSize, _getElementSize(id) + resizeStep));
      } else if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(logoSize: max(minSize, _currentLogoState.logoSize + resizeStep));
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(companyNameSize: max(minSize, _currentLogoState.companyNameSize + resizeStep));
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(sloganSize: max(minSize, _currentLogoState.sloganSize + resizeStep));
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(logo2Size: max(minSize, (_currentLogoState.logo2Size ?? minSize) + resizeStep));
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(companyName2Size: max(minSize, (_currentLogoState.companyName2Size ?? minSize) + resizeStep));
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(slogan2Size: max(minSize, (_currentLogoState.slogan2Size ?? minSize) + resizeStep));
      }
    });
  }

  void _updateElementPosition(int id, Offset delta) {
    if (_isElementLocked(id)) return;
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final canvasSize = renderBox.size;
    final originalPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);
    if (elementSize == Size.zero) return;
    final newPosition = _limitOffset(originalPosition, delta, elementSize, canvasSize);
    setState(() {
      if (id >= 100) {
        final index = id - 100;
        if (index < _currentLogoState.customTexts.length) {
          final updatedTexts = List<CustomTextElement>.from(_currentLogoState.customTexts);
          updatedTexts[index] = updatedTexts[index].copyWith(position: newPosition);
          _currentLogoState = _currentLogoState.copyWith(customTexts: updatedTexts);
        }
      } else if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(logoPosition: newPosition);
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(companyNamePosition: newPosition);
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(sloganPosition: newPosition);
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(logo2Position: newPosition);
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(companyName2Position: newPosition);
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(slogan2Position: newPosition);
      }
      _checkGridAlignment(newPosition, elementSize, canvasSize);
    });
  }

  void _onResizePanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;
    _saveState();
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getElementSize(id);
  }

  void _onResizePanUpdate(int id, DragUpdateDetails details) {
    if (_isElementLocked(id)) return;
    if (_initialDragPoint == null || _initialElementValue == null) return;
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset canvasOffset = renderBox.localToGlobal(Offset.zero);
    final elementPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);
    final elementCenterGlobal = canvasOffset + elementPosition + Offset(elementSize.width / 2, elementSize.height / 2);
    final initialDistance = (_initialDragPoint! - elementCenterGlobal).distance;
    final currentDistance = (details.globalPosition - elementCenterGlobal).distance;
    if (initialDistance == 0) return;
    final scaleFactor = currentDistance / initialDistance;
    double newSize = (_initialElementValue! * scaleFactor).clamp(10.0, 300.0);
    setState(() => _updateElementSize(id, newSize));
  }

  void _onRotatePanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;
    _saveState();
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getElementRotation(id);
  }

  void _onRotatePanUpdate(int id, DragUpdateDetails details) {
    if (_isElementLocked(id)) return;
    if (_initialDragPoint == null || _initialElementValue == null) return;
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset canvasOffset = renderBox.localToGlobal(Offset.zero);
    final elementPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);
    final elementCenterGlobal = canvasOffset + elementPosition + Offset(elementSize.width / 2, elementSize.height / 2);
    final v1 = _initialDragPoint! - elementCenterGlobal;
    final v2 = details.globalPosition - elementCenterGlobal;
    double angleDelta = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx);
    double newRotation = (_initialElementValue! + (angleDelta * 180 / pi));
    setState(() => _updateElementRotation(id, newRotation));
  }

  void _onPanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;
    _saveState();
  }

  void _onPanEnd(int id) {
    _initialDragPoint = null;
    _initialElementValue = null;
    _clearGridAlignment();
  }

  // --- Getters & Helpers ---

  Offset? _getCanvasCenter() {
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      return Offset(size.width / 2, size.height / 2);
    }
    return null;
  }

  Offset _limitOffset(Offset original, Offset delta, Size elementSize, Size canvasSize) {
    final newOffset = original + delta;
    final clampedDx = newOffset.dx.clamp(0.0, canvasSize.width - elementSize.width);
    final clampedDy = newOffset.dy.clamp(0.0, canvasSize.height - elementSize.height);
    return Offset(clampedDx, clampedDy);
  }

  void _clearGridAlignment() {
    if (_highlightedHorizontalGridLineIndex != null || _highlightedVerticalGridLineIndex != null) {
      setState(() {
        _highlightedHorizontalGridLineIndex = null;
        _highlightedVerticalGridLineIndex = null;
      });
    }
  }

  void _checkGridAlignment(Offset elementPosition, Size elementSize, Size canvasSize) {
    if (!_showGrid) return;
    int? newH, newV;
    const tolerance = 10.0;
    final centerX = elementPosition.dx + elementSize.width / 2;
    final centerY = elementPosition.dy + elementSize.height / 2;
    for (int i = 0; i <= 4; i++) {
      if ((centerX - (i * canvasSize.width / 4)).abs() < tolerance) newV = i;
      if ((centerY - (i * canvasSize.height / 4)).abs() < tolerance) newH = i;
    }
    if (newH != _highlightedHorizontalGridLineIndex || newV != _highlightedVerticalGridLineIndex) {
      setState(() {
        _highlightedHorizontalGridLineIndex = newH;
        _highlightedVerticalGridLineIndex = newV;
      });
    }
  }

  Offset _getElementPosition(int id) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) return _currentLogoState.customTexts[index].position;
    }
    switch (id) {
      case 0:
        return _currentLogoState.logoPosition;
      case 1:
        return _currentLogoState.companyNamePosition;
      case 2:
        return _currentLogoState.sloganPosition;
      case 3:
        return _currentLogoState.logo2Position ?? Offset.zero;
      case 4:
        return _currentLogoState.companyName2Position ?? Offset.zero;
      case 5:
        return _currentLogoState.slogan2Position ?? Offset.zero;
      default:
        return Offset.zero;
    }
  }

  double _getElementSize(int id) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) return _currentLogoState.customTexts[index].size;
    }
    switch (id) {
      case 0:
        return _currentLogoState.logoSize;
      case 1:
        return _currentLogoState.companyNameSize;
      case 2:
        return _currentLogoState.sloganSize;
      case 3:
        return _currentLogoState.logo2Size ?? 0;
      case 4:
        return _currentLogoState.companyName2Size ?? 0;
      case 5:
        return _currentLogoState.slogan2Size ?? 0;
      default:
        return 0;
    }
  }

  Size _getElementRenderedSize(int id) {
    final sizeValue = _getElementSize(id);
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) {
        final text = _currentLogoState.customTexts[index].text;
        return TextSizeUtil.getTextSize(text, TextStyle(fontSize: sizeValue, color: Colors.black, fontWeight: FontWeight.w500));
      }
    }
    switch (id) {
      case 0:
      case 3:
        return Size(sizeValue, sizeValue);
      case 1:
      case 4:
        return TextSizeUtil.getTextSize(widget.companyName, TextStyle(fontSize: sizeValue, fontWeight: FontWeight.bold));
      case 2:
      case 5:
        return TextSizeUtil.getTextSize(widget.sloganName, TextStyle(fontSize: sizeValue, fontStyle: FontStyle.italic));
      default:
        return Size.zero;
    }
  }

  double _getElementRotation(int id) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) return _currentLogoState.customTexts[index].rotation;
    }
    switch (id) {
      case 0:
        return _currentLogoState.logoRotation;
      case 1:
        return _currentLogoState.companyNameRotation;
      case 2:
        return _currentLogoState.sloganRotation;
      case 3:
        return _currentLogoState.logo2Rotation ?? 0;
      case 4:
        return _currentLogoState.companyName2Rotation ?? 0;
      case 5:
        return _currentLogoState.slogan2Rotation ?? 0;
      default:
        return 0;
    }
  }

  void _updateElementSize(int id, double newSize) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) {
        final updatedTexts = List<CustomTextElement>.from(_currentLogoState.customTexts);
        updatedTexts[index] = updatedTexts[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(customTexts: updatedTexts);
      }
    } else if (id == 0) {
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

  void _updateElementRotation(int id, double newRotation) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) {
        final updatedTexts = List<CustomTextElement>.from(_currentLogoState.customTexts);
        updatedTexts[index] = updatedTexts[index].copyWith(rotation: newRotation);
        _currentLogoState = _currentLogoState.copyWith(customTexts: updatedTexts);
      }
    } else if (id == 0) {
      _currentLogoState = _currentLogoState.copyWith(logoRotation: newRotation);
    } else if (id == 1) {
      _currentLogoState = _currentLogoState.copyWith(companyNameRotation: newRotation);
    } else if (id == 2) {
      _currentLogoState = _currentLogoState.copyWith(sloganRotation: newRotation);
    } else if (id == 3) {
      _currentLogoState = _currentLogoState.copyWith(logo2Rotation: newRotation);
    } else if (id == 4) {
      _currentLogoState = _currentLogoState.copyWith(companyName2Rotation: newRotation);
    } else if (id == 5) {
      _currentLogoState = _currentLogoState.copyWith(slogan2Rotation: newRotation);
    }
  }

  // ✅ --- NEW: Layer Panel Handlers ---

  void _toggleLock(int id) {
    _saveState();
    setState(() {
      final newLockedSet = Set<int>.from(_currentLogoState.lockedElements);
      if (newLockedSet.contains(id)) {
        newLockedSet.remove(id);
      } else {
        newLockedSet.add(id);
      }
      _currentLogoState = _currentLogoState.copyWith(lockedElements: newLockedSet);
    });
  }

  void _toggleLockAll(bool shouldLock) {
    _saveState();
    setState(() {
      if (shouldLock) {
        // Lock all visible elements
        _currentLogoState = _currentLogoState.copyWith(lockedElements: _currentLogoState.visibleElementIds.toSet());
      } else {
        // Unlock all
        _currentLogoState = _currentLogoState.copyWith(lockedElements: {});
      }
    });
  }

  void _reorderLayer(int id, bool moveUp) {
    _saveState();
    setState(() {
      final order = List<int>.from(_currentLogoState.elementOrder);
      final currentIndex = order.indexOf(id);

      if (moveUp) {
        if (currentIndex > 0) {
          final temp = order[currentIndex - 1];
          order[currentIndex - 1] = order[currentIndex];
          order[currentIndex] = temp;
        }
      } else {
        if (currentIndex < order.length - 1) {
          final temp = order[currentIndex + 1];
          order[currentIndex + 1] = order[currentIndex];
          order[currentIndex] = temp;
        }
      }
      _currentLogoState = _currentLogoState.copyWith(elementOrder: order);
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Text('Logo Maker', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.undo, size: 40), onPressed: _undo, tooltip: 'Undo last change'),
          IconButton(icon: const Icon(Icons.save, size: 40), onPressed: () {}, tooltip: 'Save Logo'),
          IconButton(
            icon: Icon(isEditing ? Icons.edit_off : Icons.edit, size: 40),
            onPressed: () => setState(() {
              isEditing = !isEditing;
              selectedElement = null;
              _clearGridAlignment();
            }),
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
                child: Stack(
                  children: [
                    // Layer 1: The actual Logo Canvas
                    // --- THIS IS THE NEW, CORRECTED CODE ---
                    LogoCanvas(
                      canvasKey: _canvasKey,
                      logoState: _currentLogoState,
                      svgLogo: widget.svgLogo,
                      companyName: widget.companyName,
                      sloganName: widget.sloganName,
                      showGrid: _showGrid,
                      isEditingMode: isEditing,
                      selectedElementId: selectedElement,
                      highlightedHorizontalGridLineIndex: _highlightedHorizontalGridLineIndex,
                      highlightedVerticalGridLineIndex: _highlightedVerticalGridLineIndex,
                      isLayersRibbonExtended: _isLayersPanelVisible,
                      onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                      onToggleLayersRibbon: () => setState(() => _isLayersPanelVisible = !_isLayersPanelVisible),
                      onElementPanStart: _onPanStart,
                      onElementPanUpdate: _updateElementPosition,
                      onElementPanEnd: _onPanEnd,
                      onElementTap: _elementSelect,
                      onElementDelete: _deleteElement,
                      onElementSplit: _splitElement,
                      onElementRotateTap: _rotateElementByTap,
                      onElementRotatePanStart: _onRotatePanStart,
                      onElementRotatePanUpdate: _onRotatePanUpdate,
                      onElementRotatePanEnd: _onPanEnd,
                      onElementResizeTap: _resizeElementByTap,
                      onElementResizePanStart: _onResizePanStart,
                      onElementResizePanUpdate: _onResizePanUpdate,
                      onElementResizePanEnd: _onPanEnd,
                      isCheckerboardActive: isCheckerboardActive,
                      checkerboardOpacity: checkerboardOpacity,
                      isCheckerboardVisible: isCheckerboardVisible,
                      // ✅ UNCOMMENTED: Now the canvas knows what to draw and what is locked.
                      lockedElements: _currentLogoState.lockedElements,
                      elementOrder: _currentLogoState.elementOrder,
                    ),

                    // Layer 2: The Grid Toggle Ribbon (Top Right)
                    Positioned(
                      top: 20,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showGrid = !_showGrid;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              bottomLeft: Radius.circular(25.0),
                            ),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(-2, 2))],
                          ),
                          child: Icon(_showGrid ? Icons.grid_off : Icons.grid_on, color: Colors.white, size: 28),
                        ),
                      ),
                    ),

                    // Layer 3: The Layers Ribbon (Top Left)
                    Positioned(
                      top: 20,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLayersPanelVisible = !_isLayersPanelVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0),
                            ),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))],
                          ),
                          child: const Icon(Icons.layers, color: Colors.white, size: 28),
                        ),
                      ),
                    ),

                    // ✅ Layer 4: THE NEW LAYERS PANEL
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: 80,
                      left: _isLayersPanelVisible ? 10 : -300,
                      child: _LayersPanel(
                        logoState: _currentLogoState,
                        svgLogo: widget.svgLogo,
                        onClose: () => setState(() => _isLayersPanelVisible = false),
                        onToggleLock: _toggleLock,
                        onToggleLockAll: _toggleLockAll,
                        onReorder: _reorderLayer,
                      ),
                    )
                  ],
                ),
              ),
              Column(children: [Container(height: 300, color: Colors.grey.shade200)]),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: showDropUp ? Offset.zero : const Offset(0, 1),
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  DropUpPanel(
                    onClose: () => setState(() => showDropUp = false),
                    onToggleCheckerboard: (val) {
                      setState(() {
                        isCheckerboardActive = val;
                        isCheckerboardVisible = val;
                      });
                    },
                    onOpacityChanged: (val) => setState(() => checkerboardOpacity = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LogoBottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: _handleBottomNavTap,
        hasTapped: true,
      ),
    );
  }
}

// ✅ --- PASTE THIS CORRECTED WIDGET AT THE BOTTOM OF download_logo.dart ---

class _LayersPanel extends StatelessWidget {
  final LogoStateData logoState;
  final String svgLogo;
  final VoidCallback onClose;
  final ValueChanged<int> onToggleLock;
  final ValueChanged<bool> onToggleLockAll;
  final Function(int, bool) onReorder; // id, moveUp

  const _LayersPanel({
    required this.logoState,
    required this.svgLogo,
    required this.onClose,
    required this.onToggleLock,
    required this.onToggleLockAll,
    required this.onReorder,
  });

  Widget _buildLayerPreview(BuildContext context, int id) {
    Widget child;
    String text = '';

    switch (id) {
      case 0:
      case 3:
        child = SvgPicture.string(svgLogo, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn));
        text = 'Logo';
        break;
      case 1:
      case 4:
        child = Text(logoState.companyName ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
        text = 'Company';
        break;
      case 2:
      case 5:
        child = Text(logoState.sloganName ?? '', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic));
        text = 'Slogan';
        break;
      default:
        if (id >= 100) {
          final customText = logoState.customTexts[id - 100];
          child = Text(customText.text, style: const TextStyle(fontSize: 18));
          text = customText.text;
        } else {
          child = const Icon(Icons.error);
          text = 'Unknown';
        }
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.5),
          ),
          child: FittedBox(
            child: child,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderedVisibleIds = logoState.elementOrder.where((id) => logoState.visibleElementIds.contains(id)).toList();
    final areAllLocked = logoState.lockedElements.length == logoState.visibleElementIds.length && logoState.visibleElementIds.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // Allow the panel to take up to 70% of the screen height
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            // ❌  REMOVED: mainAxisSize: MainAxisSize.min
            // This was the source of the bug. Removing it allows the Column
            // to fill the parent's height, giving space to the Expanded widget.
            children: [
              // --- Header ---
              Row(
                children: [
                  Checkbox(
                    value: areAllLocked,
                    onChanged: (val) => onToggleLockAll(val ?? false),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  const Text('Lock All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
              const Divider(color: Colors.white54, height: 1),
              // --- Layer List ---
              if (orderedVisibleIds.isEmpty)
                const Expanded( // Use expanded to center the text vertically
                  child: Center(
                    child: Text('No layers found.', style: TextStyle(color: Colors.white70)),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: _buildLayerPreview(context, id),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(isLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
                              onPressed: () => onToggleLock(id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, color: Colors.white),
                              onPressed: index > 0 ? () => onReorder(id, true) : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, color: Colors.white),
                              onPressed: index < orderedVisibleIds.length - 1 ? () => onReorder(id, false) : null,
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