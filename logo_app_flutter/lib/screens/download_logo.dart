// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
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

  Future<void> saveCanvasToGallery(GlobalKey canvasKey) async {
    // ✅ Step 1: Ask Permission for Android 13+ and older
    final isGranted = await _requestGalleryPermission();
    if (!isGranted) {
      print(" Storage permission not granted");
      return;
    }

    try {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
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

                    await saveCanvasToGallery(canvasKey);

                    if (previousSelection != null) {
                      provider.setSelectedElement(previousSelection);
                    }

                    Navigator.of(context).pop(); // Close dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logo saved to gallery!')),
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

    // _saveState();
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
            icon: const Icon(Icons.save, size: 40),
            onPressed: () => _showSaveConfirmationDialog(context, _canvasKey),
            tooltip: 'Save Logo',
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      top: 20,
                      left: _isLayersPanelVisible ? 0 : -300,
                      child: LayersPanel(
                        logoState: _currentLogoState,
                        svgLogo: widget.svgLogo,
                        onClose:
                            () => setState(() => _isLayersPanelVisible = false),
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
                    height: 300,
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

          if (selectedElement != null)
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

                logoState: _currentLogoState,

                selectedElementId: selectedElement,
                isVisible: true,
                onClose: () => setState(() => selectedElement = null),
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
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(9),
                                          topRight: Radius.circular(9),
                                        ),
                                      ),

                                      child: Icon(
                                        Icons.keyboard_double_arrow_down_sharp,
                                        size: 25,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                color: Colors.grey.shade100,
                                height: 65,

                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 7,
                                    bottom: 7,
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),

                child: Icon(
                  Icons.keyboard_double_arrow_down_sharp,
                  size: 25,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  const Icon(Icons.opacity, color: Colors.grey),
                  const SizedBox(width: 5),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

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
    _undoStack.add(_currentLogoState);
    if (mounted) setState(() {});
  }

  DateTime? _lastEmptyUndoTime;

  void _undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(_currentLogoState);
      _currentLogoState = _undoStack.removeLast();
      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Undo successful!'),
            duration: Duration(seconds: 2),
          ),
        );
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

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(_currentLogoState);

      _currentLogoState = _redoStack.removeLast();
      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Redo successful!'),
            duration: Duration(seconds: 2),
          ),
        );
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

  void duplicateSelectedElement(int id) {
    setState(() {
      if (id == 0) {
        String? svgString = _currentLogoState.svgLogo;

        if (svgString == null || svgString.isEmpty) {
          if (_currentLogoState.customSVGs.isNotEmpty) {
            final lastSvg = _currentLogoState.customSVGs.last;
            svgString = lastSvg.svgString;
          } else {
            debugPrint('❌ No SVG to duplicate.');
            return;
          }
        }

        final newSvgElement = CustomSvgElement(
          svgString: svgString,
          position: _currentLogoState.logoPosition + const Offset(20, 20),
          size: _currentLogoState.logoSize,
          rotation: _currentLogoState.logoRotation,
          opacity: 1.0,
          isVisible: true,
          color: Colors.black,
        );

        final updatedSVGs = [..._currentLogoState.customSVGs, newSvgElement];
        final newElementId = 300 + updatedSVGs.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customSVGs: updatedSVGs,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated SVG: $newElementId');
        return;
      }

      if (id == 1) {
        final newText = CustomTextElement(
          text: _currentLogoState.companyName ?? '',
          position:
              _currentLogoState.companyNamePosition + const Offset(20, 20),
          size: _currentLogoState.companyNameSize,
          rotation: _currentLogoState.companyNameRotation,
          color: Colors.black,
        );

        final updatedTexts = [..._currentLogoState.customTexts, newText];
        final newElementId = 100 + updatedTexts.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customTexts: updatedTexts,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated Company Name: $newElementId');
        return;
      }

      // Case 2: Slogan
      if (id == 2) {
        final newText = CustomTextElement(
          text: _currentLogoState.sloganName ?? '',
          position: _currentLogoState.sloganPosition + const Offset(20, 20),
          size: _currentLogoState.sloganSize,
          rotation: _currentLogoState.sloganRotation,
          color: Colors.black,
        );

        final updatedTexts = [..._currentLogoState.customTexts, newText];
        final newElementId = 100 + updatedTexts.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customTexts: updatedTexts,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated Slogan: $newElementId');
        return;
      }

      // Case 100+: Custom Text
      if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index < 0 || index >= _currentLogoState.customTexts.length) {
          debugPrint('❌ Invalid custom text index: $index');
          return;
        }

        final original = _currentLogoState.customTexts[index];
        final newText = original.copyWith(
          position: original.position + const Offset(20, 20),
        );

        final updatedTexts = [..._currentLogoState.customTexts, newText];
        final newElementId = 100 + updatedTexts.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customTexts: updatedTexts,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated Custom Text: $newElementId');
        return;
      }

      // Case 200+: Custom Images
      if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index < 0 || index >= _currentLogoState.customImages.length) {
          debugPrint('❌ Invalid custom image index: $index');
          return;
        }

        final original = _currentLogoState.customImages[index];
        final newImage = original.copyWith(
          position: original.position + const Offset(20, 20),
        );

        final updatedImages = [..._currentLogoState.customImages, newImage];
        final newElementId = 200 + updatedImages.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customImages: updatedImages,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated Custom Image: $newElementId');
        return;
      }

      // Case 300+: Custom SVG
      if (id >= 300 && id < 400) {
        final index = id - 300;
        if (index < 0 || index >= _currentLogoState.customSVGs.length) {
          debugPrint('❌ Invalid custom SVG index: $index');
          return;
        }

        final original = _currentLogoState.customSVGs[index];
        final newSvg = original.copyWith(
          position: original.position + const Offset(20, 20),
        );

        final updatedSVGs = [..._currentLogoState.customSVGs, newSvg];
        final newElementId = 300 + updatedSVGs.length - 1;

        _currentLogoState = _currentLogoState.copyWith(
          customSVGs: updatedSVGs,
          elementOrder: [..._currentLogoState.elementOrder, newElementId],
        );

        debugPrint('✅ Duplicated Custom SVG: $newElementId');
        return;
      }
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
      } else if (id >= 200 && id < 300) {
        // Custom Images
        final index = id - 200;
        final images = _currentLogoState.customImages;
        if (index >= 0 && index < images.length) {
          final updatedImages = List<CustomImageElement>.from(images);
          updatedImages[index] = updatedImages[index].copyWith(
            position: newPosition,
          );
          _currentLogoState = _currentLogoState.copyWith(
            customImages: updatedImages,
          );
        }
      } else {
        // Predefined elements
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
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
        return _currentLogoState.customTexts[index].position;
      } else {
        return Offset.zero;
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        return _currentLogoState.customImages[index].position;
      } else {
        return Offset.zero;
      }
    }

    // predefined elements
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
    }

    // predefined elements
    final sizeValue = _getElementSize(id);
    return Size(sizeValue, sizeValue);
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
