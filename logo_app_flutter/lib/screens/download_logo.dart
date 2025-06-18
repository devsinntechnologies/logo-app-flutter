import 'package:flutter/material.dart';

import 'dart:math';

import 'package:logo_app_flutter/components/logo_bottom_nav_bar.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';

import '../components/logo_canvas.dart';
import '../utils/text_size_util.dart';

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
  late LogoStateData _currentLogoState;

  final List<LogoStateData> _undoStack = [];
  final int _maxUndoHistory = 10;

  bool _showGrid = false;
  bool _isLayersRibbonExtended = false;

  bool isEditing = false;
  int? id;
  int? selectedElement;
  int selectedIndex = 0;

  int? _highlightedHorizontalGridLineIndex;
  int? _highlightedVerticalGridLineIndex;
  final GlobalKey _canvasKey = GlobalKey();
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
    _saveState();
  }

  
  Size _getElementRenderedSize(int elementId) {
    switch (elementId) {
      case 0:
        return Size(_currentLogoState.logoSize, _currentLogoState.logoSize);
      case 1:
        return TextSizeUtil.getTextSize(
          
          widget.companyName,
          TextStyle(
            fontSize: _currentLogoState.companyNameSize,
            fontWeight: FontWeight.bold,
          ),
        );
      case 2:
        return TextSizeUtil.getTextSize(
          
          widget.sloganName,
          TextStyle(
            fontSize: _currentLogoState.sloganSize,
            fontStyle: FontStyle.italic,
          ),
        );
      case 3:
        return Size(
          _currentLogoState.logo2Size ?? 0,
          _currentLogoState.logo2Size ?? 0,
        );
      case 4:
        return TextSizeUtil.getTextSize(
          
          widget.companyName,
          TextStyle(
            fontSize: _currentLogoState.companyName2Size ?? 0,
            fontWeight: FontWeight.bold,
          ),
        );
      case 5:
        return TextSizeUtil.getTextSize(
          
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
        id = null;
        _clearGridAlignment();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Undo successful!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to undo!')));
    }
  }

  
  void _onPanStart(int id, DragStartDetails details) {
    _saveState();
    
  }

  
  void _onPanUpdate(int id, Offset delta) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Size? canvasSize = renderBox?.size;

    if (canvasSize == null) return; 

    setState(() {
      Offset newPosition = _limitOffset(
        _getCurrentElementPosition(id),
        delta,
        _getElementRenderedSize(id),
      ); 

      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(
          logoPosition: newPosition,
        );
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(
          companyNamePosition: newPosition,
        );
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(
          sloganPosition: newPosition,
        );
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(
          logo2Position: newPosition,
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Position: newPosition,
        );
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Position: newPosition,
        );
      }
      _checkGridAlignment(newPosition, _getElementRenderedSize(id));
    });
  }

  
  void _onPanEnd(int id) {
    
    _clearGridAlignment();
    
  }

  Offset _limitOffset(Offset original, Offset delta, Size elementSize) {
    
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Size? canvasSize = renderBox?.size; 
    if (canvasSize == null)
      return original + delta; 

    final newOffset = original + delta;
    final clampedDx = newOffset.dx.clamp(
      0.0,
      canvasSize.width - elementSize.width,
    );
    final clampedDy = newOffset.dy.clamp(
      0.0,
      canvasSize.height - elementSize.height,
    );
    return Offset(clampedDx, clampedDy);
  }

  void _deleteElement(int id) {
    _saveState();
    setState(() {
      String message = 'Element deleted!';
      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(isLogoVisible: false);
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(
          isCompanyNameVisible: false,
        );
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(isSloganVisible: false);
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(
          isLogo2Visible: false,
          logo2Position: null,
          logo2Size: null,
          logo2Rotation: null,
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          
          isCompanyName2Visible: false,
          companyName2Position: null,
          companyName2Size: null,
          companyName2Rotation: null,
        );
      } else if (id == 5) {
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _splitElement(int id) {
    _saveState();
    setState(() {
      String message = 'Element split!';
      Offset offset = const Offset(20, 20);

      if (id == 0) {
        if (_currentLogoState.isLogo2Visible == true) {
          message =
              'Logo duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            logo2Position: _currentLogoState.logoPosition + offset,
            logo2Size: _currentLogoState.logoSize,
            logo2Rotation: _currentLogoState.logoRotation,
            isLogo2Visible: true,
          );
        }
      } else if (id == 1) {
        if (_currentLogoState.isCompanyName2Visible == true) {
          message =
              'Company Name duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            companyName2Position:
                _currentLogoState.companyNamePosition + offset,
            companyName2Size: _currentLogoState.companyNameSize,
            companyName2Rotation: _currentLogoState.companyNameRotation,
            isCompanyName2Visible: true,
          );
        }
      } else if (id == 2) {
        if (_currentLogoState.isSlogan2Visible == true) {
          message =
              'Slogan duplicate already exists or cannot be duplicated further.';
        } else {
          _currentLogoState = _currentLogoState.copyWith(
            slogan2Position: _currentLogoState.sloganPosition + offset,
            slogan2Size: _currentLogoState.sloganSize,
            slogan2Rotation: _currentLogoState.sloganRotation,
            isSlogan2Visible: true,
          );
        }
      } else if (id >= 3 && id <= 5) {
        message = 'Cannot split a duplicate element further.';
      } else {
        message = 'No element selected for splitting.';
      }
      selectedElement = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _rotateElementByTap(int id) {
    _saveState();
    setState(() {
      const double rotationStep = 45;
      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(
          logoRotation: (_currentLogoState.logoRotation + rotationStep) % 360,
        );
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(
          companyNameRotation:
              (_currentLogoState.companyNameRotation + rotationStep) % 360,
        );
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(
          sloganRotation:
              (_currentLogoState.sloganRotation + rotationStep) % 360,
        );
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(
          logo2Rotation:
              (_currentLogoState.logo2Rotation! + rotationStep) % 360,
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Rotation:
              (_currentLogoState.companyName2Rotation! + rotationStep) % 360,
        );
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Rotation:
              (_currentLogoState.slogan2Rotation! + rotationStep) % 360,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No element selected to rotate.')),
        );
      }
    });
  }

  void _resizeElementByTap(int id) {
    _saveState();
    setState(() {
      const double resizeStep = 20.0;
      const double minSize = 10.0;
      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(
          logoSize: max(minSize, _currentLogoState.logoSize + resizeStep),
        );
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(
          companyNameSize: max(
            minSize,
            _currentLogoState.companyNameSize + resizeStep,
          ),
        );
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(
          sloganSize: max(minSize, _currentLogoState.sloganSize + resizeStep),
        );
      } else if (id == 3) {
        _currentLogoState = _currentLogoState.copyWith(
          logo2Size: max(minSize, _currentLogoState.logo2Size! + resizeStep),
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Size: max(
            minSize,
            _currentLogoState.companyName2Size! + resizeStep,
          ),
        );
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Size: max(
            minSize,
            _currentLogoState.slogan2Size! + resizeStep,
          ),
        );
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

  void _checkGridAlignment(Offset elementPosition, Size elementSize) {
    
    int? newHighlightedHorizontal;
    int? newHighlightedVertical;

    if (!_showGrid) {
      _clearGridAlignment();
      return;
    }

    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Size? canvasSize = renderBox?.size; 
    if (canvasSize == null) return; 

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

  void _onResizePanStart(int id, DragStartDetails details) {
    _saveState();
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getCurrentElementSize(id);
  }
  void _onResizePanUpdate(int id, DragUpdateDetails details) {
    if (_initialDragPoint == null || _initialElementValue == null) return;
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? canvasOffset = renderBox?.localToGlobal(Offset.zero);
    final Size? canvasSize = renderBox?.size; 

    if (canvasOffset == null || canvasSize == null) return; 

    final Offset elementCurrentPosition = _getCurrentElementPosition(id);
    final Size elementCurrentSize = _getElementRenderedSize(id);
    final Offset elementCenterGlobal = Offset(
      canvasOffset.dx +
          elementCurrentPosition.dx +
          elementCurrentSize.width / 2,
      canvasOffset.dy +
          elementCurrentPosition.dy +
          elementCurrentSize.height / 2,
    );
    final double initialDistance =
        (_initialDragPoint! - elementCenterGlobal).distance;
    final double currentDistance =
        (details.globalPosition - elementCenterGlobal).distance;
    final double scaleFactor = currentDistance / initialDistance;
    const double sensitivity = 0.5;
    double newSize = _initialElementValue! * scaleFactor;
    newSize =
        _initialElementValue! + (newSize - _initialElementValue!) * sensitivity;
    const double minSize = 10.0;
    const double maxSize = 300.0;
    newSize = newSize.clamp(minSize, maxSize);

    setState(() {
      _updateElementSize(id, newSize);
      _checkGridAlignment(
        _getCurrentElementPosition(id),
        _getElementRenderedSize(id),
      ); 
    });
  }

  void _onResizePanEnd(int id) {
    _initialDragPoint = null;
    _initialElementValue = null;
    _clearGridAlignment();
  }

  void _onRotatePanStart(int id, DragStartDetails details) {
    _saveState();
    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getCurrentElementRotation(id);
  }

  
  

  
  void _onRotatePanUpdate(int id, DragUpdateDetails details) {
    
    if (_initialDragPoint == null || _initialElementValue == null) return;
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? canvasOffset = renderBox?.localToGlobal(Offset.zero);

    if (canvasOffset == null) return; 

    final Offset elementCurrentPosition = _getCurrentElementPosition(id);
    final Size elementCurrentSize = _getElementRenderedSize(id);
    final Offset elementCenterGlobal = Offset(
      canvasOffset.dx +
          elementCurrentPosition.dx +
          elementCurrentSize.width / 2,
      canvasOffset.dy +
          elementCurrentPosition.dy +
          elementCurrentSize.height / 2,
    );
    final Offset v1 = _initialDragPoint! - elementCenterGlobal;
    final Offset v2 = details.globalPosition - elementCenterGlobal;
    double angle1 = atan2(v1.dy, v1.dx);
    double angle2 = atan2(v2.dy, v2.dx);
    double angleDeltaRadians = angle2 - angle1;
    double angleDeltaDegrees = angleDeltaRadians * 180 / pi;
    double newRotation = (_initialElementValue! + angleDeltaDegrees) % 360;
    if (newRotation < 0) {
      newRotation += 360;
    }

    setState(() {
      _updateElementRotation(id, newRotation);
    });
  }

  void _onRotatePanEnd(int id) {
    _initialDragPoint = null;
    _initialElementValue = null;
  }

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

  void _updateElementRotation(int id, double newRotation) {
    if (id == 0) {
      _currentLogoState = _currentLogoState.copyWith(logoRotation: newRotation);
    } else if (id == 1) {
      _currentLogoState = _currentLogoState.copyWith(
        companyNameRotation: newRotation,
      );
    } else if (id == 2) {
      _currentLogoState = _currentLogoState.copyWith(
        sloganRotation: newRotation,
      );
    } else if (id == 3) {
      _currentLogoState = _currentLogoState.copyWith(
        logo2Rotation: newRotation,
      );
    } else if (id == 4) {
      _currentLogoState = _currentLogoState.copyWith(
        companyName2Rotation: newRotation,
      );
    } else if (id == 5) {
      _currentLogoState = _currentLogoState.copyWith(
        slogan2Rotation: newRotation,
      );
    }
  }

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
                id = null;
                _clearGridAlignment();
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
                child: LogoCanvas(
                  canvasKey: _canvasKey,
                  logoState: _currentLogoState,
                  svgLogo: widget.svgLogo,
                  companyName: widget.companyName,
                  sloganName: widget.sloganName,
                  showGrid: _showGrid,
                  isEditingMode: isEditing,
                  selectedElementId: selectedElement,
                  highlightedHorizontalGridLineIndex:
                      _highlightedHorizontalGridLineIndex,
                  highlightedVerticalGridLineIndex:
                      _highlightedVerticalGridLineIndex,
                  isLayersRibbonExtended: _isLayersRibbonExtended,
                  onToggleGrid: () {
                    setState(() {
                      _showGrid = !_showGrid;
                      if (!_showGrid) {
                        _clearGridAlignment();
                      }
                    });
                  },
                  onToggleLayersRibbon: () {
                    setState(() {
                      _isLayersRibbonExtended = !_isLayersRibbonExtended;
                    });
                  },
                  onElementTap: (id) {
                    setState(() {
                      selectedElement = id;
                      _clearGridAlignment();
                    });
                  },
                  
                  onElementPanStart: _onPanStart,
                  onElementPanUpdate: _onPanUpdate,
                  onElementPanEnd: _onPanEnd,
                  onElementDelete: _deleteElement,
                  onElementSplit: _splitElement,
                  onElementRotateTap: _rotateElementByTap,
                  onElementRotatePanStart: _onRotatePanStart,
                  onElementRotatePanUpdate: _onRotatePanUpdate,
                  onElementRotatePanEnd: _onRotatePanEnd,
                  onElementResizeTap: _resizeElementByTap,
                  onElementResizePanStart: _onResizePanStart,
                  onElementResizePanUpdate: _onResizePanUpdate,
                  onElementResizePanEnd: _onResizePanEnd,
                ),
              ),
              Column(
                children: [Container(height: 300, color: Colors.grey.shade200)],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: LogoBottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            isEditing = false;
            selectedIndex = index;
            selectedElement =
                null; 
          });
        }, hasTapped: true, // Assuming this is a flag to indicate if the user has tapped on the nav bar
      ),
    );
  }
}

