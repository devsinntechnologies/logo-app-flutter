// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
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
  final String? companyFontFamily;
  final String? sloganFontFamily;

  const DownloadLogo({
    super.key,
    required this.svgLogo,
    required this.companyName,
    required this.sloganName,
    this.companyFontFamily,
    this.sloganFontFamily,
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

  String _selectedSaveFormat = 'png';

  String selectedShapeName = ""; // 👈 Add this
  // --- State Management ---
  late LogoStateData _currentLogoState;
  //  int? _selectedElementId;
  int? selectedElementId;

  double _gridOpacity = 0.4;

  final List<String> imageList = [
    "assets/EffectGrad/1.jpg",
    "assets/EffectGrad/2.jpg",
    "assets/EffectGrad/3.jpg",
    "assets/EffectGrad/4.jpg",
    "assets/EffectGrad/5.jpg",
    "assets/EffectGrad/6.jpg",
    "assets/EffectGrad/7.jpg",
    "assets/EffectGrad/8.jpg",
    "assets/EffectGrad/9.jpg",
    "assets/EffectGrad/10.jpeg",
    "assets/EffectGrad/11.jpg",
    "assets/EffectGrad/12.jpg",
    "assets/EffectGrad/13.jpg",
    "assets/EffectGrad/14.jpg",
    "assets/EffectGrad/15.jpg",
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

  bool _didCenterOnOpen = false;

  Future<void> _centerCanvasOnOpen() async {
    if (!mounted || _didCenterOnOpen) return;

    await WidgetsBinding.instance.endOfFrame;

    final rb = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;
    final Size canvasSize = rb.size;

    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final companyFamily =
        provider.getFontForElement(1) ?? _currentLogoState.companyNameFont;
    final sloganFamily =
        provider.getFontForElement(2) ?? _currentLogoState.sloganFont;

    Size _measure(String text, double size, String? family) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, fontFamily: family),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return tp.size;
    }

    final double logoSize = _currentLogoState.logoSize;
    final Size companySize = _measure(
      _currentLogoState.companyName ?? '',
      _currentLogoState.companyNameSize,
      companyFamily,
    );
    final Size sloganSize = _measure(
      _currentLogoState.sloganName ?? '',
      _currentLogoState.sloganSize,
      sloganFamily,
    );

    const double spacing1 = 16;
    const double spacing2 = 12;
    final totalHeight =
        logoSize + spacing1 + companySize.height + spacing2 + sloganSize.height;
    final startY = (canvasSize.height - totalHeight) / 2;

    final logoX = (canvasSize.width - logoSize) / 2;
    final companyX = (canvasSize.width - companySize.width) / 2;
    final sloganX = (canvasSize.width - sloganSize.width) / 2;

    setState(() {
      _currentLogoState = _currentLogoState.copyWith(
        logoPosition: Offset(logoX, startY),
        companyNamePosition: Offset(companyX, startY + logoSize + spacing1),
        sloganPosition: Offset(
          sloganX,
          startY + logoSize + spacing1 + companySize.height + spacing2,
        ),
      );
      _didCenterOnOpen = true;
    });

    provider.updateLogoState(_currentLogoState);
  }

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
    final theme = Theme.of(context);
    final shapeText =
        selectedShapeName.isNotEmpty && selectedShapeName != "none"
            ? " in ${selectedShapeName} shape"
            : "";

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder:
              (ctx, setStateDialog) => AlertDialog(
                backgroundColor: theme.dialogBackgroundColor,
                title: const Text('Save Logo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'png',
                      groupValue: _selectedSaveFormat,
                      onChanged:
                          (v) => setStateDialog(() {
                            _selectedSaveFormat = v!;
                          }),
                      title: const Text('PNG'),
                      secondary: const Icon(Icons.image_outlined),
                      dense: true,
                    ),
                    RadioListTile<String>(
                      value: 'jpg',
                      groupValue: _selectedSaveFormat,
                      onChanged:
                          (v) => setStateDialog(() {
                            _selectedSaveFormat = v!;
                          }),
                      title: const Text('JPG'),
                      secondary: const Icon(
                        Icons.photo_size_select_actual_outlined,
                      ),
                      dense: true,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final adManager = Provider.of<SmartInterstitialManager>(
                        context,
                        listen: false,
                      );
                      adManager.onDownloadAttempted();
                      adManager.onButtonClick('save_logo');

                      await _saveLogoAsFormat(_selectedSaveFormat); // png | jpg

                      if (context.mounted) {
                        Navigator.of(dialogCtx).pop();
                      }

                      Provider.of<InterestitialAdProvider>(
                        context,
                        listen: false,
                      ).showAd();
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
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
      companyNameFont: widget.companyFontFamily ?? 'Roboto',
      sloganFont: widget.sloganFontFamily ?? 'Roboto',
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      provider.seedInitialFonts(
        company: widget.companyFontFamily,
        slogan: widget.sloganFontFamily,
      );
      provider.updateLogoState(_currentLogoState);
      await _centerCanvasOnOpen();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
        body: OrientationBuilder(
          builder:
              (context, orientation) =>
                  orientation == Orientation.portrait
                      ? buildPortrait()
                      : buildLandscape(),
        ),
        bottomNavigationBar: LogoBottomNavBar(
          selectedIndex: selectedIndex,
          onItemSelected: _handleBottomNavTap,
          hasTapped: true,
        ),
      ),
    );
  }

  // Widget buildLandscape() {
  //   final theme = Theme.of(context);
  //   return Row(
  //     children: [
  //       SizedBox(width: 100),
  //       Expanded(
  //         child: Stack(
  //           children: [
  //             RepaintBoundary(
  //               key: _canvasKey,
  //               child: GestureDetector(
  //                 behavior: HitTestBehavior.translucent,
  //                 onTap: () {
  //                   setState(() {
  //                     selectedElement = null;
  //                     isMovementPanelVisible = false;
  //                   });
  //                 },
  //                 child: Consumer<SelectedColorProvider>(
  //                   builder: (context, provider, _) {
  //                     final logoState =
  //                         provider.getCurrentLogoState() ?? _currentLogoState;
  //                     return LogoCanvas(
  //                       selectedShapeName: selectedShapeName,
  //                       logoState: logoState,
  //                       svgLogo: widget.svgLogo,
  //                       companyName: widget.companyName,
  //                       sloganName: widget.sloganName,
  //                       showGrid: _showGrid,
  //                       gridOpacity: _gridOpacity,
  //                       isEditingMode: true,
  //                       selectedElementId: selectedElement,
  //                       highlightedHorizontalGridLineIndex:
  //                           _highlightedHorizontalGridLineIndex,
  //                       highlightedVerticalGridLineIndex:
  //                           _highlightedVerticalGridLineIndex,
  //                       isLayersRibbonExtended: _isLayersPanelVisible,
  //                       onToggleGrid:
  //                           () => setState(() => _showGrid = !_showGrid),
  //                       onToggleLayersRibbon:
  //                           () => setState(
  //                             () =>
  //                                 _isLayersPanelVisible =
  //                                     !_isLayersPanelVisible,
  //                           ),
  //                       onElementPanStart: _onPanStart,
  //                       onElementPanUpdate: _updateElementPosition,
  //                       onElementPanEnd: _onPanEnd,
  //                       onElementTap: _elementSelect,
  //                       onElementDelete: _deleteElement,
  //                       onElementSplit: _splitElement,
  //                       onElementRotateTap: _rotateElementByTap,
  //                       onElementRotatePanStart: _onRotatePanStart,
  //                       onElementRotatePanUpdate: _onRotatePanUpdate,
  //                       onElementRotatePanEnd: _onPanEnd,
  //                       onElementResizeTap: _resizeElementByTap,
  //                       onElementResizePanStart: _onResizePanStart,
  //                       onElementResizePanUpdate: _onResizePanUpdate,
  //                       onElementResizePanEnd: _onPanEnd,
  //                       isCheckerboardActive: true,
  //                       checkerboardOpacity: checkerboardOpacity,
  //                       isCheckerboardVisible: isCheckerboardVisible,
  //                       lockedElements: logoState.lockedElements,
  //                       elementOrder: logoState.elementOrder,
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),

  //             Positioned(
  //               top: 20,
  //               right: 0,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     _showGrid = !_showGrid;
  //                   });
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text(
  //                         _showGrid ? 'Grid enabled' : 'Grid disabled',
  //                       ),
  //                       duration: const Duration(milliseconds: 1000),
  //                     ),
  //                   );
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 16,
  //                     vertical: 8,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color:
  //                         Theme.of(context).brightness == Brightness.dark
  //                             ? Colors.grey[800]
  //                             : Colors.grey[300],
  //                     borderRadius: const BorderRadius.only(
  //                       topLeft: Radius.circular(25.0),
  //                       bottomLeft: Radius.circular(25.0),
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color:
  //                             Theme.of(context).brightness == Brightness.dark
  //                                 ? Colors.black.withOpacity(0.5)
  //                                 : Colors.black.withOpacity(0.2),
  //                         blurRadius: 8,
  //                         offset: const Offset(-2, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Icon(
  //                     _showGrid ? Icons.grid_off : Icons.grid_on,
  //                     color:
  //                         Theme.of(context).brightness == Brightness.dark
  //                             ? Colors.white
  //                             : Colors.black87,
  //                     size: 28,
  //                   ),
  //                 ),
  //               ),
  //             ),

  //             Positioned(
  //               top: 20,
  //               left: 0,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     _isLayersPanelVisible = !_isLayersPanelVisible;
  //                   });
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 16,
  //                     vertical: 8,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color:
  //                         Theme.of(context).brightness == Brightness.dark
  //                             ? Colors.grey[800]
  //                             : Colors.grey[300],
  //                     borderRadius: const BorderRadius.only(
  //                       topRight: Radius.circular(25.0),
  //                       bottomRight: Radius.circular(25.0),
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color:
  //                             Theme.of(context).brightness == Brightness.dark
  //                                 ? Colors.black.withOpacity(0.5)
  //                                 : Colors.black.withOpacity(0.2),
  //                         blurRadius: 8,
  //                         offset: const Offset(2, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Icon(
  //                     Icons.layers,
  //                     color:
  //                         Theme.of(context).brightness == Brightness.dark
  //                             ? Colors.white
  //                             : Colors.black87,
  //                     size: 28,
  //                   ),
  //                 ),
  //               ),
  //             ),

  //             if (_isLayersPanelVisible)
  //               Positioned(
  //                 top: 30,
  //                 right: 70,
  //                 child: Container(
  //                   height: 40,
  //                   width: 100,
  //                   decoration: BoxDecoration(
  //                     color:
  //                         Theme.of(context).brightness == Brightness.dark
  //                             ? Colors.grey[800]!.withOpacity(0.95)
  //                             : Colors.grey[200]!.withOpacity(0.95),
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       IconButton(
  //                         icon: Icon(
  //                           Icons.arrow_back_ios_new,
  //                           size: 20,
  //                           color:
  //                               Theme.of(context).brightness == Brightness.dark
  //                                   ? Colors.white
  //                                   : Colors.black87,
  //                         ),
  //                         onPressed: () {
  //                           setState(() {
  //                             _isLayersPanelVisible = !_isLayersPanelVisible;
  //                           });
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),

  //             AnimatedPositioned(
  //               duration: const Duration(milliseconds: 300),
  //               curve: Curves.easeInOut,
  //               top: 20,
  //               left: _isLayersPanelVisible ? 0 : -300,
  //               child: Consumer<SelectedColorProvider>(
  //                 builder: (context, provider, _) {
  //                   final logoState =
  //                       provider.getCurrentLogoState() ?? _currentLogoState;
  //                   return LayersPanel(
  //                     logoState: logoState,
  //                     svgLogo: widget.svgLogo,
  //                     onClose:
  //                         () => setState(() => _isLayersPanelVisible = false),
  //                     onToggleLock: (id) => provider.toggleLock(id),
  //                     onToggleLockAll:
  //                         (shouldLock) => provider.toggleLockAll(shouldLock),
  //                     onReorder: (id, moveUp) {
  //                       if (moveUp) {
  //                         provider.moveElementUp(id);
  //                       } else {
  //                         provider.moveElementDown(id);
  //                       }
  //                       final s = provider.getCurrentLogoState();
  //                       if (s != null) setState(() => _currentLogoState = s);
  //                     },
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Column(
  //         children: [
  //           Container(
  //             height: 300,
  //             color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
  //           ),
  //         ],
  //       ),

  //       if (tabToolbarIndex != -1 &&
  //           (!isMovementPanelVisible || selectedElement == null))
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           bottom: kBottomNavigationBarHeight - 44,
  //           top: MediaQuery.sizeOf(context).height.toDouble() * 0.52,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               SingleChildScrollView(
  //                 child: AnimatedContainer(
  //                   duration: const Duration(milliseconds: 300),
  //                   height: 200,
  //                   child: _buildToolbarForTabs(tabToolbarIndex),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       if (tabToolbarIndex != -1 &&
  //           (!isMovementPanelVisible || selectedElement == null))
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           top: MediaQuery.sizeOf(context).height * 0.48 - 30,
  //           child: Center(
  //             child: GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   tabToolbarIndex = -1;
  //                 });
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(16),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black26,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                 child: Icon(
  //                   Icons.keyboard_arrow_down,
  //                   size: 32,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),

  //       if (tabToolbarIndex == -1 &&
  //           (selectedElement == null || !isMovementPanelVisible))
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           bottom: kBottomNavigationBarHeight + 8,
  //           child: Center(
  //             child: GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   tabToolbarIndex = selectedIndex;
  //                 });
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.blue,
  //                   borderRadius: BorderRadius.circular(16),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black26,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                 child: Icon(
  //                   Icons.keyboard_arrow_up,
  //                   size: 32,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (selectedElement != null && isMovementPanelVisible)
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           bottom: MediaQuery.of(context).size.width * 0.52 + 30,
  //           child: Center(
  //             child: GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   isMovementPanelVisible = false;
  //                   selectedElement = null;
  //                 });
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(16),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black26,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                 child: Icon(
  //                   Icons.keyboard_arrow_down,
  //                   size: 32,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),

  //       if (selectedElement != null && isMovementPanelVisible)
  //         Positioned(
  //           bottom: 0,
  //           left: 0,
  //           right: 0,
  //           child: MovementPanel(
  //             isVisible: isMovementPanelVisible,
  //             onDirectionPressed: (String direction) {
  //               const double moveAmount = 5.0;
  //               Offset delta;
  //               switch (direction) {
  //                 case 'up':
  //                   delta = const Offset(0, -moveAmount);
  //                   break;
  //                 case 'down':
  //                   delta = const Offset(0, moveAmount);
  //                   break;
  //                 case 'left':
  //                   delta = const Offset(-moveAmount, 0);
  //                   break;
  //                 case 'right':
  //                   delta = const Offset(moveAmount, 0);
  //                   break;
  //                 default:
  //                   delta = Offset.zero;
  //               }
  //               setState(() {});
  //               _updateElementPosition(selectedElement!, delta);
  //             },
  //             onDuplicatePressed: () {
  //               print('Duplicate called for $selectedElement');
  //               duplicateSelectedElement(selectedElement!);
  //             },
  //             onBringToFrontPressed:
  //                 () => bringToFront(selectedElement!, _currentLogoState),
  //             onSendToBackPressed:
  //                 () => sendToBack(selectedElement!, _currentLogoState),
  //             selectedElementId: selectedElement,
  //             onClose: () {},
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget buildLandscape() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 80,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolbarButton(Icons.grid_on, 'Grid', () {
                      setState(() => _showGrid = !_showGrid);
                    }),
                    _buildToolbarButton(Icons.layers, 'Layers', () {
                      setState(
                        () => _isLayersPanelVisible = !_isLayersPanelVisible,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Canvas
              RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      selectedElement = null;
                      isMovementPanelVisible = false;
                      tabToolbarIndex = selectedIndex;
                    });
                  },
                  child: Consumer<SelectedColorProvider>(
                    builder: (context, provider, _) {
                      final logoState =
                          provider.getCurrentLogoState() ?? _currentLogoState;
                      return LogoCanvas(
                        selectedShapeName: selectedShapeName,
                        logoState: logoState,
                        svgLogo: widget.svgLogo,
                        companyName: widget.companyName,
                        sloganName: widget.sloganName,
                        showGrid: _showGrid,
                        gridOpacity: _gridOpacity,
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
                        isCheckerboardActive: isCheckerboardActive,
                        checkerboardOpacity: checkerboardOpacity,
                        isCheckerboardVisible: isCheckerboardVisible,
                        lockedElements: logoState.lockedElements,
                        elementOrder: logoState.elementOrder,
                      );
                    },
                  ),
                ),
              ),

              if (_isLayersPanelVisible)
                Positioned(
                  top: 20,
                  left: 20,
                  width: 280,
                  height: MediaQuery.of(context).size.height - 120,
                  child: Consumer<SelectedColorProvider>(
                    builder: (context, provider, _) {
                      final logoState =
                          provider.getCurrentLogoState() ?? _currentLogoState;
                      return LayersPanel(
                        logoState: logoState,
                        svgLogo: widget.svgLogo,
                        onClose:
                            () => setState(() => _isLayersPanelVisible = false),
                        onToggleLock: (id) => provider.toggleLock(id),
                        onToggleLockAll:
                            (shouldLock) => provider.toggleLockAll(shouldLock),
                        onReorder: (id, moveUp) {
                          if (moveUp) {
                            provider.moveElementUp(id);
                          } else {
                            provider.moveElementDown(id);
                          }
                          final s = provider.getCurrentLogoState();
                          if (s != null) setState(() => _currentLogoState = s);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        Container(
          width: 400,
          height: double.infinity,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          child: Column(
            children: [
              if (selectedElement != null && isMovementPanelVisible)
                Container(
                  height: 300,
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.control_camera,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Element Controls',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedElement = null;
                                  isMovementPanelVisible = false;
                                  tabToolbarIndex = selectedIndex;
                                });
                              },
                              tooltip: 'Close Controls',
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: MovementPanel(
                          isVisible: true,
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
                            _updateElementPosition(selectedElement!, delta);
                          },
                          onDuplicatePressed:
                              () => duplicateSelectedElement(selectedElement!),
                          onBringToFrontPressed:
                              () => bringToFront(
                                selectedElement!,
                                _currentLogoState,
                              ),
                          onSendToBackPressed:
                              () => sendToBack(
                                selectedElement!,
                                _currentLogoState,
                              ),
                          selectedElementId: selectedElement,
                          onClose:
                              () => setState(() {
                                isMovementPanelVisible = false;
                                selectedElement = null;
                                tabToolbarIndex = selectedIndex;
                              }),
                        ),
                      ),
                    ],
                  ),
                ),

              if (selectedElement == null && tabToolbarIndex != -1)
                Container(
                  height: 350,
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getToolbarIcon(tabToolbarIndex),
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getToolbarTitle(tabToolbarIndex),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  tabToolbarIndex = -1;
                                });
                              },
                              tooltip: 'Close Panel',
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: _buildToolbarForTabs(tabToolbarIndex),
                        ),
                      ),
                    ],
                  ),
                ),

              if (selectedElement == null && tabToolbarIndex == -1)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap an element to edit\nor use bottom toolbar',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getToolbarIcon(int index) {
    switch (index) {
      case 0:
        return Icons.layers;
      case 3:
        return Icons.auto_awesome;
      case 4:
        return Icons.palette;
      default:
        return Icons.build;
    }
  }

  Widget _buildToolbarButton(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: theme.iconTheme.color),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPortrait() {
    final theme = Theme.of(context);

    return Stack(
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
                            gridOpacity: _gridOpacity,
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
                            lockedElements: logoState.lockedElements,
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.dark
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
                              Theme.of(context).brightness == Brightness.dark
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
                              Theme.of(context).brightness == Brightness.dark
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
                              Theme.of(context).brightness == Brightness.dark
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
                              Theme.of(context).brightness == Brightness.dark
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
                            provider.getCurrentLogoState() ?? _currentLogoState;
                        return LayersPanel(
                          logoState: logoState,
                          svgLogo: widget.svgLogo,
                          onClose:
                              () =>
                                  setState(() => _isLayersPanelVisible = false),
                          onToggleLock: (id) => provider.toggleLock(id),
                          onToggleLockAll:
                              (shouldLock) =>
                                  provider.toggleLockAll(shouldLock),
                          onReorder: (id, moveUp) {
                            if (moveUp) {
                              provider.moveElementUp(id);
                            } else {
                              provider.moveElementDown(id);
                            }
                            final s = provider.getCurrentLogoState();
                            if (s != null)
                              setState(() => _currentLogoState = s);
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
                Container(
                  height: 300,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),

        if (tabToolbarIndex != -1 &&
            (!isMovementPanelVisible || selectedElement == null))
          Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight - 44,
            top: MediaQuery.sizeOf(context).height.toDouble() * 0.52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 200,
                    child: _buildToolbarForTabs(tabToolbarIndex),
                  ),
                ),
              ],
            ),
          ),
        if (tabToolbarIndex != -1 &&
            (!isMovementPanelVisible || selectedElement == null))
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.sizeOf(context).height * 0.48 - 30,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    tabToolbarIndex = -1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 32,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

        if (tabToolbarIndex == -1 &&
            (selectedElement == null || !isMovementPanelVisible))
          Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight + 8,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    tabToolbarIndex = selectedIndex;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (selectedElement != null && isMovementPanelVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.width * 0.52 + 30,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isMovementPanelVisible = false;
                    selectedElement = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 32,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

        if (selectedElement != null && isMovementPanelVisible)
          Positioned(
            bottom: 0,
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
              onClose: () {},
            ),
          ),
      ],
    );
  }

  Widget _buildCustomUndoRedoWidget() {
    final theme = Theme.of(context);
    return Consumer<UndoProvider>(
      builder: (context, undoProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.undo,
                size: 32,
                color:
                    undoProvider.canUndo
                        ? theme.appBarTheme.actionsIconTheme?.color
                        : Colors.grey,
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
                color:
                    undoProvider.canRedo
                        ? theme.appBarTheme.actionsIconTheme?.color
                        : Colors.grey,
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

  void _showSaveSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: Row(
          children: [
            const Text('Save as:'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => _saveLogoAsFormat('png'),
              child: const Text('PNG'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _saveLogoAsFormat('jpg'),
              child: const Text('JPG'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLogoAsFormat(String format) async {
    final wasMovementPanelVisible = isMovementPanelVisible;
    final previousSelectedElement = selectedElement;
    final wasGridVisible = _showGrid;

    try {
      setState(() {
        selectedElement = null;
        isMovementPanelVisible = false;
        _showGrid = false;
      });
      Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      ).clearSelection();
      await Future.delayed(const Duration(milliseconds: 120));
      await WidgetsBinding.instance.endOfFrame;

      final isGranted = await _requestGalleryPermission();
      if (!isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      final ui.Image captured = await _captureCanvasImage(_canvasKey);

      final ui.Image finalImage =
          (selectedShapeName.isNotEmpty && selectedShapeName != 'none')
              ? await _applyShapeMask(captured, selectedShapeName)
              : captured;

      final Uint8List bytes = await _encodeImageBytes(finalImage, format);

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.$format';
      final file = await File(path).writeAsBytes(bytes);
      final saved = await GallerySaver.saveImage(
        file.path,
        albumName: 'LogoMaker',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved == true ? 'Saved as .$format' : 'Save failed'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() {
        selectedElement = previousSelectedElement;
        isMovementPanelVisible = wasMovementPanelVisible;
        _showGrid = wasGridVisible;
      });
      if (previousSelectedElement != null) {
        Provider.of<SelectedColorProvider>(
          context,
          listen: false,
        ).setSelectedElement(previousSelectedElement);
      }
    }
  }

  Future<ui.Image> _captureCanvasImage(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Canvas not ready');
    }
    return await boundary.toImage(pixelRatio: 3.0);
  }

  Future<Uint8List> _encodeImageBytes(ui.Image image, String format) async {
    final ByteData? pngData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (pngData == null) throw Exception('Failed to get bytes from canvas');
    final Uint8List pngBytes = pngData.buffer.asUint8List();

    if (format.toLowerCase() == 'png') return pngBytes;

    final img.Image? decoded = img.decodeImage(pngBytes);
    if (decoded == null)
      throw Exception('Failed to decode PNG for JPG conversion');
    final img.Image whiteBg = img.Image(
      width: decoded.width,
      height: decoded.height,
    );
    img.fill(whiteBg, color: img.ColorUint8.rgb(255, 255, 255));
    img.compositeImage(whiteBg, decoded);
    return Uint8List.fromList(img.encodeJpg(whiteBg, quality: 92));
  }

  Widget _buildToolbarForTabs(int index) {
    final theme = Theme.of(context);

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
      case 3:
        return _buildEffectPanel();
      case 4:
        return _buildPaletteSelection();
      default:
        return SizedBox.shrink();
    }
  }

  String _getToolbarTitle(int index) {
    switch (index) {
      case 0:
        return 'Background & Shape';
      case 3:
        return 'Effects';
      case 4:
        return 'Color Palettes';
      default:
        return 'Tools';
    }
  }

  Widget _buildPaletteSelection() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface.withOpacity(0.8),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            "Color Palettes",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
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

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied palette ${index + 1}'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            if (context.read<UndoProvider>().canUndo) _undo();
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 80,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                        width: isSelected ? 3 : 1,
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
                                        height: 25,
                                        width: double.infinity,
                                        color: color,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cardColor,
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
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

  void bringToFront(int elementId, dynamic _) {
    final p = Provider.of<SelectedColorProvider>(context, listen: false);
    p.bringToFront(elementId);
    final s = p.getCurrentLogoState();
    if (s != null) setState(() => _currentLogoState = s);
  }

  void sendToBack(int elementId, dynamic _) {
    final p = Provider.of<SelectedColorProvider>(context, listen: false);
    p.sendToBack(elementId);
    final s = p.getCurrentLogoState();
    if (s != null) setState(() => _currentLogoState = s);
  }

  Widget _buildEffectPanel() {
    final theme = Theme.of(context);

    Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
      final ByteData data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    }

    void _onEffectImageSelectedWithUndo(String imagePath) {
      _saveUndoState('Apply effect: ${imagePath.split('/').last}');

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );

      loadUiImageFromAsset(imagePath).then((uiImage) {
        colorProvider.setBackgroundImage(uiImage, null);
      });
    }

    void _onEffectImageRemovedWithUndo() {
      _saveUndoState('Remove background effect');

      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      colorProvider.setBackgroundImage(null, null);
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Text(
              "Background Effects",
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Opacity",
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            Row(
              children: [
                Icon(Icons.opacity, color: theme.iconTheme.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Consumer<SelectedColorProvider>(
                    builder: (context, provider, _) {
                      return Slider(
                        value: provider.backgroundOpacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label:
                            (provider.backgroundOpacity * 100).round().toString(),
                        activeColor: theme.colorScheme.primary,
                        onChangeStart: (value) {
                          _saveUndoState('Start changing background opacity');
                        },
                        onChanged: (value) {
                          provider.setBackgroundOpacity(value);
                        },
                        onChangeEnd: (value) {
                          _saveUndoState(
                            'Set background opacity to ${(value * 100).round()}%',
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
                        "${(provider.backgroundOpacity * 100).round()}%",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Effect Images",
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _onEffectImageRemovedWithUndo,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Icon(
                          Icons.close,
                          color: theme.iconTheme.color,
                          size: 30,
                        ),
                      ),
                    );
                  }
      
                  final imagePath = imageList[index - 1];
                  return GestureDetector(
                    onTap: () => _onEffectImageSelectedWithUndo(imagePath),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUndoState(String action) {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    if (!undoProvider.isUndoRedoInProgress) {
      colorProvider.updateLogoState(_currentLogoState);
      final currentState = colorProvider.captureCurrentState();
      currentState['selectedShapeName'] = selectedShapeName;
      currentState['selectedElement'] = selectedElement;
      currentState['tabToolbarIndex'] = tabToolbarIndex;
      currentState['selectedIndex'] = selectedIndex;
      currentState['isMovementPanelVisible'] = isMovementPanelVisible;

      undoProvider.saveState(action: action, state: currentState);

      print('✅ Saved undo state: $action');
    }
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

    if (!undoProvider.canUndo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to undo!'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    final currentState = colorProvider.captureCurrentState();
    currentState['selectedShapeName'] = selectedShapeName;
    currentState['selectedElement'] = selectedElement;
    currentState['tabToolbarIndex'] = tabToolbarIndex;
    currentState['selectedIndex'] = selectedIndex;
    currentState['isMovementPanelVisible'] = isMovementPanelVisible;

    final previousState = undoProvider.undo();

    if (previousState != null) {
      colorProvider.restoreFromState(previousState.data);

      final restoredLogoState = colorProvider.getCurrentLogoState();

      if (restoredLogoState != null) {
        setState(() {
          _currentLogoState = restoredLogoState;

          selectedElement = previousState.data['selectedElement'];
          selectedShapeName = previousState.data['selectedShapeName'] ?? '';
          tabToolbarIndex = previousState.data['tabToolbarIndex'] ?? 0;
          selectedIndex = previousState.data['selectedIndex'] ?? 0;
          isMovementPanelVisible =
              previousState.data['isMovementPanelVisible'] ?? false;

          _clearGridAlignment();
        });

        colorProvider.notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undo: ${previousState.action}'),
          duration: const Duration(milliseconds: 800),
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

    if (!undoProvider.canRedo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to redo!'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    final currentState = colorProvider.captureCurrentState();
    currentState['selectedShapeName'] = selectedShapeName;
    currentState['selectedElement'] = selectedElement;
    currentState['tabToolbarIndex'] = tabToolbarIndex;
    currentState['selectedIndex'] = selectedIndex;
    currentState['isMovementPanelVisible'] = isMovementPanelVisible;

    final nextState = undoProvider.redo();

    if (nextState != null) {
      colorProvider.restoreFromState(nextState.data);

      final restoredLogoState = colorProvider.getCurrentLogoState();

      if (restoredLogoState != null) {
        setState(() {
          _currentLogoState = restoredLogoState;

          selectedElement = nextState.data['selectedElement'];
          selectedShapeName = nextState.data['selectedShapeName'] ?? '';
          tabToolbarIndex = nextState.data['tabToolbarIndex'] ?? 0;
          selectedIndex = nextState.data['selectedIndex'] ?? 0;
          isMovementPanelVisible =
              nextState.data['isMovementPanelVisible'] ?? false;

          _clearGridAlignment();
        });

        colorProvider.notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redo: ${nextState.action}'),
          duration: const Duration(milliseconds: 800),
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

    if (index == 2) {
      // Text addition
      final result = await Navigator.of(
        context,
      ).push<String>(_createSlideRoute());

      if (result != null && result.isNotEmpty) {
        _saveUndoState('Add text element: "$result"');

        final provider = Provider.of<SelectedColorProvider>(
          context,
          listen: false,
        );
        final family =
            provider.getFontForElement(1) ??
            _currentLogoState.companyNameFont ??
            'Roboto';

        setState(() {
          final newTextElement = CustomTextElement(
            text: result,
            position: _getCanvasCenter() ?? const Offset(150, 150),
            size: 22,
            rotation: 0,
            fontFamily: family,
            isVisible: true,
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

        Provider.of<SelectedColorProvider>(
          context,
          listen: false,
        ).updateLogoState(_currentLogoState);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added text: "$result"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                if (context.read<UndoProvider>().canUndo) _undo();
              },
            ),
          ),
        );
      }
    }

    if (index == 1) {
      // Art selection
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
        final fileName = selectedImagePath.split('/').last;
        _saveUndoState('Add art: $fileName');
        _addImageToCanvas(selectedImagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $fileName'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                if (context.read<UndoProvider>().canUndo) _undo();
              },
            ),
          ),
        );
      }
    }

    if (index == 5) {
      // Custom image from camera/gallery
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
          _saveUndoState('Add custom image');

          final imageIndex = _currentLogoState.customImages.length;
          final newImage = CustomImageElement(
            path: pickedFile.path,
            position: _getCanvasCenter() ?? const Offset(100, 100),
            size: 100,
            rotation: 0,
          );

          setState(() {
            _currentLogoState = _currentLogoState.copyWith(
              customImages: [..._currentLogoState.customImages, newImage],
              elementOrder: [
                ..._currentLogoState.elementOrder,
                200 + imageIndex,
              ],
            );
          });

          Provider.of<SelectedColorProvider>(
            context,
            listen: false,
          ).updateLogoState(_currentLogoState);

          final pickedName = pickedFile.path.split('/').last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $pickedName'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
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
    print("Selected Element Id: $id");
    _saveUndoState('Select element $id');

    setState(() {
      selectedElement = id;
      isMovementPanelVisible = true;
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        tabToolbarIndex = -1;
      }
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

      // Handle different element types
      if (id >= 100 && id < 200) {
        // Custom text elements
        final index = id - 100;
        if (index < _currentLogoState.customTexts.length) {
          final updatedCustomTexts = List<CustomTextElement>.from(
            _currentLogoState.customTexts,
          )..removeAt(index);
          newState = newState.copyWith(customTexts: updatedCustomTexts);
        }
      } else if (id >= 200 && id < 300) {
        // Custom image elements
        final index = id - 200;
        if (index < _currentLogoState.customImages.length) {
          final updatedCustomImages = List<CustomImageElement>.from(
            _currentLogoState.customImages,
          )..removeAt(index);
          newState = newState.copyWith(customImages: updatedCustomImages);
        }
      } else if (id >= 300 && id < 400) {
        // Custom SVG elements
        final index = id - 300;
        if (index < _currentLogoState.customSVGs.length) {
          final updatedCustomSVGs = List<CustomSvgElement>.from(
            _currentLogoState.customSVGs,
          )..removeAt(index);
          newState = newState.copyWith(customSVGs: updatedCustomSVGs);
        }
      } else {
        // Built-in elements
        switch (id) {
          case 0:
            newState = newState.copyWith(isLogoVisible: false);
            break;
          case 1:
            newState = newState.copyWith(isCompanyNameVisible: false);
            break;
          case 2:
            newState = newState.copyWith(isSloganVisible: false);
            break;
          default:
            message = 'Cannot delete this element.';
        }
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
    if (_isElementLocked(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Element is locked'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }

    _saveUndoState('Start moving element $id');
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
      // Update position based on element type
      if (id >= 100 && id < 200) {
        // Custom text elements
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
        // Custom image elements
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
        // Custom SVG elements
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
        // Built-in elements
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
    _saveUndoState('Finish moving element $id');
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

  Offset? _getCanvasCenter() {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      return Offset(size.width / 2, size.height / 2);
    }
    return null;
  }

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
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final logoState = provider.getCurrentLogoState() ?? _currentLogoState;
    TextStyle _applyFont(String? family, TextStyle base) {
      if (family == null || family.isEmpty) return base;
      return base.copyWith(fontFamily: family);
    }

    TextStyle _familyStyle(String? family, double size) {
      final base = TextStyle(fontSize: size, color: Colors.black);
      return _applyFont(family, base);
    }

    if (id == 1) {
      final family = provider.getFontForElement(1) ?? logoState.companyNameFont;
      final style = _familyStyle(family, logoState.companyNameSize);
      return TextSizeUtil.getTextSize(logoState.companyName ?? '', style);
    }

    if (id == 2) {
      final family = provider.getFontForElement(2) ?? logoState.sloganFont;
      final style = _familyStyle(family, logoState.sloganSize);
      return TextSizeUtil.getTextSize(logoState.sloganName ?? '', style);
    }

    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < logoState.customTexts.length) {
        final el = logoState.customTexts[index];
        final size = provider.getSizeForElement(id) ?? el.size;
        final family =
            provider.getFontForElement(id) ??
            el.fontFamily ??
            provider.getFontForElement(1) ??
            logoState.companyNameFont;
        final style = _familyStyle(family, size);
        return TextSizeUtil.getTextSize(el.text, style);
      }
      return const Size(100, 100);
    }

    // Custom Image 200–299
    if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < logoState.customImages.length) {
        final sizeValue = logoState.customImages[index].size ?? 100;
        return Size(sizeValue, sizeValue);
      }
      return const Size(100, 100);
    }

    // Custom SVG 300–399
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < logoState.customSVGs.length) {
        final sizeValue = logoState.customSVGs[index].size;
        return Size(sizeValue, sizeValue);
      }
      return const Size(100, 100);
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

  bool _isElementLocked(int id) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final currentState = provider.getCurrentLogoState() ?? _currentLogoState;
    return currentState.lockedElements.contains(id);
  }

  void duplicateSelectedElement(int id) {
    _saveUndoState('Duplicate element $id');

    setState(() {
      final logoState = _currentLogoState;
      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );

      final fontStyle = provider.getFontStyleForElement(id);
      final outlineColor = provider.getOutlineColor(id);
      final outlineWidth = provider.getOutlineWidth(id);
      final shadowColor = provider.getShadowColorForElement(id);
      final shadowOffsetX = provider.getShadowOffsetXForElement(id);
      final shadowOffsetY = provider.getShadowOffsetYForElement(id);
      final fontFamily =
          provider.getFontForElement(id) ??
          provider.getFontForElement(1) ??
          logoState.companyNameFont ??
          'Roboto';
      final color = provider.getElementColor(id);
      final opacity = provider.opacity;
      final size = provider.getSizeForElement(id) ?? _getElementSize(id);
      final rotation =
          provider.getRotationForElement(id) ?? _getElementRotation(id);

      if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index >= 0 && index < logoState.customTexts.length) {
          final original = logoState.customTexts[index];
          final duplicated = CustomTextElement(
            text: original.text,
            position: original.position + const Offset(20, 20),
            size: size,
            rotation: rotation,
            color: color ?? original.color ?? Colors.black,
            fontFamily: fontFamily,
            isBold: fontStyle.isBold,
            isItalic: fontStyle.isItalic,
            isUnderline: fontStyle.isUnderline,
            outlineColor: outlineColor ?? original.outlineColor,
            outlineWidth: outlineWidth ?? original.outlineWidth,
            shadowColor: shadowColor ?? original.shadowColor,
            shadowOffsetX: shadowOffsetX ?? original.shadowOffsetX,
            shadowOffsetY: shadowOffsetY ?? original.shadowOffsetY,
            opacity: opacity,
            isVisible: true,
          );

          final newCustomTexts = List<CustomTextElement>.from(
            logoState.customTexts,
          )..add(duplicated);
          final newElementId = 100 + newCustomTexts.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);

          _currentLogoState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );
          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated text element'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index >= 0 && index < logoState.customImages.length) {
          final original = logoState.customImages[index];
          final duplicated = CustomImageElement(
            path: original.path,
            position: original.position + const Offset(20, 20),
            size: size,
            rotation: rotation,
            isAsset: original.isAsset ?? false,
            isVisible: true,
            opacity: opacity,
          );

          final newCustomImages = List<CustomImageElement>.from(
            logoState.customImages,
          )..add(duplicated);
          final newElementId = 200 + newCustomImages.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);

          _currentLogoState = logoState.copyWith(
            customImages: newCustomImages,
            elementOrder: newElementOrder,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated image element'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id >= 300 && id < 400) {
        final index = id - 300;
        if (index >= 0 && index < logoState.customSVGs.length) {
          final original = logoState.customSVGs[index];
          final duplicated = CustomSvgElement(
            svgString: original.svgString,
            position: original.position + const Offset(20, 20),
            size: size,
            rotation: rotation,
            color: color ?? original.color,
            opacity: opacity,
            isVisible: true,
            outlineColor: outlineColor ?? original.outlineColor,
            outlineWidth: outlineWidth ?? original.outlineWidth,
          );

          final newCustomSVGs = List<CustomSvgElement>.from(
            logoState.customSVGs,
          )..add(duplicated);
          final newElementId = 300 + newCustomSVGs.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);

          _currentLogoState = logoState.copyWith(
            customSVGs: newCustomSVGs,
            elementOrder: newElementOrder,
          );

          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated SVG element'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 0) {
        if (logoState.svgLogo != null && logoState.isLogoVisible) {
          final duplicated = CustomSvgElement(
            svgString: logoState.svgLogo!,
            position: logoState.logoPosition + const Offset(20, 20),
            size: size,
            color: color ?? logoState.logoColor,
            rotation: rotation,
            opacity: opacity,
            isVisible: true,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
          );

          final newCustomSVGs = List<CustomSvgElement>.from(
            logoState.customSVGs,
          )..add(duplicated);
          final newElementId = 300 + newCustomSVGs.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);

          _currentLogoState = logoState.copyWith(
            customSVGs: newCustomSVGs,
            elementOrder: newElementOrder,
          );

          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated main logo'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 1) {
        if (logoState.companyName != null && logoState.isCompanyNameVisible) {
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

          _currentLogoState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );

          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated company name'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 2) {
        if (logoState.sloganName != null && logoState.isSloganVisible) {
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

          _currentLogoState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );

          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated slogan'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 3) {
        if (logoState.svgLogo != null && logoState.isLogo2Visible) {
          final duplicated = CustomSvgElement(
            svgString: logoState.svgLogo!,
            position:
                (logoState.logo2Position ?? logoState.logoPosition) +
                const Offset(20, 20),
            size: logoState.logo2Size ?? size,
            color: color ?? logoState.logoColor,
            rotation: logoState.logo2Rotation ?? 0,
            opacity: opacity,
            isVisible: true,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
          );

          final newCustomSVGs = List<CustomSvgElement>.from(
            logoState.customSVGs,
          )..add(duplicated);
          final newElementId = 300 + newCustomSVGs.length - 1;
          final newElementOrder = List<int>.from(logoState.elementOrder)
            ..add(newElementId);

          _currentLogoState = logoState.copyWith(
            customSVGs: newCustomSVGs,
            elementOrder: newElementOrder,
          );

          _applyCurrentStateToNewElement(
            provider,
            id,
            newElementId,
            color,
            rotation,
            size,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated secondary logo'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 4) {
        if (logoState.companyName != null && logoState.isCompanyName2Visible) {
          final duplicated = CustomTextElement(
            text: logoState.companyName!,
            position:
                (logoState.companyName2Position ??
                    logoState.companyNamePosition) +
                const Offset(20, 20),
            size: logoState.companyName2Size ?? size,
            rotation: logoState.companyName2Rotation ?? 0,
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

          _currentLogoState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated secondary company name'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else if (id == 5) {
        if (logoState.sloganName != null && logoState.isSlogan2Visible) {
          final duplicated = CustomTextElement(
            text: logoState.sloganName!,
            position:
                (logoState.slogan2Position ?? logoState.sloganPosition) +
                const Offset(20, 20),
            size: logoState.slogan2Size ?? size,
            rotation: logoState.slogan2Rotation ?? 0,
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

          _currentLogoState = logoState.copyWith(
            customTexts: newCustomTexts,
            elementOrder: newElementOrder,
          );

          provider.cloneElementStyles(id, newElementId);
          provider.updateLogoState(_currentLogoState);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated secondary slogan'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (context.read<UndoProvider>().canUndo) _undo();
                },
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot duplicate this element (ID: $id)'),
            backgroundColor: Colors.orange,
          ),
        );
        print('Attempted to duplicate unsupported element ID: $id');
      }
    });
  }

  void _applyCurrentStateToNewElement(
    SelectedColorProvider provider,
    int sourceId,
    int newId,
    Color? color,
    double rotation,
    double size,
  ) {
    // Apply color if it exists
    if (color != null) {
      provider.setColorForElement(newId, color);
    }

    // Apply rotation
    provider.setRotationForElement(newId, rotation);

    provider.setSizeForElement(newId, size);

    final gradient = provider.getGradientForElement(sourceId);
    if (gradient != null) {
      provider.setGradientForElement(newId, gradient);
    }

    final rotX = provider.getRotationXForElement(sourceId);
    final rotY = provider.getRotationYForElement(sourceId);
    final rotZ = provider.getRotationZForElement(sourceId);
    if (rotX != null && rotX != 0) provider.setRotationXForElement(newId, rotX);
    if (rotY != null && rotY != 0) provider.setRotationYForElement(newId, rotY);
    if (rotZ != null && rotZ != 0) provider.setRotationZForElement(newId, rotZ);

    final font = provider.getFontForElement(sourceId);
    if (font != null) provider.setFontForElement(newId, font);

    final fontStyle = provider.getFontStyleForElement(sourceId);
    provider.setFontStyleForElement(newId, fontStyle);

    print(
      '✅ Applied current state from element $sourceId to new element $newId',
    );
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
