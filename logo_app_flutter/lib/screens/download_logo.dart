// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
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
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:screenshot/screenshot.dart';

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
  String selectedShapeName = ""; // 👈 Add this
  // --- State Management ---
  late LogoStateData _currentLogoState;
  //  int? _selectedElementId;
  int? selectedElementId;
  final List<LogoStateData> _undoStack = [];
  final List<LogoStateData> _redoStack = [];
  final int _maxUndoHistory = 10;
  //   List<LogoElement> customTextElements = [];
  //   List<LogoElement> customImageElements = [];
  //   LogoElement? _getElementById(int id) {
  //   return customTextElements.firstWhereOrNull((e) => e.id == id);
  // }

  final List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.black,
  ];

  final List<String> imageList = [
    "assets/effects_images/ef1.jpg",
    "assets/effects_images/ef2.jpg",
    "assets/effects_images/ef3.jpg",
    "assets/effects_images/ef4.jpg",
    "assets/effects_images/ef5.jpg",
    "assets/effects_images/ef6.jpg",
    "assets/effects_images/ef7.jpg",
    "assets/effects_images/ef8.jpg",
    "assets/effects_images/ef9.jpg",
    "assets/effects_images/ef10.jpg",
  ];
  Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // --- UI Toggles ---
  bool _showGrid = false;
  bool _isLayersPanelVisible = false;
  bool showDropUp = false;
  bool showEffectPanel = false;

  bool showPaletteBar = false;
  int selectedPaletteIndex = -1;

  // --- Movement Panel Toggle ---
  bool isMovementPanelVisible = true;

  // --- Background Toggles ---
  bool isCheckerboardActive = false;
  bool isCheckerboardVisible = false;
  double checkerboardOpacity = 1.0;

  // --- Editing State ---
  bool isEditing = false;
  int? selectedElement;
  int selectedIndex = -1;
  bool hasTapped = false;

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
  final isExportingNotifier = ValueNotifier<bool>(false);

  Future<void> saveCanvasToGallery(
    GlobalKey canvasKey,
    ValueNotifier<bool> isExportingNotifier,
  ) async {
    print('🔄 Starting export process...');
    isExportingNotifier.value = true;
    print('📢 isExportingNotifier set to: ${isExportingNotifier.value}');

    // Force multiple frames to ensure rebuild
    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    print('📸 Capturing canvas...');
    try {
      RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).writeAsBytes(pngBytes);
      await GallerySaver.saveImage(file.path, albumName: "LogoMaker");

      print('✅ Export completed successfully');
    } catch (e) {
      print('❌ Export failed: $e');
    } finally {
      isExportingNotifier.value = false;
      print('📢 isExportingNotifier set to: ${isExportingNotifier.value}');
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
          title: const Text(
            'Save Logo',
            style: TextStyle(
              color: ThemeColors.purple,
              fontWeight: FontWeight.w500
            ),
          ),
          content: const Text(
            'Do you want to save this logo to your gallery?',
            style: TextStyle(
              fontSize: 16,
                            color: ThemeColors.purple,

            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: ThemeColors.purple),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final provider = Provider.of<SelectedColorProvider>(
                      context,
                      listen: false,
                    );

                    int? previousSelection = provider.selectedElementId;

                    provider.clearSelection();

                    await WidgetsBinding.instance.endOfFrame;

                    await saveCanvasToGallery(canvasKey, isExportingNotifier);

                    if (previousSelection != null) {
                      provider.setSelectedElement(previousSelection);
                    }

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: ThemeColors.purple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Logo saved successfully!',
                                style: TextStyle(
                                  color: ThemeColors.purple,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: ThemeColors.purple),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  void initState() {
    super.initState();
    selectedElement = selectedElementId;

    _currentLogoState = LogoStateData(
      logoPosition: const Offset(150, 100),
      logoSize: 100,
      logoRotation: 0,
      isLogoVisible: true,
      svgLogo: "${widget.svgLogo}",
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

    // ---- ADD THIS ----
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );

      colorProvider.resetAllOutlines(); // outline reset
      colorProvider.resetAllColors(defaultColors: {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        leading: InkWell(
          onTap: () => _showBackSaveConfirmationDialog(context, _canvasKey),

          child: Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Logo Maker',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.redo, size: 30),
          //   onPressed: _redo,
          //   tooltip: 'redo last change',
          // ),
          // IconButton(
          //   icon: const Icon(Icons.undo, size: 30),
          //   onPressed: _undo,
          //   tooltip: 'Undo last change',
          // ),
          IconButton(
            icon: const Icon(Icons.save, size: 35),
            onPressed: () => _showSaveConfirmationDialog(context, _canvasKey),
            tooltip: 'Save Logo',
          ),
        ],
      ),

      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: Center(
                            child: LogoCanvas(
                              selectedShapeName: selectedShapeName,
                              isExportingNotifier: isExportingNotifier,
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

                              lockedElements: _currentLogoState.lockedElements,
                              elementOrder: _currentLogoState.elementOrder,
                            ),
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
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
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
                              size: 25,
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
                              horizontal: 10,
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
                              size: 25,
                            ),
                          ),
                        ),
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 20,
                        left: _isLayersPanelVisible ? 0 : -300,
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

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 30,
                        // moves left when closing instead of right
                        left: _isLayersPanelVisible ? 160 : -110,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isLayersPanelVisible ? 1 : 0,
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isLayersPanelVisible = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Container(
                      height:
                          (MediaQuery.of(context).size.height > 500) ? 300 : 30,

                      color: Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            children: [
                              Tooltip(
                                message: "undo last change",
                                child: InkWell(
                                  onTap: _undo,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.replay,
                                      color:
                                          _undoStack.isNotEmpty
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Tooltip(
                                message: "redo last change",
                                child: InkWell(
                                  onTap: _redo,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.refresh,
                                      color:
                                          _redoStack.isNotEmpty
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (selectedElement != null)
            Positioned(
              bottom: -100,
              child: MovementPanel(
                onLogoStateChanged: (newLogoState) {
                  setState(() {
                    _currentLogoState = newLogoState;
                  });
                },
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

                  print(
                    '🎯 Moving element $selectedElement in direction: $direction',
                  );

                  // Save state before movement
                  _saveState();

                  // Just call the function - it handles setState internally
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

                logoState: _currentLogoState,

                selectedElementId: selectedElement,
                isVisible: true,
                onClose: () => setState(() => selectedElement = null),

                onEditPressed: () async {
                  if (selectedElement == null) return;

                  // 1️⃣ Get current text
                  String currentText = '';
                  if (selectedElement == 1) {
                    currentText = _currentLogoState.companyName ?? '';
                  } else if (selectedElement == 2) {
                    currentText = _currentLogoState.sloganName ?? '';
                  } else if (selectedElement! >= 100 &&
                      selectedElement! < 200) {
                    currentText =
                        _currentLogoState
                            .customTexts[selectedElement! - 100]
                            .text;
                  }

                  // 2️⃣ Open text editor
                  final editedText = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextScreen(initialText: currentText),
                    ),
                  );

                  if (editedText == null) return;

                  // 3️⃣ Save current state BEFORE making changes
                  _saveState();

                  // 4️⃣ Apply edited text
                  LogoStateData updatedState = _currentLogoState;

                  if (selectedElement == 1) {
                    updatedState = updatedState.copyWith(
                      companyName: editedText,
                    );
                  } else if (selectedElement == 2) {
                    updatedState = updatedState.copyWith(
                      sloganName: editedText,
                    );
                  } else if (selectedElement! >= 100 &&
                      selectedElement! < 200) {
                    final index = selectedElement! - 100;

                    // Deep clone the list to avoid mutating undo history
                    final updatedCustomTexts =
                        _currentLogoState.customTexts
                            .map((e) => e.clone())
                            .toList();

                    updatedCustomTexts[index] = updatedCustomTexts[index]
                        .copyWith(text: editedText);

                    updatedState = updatedState.copyWith(
                      customTexts: updatedCustomTexts,
                    );
                  }
                  onSaveState:
                  _saveState;
                  // 5️⃣ Update state
                  setState(() {
                    _currentLogoState = updatedState;
                  });
                },
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
                            onClose:
                                () => setState(() {
                                  showDropUp = false;
                                  selectedIndex = -1;
                                }),

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
                          Column(
                            children: [
                              Container(
                                height: 30,
                                color: Colors.grey.shade200,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        showPaletteBar = false;

                                        selectedIndex = -1;
                                      });
                                    },

                                    child: Container(
                                      width: 25,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(9),
                                          topRight: Radius.circular(9),
                                        ),
                                      ),

                                      child: Icon(
                                        Icons.keyboard_double_arrow_down_sharp,
                                        size: 25,
                                        color: ThemeColors.purple,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                color: Colors.white,
                                height: 70,

                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: paletteList.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 7),
                                    itemBuilder: (context, index) {
                                      final colors = paletteList[index];
                                      final isSelected =
                                          selectedPaletteIndex == index;

                                      return GestureDetector(
                                        onTap: () {
                                          final provider = Provider.of<
                                            SelectedColorProvider
                                          >(context, listen: false);
                                          setState(() {
                                            selectedPaletteIndex = index;
                                            provider
                                                .setInitialColorsFromPalette(
                                                  colors,
                                                  _currentLogoState
                                                      .elementOrder,
                                                );
                                          });
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Colors.orange
                                                      : Colors.grey.shade400,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Column(
                                                  children:
                                                      colors
                                                          .map(
                                                            (
                                                              color,
                                                            ) => Container(
                                                              height: 15,
                                                              width:
                                                                  double
                                                                      .infinity,
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
                                                        Provider.of<
                                                          SelectedColorProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        ).setColorsRotated(
                                                          colors,
                                                          allElementIds:
                                                              _currentLogoState
                                                                  .elementOrder,
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                color:
                                                                    Colors
                                                                        .orange,
                                                                width: 1,
                                                              ),
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
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
                                ),
                              ),
                            ],
                          ),

                        if (showEffectPanel)
                          _buildEffectPanel(
                            onClose: () {
                              setState(() {
                                showEffectPanel = false;
                                selectedIndex = -1;
                              });
                            },
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
        hasTapped: selectedIndex != -1,
        onItemSelected: _handleBottomNavTap,
        
      ),
    );
  }

  void _showBackSaveConfirmationDialog(
    BuildContext parentContext,
    GlobalKey canvasKey,
  ) {
    bool saveLogoChecked = true;

    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Do you want to exit logo Maker?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  color: ThemeColors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: saveLogoChecked,
                      onChanged: (value) {
                        setState(() {
                          saveLogoChecked = value!;
                        });
                      },
                        fillColor: MaterialStateProperty.all(ThemeColors.purple),
                    ),
                  ),
                  const Text(
                    'Save Logo',
                    style: TextStyle(color: ThemeColors.purple, fontSize: 16),
                  ),
                ],
              ),

              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(parentContext).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color:ThemeColors.purple,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          saveLogoChecked
                              ? () async {
                                final provider =
                                    Provider.of<SelectedColorProvider>(
                                      parentContext,
                                      listen: false,
                                    );

                                int? previousSelection =
                                    provider.selectedElementId;
                                provider.clearSelection();
                                await WidgetsBinding.instance.endOfFrame;
                                await saveCanvasToGallery(
                                  canvasKey,
                                  isExportingNotifier,
                                );
                                if (previousSelection != null) {
                                  provider.setSelectedElement(
                                    previousSelection,
                                  );
                                }

                                Navigator.of(dialogContext).pop();

                                ScaffoldMessenger.of(parentContext)
                                    .showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.white,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                        content: Row(
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: ThemeColors.purple,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Logo saved to gallery!',
                                                style: TextStyle(
                                                  color: ThemeColors.purple,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .closed
                                    .then((_) {
                                      Navigator.of(parentContext).pop();
                                    });
                              }
                              : null,
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return ThemeColors.purple;
                        }),
                      ),

                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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

  Widget _buildEffectPanel({required VoidCallback onClose}) {
    return Column(
      children: [
        Container(
          height: 30,
          color: Colors.grey.shade200,
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: onClose,
              child: Container(
                width: 25,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_down_sharp,
                  size: 25,
                  color: ThemeColors.purple,
                ),
              ),
            ),
          ),
        ),

        // CONTENT SECTION
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OPACITY SLIDER
              // Row(
              //   children: [
              //     const SizedBox(width: 5),
              //     const Icon(Icons.opacity, color: Colors.grey),
              //     const SizedBox(width: 5),
              //     Expanded(
              //       child: Consumer<SelectedColorProvider>(
              //         builder: (context, provider, _) {
              //           return Slider(
              //             value: provider.opacity,
              //             min: 0.0,
              //             max: 1.0,
              //             divisions: 10,
              //             label: (provider.opacity * 100).round().toString(),
              //             activeColor: Colors.orange,
              //             onChanged: (value) {
              //               provider.setOpacity(value);
              //             },
              //           );
              //         },
              //       ),
              //     ),
              //     SizedBox(
              //       width: 40,
              //       child: Consumer<SelectedColorProvider>(
              //         builder: (context, provider, _) {
              //           return Text(
              //             "${(provider.opacity * 100).round()}%",
              //             textAlign: TextAlign.center,
              //           );
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),

              // IMAGE LIST
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    // FIRST ITEM = CLOSE/RESET BUTTON
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Provider.of<SelectedColorProvider>(
                            context,
                            listen: false,
                          ).resetImage(); // reset image
                        },

                        child: Container(
                          width: 40,
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

                    // SHOW IMAGE TILES
                    final imagePath = imageList[index - 1];
                    return GestureDetector(
                      onTap: () async {
                        final provider = Provider.of<SelectedColorProvider>(
                          context,
                          listen: false,
                        );

                        final uiImage = await loadUiImageFromAsset(imagePath);

                        provider.setImage(uiImage);
                      },

                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  // --- State Save/Undo ---
  void _saveState() {
    _redoStack.clear();

    if (_undoStack.length >= _maxUndoHistory) {
      _undoStack.removeAt(0);
    }

    _undoStack.add(_currentLogoState.clone());

    if (mounted) setState(() {});
  }

  DateTime? _lastEmptyUndoTime;
  DateTime? _lastSuccessUndoTime;

  void _undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(_currentLogoState.clone());
      _currentLogoState = _undoStack.removeLast();
      setState(() {});

      final now = DateTime.now();
      // 👇 APPLY SAME LOGIC FOR SUCCESS MESSAGES
      if (_lastSuccessUndoTime == null ||
          now.difference(_lastSuccessUndoTime!) > const Duration(seconds: 2)) {
        _lastSuccessUndoTime = now;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Undo successful!'),
              duration: Duration(seconds: 2),
            ),
          );
      }
    } else {
      final now = DateTime.now();
      if (_lastEmptyUndoTime == null ||
          now.difference(_lastEmptyUndoTime!) > const Duration(seconds: 2)) {
        _lastEmptyUndoTime = now;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nothing to undo!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  DateTime? _lastEmptyRedoTime;
  DateTime? _lastSuccessRedoTime;

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(_currentLogoState.clone());
      _currentLogoState = _redoStack.removeLast();
      setState(() {});

      final now = DateTime.now();
      // 👇 APPLY SAME LOGIC FOR SUCCESS MESSAGES
      if (_lastSuccessRedoTime == null ||
          now.difference(_lastSuccessRedoTime!) > const Duration(seconds: 2)) {
        _lastSuccessRedoTime = now;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Redo successful!'),
              duration: Duration(seconds: 2),
            ),
          );
      }
    } else {
      final now = DateTime.now();
      if (_lastEmptyRedoTime == null ||
          now.difference(_lastEmptyRedoTime!) > const Duration(seconds: 2)) {
        _lastEmptyRedoTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nothing to redo!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleBottomNavTap(int index) async {
    if (selectedIndex == index) {
      setState(() {
        selectedIndex = -1;
        showDropUp = false;
        showPaletteBar = false;
        showEffectPanel = false;
      });
      return;
    }

    setState(() {
      selectedIndex = index;
      showDropUp = index == 0;
      showEffectPanel = index == 3;
      showPaletteBar = index == 4;
    });

    if (index == 2) {
      final result = await Navigator.of(
        context,
      ).push<String>(_createSlideRoute());

      setState(() {
        selectedIndex = -1;
      });

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

      setState(() {
        selectedIndex = -1;
      });

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
              backgroundColor: Colors.white,
              title: const Text('Select Image Source',style: TextStyle(color: ThemeColors.purple,fontWeight: FontWeight.w500)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text('Camera',style: TextStyle(color: ThemeColors.purple,fontSize: 15),),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text('Gallery',style: TextStyle(color: ThemeColors.purple,fontSize: 15),),
                ),
              ],
            ),
      );

      setState(() {
        selectedIndex = -1;
      });

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
    //     _currentLogoState= _currentLogoState.copyWith(
    //   rotation3DX: 0,
    //   rotation3DY: 0,
    //   rotation3DZ: 0,
    // );
    });
    
  }

  void _deleteElement(int id) {
    _saveState();
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
      position: _getCanvasCenter() ?? const Offset(150, 150),
      rotation: 0,
      size: 120,
    );

    setState(() {
      final updatedCustomImages = List<CustomImageElement>.from(
        _currentLogoState.customImages,
      )..add(newImage);
      final newElementId = 200 + index;
      final updatedElementOrder = List<int>.from(_currentLogoState.elementOrder)
        ..add(newElementId);

      _currentLogoState = _currentLogoState.copyWith(
        customImages: updatedCustomImages,
        elementOrder: updatedElementOrder,
      );
    });
  }
