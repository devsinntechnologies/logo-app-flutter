// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/art_select_screen.dart';
import 'package:logo_app_flutter/screens/movement_panel.dart';
import 'package:no_screenshot/no_screenshot.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:math';

// Added for layer preview
import 'package:logo_app_flutter/components/logo_bottom_nav_bar.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/screens/color_screen.dart';
import 'package:logo_app_flutter/screens/layer_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

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
  final _noScreenshot = NoScreenshot.instance;

  String selectedShapeName = ""; // 👈 Add this
  // --- State Management ---
  late LogoStateData _currentLogoState;
  //  int? _selectedElementId;
   int? selectedElementId;

  final List<LogoStateData> _undoStack = [];
  final int _maxUndoHistory = 10;
  List<LogoElement> customTextElements = [];
  List<LogoElement> customImageElements = [];
  LogoElement? _getElementById(int id) {
  return customTextElements.firstWhereOrNull((e) => e.id == id);
}



  final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.black,
  ];

  // --- UI Toggles ---
  bool _showGrid = false;
  bool _isLayersPanelVisible = false;
  bool showDropUp = false;
  bool showEffectPanel = false;

  bool showPaletteBar = false;
  int selectedPaletteIndex = 0;

  // --- Movement Panel Toggle ---
  bool isMovementPanelVisible = true;

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

  final List<List<Color>> paletteList = [
    [Colors.white, Colors.grey, Colors.white],
    [Colors.red, Colors.orange, Colors.yellow],
    [Colors.green, Colors.teal, Colors.lightGreen],
    [Colors.blue, Colors.indigo, Colors.cyan],
    [Colors.purple, Colors.deepPurple, Colors.pink],
    [Colors.brown, Colors.grey, Colors.black],
    [Colors.deepOrange, Colors.amber, Colors.lime],
    [Colors.blueGrey, Colors.white, Colors.grey.shade300],
  ];

  int? _selectedBottomOption; // null = none selected


  // --- Drag State ---
  Offset? _initialDragPoint;
  double? _initialElementValue;

  Future<void> saveCanvasToGallery(GlobalKey canvasKey) async {
    // ✅ Step 1: Ask Permission for Android 13+ and older
    final isGranted = await _requestGalleryPermission();
    if (!isGranted) {
      print("❌ Storage permission not granted");
      return;
    }

    try {
      // ✅ Step 2: Capture image from widget
      RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // ✅ Step 3: Save to temp directory
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).writeAsBytes(pngBytes);

      // ✅ Step 4: Save to Gallery using gallery_saver_plus
      final result = await GallerySaver.saveImage(
        file.path,
        albumName: "LogoMaker",
      );
      print("✅ Image saved to gallery: $result");
    } catch (e) {
      print("❌ Failed to save canvas: $e");
    }
  }

  /// 🔐 Handles permission for all Android versions
  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      final photos = await Permission.photos.request(); // Android 13+

      return storage.isGranted || photos.isGranted;
    }
    return true; // iOS will handle internally
  }

  void _showSaveConfirmationDialog(BuildContext context, GlobalKey canvasKey) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Save Logo'),
          content: const Text(
            'Do you want to save this logo to your gallery?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                saveCanvasToGallery(canvasKey);
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logo saved to gallery!')),
                );
              },
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedElement = selectedElementId;
    _noScreenshot.screenshotOff();
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
      customImages: [],
      lockedElements: {},
      elementOrder: [0, 1, 2],
    );

    _saveState();
  }

  @override
  void dispose() {
    _noScreenshot.screenshotOn();
    super.dispose();
  }



  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: ScreenshotController(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          title: const Text(
            'Logo Maker',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo, size: 40),
              onPressed: _undo,
              tooltip: 'Undo last change',
            ),
            IconButton(
              icon: const Icon(Icons.save, size: 40),
              onPressed: () => _showSaveConfirmationDialog(context, _canvasKey),
              tooltip: 'Save Logo',
            ),
            IconButton(
              icon: Icon(isEditing ? Icons.edit_off : Icons.edit, size: 40),
              onPressed:
                  () => setState(() {
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
            SizedBox(height: 700, width: double.infinity),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        key: _canvasKey,
                        child: LogoCanvas(
                          selectedShapeName: selectedShapeName,
                          // key: _canvasKey,
                          logoState: _currentLogoState,
                          svgLogo: widget.svgLogo,
                          companyName: widget.companyName,
                          sloganName: widget.sloganName,
                          showGrid: _showGrid,
                          isEditingMode: true,
                          selectedElementId: selectedElement,
                          highlightedHorizontalGridLineIndex:
                              _highlightedHorizontalGridLineIndex,
                          highlightedVerticalGridLineIndex:
                              _highlightedVerticalGridLineIndex,
                          isLayersRibbonExtended: _isLayersPanelVisible,
                          onToggleGrid:
                              () => setState(() => _showGrid = !_showGrid),
                          onToggleLayersRibbon:
                              () => setState(
                                () =>
                                    _isLayersPanelVisible =
                                        !_isLayersPanelVisible,
                              ),
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
                          isCheckerboardActive: true,
                          checkerboardOpacity: checkerboardOpacity,
                          isCheckerboardVisible: isCheckerboardVisible,
                          // ✅ UNCOMMENTED: Now the canvas knows what to draw and what is locked.
                          lockedElements: _currentLogoState.lockedElements,
                          elementOrder: _currentLogoState.elementOrder,
                        ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                              _isLayersPanelVisible = !_isLayersPanelVisible;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                            child: const Icon(
                              Icons.layers,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 80,
                        left: _isLayersPanelVisible ? 10 : -300,
                        child: LayersPanel(
                          logoState: _currentLogoState,
                          svgLogo: widget.svgLogo,
                          onClose:
                              () =>
                                  setState(() => _isLayersPanelVisible = false),
                          onToggleLock: _toggleLock,
                          onToggleLockAll: _toggleLockAll,
                          onReorder: _reorderLayer,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Container(height: 300, color: Colors.grey.shade200),
                  ],
                ),
              ],
            ),
           
if (selectedElement != null && isMovementPanelVisible)
  Positioned(
    bottom: -100,
    
    child: MovementPanel(
      onDirectionPressed: (String direction) {
        const double moveAmount = 5.0;
        Offset delta;

        switch (direction) {
          case 'up':
            delta = const Offset(0, -moveAmount);
            break;
          case 'down':
            delta = const Offset(0, moveAmount);
            break;
          case 'left':
            delta = const Offset(-moveAmount, 0);
            break;
          case 'right':
            delta = const Offset(moveAmount, 0);
            break;
          default:
            delta = Offset.zero;
        }
setState(() {
  
});
        _updateElementPosition(selectedElement!, delta);
      },
      onDuplicatePressed: _duplicateSelectedElement,
   
      selectedElementId: selectedElement,
      isVisible: true,
    ),
  ),


            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset:
                    (showDropUp || showPaletteBar || showEffectPanel)
                        ? Offset.zero
                        : const Offset(0, 1),
                curve: Curves.easeInOut,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showDropUp)
                            DropUpPanel(
                              onClose: () => setState(() => showDropUp = false),
                              onToggleCheckerboard: (val) {
                                setState(() {
                                  isCheckerboardActive = val;
                                  isCheckerboardVisible = val;
                                });
                              },
                              onOpacityChanged:
                                  (val) =>
                                      setState(() => checkerboardOpacity = val),
                              onShapeSelected: (shapeName) {
                                setState(() {
                                  selectedShapeName = shapeName;
                                });
                              },
                            ),
                          if (showPaletteBar)
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: paletteList.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final colors = paletteList[index];
                                  final isSelected =
                                      selectedPaletteIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPaletteIndex = index;
                                        Provider.of<SelectedColorProvider>(
                                          context,
                                          listen: false,
                                        ).resetRotation();
                                      });
                                    },
                                    child: Container(
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.orange
                                                  : Colors.grey.shade400,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Column(
                                              children:
                                                  colors
                                                      .map(
                                                        (color) => Container(
                                                          height: 20,
                                                          width:
                                                              double.infinity,
                                                          color: color,
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),

                                          if (isSelected)
                                            Positioned(
                                              top: 30,
                                              right: 15,
                                              child: InkWell(
                                                onTap: () {
                                                  Provider.of<
                                                    SelectedColorProvider
                                                  >(
                                                    context,
                                                    listen: false,
                                                  ).setColorsRotated(colors);
                                                },
                                                child: const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Colors.white,
                                                  child: Icon(
                                                    Icons.refresh,
                                                    size: 14,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          if (showEffectPanel)
                            Positioned(
                              bottom: 40,
                              left: 0,
                              right: 0,

                              child: _buildEffectPanel(),
                            ),
                        ],
                      ),
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildEffectPanel() {
    return Container(
      // padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          const SizedBox(height: 10),

          // Color list below it
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colorList.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Provider.of<SelectedColorProvider>(
                        context,
                        listen: false,
                      ).resetColor();
                      // setState(() => showEffectPanel = false);
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  );
                }

                final color = colorList[index - 1];
                return GestureDetector(
                  onTap: () {
                    Provider.of<SelectedColorProvider>(
                      context,
                      listen: false,
                    ).setColor(color);
                   
                  },
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Undo successful!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to undo!')));
    }
  }

  void _handleBottomNavTap(int index) async {
    // 👇 Index update kro
    setState(() {
      selectedIndex = index;
    });

    // 👇 DropUp aur Palette toggle ek frame delay k sath karo
    Future.delayed(Duration.zero, () {
      setState(() {
        showDropUp = index == 0;
        showPaletteBar = index == 4;
        showEffectPanel = index == 3;
      });
    });

    // ✅ Navigation & other logic
    if (index == 2) {
      final result = await Navigator.of(
        context,
      ).push<String>(_createSlideRoute());
      if (result != null && result.isNotEmpty) {
        _saveState();
        setState(() {
          final newTextElement = CustomTextElement(
            text: result,
            position: _getCanvasCenter() ?? const Offset(150, 150),
            size: 22,
            rotation: 0,
          );
          final updatedCustomTexts = List<CustomTextElement>.from(
            _currentLogoState.customTexts,
          )..add(newTextElement);
          final newElementId = 100 + _currentLogoState.customTexts.length;
          final updatedElementOrder = List<int>.from(
            _currentLogoState.elementOrder,
          )..add(newElementId);
          _currentLogoState = _currentLogoState.copyWith(
            customTexts: updatedCustomTexts,
            elementOrder: updatedElementOrder,
          );
        });
      }
    }

    if (index == 1) {
      final selectedImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ArtSelectScreen(
                images: [
                  'assets/logo_images/logo_1.jpg',
                  'assets/logo_images/logo_2.png',
                  'assets/logo_images/logo_3.jpg',
                  'assets/logo_images/logo_4.png',
                  'assets/logo_images/logo_5.jpg',
                  'assets/logo_images/logo_6.jpg',
                  'assets/logo_images/logo_7.png',
                  'assets/logo_images/logo_8.jpg',
                  'assets/logo_images/logo_9.png',
                  'assets/logo_images/logo_10.jpg',
                ],
              ),
        ),
      );
      if (selectedImagePath != null && mounted) {
        _addImageToCanvas(selectedImagePath);
      }
    }


    if (index == 5) {
      final picker = ImagePicker();
      final selectedSource = await showDialog<ImageSource>(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Image Source'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text('Camera'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text('Gallery'),
                ),
              ],
            ),
      );
      if (selectedSource != null) {
        final pickedFile = await picker.pickImage(source: selectedSource);
        if (pickedFile != null) {
          final imageIndex = _currentLogoState.customImages.length;
          final newImage = CustomImageElement(
            path: pickedFile.path,
            position: _getCanvasCenter() ?? const Offset(100, 100),
            size: 100,
            rotation: 0,
          );
          _saveState();
          setState(() {
            _currentLogoState = _currentLogoState.copyWith(
              customImages: [..._currentLogoState.customImages, newImage],
              elementOrder: [
                ..._currentLogoState.elementOrder,
                200 + imageIndex,
              ],
            );
          });
        }
      }
    }
  }

  Route<String> _createSlideRoute() {
    return PageRouteBuilder<String>(
      pageBuilder:
          (context, animation, secondaryAnimation) => const TextScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route<String> navRoute() {
    return PageRouteBuilder<String>(
      pageBuilder:
          (context, animation, secondaryAnimation) => const TextScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  void _elementSelect(int id) {
  setState(() {
    selectedElement = id;
    _selectedBottomOption = null; // ✅ close bottom options
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
      newState = newState.copyWith(
        elementOrder: newOrder,
        lockedElements: newLocked,
      );

      if (id >= 100) {
        final index = id - 100;
        if (index < _currentLogoState.customTexts.length) {
          final updatedCustomTexts = List<CustomTextElement>.from(
            _currentLogoState.customTexts,
          )..removeAt(index);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _addImageToCanvas(String imagePath) {
    final index = _currentLogoState.customImages.length;

    final newImage = CustomImageElement(
      path: imagePath,
      position: _getCanvasCenter() ?? const Offset(100, 100),
      rotation: 0,
      size: 120,
    );

    setState(() {
      _currentLogoState = _currentLogoState.copyWith(
        customImages: [..._currentLogoState.customImages, newImage],
        elementOrder: [..._currentLogoState.elementOrder, 200 + index],
      );
    });
  }


void _duplicateSelectedElement() {
  if (selectedElementId == null) return;

  final original = _getElementById(selectedElementId!);
  if (original == null) return;

  final newId = DateTime.now().millisecondsSinceEpoch;

  final duplicated = original.copyWith(
    id: newId,
    position: original.position + const Offset(20, 20), // thoda move
  );

  setState(() {
    if (selectedElementId! >= 100 && selectedElementId! < 200) {
      // Duplicate custom text element
      final updatedCustomTexts = List<CustomTextElement>.from(_currentLogoState.customTexts)..add(duplicated as CustomTextElement);
      final updatedElementOrder = List<int>.from(_currentLogoState.elementOrder)..add(newId);
      _currentLogoState = _currentLogoState.copyWith(
        customTexts: updatedCustomTexts,
        elementOrder: updatedElementOrder,
      );
    } else if (selectedElementId! >= 200) {
      // Duplicate custom image element
      final updatedCustomImages = List<CustomImageElement>.from(_currentLogoState.customImages)..add(duplicated as CustomImageElement);
      final updatedElementOrder = List<int>.from(_currentLogoState.elementOrder)..add(newId);
      _currentLogoState = _currentLogoState.copyWith(
        customImages: updatedCustomImages,
        elementOrder: updatedElementOrder,
      );
    }
    selectedElementId = newId;
    selectedElement = newId;
  });
}




  bool _isElementLocked(int id) {
    final isLocked = _currentLogoState.lockedElements.contains(id);
    if (isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Element is locked.'),
            duration: Duration(seconds: 1),
          ),
        );
    }
    return isLocked;
  }

  void _splitElement(int id) {
    if (_isElementLocked(id)) return;
    if (id >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot split custom text elements.')),
      );
      return;
    }
    _saveState();
    setState(() {
      String message = 'Element split!';
      Offset offset = const Offset(20, 20);
      if (id == 0) {
        _currentLogoState = _currentLogoState.copyWith(
          logo2Position: _currentLogoState.logoPosition + offset,
          logo2Size: _currentLogoState.logoSize,
          logo2Rotation: _currentLogoState.logoRotation,
          isLogo2Visible: true,
        );
      } else if (id == 1) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Position: _currentLogoState.companyNamePosition + offset,
          companyName2Size: _currentLogoState.companyNameSize,
          companyName2Rotation: _currentLogoState.companyNameRotation,
          isCompanyName2Visible: true,
        );
      } else if (id == 2) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Position: _currentLogoState.sloganPosition + offset,
          slogan2Size: _currentLogoState.sloganSize,
          slogan2Rotation: _currentLogoState.sloganRotation,
          isSlogan2Visible: true,
        );
      } else {
        message = 'Cannot split this element.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
              ((_currentLogoState.logo2Rotation ?? 0) + rotationStep) % 360,
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Rotation:
              ((_currentLogoState.companyName2Rotation ?? 0) + rotationStep) %
              360,
        );
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Rotation:
              ((_currentLogoState.slogan2Rotation ?? 0) + rotationStep) % 360,
        );
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
          logo2Size: max(
            minSize,
            (_currentLogoState.logo2Size ?? minSize) + resizeStep,
          ),
        );
      } else if (id == 4) {
        _currentLogoState = _currentLogoState.copyWith(
          companyName2Size: max(
            minSize,
            (_currentLogoState.companyName2Size ?? minSize) + resizeStep,
          ),
        );
      } else if (id == 5) {
        _currentLogoState = _currentLogoState.copyWith(
          slogan2Size: max(
            minSize,
            (_currentLogoState.slogan2Size ?? minSize) + resizeStep,
          ),
        );
      }
    });
  }

  void _updateElementPosition(int id, Offset delta) {
    if (_isElementLocked(id)) return;

    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final canvasSize = renderBox.size;
    final originalPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);

    if (elementSize == Size.zero) return;

    final newPosition = _limitOffset(
      originalPosition,
      delta,
      elementSize,
      canvasSize,
    );

    setState(() {
      if (id >= 100 && id < 200) {
        // Custom Text Elements
        final index = id - 100;
        if (index >= 0 && index < _currentLogoState.customTexts.length) {
          final updatedTexts = List<CustomTextElement>.from(
            _currentLogoState.customTexts,
          );
          updatedTexts[index] = updatedTexts[index].copyWith(
            position: newPosition,
          );
          _currentLogoState = _currentLogoState.copyWith(
            customTexts: updatedTexts,
          );
        }
      } else if (id == 0) {
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
      } else if (id >= 200 && id < 300) {
        final index = id - 200;
        final images = _currentLogoState.customImages;

        // ✅ Ye condition crash se bachayegi
        if (index >= 0 && index < images.length) {
          final updatedImages = List<CustomImageElement>.from(images);
          updatedImages[index] = updatedImages[index].copyWith(
            position: newPosition,
          );
          _currentLogoState = _currentLogoState.copyWith(
            customImages: updatedImages,
          );
        } else {
          debugPrint(
            '❌ Invalid image index: $index, List length: ${images.length}',
          );
        }
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
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset canvasOffset = renderBox.localToGlobal(Offset.zero);
    final elementPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);
    final elementCenterGlobal =
        canvasOffset +
        elementPosition +
        Offset(elementSize.width / 2, elementSize.height / 2);
    final initialDistance = (_initialDragPoint! - elementCenterGlobal).distance;
    final currentDistance =
        (details.globalPosition - elementCenterGlobal).distance;
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
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset canvasOffset = renderBox.localToGlobal(Offset.zero);
    final elementPosition = _getElementPosition(id);
    final elementSize = _getElementRenderedSize(id);
    final elementCenterGlobal =
        canvasOffset +
        elementPosition +
        Offset(elementSize.width / 2, elementSize.height / 2);
    final v1 = _initialDragPoint! - elementCenterGlobal;
    final v2 = details.globalPosition - elementCenterGlobal;
    double angleDelta = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx);
    double newRotation = (_initialElementValue! + (angleDelta * 180 / pi));
    setState(() => _updateElementRotation(id, newRotation));
  }

  // void _onPanStart(int id, DragStartDetails details) {
  //   if (_isElementLocked(id)) return;
  //   _saveState();
  // }
  void _onPanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;

    setState(() {
      selectedElement = id; // ✅ yeh line add karo
    });

    _saveState();
  }

  void _onPanEnd(int id) {
    _initialDragPoint = null;
    _initialElementValue = null;
    _clearGridAlignment();
  }

  // --- Getters & Helpers ---

  Offset? _getCanvasCenter() {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      return Offset(size.width / 2, size.height / 2);
    }
    return null;
  }

  Offset _limitOffset(
    Offset original,
    Offset delta,
    Size elementSize,
    Size canvasSize,
  ) {
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

  void _clearGridAlignment() {
    if (_highlightedHorizontalGridLineIndex != null ||
        _highlightedVerticalGridLineIndex != null) {
      setState(() {
        _highlightedHorizontalGridLineIndex = null;
        _highlightedVerticalGridLineIndex = null;
      });
    }
  }

  void _checkGridAlignment(
    Offset elementPosition,
    Size elementSize,
    Size canvasSize,
  ) {
    // Remove this line if you want alignment to work even when grid icon is off
    if (!_showGrid) return;

    int? newH, newV;
    const tolerance = 10.0;
    final centerX = elementPosition.dx + elementSize.width / 2;
    final centerY = elementPosition.dy + elementSize.height / 2;

    for (int i = 0; i <= 4; i++) {
      if ((centerX - (i * canvasSize.width / 4)).abs() < tolerance) newV = i;
      if ((centerY - (i * canvasSize.height / 4)).abs() < tolerance) newH = i;
    }

    if (newH != _highlightedHorizontalGridLineIndex ||
        newV != _highlightedVerticalGridLineIndex) {
      setState(() {
        _highlightedHorizontalGridLineIndex = newH;
        _highlightedVerticalGridLineIndex = newV;
      });
    }
  }

  void _addCustomImage(String imagePath) {
    final index = _currentLogoState.customImages.length;

    final imageElement = CustomImageElement(
      path: imagePath,
      position: const Offset(100, 100),
      rotation: 0,
      size: 100,
    );

    setState(() {
      _currentLogoState = _currentLogoState.copyWith(
        customImages: [..._currentLogoState.customImages, imageElement],
        elementOrder: [..._currentLogoState.elementOrder, 200 + index], // ✅
      );
    });
  }

  Offset _getElementPosition(int id) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length)
        return _currentLogoState.customTexts[index].position;
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
      if (index < _currentLogoState.customTexts.length)
        return _currentLogoState.customTexts[index].size;
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
        return TextSizeUtil.getTextSize(
          text,
          TextStyle(
            fontSize: sizeValue,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    }
    switch (id) {
      case 0:
      case 3:
        return Size(sizeValue, sizeValue);
      case 1:
      case 4:
        return TextSizeUtil.getTextSize(
          widget.companyName,
          TextStyle(
            fontSize: sizeValue,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      case 2:
      case 5:
        return TextSizeUtil.getTextSize(
          widget.sloganName,
          TextStyle(
            fontSize: sizeValue,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
        );
      default:
        return Size.zero;
    }
  }

  double _getElementRotation(int id) {
    if (id >= 100) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length)
        return _currentLogoState.customTexts[index].rotation;
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
        final updatedTexts = List<CustomTextElement>.from(
          _currentLogoState.customTexts,
        );
        updatedTexts[index] = updatedTexts[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(
          customTexts: updatedTexts,
        );
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
        final updatedTexts = List<CustomTextElement>.from(
          _currentLogoState.customTexts,
        );
        updatedTexts[index] = updatedTexts[index].copyWith(
          rotation: newRotation,
        );
        _currentLogoState = _currentLogoState.copyWith(
          customTexts: updatedTexts,
        );
      }
    } else if (id == 0) {
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
      _currentLogoState = _currentLogoState.copyWith(
        lockedElements: newLockedSet,
      );
    });
  }

  void _toggleLockAll(bool shouldLock) {
    _saveState();
    setState(() {
      if (shouldLock) {
        // Lock all visible elements
        _currentLogoState = _currentLogoState.copyWith(
          lockedElements: _currentLogoState.visibleElementIds.toSet(),
        );
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
}

// ✅-- PASTE THIS CORRECTED WIDGET AT THE BOTTOM OF download_logo.dart ---
