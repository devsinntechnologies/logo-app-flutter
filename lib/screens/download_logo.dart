// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:logo_app_flutter/fragments/theme_toggle_widget.dart';
import 'package:logo_app_flutter/provider/interestitial_ad.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:logo_app_flutter/screens/art_select_screen.dart';
import 'package:logo_app_flutter/screens/movement_panel.dart';
// import 'package:no_screenshot/no_screenshot.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:math';

// Added for layer preview
import 'package:logo_app_flutter/components/logo_bottom_nav_bar.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/screens/layer_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:screenshot/screenshot.dart';

import '../components/logoBottomNavbarItems/drop_up_panel.dart';
import '../components/logo_canvas.dart';
import '../utils/text_size_util.dart';
import 'text_screen.dart';
import 'package:logo_app_flutter/provider/smart_interstitial_manager.dart';
import 'package:logo_app_flutter/components/undo_redo_widget.dart';

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
  Future<ui.Image> _applyShapeMask(
    ui.Image sourceImage,
    String shapeName,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(
      sourceImage.width.toDouble(),
      sourceImage.height.toDouble(),
    );

    final shapePath = _createShapePath(shapeName, size);
    canvas.clipPath(shapePath);
    canvas.drawImage(sourceImage, Offset.zero, Paint());
    final picture = recorder.endRecording();
    return await picture.toImage(sourceImage.width, sourceImage.height);
  }

  Path _createShapePath(String shapeName, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    switch (shapeName.toLowerCase()) {
      case 'circle':
        path.addOval(Rect.fromCircle(center: center, radius: radius));
        break;

      case 'triangle':
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx - radius, center.dy + radius);
        path.lineTo(center.dx + radius, center.dy + radius);
        path.close();
        break;

      case 'diamond':
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx + radius, center.dy);
        path.lineTo(center.dx, center.dy + radius);
        path.lineTo(center.dx - radius, center.dy);
        path.close();
        break;

      case 'hexagon':
        final points = <Offset>[];
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60.0) * (math.pi / 180.0);
          points.add(
            Offset(
              center.dx + radius * math.cos(angle),
              center.dy + radius * math.sin(angle),
            ),
          );
        }
        path.moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        path.close();
        break;

      case 'star':
        final outerRadius = radius;
        final innerRadius = radius * 0.4;
        final points = <Offset>[];

        for (int i = 0; i < 10; i++) {
          final angle = (i * 36.0) * (math.pi / 180.0);
          final currentRadius = i.isEven ? outerRadius : innerRadius;
          points.add(
            Offset(
              center.dx + currentRadius * math.cos(angle - math.pi / 2),
              center.dy + currentRadius * math.sin(angle - math.pi / 2),
            ),
          );
        }

        path.moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        path.close();
        break;

      default:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return path;
  }

  String selectedShapeName = ""; // 👈 Add this
  // --- State Management ---
  late LogoStateData _currentLogoState;
  //  int? _selectedElementId;
  int? selectedElementId;

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
  // bool showEffectPanel = false;

  // bool showPaletteBar = false;
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
  int tabToolbarIndex = 0; //? Points no active toolbar
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

  Offset? _initialDragPoint;
  double? _initialElementValue;

  Future<void> _saveLogoCleanly(GlobalKey canvasKey) async {
    final wasMovementPanelVisible = isMovementPanelVisible;
    final previousSelectedElement = selectedElement;
    final wasGridVisible = _showGrid;

    try {
      setState(() {
        selectedElement = null;
        isMovementPanelVisible = false;
        _showGrid = false;
      });

      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      provider.clearSelection();

      await Future.delayed(const Duration(milliseconds: 150));
      await WidgetsBinding.instance.endOfFrame;

      await saveCanvasToGallery(canvasKey);
    } finally {
      setState(() {
        selectedElement = previousSelectedElement;
        isMovementPanelVisible = wasMovementPanelVisible;
        _showGrid = wasGridVisible;
      });

      if (previousSelectedElement != null) {
        final provider = Provider.of<SelectedColorProvider>(
          context,
          listen: false,
        );
        provider.setSelectedElement(previousSelectedElement);
      }
    }
  }

  Future<void> saveCanvasToGallery(GlobalKey canvasKey) async {
    final isGranted = await _requestGalleryPermission();
    if (!isGranted) {
      print("Storage permission not granted");
      return;
    }

    try {
      RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image canvasImage = await boundary.toImage(pixelRatio: 3.0);

      ui.Image finalImage;
      if (selectedShapeName.isNotEmpty && selectedShapeName != "none") {
        finalImage = await _applyShapeMask(canvasImage, selectedShapeName);
      } else {
        finalImage = canvasImage;
      }

      ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).writeAsBytes(pngBytes);

      final result = await GallerySaver.saveImage(
        file.path,
        albumName: "LogoMaker",
      );
      print("✅ Image saved to gallery: $result");
    } catch (e) {
      print("Failed to save canvas: $e");
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
    final shapeText =
        selectedShapeName.isNotEmpty && selectedShapeName != "none"
            ? " in ${selectedShapeName} shape"
            : "";

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Save Logo'),
          content: Text(
            'Do you want to save this logo to your gallery$shapeText?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () async {
                    final adManager = Provider.of<SmartInterstitialManager>(
                      context,
                      listen: false,
                    );
                    adManager.onDownloadAttempted();
                    adManager.onButtonClick('save_logo');

                    await _saveLogoCleanly(canvasKey);

                    Navigator.of(context).pop();

                    Provider.of<InterestitialAdProvider>(
                      context,
                      listen: false,
                    ).showAd();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logo saved to gallery$shapeText!'),
                      ),
                    );
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ],
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
    Provider.of<InterestitialAdProvider>(context, listen: false).loadAd();
    _currentLogoState = LogoStateData(
      logoPosition: const Offset(150, 100),
      logoSize: 100,
      logoRotation: 0,
      isLogoVisible: true,
      svgLogo: widget.svgLogo,
      logoColor: null,
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
      customSVGs: [],
      lockedElements: {},
      elementOrder: [0, 1, 2],
      backgroundColor: Colors.white,
      backgroundGradient: null,
      backgroundTexture: null,
      backgroundImage: null,
      palette: null,
      opacity: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLogoColorChanged(Color color) {
    setState(() {
      _currentLogoState = _currentLogoState.copyWith(logoColor: color);
    });
    Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    ).updateLogoState(_currentLogoState);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldDiscard = await _showDiscardChangesDialog(context);
        if (shouldDiscard) {
          final colorProvider = Provider.of<SelectedColorProvider>(
            context,
            listen: false,
          );
          colorProvider.resetElementGradients();
          _resetEditorStateToDefault();
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldDiscard = await _showDiscardChangesDialog(context);
              if (shouldDiscard) {
                final colorProvider = Provider.of<SelectedColorProvider>(
                  context,
                  listen: false,
                );
                colorProvider.resetElementGradients();
                _resetEditorStateToDefault();
                Navigator.pop(context);
              }
            },
          ),
          title: const Text('Logo Editor'),
          centerTitle: true,
          actions: [
            const ThemeToggleWidget(),
            const SizedBox(width: 8),
            _buildCustomUndoRedoWidget(),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.save, size: 40),
              onPressed: () => _showSaveConfirmationDialog(context, _canvasKey),
              tooltip: 'Save Logo',
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
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              selectedElement = null;
                              isMovementPanelVisible = false;
                            });
                          },
                          child: Consumer<SelectedColorProvider>(
                            builder: (context, provider, _) {
                              final logoState =
                                  provider.getCurrentLogoState() ??
                                  _currentLogoState;
                              return LogoCanvas(
                                selectedShapeName: selectedShapeName,
                                logoState: logoState,
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
                                    () =>
                                        setState(() => _showGrid = !_showGrid),
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
                                lockedElements:
                                    _currentLogoState.lockedElements,
                                elementOrder: logoState.elementOrder,
                              );
                            },
                          ),
                        ),
                      ),

                      Positioned(
                        top: 20,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showGrid = !_showGrid;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _showGrid ? 'Grid enabled' : 'Grid disabled',
                                ),
                                duration: const Duration(milliseconds: 1000),
                              ),
                            );
                          },
                          onLongPress: () => _showGridPropertiesDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(25.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(-2, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _showGrid ? Icons.grid_off : Icons.grid_on,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
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
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(25.0),
                                bottomRight: Radius.circular(25.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.layers,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      if (_isLayersPanelVisible)
                        Positioned(
                          top: 30,
                          right: 70,
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]!.withOpacity(0.95)
                                      : Colors.grey[200]!.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 20,
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isLayersPanelVisible =
                                          !_isLayersPanelVisible;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 20,
                        left: _isLayersPanelVisible ? 0 : -300,
                        child: Consumer<SelectedColorProvider>(
                          builder: (context, provider, _) {
                            final logoState =
                                provider.getCurrentLogoState() ??
                                _currentLogoState;
                            return LayersPanel(
                              logoState: logoState,
                              svgLogo: widget.svgLogo,
                              onClose:
                                  () => setState(
                                    () => _isLayersPanelVisible = false,
                                  ),
                              onToggleLock: _toggleLock,
                              onToggleLockAll: _toggleLockAll,
                              onReorder: (id, moveUp) {
                                if (moveUp) {
                                  provider.moveElementUp(id);
                                } else {
                                  provider.moveElementDown(id);
                                }
                              },
                            );
                          },
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

            if (tabToolbarIndex != -1 &&
                (!isMovementPanelVisible || selectedElement == null))
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight - 50,
                top: MediaQuery.sizeOf(context).height.toDouble() * 0.44,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 280,
                      child: _buildToolbarForTabs(tabToolbarIndex),
                    ),
                  ],
                ),
              ),

            if (selectedElement != null && isMovementPanelVisible)
              Positioned(
                bottom:
                    0, 
                left: 0,
                right: 0,
                child: MovementPanel(
                  isVisible: isMovementPanelVisible,
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
                    setState(() {});
                    _updateElementPosition(selectedElement!, delta);
                  },
                  onDuplicatePressed: () {
                    print('Duplicate called for $selectedElement');
                    duplicateSelectedElement(selectedElement!);
                  },
                  onBringToFrontPressed:
                      () => bringToFront(selectedElement!, _currentLogoState),
                  onSendToBackPressed:
                      () => sendToBack(selectedElement!, _currentLogoState),
                  selectedElementId: selectedElement,
                  onClose: () {
                    
                  },
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

  Widget _buildCustomUndoRedoWidget() {
    return Consumer<UndoProvider>(
      builder: (context, undoProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.undo,
                size: 32,
                color: undoProvider.canUndo ? Colors.black : Colors.grey,
              ),
              onPressed: undoProvider.canUndo ? _undo : null,
              tooltip:
                  undoProvider.canUndo
                      ? 'Undo: ${undoProvider.getLastAction()}'
                      : 'No actions to undo',
            ),
            IconButton(
              icon: Icon(
                Icons.redo,
                size: 32,
                color: undoProvider.canRedo ? Colors.black : Colors.grey,
              ),
              onPressed: undoProvider.canRedo ? _redo : null,
              tooltip:
                  undoProvider.canRedo
                      ? 'Redo: ${undoProvider.getNextAction()}'
                      : 'No actions to redo',
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbarForTabs(int index) {
    switch (index) {
      case 0:
        return DropUpPanel(
          onClose: () => setState(() => showDropUp = false),
          onToggleCheckerboard: (val) {
            setState(() {
              isCheckerboardActive = val;
              isCheckerboardVisible = val;
            });
          },
          onOpacityChanged: (val) => setState(() => checkerboardOpacity = val),
          onShapeSelected: (shapeName) {
            _saveUndoState('Change shape to $shapeName');

            setState(() {
              selectedShapeName = shapeName;
            });

            final colorProvider = Provider.of<SelectedColorProvider>(
              context,
              listen: false,
            );
            colorProvider.updateLogoState(_currentLogoState);
          },
        );
      // case 3:
      //   return _buildEffectPanel();
      case 4:
        return _buildPaletteSelection();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildPaletteSelection() {
    return Container(
      color: const ui.Color.fromARGB(255, 72, 70, 70),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: paletteList.length,
        itemBuilder: (context, index) {
          final colors = paletteList[index];
          final isSelected = selectedPaletteIndex == index;
          return GestureDetector(
            onTap: () {
              _saveUndoState('Apply color palette ${index + 1}');
              final provider = Provider.of<SelectedColorProvider>(
                context,
                listen: false,
              );

              setState(() {
                selectedPaletteIndex = index;
              });

              provider.setInitialColorsFromPalette(
                colors,
                _currentLogoState.elementOrder,
              );

              provider.updateLogoState(_currentLogoState);
            },
            child: Container(
              height: 10,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      children:
                          colors
                              .map(
                                (color) => Container(
                                  height: 93.6,
                                  width: double.infinity,
                                  color: color,
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            _saveUndoState('Rotate palette colors');
                            final provider = Provider.of<SelectedColorProvider>(
                              context,
                              listen: false,
                            );
                            provider.setColorsRotated(
                              colors,
                              allElementIds: _currentLogoState.elementOrder,
                            );
                            // CRITICAL: Sync logo state back to provider
                            provider.updateLogoState(_currentLogoState);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.refresh,
                              size: 10,
                              color: Colors.orange,
                            ),
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
    );
  }

  void bringToFront(int elementId, dynamic logoState) {
    final index = logoState.elementOrder.indexOf(elementId);
    if (index != -1) {
      logoState.elementOrder.removeAt(index);
      logoState.elementOrder.add(elementId);
      setState(() {});
    }
  }

  void sendToBack(int elementId, dynamic logoState) {
    final index = logoState.elementOrder.indexOf(elementId);
    if (index != -1) {
      logoState.elementOrder.removeAt(index);
      logoState.elementOrder.insert(0, elementId);
      setState(() {});
    }
  }

  Widget _buildEffectPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const ui.Color.fromARGB(255, 72, 70, 70),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Text("Opacity", style: TextStyle(color: Colors.white)),
          Row(
            children: [
              const Icon(Icons.opacity, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Consumer<SelectedColorProvider>(
                  builder: (context, provider, _) {
                    return Slider(
                      value: provider.opacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: (provider.opacity * 100).round().toString(),
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        provider.setOpacity(value);
                      },
                      onChangeStart: (value) {
                        _saveUndoState('Change opacity');
                      },
                      onChangeEnd: (value) {
                        _saveUndoState(
                          'Set opacity to ${(value * 100).round()}%',
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Consumer<SelectedColorProvider>(
                  builder: (context, provider, _) {
                    return Text(
                      "${(provider.opacity * 100).round()}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text("Background Color", style: TextStyle(color: Colors.white)),

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
                      _saveUndoState('Reset background color');
                      Provider.of<SelectedColorProvider>(
                        context,
                        listen: false,
                      ).resetColor();
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
                    _saveUndoState('Change element color');
                    final provider = Provider.of<SelectedColorProvider>(
                      context,
                      listen: false,
                    );
                    if (selectedElement != null) {
                      provider.setElementColor(selectedElement!, color);
                    } else {
                      provider.setBackgroundColor(color);
                    }
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

  void _saveUndoState(String action) {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    colorProvider.updateLogoState(_currentLogoState);

    final currentState = colorProvider.captureCurrentState();
    currentState['selectedShapeName'] = selectedShapeName;

    undoProvider.saveState(action: action, state: currentState);

    print('✅ Saved undo state: $action');
    print('   Opacity: ${colorProvider.opacity}');
    print('   Shape: $selectedShapeName');
  }

  void _undo() {
    final adManager = Provider.of<SmartInterstitialManager>(
      context,
      listen: false,
    );
    adManager.onButtonClick('undo');

    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (undoProvider.canUndo) {
      final previousState = undoProvider.undo();
      if (previousState != null) {
        colorProvider.restoreFromState(previousState.data);

        final restoredLogoState = colorProvider.getCurrentLogoState();
        if (restoredLogoState != null) {
          setState(() {
            _currentLogoState = restoredLogoState;
            selectedElement = null;
            _clearGridAlignment();
            if (previousState.data['selectedShapeName'] != null) {
              selectedShapeName = previousState.data['selectedShapeName'];
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Undo: ${previousState.action}'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to undo!'),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _redo() {
    final adManager = Provider.of<SmartInterstitialManager>(
      context,
      listen: false,
    );
    adManager.onButtonClick('redo');

    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (undoProvider.canRedo) {
      final redoState = undoProvider.redo();
      if (redoState != null) {
        colorProvider.restoreFromState(redoState.data);

        final restoredLogoState = colorProvider.getCurrentLogoState();
        if (restoredLogoState != null) {
          setState(() {
            _currentLogoState = restoredLogoState;
            selectedElement = null;
            _clearGridAlignment();
            if (redoState.data['selectedShapeName'] != null) {
              selectedShapeName = redoState.data['selectedShapeName'];
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redo: ${redoState.action}'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to redo!'),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _handleBottomNavTap(int index) async {
    setState(() {
      selectedIndex = index;
      tabToolbarIndex = index == tabToolbarIndex ? -1 : index;
      selectedElement = null;
      isMovementPanelVisible = false;
    });

    //? Future.delayed(Duration.zero, () {
    //   setState(() {
    //     showDropUp = index == 0;
    //     showPaletteBar = index == 4;
    //     showEffectPanel = index == 3;
    //   });
    // });

    // ✅ Navigation & other logic
    if (index == 2) {
      final result = await Navigator.of(
        context,
      ).push<String>(_createSlideRoute());
      if (result != null && result.isNotEmpty) {
        _saveUndoState('Add text element');
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
                images: const [
                  'assets/logo_images/logo_1.png',
                  'assets/logo_images/logo_2.png',
                  'assets/logo_images/logo_3.png',
                  'assets/logo_images/logo_4.png',
                  'assets/logo_images/logo_5.png',
                  'assets/logo_images/logo_6.png',
                  'assets/logo_images/logo_7.png',
                  'assets/logo_images/logo_8.png',
                  'assets/logo_images/logo_9.png',
                  'assets/logo_images/logo_10.png',
                ],
              ),
        ),
      );
      if (selectedImagePath != null && mounted) {
        _saveUndoState('Add art element');
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
          _saveUndoState('Add custom image');
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
    print("Selected Element Id: $id ");
    setState(() {
      selectedElement = id;
      isMovementPanelVisible = true;
    });
  }

  void _deleteElement(int id) {
    _saveUndoState('Delete element $id');
    setState(() {
      String message = 'Element deleted!';
      LogoStateData newState = _currentLogoState;

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

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      colorProvider.updateLogoState(_currentLogoState);

      selectedElement = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _splitElement(int id) {
    if (_isElementLocked(id)) return;
    _saveUndoState('Split element $id');
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
        // }        else if (id == 4) {
        //         _currentLogoState = _currentLogoState.copyWith(
        //           slogan2Position: _currentLogoState.sloganPosition + offset,
        //           slogan2Size: _currentLogoState.sloganSize,
        //           slogan2Rotation: _currentLogoState.sloganRotation,
        //           isSlogan2Visible: true,
        //         );
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
    _saveUndoState('Rotate element $id by 45°');
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
    _saveUndoState('Resize element $id');
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

  //   void _updateElementPosition(int id, Offset delta) {
  //     if (_isElementLocked(id)) return;

  //     final RenderBox? renderBox =
  //         _canvasKey.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox == null) return;

  //     final canvasSize = renderBox.size;
  //     final originalPosition = _getElementPosition(id);
  //     final elementSize = _getElementRenderedSize(id);

  //     if (elementSize == Size.zero) return;

  //     final newPosition = _limitOffset(
  //       originalPosition,
  //       delta,
  //       elementSize,
  //       canvasSize,
  //     );

  //     setState(() {
  //       if (id >= 100 && id < 200) {
  //         // Custom Text Elements
  //         final index = id - 100;
  //         if (index >= 0 && index < _currentLogoState.customTexts.length) {
  //           final updatedTexts = List<CustomTextElement>.from(
  //             _currentLogoState.customTexts,
  //           );
  //           updatedTexts[index] = updatedTexts[index].copyWith(
  //             position: newPosition,
  //           );
  //           _currentLogoState = _currentLogoState.copyWith(
  //             customTexts: updatedTexts,
  //           );
  //         }
  //       } else if (id == 0) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           logoPosition: newPosition,
  //         );
  //       } else if (id == 1) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           companyNamePosition: newPosition,
  //         );
  //       } else if (id == 2) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           sloganPosition: newPosition,
  //         );
  //       } else if (id == 3) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           logo2Position: newPosition,
  //         );
  //       } else if (id == 4) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           companyName2Position: newPosition,
  //         );
  //       } else if (id == 5) {
  //         _currentLogoState = _currentLogoState.copyWith(
  //           slogan2Position: newPosition,
  //         );
  //       }
  //       if (id >= 200 && id < 300) {
  //   final index = id - 200;
  //   final images = _currentLogoState.customImages;

  //   if (index >= 0 && index < images.length) {
  //     final updatedImages = List<CustomImageElement>.from(images);
  //     updatedImages[index] = updatedImages[index].copyWith(
  //       position: newPosition,
  //     );
  //     _currentLogoState = _currentLogoState.copyWith(
  //       customImages: updatedImages,
  //     );
  //   }

  //  else {
  //           debugPrint(
  //             '❌ Invalid image index: $index, List length: ${images.length}',
  //           );
  //         }
  //       }

  //       _checkGridAlignment(newPosition, elementSize, canvasSize);
  //     });
  //   }

  void _showGridPropertiesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            'Grid Properties',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Grid Density Slider
              Text(
                'Grid Density',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: 4.0, // Default 4x4 grid
                min: 2.0,
                max: 8.0,
                divisions: 6,
                label: '4x4',
                activeColor: Colors.orange,
                onChanged: (value) {
                  // TODO: Implement grid density change
                  print('Grid density changed to: $value');
                },
              ),

              const SizedBox(height: 16),

              // ✅ Grid Color Picker
              Text(
                'Grid Color',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(Colors.white, 'White'),
                  _buildColorOption(Colors.black, 'Black'),
                  _buildColorOption(Colors.grey, 'Grey'),
                  _buildColorOption(Colors.blue, 'Blue'),
                  _buildColorOption(Colors.red, 'Red'),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Grid Opacity',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: 0.3,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '30%',
                activeColor: Colors.orange,
                onChanged: (value) {
                  // TODO: Implement grid opacity change
                  print('Grid opacity changed to: ${(value * 100).round()}%');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(Color color, String label) {
    return GestureDetector(
      onTap: () {
        print('Grid color changed to: $label');
      },
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;
    _saveUndoState('Move element $id');
    debugPrint('Pan started for id=$id');
    setState(() {
      selectedElement = id;
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
      } else if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index >= 0 && index < _currentLogoState.customImages.length) {
          final updatedImages = List<CustomImageElement>.from(
            _currentLogoState.customImages,
          );
          updatedImages[index] = updatedImages[index].copyWith(
            position: newPosition,
          );
          _currentLogoState = _currentLogoState.copyWith(
            customImages: updatedImages,
          );
        }
      } else if (id >= 300 && id < 400) {
        // ✅ Custom SVGs (DUPLICATE LOGOS)
        final index = id - 300;
        if (index >= 0 && index < _currentLogoState.customSVGs.length) {
          final updatedSVGs = List<CustomSvgElement>.from(
            _currentLogoState.customSVGs,
          );
          updatedSVGs[index] = updatedSVGs[index].copyWith(
            position: newPosition,
          );
          _currentLogoState = _currentLogoState.copyWith(
            customSVGs: updatedSVGs,
          );
        }
      } else {
        switch (id) {
          case 0:
            _currentLogoState = _currentLogoState.copyWith(
              logoPosition: newPosition,
            );
            break;
          case 1:
            _currentLogoState = _currentLogoState.copyWith(
              companyNamePosition: newPosition,
            );
            break;
          case 2:
            _currentLogoState = _currentLogoState.copyWith(
              sloganPosition: newPosition,
            );
            break;
          case 3:
            _currentLogoState = _currentLogoState.copyWith(
              logo2Position: newPosition,
            );
            break;
          case 4:
            _currentLogoState = _currentLogoState.copyWith(
              companyName2Position: newPosition,
            );
            break;
          case 5:
            _currentLogoState = _currentLogoState.copyWith(
              slogan2Position: newPosition,
            );
            break;
        }
      }

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      colorProvider.updateLogoState(_currentLogoState);

      _checkGridAlignment(newPosition, elementSize, canvasSize);
    });
  }

  void _onPanEnd(int id) {
    _initialDragPoint = null;
    _initialElementValue = null;
    _clearGridAlignment();
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

  // --- Optional Debugging ---
  Offset _getElementPositionSafe(int id) {
    try {
      return _getElementPosition(id);
    } catch (_) {
      debugPrint('⚠️ _getElementPosition failed for id=$id');
      return Offset.zero;
    }
  }

  void _onResizePanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;
    _saveUndoState('Resize element $id');
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
    _saveUndoState('Rotate element $id');
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

  void _addImageToCanvas(String imagePath) {
    _saveUndoState('Add art element');

    final imageIndex = _currentLogoState.customImages.length;
    final newImage = CustomImageElement(
      path: imagePath,
      position: _getCanvasCenter() ?? const Offset(100, 100),
      size: 100,
      rotation: 0,
      isAsset: imagePath.startsWith('assets/'),
      isVisible: true,
      opacity: 1.0,
    );

    setState(() {
      _currentLogoState = _currentLogoState.copyWith(
        customImages: [..._currentLogoState.customImages, newImage],
        elementOrder: [..._currentLogoState.elementOrder, 200 + imageIndex],
      );

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      colorProvider.updateLogoState(_currentLogoState);
    });
  }

  // void _onPanStart(int id, DragStartDetails details) {
  //   if (_isElementLocked(id)) return;
  //   _saveState();
  // }
  // void _onPanStart(int id, DragStartDetails details) {
  //   if (_isElementLocked(id)) return;

  //   setState(() {
  //     selectedElement = id; // ✅ yeh line add karo
  //   });

  //   _saveState();
  // }

  // void _onPanEnd(int id) {
  //   _initialDragPoint = null;
  //   _initialElementValue = null;
  //   _clearGridAlignment();
  // }

  Offset? _getCanvasCenter() {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      return Offset(size.width / 2, size.height / 2);
    }
    return null;
  }

  // Offset _limitOffset(
  //   Offset original,
  //   Offset delta,
  //   Size elementSize,
  //   Size canvasSize,
  // ) {
  //   final newOffset = original + delta;
  //   final clampedDx = newOffset.dx.clamp(
  //     0.0,
  //     canvasSize.width - elementSize.width,
  //   );
  //   final clampedDy = newOffset.dy.clamp(
  //     0.0,
  //     canvasSize.height - elementSize.height,
  //   );
  //   return Offset(clampedDx, clampedDy);
  // }

  // void _clearGridAlignment() {
  //   if (_highlightedHorizontalGridLineIndex != null ||
  //       _highlightedVerticalGridLineIndex != null) {
  //     setState(() {
  //       _highlightedHorizontalGridLineIndex = null;
  //       _highlightedVerticalGridLineIndex = null;
  //     });
  //   }
  // }

  void _checkGridAlignment(
    Offset elementPosition,
    Size elementSize,
    Size canvasSize,
  ) {
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

  double _getElementSize(int id) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final logoState = provider.getCurrentLogoState() ?? _currentLogoState;
    if (id >= 100) {
      final index = id - 100;
      if (index < logoState.customTexts.length)
        return logoState.customTexts[index].size;
    }
    switch (id) {
      case 0:
        return logoState.logoSize;
      case 1:
        return logoState.companyNameSize;
      case 2:
        return logoState.sloganSize;
      case 3:
        return logoState.logo2Size ?? 0;
      case 4:
        return logoState.companyName2Size ?? 0;
      case 5:
        return logoState.slogan2Size ?? 0;
      default:
        return 0;
    }
  }

  // Size _getElementRenderedSize(int id) {
  //   final sizeValue = _getElementSize(id);
  //   if (id >= 100) {
  //     final index = id - 100;
  //     if (index < _currentLogoState.customTexts.length) {
  //       final text = _currentLogoState.customTexts[index].text;
  //       return TextSizeUtil.getTextSize(
  //         text,
  //         TextStyle(
  //           fontSize: sizeValue,
  //           color: Colors.black,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       );
  //     }
  //   }
  //   switch (id) {
  //     case 0:
  //     case 3:
  //       return Size(sizeValue, sizeValue);
  //     case 1:
  //     case 4:
  //       return TextSizeUtil.getTextSize(
  //         widget.companyName,
  //         TextStyle(
  //           fontSize: sizeValue,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black,
  //         ),
  //       );
  //     case 2:
  //     case 5:
  //       return TextSizeUtil.getTextSize(
  //         widget.sloganName,
  //         TextStyle(
  //           fontSize: sizeValue,
  //           fontStyle: FontStyle.italic,
  //           color: Colors.black,
  //         ),
  //       );
  //     default:
  //       return Size.zero;
  //   }
  // }

  // Offset _getElementPosition(int id) {
  //   final provider = Provider.of<SelectedColorProvider>(context, listen: false);
  // //         widget.companyName,
  // //         TextStyle(
  // //           fontSize: sizeValue,
  // //           fontWeight: FontWeight.bold,
  // //           color: Colors.black,
  // //         ),
  // //       );
  // //     case 2:
  // //     case 5:
  // //       return TextSizeUtil.getTextSize(
  // //         widget.sloganName,
  // //         TextStyle(
  // //           fontSize: sizeValue,
  // //           fontStyle: FontStyle.italic,
  // //           color: Colors.black,
  // //         ),
  // //       );
  // //     default:
  // //       return Size.zero;
  // //   }
  // // }

  Offset _getElementPosition(int id) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final logoState = provider.getCurrentLogoState() ?? _currentLogoState;
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < logoState.customTexts.length) {
        return logoState.customTexts[index].position;
      } else {
        return Offset.zero;
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < logoState.customImages.length) {
        return logoState.customImages[index].position;
      } else {
        return Offset.zero;
      }
    } else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < logoState.customSVGs.length) {
        return logoState.customSVGs[index].position;
      } else {
        return Offset.zero;
      }
    }

    switch (id) {
      case 0:
        return logoState.logoPosition;
      case 1:
        return logoState.companyNamePosition;
      case 2:
        return logoState.sloganPosition;
      case 3:
        return logoState.logo2Position ?? Offset.zero;
      case 4:
        return logoState.companyName2Position ?? Offset.zero;
      case 5:
        return logoState.slogan2Position ?? Offset.zero;
      default:
        return Offset.zero;
    }
  }

  Size _getElementRenderedSize(int id) {
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
        final text = _currentLogoState.customTexts[index].text;
        final sizeValue = _currentLogoState.customTexts[index].size;
        return TextSizeUtil.getTextSize(
          text,
          TextStyle(fontSize: sizeValue, color: Colors.black),
        );
      } else {
        return Size(100, 100);
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final sizeValue = _currentLogoState.customImages[index].size ?? 100;
        return Size(sizeValue, sizeValue);
      } else {
        return Size(100, 100);
      }
    } else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final sizeValue = _currentLogoState.customSVGs[index].size;
        return Size(sizeValue, sizeValue);
      } else {
        return Size(100, 100);
      }
    }

    final sizeValue = _getElementSize(id);
    return Size(sizeValue, sizeValue);
  }

  double _getElementRotation(int id) {
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length)
        return _currentLogoState.customTexts[index].rotation;
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index < _currentLogoState.customImages.length)
        return _currentLogoState.customImages[index].rotation;
    } else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index < _currentLogoState.customSVGs.length)
        return _currentLogoState.customSVGs[index].rotation;
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
    if (id >= 100 && id < 200) {
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
    } else if (id >= 200 && id < 300) {
      // ✅ Custom Images
      final index = id - 200;
      if (index < _currentLogoState.customImages.length) {
        final updatedImages = List<CustomImageElement>.from(
          _currentLogoState.customImages,
        );
        updatedImages[index] = updatedImages[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(
          customImages: updatedImages,
        );
      }
    } else if (id >= 300 && id < 400) {
      // ✅ Custom SVGs
      final index = id - 300;
      if (index < _currentLogoState.customSVGs.length) {
        final updatedSVGs = List<CustomSvgElement>.from(
          _currentLogoState.customSVGs,
        );
        updatedSVGs[index] = updatedSVGs[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(customSVGs: updatedSVGs);
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
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.updateLogoState(_currentLogoState);
  }

  void _updateElementRotation(int id, double newRotation) {
    if (id >= 100 && id < 200) {
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
    } else if (id >= 200 && id < 300) {
      // ✅ Custom Images
      final index = id - 200;
      if (index < _currentLogoState.customImages.length) {
        final updatedImages = List<CustomImageElement>.from(
          _currentLogoState.customImages,
        );
        updatedImages[index] = updatedImages[index].copyWith(
          rotation: newRotation,
        );
        _currentLogoState = _currentLogoState.copyWith(
          customImages: updatedImages,
        );
      }
    } else if (id >= 300 && id < 400) {
      // ✅ Custom SVGs
      final index = id - 300;
      if (index < _currentLogoState.customSVGs.length) {
        final updatedSVGs = List<CustomSvgElement>.from(
          _currentLogoState.customSVGs,
        );
        updatedSVGs[index] = updatedSVGs[index].copyWith(rotation: newRotation);
        _currentLogoState = _currentLogoState.copyWith(customSVGs: updatedSVGs);
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
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.updateLogoState(_currentLogoState);
  }

  void _toggleLock(int id) {
    _saveUndoState('Toggle lock element $id');
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
    _saveUndoState(shouldLock ? 'Lock all elements' : 'Unlock all elements');
    setState(() {
      if (shouldLock) {
        _currentLogoState = _currentLogoState.copyWith(
          lockedElements: _currentLogoState.visibleElementIds.toSet(),
        );
      } else {
        _currentLogoState = _currentLogoState.copyWith(lockedElements: {});
      }
    });
  }

  void _reorderLayer(int id, bool moveUp) {
    _saveUndoState(moveUp ? 'Move element $id up' : 'Move element $id down');
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

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      colorProvider.updateLogoState(_currentLogoState);
    });
  }

  bool _isElementLocked(int id) {
    return _currentLogoState.lockedElements.contains(id);
  }

  void duplicateSelectedElement(int id) {
    _saveUndoState('Duplicate element $id');
    setState(() {
      final logoState = _currentLogoState;
      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );

      FontStyleState fontStyle = provider.getFontStyleForElement(id);
      Color outlineColor = provider.getOutlineColor(id);
      double outlineWidth = provider.getOutlineWidth(id);
      Color shadowColor = provider.getShadowColorForElement(id);
      double shadowOffsetX = provider.getShadowOffsetXForElement(id);
      double shadowOffsetY = provider.getShadowOffsetYForElement(id);
      String fontFamily = provider.getFontForElement(id);
      Color? color = provider.getElementColor(id);
      double opacity = provider.opacity;
      double size = provider.getSizeForElement(id) ?? _getElementSize(id);
      double rotation = provider.getRotationForElement(id);

      if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index >= 0 && index < logoState.customTexts.length) {
          final original = logoState.customTexts[index];

          final currentSize = provider.getSizeForElement(id) ?? original.size;
          final currentRotation =
              provider.getRotationForElement(id) ?? original.rotation;
          final currentColor = provider.getElementColor(id) ?? original.color;
          final fontStyle = provider.getFontStyleForElement(id);
          final currentFont =
              provider.getFontForElement(id) ?? original.fontFamily;

          final duplicated = CustomTextElement(
            text: original.text,
            position: original.position + const Offset(20, 20),
            size: currentSize,
            rotation: currentRotation,
            color: currentColor,
            fontFamily: currentFont,
            isBold: fontStyle.isBold,
            isItalic: fontStyle.isItalic,
            isUnderline: fontStyle.isUnderline,
            outlineColor: provider.getOutlineColor(id) ?? original.outlineColor,
            outlineWidth: provider.getOutlineWidth(id) ?? original.outlineWidth,
            shadowColor:
                provider.getShadowColorForElement(id) ?? original.shadowColor,
            shadowOffsetX:
                provider.getShadowOffsetXForElement(id) ??
                original.shadowOffsetX,
            shadowOffsetY:
                provider.getShadowOffsetYForElement(id) ??
                original.shadowOffsetY,
            opacity: opacity,
            isVisible: true,
          );
          final newCustomTexts = List<CustomTextElement>.from(
            logoState.customTexts,
          )..add(duplicated);
          final newElementId = 100 + newCustomTexts.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);
          final newState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );
          _currentLogoState = newState;
          provider.updateLogoState(newState);
        }
        return;
      }

      if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index >= 0 && index < logoState.customImages.length) {
          final original = logoState.customImages[index];

          final currentSize =
              provider.getSizeForElement(id) ?? original.size ?? 100.0;
          final currentRotation =
              provider.getRotationForElement(id) ?? original.rotation;
          final currentOpacity = provider.opacity;

          final duplicated = CustomImageElement(
            path: original.path,
            position: original.position + const Offset(20, 20),
            size: currentSize,
            rotation: currentRotation, // ✅ Use current rotation
            isAsset: original.isAsset,
            isVisible: true,
            opacity: currentOpacity,
          );
          final newCustomImages = List<CustomImageElement>.from(
            logoState.customImages,
          )..add(duplicated);
          final newElementId = 200 + newCustomImages.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);
          final newState = logoState.copyWith(
            customImages: newCustomImages,
            elementOrder: newElementOrder,
          );
          _currentLogoState = newState;
          provider.updateLogoState(newState);
        }
        return;
      }

      if (id >= 300 && id < 400) {
        final index = id - 300;
        if (index >= 0 && index < logoState.customSVGs.length) {
          final original = logoState.customSVGs[index];
          final duplicated = CustomSvgElement(
            svgString: original.svgString,
            position: original.position + const Offset(20, 20),
            size: original.size,
            rotation: original.rotation,
            color: original.color,
            opacity: original.opacity,
            isVisible: original.isVisible,
            outlineColor: original.outlineColor,
            outlineWidth: original.outlineWidth,
          );
          final newCustomSVGs = List<CustomSvgElement>.from(
            logoState.customSVGs,
          )..add(duplicated);
          final newElementId = 300 + newCustomSVGs.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);
          final newState = logoState.copyWith(
            customSVGs: newCustomSVGs,
            elementOrder: newElementOrder,
          );
          _currentLogoState = newState;
          provider.updateLogoState(newState);
        }
        return;
      }

      if (id == 0) {
        final duplicated = CustomSvgElement(
          svgString: logoState.svgLogo!,
          position: logoState.logoPosition + const Offset(20, 20),
          size: size,
          color: provider.getElementColor(0) ?? color,
          rotation: rotation,
          opacity: opacity,
          isVisible: true,
          outlineColor: provider.getOutlineColor(id),
          outlineWidth: provider.getOutlineWidth(id),
        );
        final newCustomSVGs = List<CustomSvgElement>.from(logoState.customSVGs)
          ..add(duplicated);
        final newElementId = 300 + newCustomSVGs.length - 1;
        final newElementOrder = List<int>.from(logoState.elementOrder)
          ..add(newElementId);
        final newState = logoState.copyWith(
          customSVGs: newCustomSVGs,
          elementOrder: newElementOrder,
        );
        _currentLogoState = newState;
        provider.updateLogoState(newState);
        return;
      }

      if (id == 1) {
        final duplicated = CustomTextElement(
          text: logoState.companyName!,
          position: logoState.companyNamePosition + const Offset(20, 20),
          size: size,
          rotation: rotation,
          color: color ?? Colors.black,
          fontFamily: fontFamily,
          isBold: fontStyle.isBold,
          isItalic: fontStyle.isItalic,
          isUnderline: fontStyle.isUnderline,
          outlineColor: outlineColor,
          outlineWidth: outlineWidth,
          shadowColor: shadowColor,
          shadowOffsetX: shadowOffsetX,
          shadowOffsetY: shadowOffsetY,
          opacity: opacity,
          isVisible: true,
        );
        final newCustomTexts = List<CustomTextElement>.from(
          logoState.customTexts,
        )..add(duplicated);
        final newElementId = 100 + newCustomTexts.length - 1;
        final newElementOrder = List<int>.from(logoState.elementOrder)
          ..add(newElementId);
        final newState = logoState.copyWith(
          customTexts: newCustomTexts,
          elementOrder: newElementOrder,
        );
        _currentLogoState = newState;
        provider.updateLogoState(newState);
        return;
      }

      // --- Slogan (id == 2) as CustomTextElement ---
      if (id == 2) {
        final duplicated = CustomTextElement(
          text: logoState.sloganName!,
          position: logoState.sloganPosition + const Offset(20, 20),
          size: size,
          rotation: rotation,
          color: color ?? Colors.black,
          fontFamily: fontFamily,
          isBold: fontStyle.isBold,
          isItalic: fontStyle.isItalic,
          isUnderline: fontStyle.isUnderline,
          outlineColor: outlineColor,
          outlineWidth: outlineWidth,
          shadowColor: shadowColor,
          shadowOffsetX: shadowOffsetX,
          shadowOffsetY: shadowOffsetY,
          opacity: opacity,
          isVisible: true,
        );
        final newCustomTexts = List<CustomTextElement>.from(
          logoState.customTexts,
        )..add(duplicated);
        final newElementId = 100 + newCustomTexts.length - 1;
        final newElementOrder = List<int>.from(logoState.elementOrder)
          ..add(newElementId);
        final newState = logoState.copyWith(
          customTexts: newCustomTexts,
          elementOrder: newElementOrder,
        );
        _currentLogoState = newState;
        provider.updateLogoState(newState);
        return;
      }
    });
  }

  void _testUndoRedo() {
    _testUndoRedo() {
      final undoProvider = Provider.of<UndoProvider>(context, listen: false);
      print('Can Undo: ${undoProvider.canUndo}');
      print('Can Redo: ${undoProvider.canRedo}');
    }
  }

  void _resetEditorStateToDefault() {
    setState(() {
      _currentLogoState = LogoStateData(
        logoPosition: const Offset(150, 100),
        logoSize: 100,
        logoRotation: 0,
        isLogoVisible: true,
        svgLogo: widget.svgLogo,
        companyNamePosition: const Offset(160, 200),
        companyNameSize: 20,
        companyNameRotation: 0,
        isCompanyNameVisible: true,
        logoColor: null,
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
        customSVGs: [],
        lockedElements: {},
        elementOrder: [0, 1, 2],
        backgroundColor: Colors.white,
        backgroundGradient: null,
        backgroundTexture: null,
        backgroundImage: null,
        palette: null,
        opacity: 1.0,
      );

      // Reset UI state
      selectedElement = null;
      selectedElementId = null;
      tabToolbarIndex = 0;
      selectedIndex = 0;
      _showGrid = false;
      _isLayersPanelVisible = false;
      showDropUp = false;
      selectedPaletteIndex = 0;
      isMovementPanelVisible = true;
      isCheckerboardActive = false;
      isCheckerboardVisible = false;
      checkerboardOpacity = 1.0;
      isEditing = false;
      _highlightedHorizontalGridLineIndex = null;
      _highlightedVerticalGridLineIndex = null;

      selectedShapeName = "";
    });

    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    colorProvider.resetAllEditorState();

    colorProvider.resetElementGradients();

    colorProvider.updateLogoState(_currentLogoState);

    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    undoProvider.clear();

    print('✅ Editor reset to default including gradients');
  }
}

Future<bool> _showDiscardChangesDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: theme.dialogBackgroundColor,
              title: Text(
                'Discard Changes?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              content: Text(
                'Are you sure you want to discard all your edits including colors, gradients, and modifications?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final colorProvider = Provider.of<SelectedColorProvider>(
                      context,
                      listen: false,
                    );
                    colorProvider.resetElementGradients();

                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Discard',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
      ) ??
      false;
}