LogoStateData _duplicate3DRotation({
  required int oldId,
  required int newId,
  required LogoStateData state,
}) {
  final newRotationX = Map<int, double>.from(state.rotationXMap);
  final newRotationY = Map<int, double>.from(state.rotationYMap);
  final newRotationZ = Map<int, double>.from(state.rotationZMap);

  newRotationX[newId] = state.rotationXMap[oldId] ?? 0;
  newRotationY[newId] = state.rotationYMap[oldId] ?? 0;
  newRotationZ[newId] = state.rotationZMap[oldId] ?? 0;

  return state.copyWith(
    rotationXMap: newRotationX,
    rotationYMap: newRotationY,
    rotationZMap: newRotationZ,
  );
}


  void duplicateSelectedElement(int id) {
    _saveState(); // Save current state for undo

    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    LogoStateData updatedState = _currentLogoState;
    int? newElementId;

    int generateNewId(int base, int count) => base + count;

    // Helper function to convert center position to top-left position
    Offset getTopLeftPosition(Offset centerPosition, Size elementSize) {
      return Offset(
        centerPosition.dx - elementSize.width / 2,
        centerPosition.dy - elementSize.height / 2,
      );
    }

    // Helper function to convert top-left position to center position
    Offset getCenterPosition(Offset topLeftPosition, Size elementSize) {
      return Offset(
        topLeftPosition.dx + elementSize.width / 2,
        topLeftPosition.dy + elementSize.height / 2,
      );
    }

    if (id == 0) {
      // Duplicate main Logo
      final outlineColor = provider.getOutlineColor(0);
      final outlineWidth = provider.getOutlineWidth(0);
      final originalColor = provider.getColorForElement(
        0,
        fallback: provider.shapeColor,
      );

      String svgString = updatedState.svgLogo ?? '';
      if (svgString.isEmpty) {
        if (updatedState.customSVGs.isNotEmpty) {
          svgString = updatedState.customSVGs.last.svgString;
        } else {
          debugPrint('❌ No SVG to duplicate.');
          return;
        }
      }

      // Calculate proper duplicate position
      final originalSize = Size(updatedState.logoSize, updatedState.logoSize);
      final originalTopLeft = getTopLeftPosition(
        updatedState.logoPosition ?? Offset.zero,
        originalSize,
      );
      final newTopLeft =
          originalTopLeft +
          const Offset(30, 30); // Offset the top-left position
      final newCenterPosition = getCenterPosition(newTopLeft, originalSize);

      // Create new SVG element in customSVGs
      final newSvgElement = CustomSvgElement(
        svgString: svgString,
        position: newCenterPosition,
        size: updatedState.logoSize,
        rotation: updatedState.logoRotation,
        opacity: 1.0,
        isVisible: true,
        color: originalColor,
      );

      final updatedSVGs =
          updatedState.customSVGs.map((e) => e.clone()).toList()
            ..add(newSvgElement);

      newElementId = generateNewId(300, updatedSVGs.length - 1);

      updatedState = updatedState.copyWith(
        customSVGs: updatedSVGs,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      provider.setOverrideColorForElement(newElementId, originalColor);
updatedState = _duplicate3DRotation(
  oldId: id,
  newId: newElementId,
  state: updatedState,
);



      debugPrint(
        '✅ Duplicated Logo as customSVG with id: $newElementId at position: $newCenterPosition',
      );
    }
    // Duplicate Custom SVGs (if id >= 300)
    else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= updatedState.customSVGs.length) return;

      final original = updatedState.customSVGs[index].clone();
      final outlineColor = provider.getOutlineColor(id);
      final outlineWidth = provider.getOutlineWidth(id);
      final originalColor = provider.getColorForElement(
        id,
        fallback: original.color ?? Colors.black,
      );

      // Calculate proper duplicate position
      final originalSize = Size(original.size, original.size);
      final originalTopLeft = getTopLeftPosition(
        original.position,
        originalSize,
      );
      final newTopLeft = originalTopLeft + const Offset(30, 30);
      final newCenterPosition = getCenterPosition(newTopLeft, originalSize);

      final newSvg = original.copyWith(
        position: newCenterPosition, // Store as center position
        color: originalColor,
      );

      final updatedSVGs =
          updatedState.customSVGs.map((e) => e.clone()).toList()..add(newSvg);
      newElementId = generateNewId(300, updatedSVGs.length - 1);

      updatedState = updatedState.copyWith(
        customSVGs: updatedSVGs,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      provider.setOverrideColorForElement(newElementId, originalColor);
updatedState = _duplicate3DRotation(
  oldId: id,
  newId: newElementId,
  state: updatedState,
);

      debugPrint(
        '✅ Duplicated Custom SVG with id: $newElementId at position: $newCenterPosition',
      );
    }
    // Duplicate Custom Texts (id 100–199)
    else if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= updatedState.customTexts.length) return;

      final original = updatedState.customTexts[index].clone();
      final outlineColor = provider.getOutlineColor(id);
      final outlineWidth = provider.getOutlineWidth(id);
      final originalColor = provider.getColorForElement(
        id,
        fallback: original.color,
      );

      // Calculate text size for proper positioning
      final textStyle = TextStyle(
        fontSize: original.size,
        fontWeight: FontWeight.w500,
      );
      final textSize = _calculateTextSize(original.text, textStyle);

      // Calculate proper duplicate position
      final originalTopLeft = getTopLeftPosition(original.position, textSize);
      final newTopLeft = originalTopLeft + const Offset(30, 30);
      final newCenterPosition = getCenterPosition(newTopLeft, textSize);

      final newText = original.copyWith(
        position: newCenterPosition, // Store as center position
        color: originalColor,
        outlineColor: outlineColor,
        strokeWidth: outlineWidth,
        isOutlined: outlineWidth > 0,
      );

      final updatedTexts =
          updatedState.customTexts.map((e) => e.clone()).toList()..add(newText);
      newElementId = generateNewId(100, updatedTexts.length - 1);

      updatedState = updatedState.copyWith(
        customTexts: updatedTexts,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      provider.setOverrideColorForElement(newElementId, originalColor);
updatedState = _duplicate3DRotation(
  oldId: id,
  newId: newElementId,
  state: updatedState,
);

      debugPrint(
        '✅ Duplicated Custom Text with id: $newElementId at position: $newCenterPosition',
      );
    }
    // Duplicate Company Name (id == 1)
    else if (id == 1) {
      final original = updatedState;
      final outlineColor = provider.getOutlineColor(1);
      final outlineWidth = provider.getOutlineWidth(1);
      final originalColor = provider.companyTextColor;

      final textStyle = TextStyle(
        fontSize: original.companyNameSize,
        fontWeight: FontWeight.w600,
      );
      final textSize = _calculateTextSize(
        original.companyName ?? "",
        textStyle,
      );

      final originalTopLeft = getTopLeftPosition(
        original.companyNamePosition,
        textSize,
      );
      final newTopLeft = originalTopLeft + const Offset(30, 30);
      final newCenter = getCenterPosition(newTopLeft, textSize);

      final newText = CustomTextElement(
        text: original.companyName ?? "",
        position: newCenter,
        rotation: original.companyNameRotation,
        size: original.companyNameSize,
        color: originalColor,
        isVisible: true,
        fontWeight: FontWeight.w900,
        opacity: 1,
        isOutlined: outlineWidth > 0,
        outlineColor: outlineColor,
        strokeWidth: outlineWidth,
      );

      final updatedTexts =
          updatedState.customTexts.map((e) => e.clone()).toList()..add(newText);

      newElementId = 100 + updatedTexts.length - 1;

      updatedState = updatedState.copyWith(
        customTexts: updatedTexts,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      provider.setOverrideColorForElement(newElementId, originalColor);
updatedState = _duplicate3DRotation(
  oldId: id,
  newId: newElementId,
  state: updatedState,
);


      debugPrint("✅ Duplicated Company Name as custom text → $newElementId");
    }
    // Duplicate Slogan (id == 2)
    else if (id == 2) {
      final original = updatedState;

      final outlineColor = provider.getOutlineColor(2);
      final outlineWidth = provider.getOutlineWidth(2);
      final originalColor = provider.sloganColor;

      final textStyle = TextStyle(
        fontSize: original.sloganSize,
        fontWeight: FontWeight.w500,
      );
      final textSize = _calculateTextSize(original.sloganName ?? "", textStyle);

      final originalTopLeft = getTopLeftPosition(
        original.sloganPosition,
        textSize,
      );
      final newTopLeft = originalTopLeft + const Offset(30, 30);
      final newCenter = getCenterPosition(newTopLeft, textSize);

      final newText = CustomTextElement(
        text: original.sloganName ?? "",
        position: newCenter,
        rotation: original.sloganRotation,
        size: original.sloganSize,
        color: originalColor,
        isVisible: true,
        opacity: 1,
        isOutlined: outlineWidth > 0,
        outlineColor: outlineColor,
        strokeWidth: outlineWidth,
      );

      final updatedTexts =
          updatedState.customTexts.map((e) => e.clone()).toList()..add(newText);

      newElementId = 100 + updatedTexts.length - 1;

      updatedState = updatedState.copyWith(
        customTexts: updatedTexts,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      provider.setOverrideColorForElement(newElementId, originalColor);
   updatedState = _duplicate3DRotation(
  oldId: id,
  newId: newElementId,
  state: updatedState,
);


      debugPrint("✅ Duplicated Slogan as custom text → $newElementId");
    }

    // Update state and select new element
    setState(() => _currentLogoState = updatedState);

    if (newElementId != null) {
      provider.selectedElementId = newElementId;
      debugPrint('🎯 Selected duplicated element: $newElementId');
    }
  }

  // Add this helper method to calculate text size
  Size _calculateTextSize(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.size;
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
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(message)));
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

  // --- Pan / Drag Handling ---
  void _onPanStart(int id, DragStartDetails details) {
    if (_isElementLocked(id)) return;

    debugPrint('Pan started for id=$id');
    setState(() {
      selectedElement = id;
    });

    _saveState();
  }

  void _updateElementPosition(int id, Offset delta) {
    print('🔄 _updateElementPosition called for id: $id, delta: $delta');

    if (_isElementLocked(id)) {
      print('❌ Element $id is locked, cannot move');
      return;
    }

    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      print('❌ RenderBox is null');
      return;
    }

    final canvasSize = renderBox.size;
    final originalPosition = _getElementPosition(id);
    Size elementSize = _getElementRenderedSize(id);

    // ⚠️ TEMPORARY FIX: If size is zero, use a default size
    if (elementSize == Size.zero) {
      print('⚠️ Element size is zero, using default size for element: $id');
      if (id >= 300 && id < 400) {
        // For custom SVGs, use a reasonable default size
        elementSize = Size(100, 100);
      } else {
        elementSize = Size(50, 50);
      }
      print('⚠️ Using default size: $elementSize');
    }
    print(
      '📍 Original position: $originalPosition, Element size: $elementSize',
    );

    if (elementSize == Size.zero) {
      print('❌ Element size is zero');
      return;
    }

    final newPosition = _limitOffset(
      originalPosition,
      delta,
      elementSize,
      canvasSize,
    );

    print('📍 New position: $newPosition');

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
          print('✅ Updated custom text position');
        } else {
          print('❌ Custom text index out of bounds: $index');
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
          print('✅ Updated custom image position');
        } else {
          print('❌ Custom image index out of bounds: $index');
        }
      } else if (id >= 300 && id < 400) {
        // ✅ This is where duplicated logos should be handled
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
          print('✅ Updated custom SVG position (duplicated logo)');
        } else {
          print(
            '❌ Custom SVG index out of bounds: $index, total SVGs: ${_currentLogoState.customSVGs.length}',
          );
        }
      } else {
        // Predefined elements
        switch (id) {
          case 0:
            _currentLogoState = _currentLogoState.copyWith(
              logoPosition: newPosition,
            );
            print('✅ Updated main logo position');
            break;
          case 1:
            _currentLogoState = _currentLogoState.copyWith(
              companyNamePosition: newPosition,
            );
            print('✅ Updated company name position');
            break;
          case 2:
            _currentLogoState = _currentLogoState.copyWith(
              sloganPosition: newPosition,
            );
            print('✅ Updated slogan position');
            break;
          case 3:
            _currentLogoState = _currentLogoState.copyWith(
              logo2Position: newPosition,
            );
            print('✅ Updated logo2 position');
            break;
          case 4:
            _currentLogoState = _currentLogoState.copyWith(
              companyName2Position: newPosition,
            );
            print('✅ Updated company name2 position');
            break;
          case 5:
            _currentLogoState = _currentLogoState.copyWith(
              slogan2Position: newPosition,
            );
            print('✅ Updated slogan2 position');
            break;
          default:
            print('❌ Unknown element ID: $id');
        }
      }

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

    _saveState();

    _initialDragPoint = details.globalPosition;
    _initialElementValue = _getElementSize(id);
  }

  void _onResizePanUpdate(int id, DragUpdateDetails details) {
    if (_isElementLocked(id)) return;
    if (_initialDragPoint == null || _initialElementValue == null) return;

    final dragDelta = details.globalPosition.dx - _initialDragPoint!.dx;

    const sensitivity = 0.5; // smooth speed
    double newSize = (_initialElementValue! + dragDelta * sensitivity).clamp(
      10.0,
      400.0,
    );

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

  // Offset _getElementPosition(int id) {
  //   if (id >= 100) {
  //     final index = id - 100;
  //     if (index < _currentLogoState.customTexts.length)
  //       return _currentLogoState.customTexts[index].position;
  //   }
  //   switch (id) {
  //     case 0:
  //       return _currentLogoState.logoPosition;
  //     case 1:
  //       return _currentLogoState.companyNamePosition;
  //     case 2:
  //       return _currentLogoState.sloganPosition;
  //     case 3:
  //       return _currentLogoState.logo2Position ?? Offset.zero;
  //     case 4:
  //       return _currentLogoState.companyName2Position ?? Offset.zero;
  //     case 5:
  //       return _currentLogoState.slogan2Position ?? Offset.zero;
  //     default:
  //       return Offset.zero;
  //   }
  // }

double _getElementSize(int id) {
  // Custom text (100+)
  if (id >= 100 && id < 200) {
    final index = id - 100;
    if (index < _currentLogoState.customTexts.length) {
      return _currentLogoState.customTexts[index].size;
    }
  }

  // Custom SVGs (200+)
  if (id >= 200 && id < 300) {
    final index = id - 200;
    if (index < _currentLogoState.customSVGs.length) {
      return _currentLogoState.customSVGs[index].size;
    }
  }

  // Built-in logos / text
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

  Offset _getElementPosition(int id) {
    print('📍 Getting position for element: $id');

    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
        final position = _currentLogoState.customTexts[index].position;
        print('📍 Custom text position: $position');
        return position;
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final position = _currentLogoState.customImages[index].position;
        print('📍 Custom image position: $position');
        return position;
      }
    } else if (id >= 300 && id < 400) {
      // ✅ THIS IS FOR DUPLICATED LOGOS
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final position = _currentLogoState.customSVGs[index].position;
        print('📍 Custom SVG position: $position');
        return position;
      } else {
        print(
          '❌ Custom SVG index out of bounds: $index, total SVGs: ${_currentLogoState.customSVGs.length}',
        );
      }
    } else {
      switch (id) {
        case 0:
          final position = _currentLogoState.logoPosition ?? Offset.zero;
          print('📍 Main logo position: $position');
          return position;
        case 1:
          final position = _currentLogoState.companyNamePosition ?? Offset.zero;
          print('📍 Company name position: $position');
          return position;
        case 2:
          final position = _currentLogoState.sloganPosition ?? Offset.zero;
          print('📍 Slogan position: $position');
          return position;
        // ... other cases
      }
    }

    print('❌ Returning zero position for element: $id');
    return Offset.zero;
  }

  Size _getElementRenderedSize(int id) {
    print('📏 Getting rendered size for element: $id');

    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
        final text = _currentLogoState.customTexts[index];
        final style = TextStyle(
          fontSize: text.size,
          fontWeight: FontWeight.w500,
        );
        final size = _calculateTextSize(text.text, style);
        print('📏 Custom text size: $size');
        return size;
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final image = _currentLogoState.customImages[index];
        final size = Size(image.size ?? 100, image.size ?? 100);
        print('📏 Custom image size: $size');
        return size;
      }
    } else if (id >= 300 && id < 400) {
      // ✅ THIS IS THE KEY FIX FOR DUPLICATED LOGOS
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final svg = _currentLogoState.customSVGs[index];
        final size = Size(svg.size, svg.size);
        print('📏 Custom SVG size: $size (from svg.size: ${svg.size})');
        return size;
      } else {
        print(
          '❌ Custom SVG index out of bounds: $index, total SVGs: ${_currentLogoState.customSVGs.length}',
        );
      }
    } else {
      switch (id) {
        case 0:
          final size = Size(
            _currentLogoState.logoSize,
            _currentLogoState.logoSize,
          );
          print('📏 Main logo size: $size');
          return size;
        case 1:
          final text = _currentLogoState.companyName ?? '';
          final style = TextStyle(
            fontSize: _currentLogoState.companyNameSize,
            fontWeight: FontWeight.bold,
          );
          final size = _calculateTextSize(text, style);
          print('📏 Company name size: $size');
          return size;
        case 2:
          final text = _currentLogoState.sloganName ?? '';
          final style = TextStyle(fontSize: _currentLogoState.sloganSize);
          final size = _calculateTextSize(text, style);
          print('📏 Slogan size: $size');
          return size;
        // ... other cases
      }
    }

    print('❌ Returning zero size for element: $id');
    return Size.zero;
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
        _currentLogoState = _currentLogoState.copyWith(
          lockedElements: _currentLogoState.visibleElementIds.toSet(),
        );
      } else {
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
