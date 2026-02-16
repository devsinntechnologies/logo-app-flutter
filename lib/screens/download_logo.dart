// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/components/google_alert.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/art_select_screen.dart';
import 'package:logo_app_flutter/screens/canvas_exporter.dart';
import 'package:logo_app_flutter/services/ad_mob_service.dart';
import 'package:logo_app_flutter/services/canvas_upload_service.dart';
import 'package:logo_app_flutter/screens/movement_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:logo_app_flutter/components/logo_bottom_nav_bar.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/screens/layer_panel.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logo_app_flutter/services/user_design_service.dart';
import '../components/logoBottomNavbarItems/drop_up_panel.dart';
import '../components/logo_canvas.dart';
import '../utils/text_size_util.dart';
import 'text_screen.dart';

class DownloadLogo extends StatefulWidget {
  final String svgLogo;
  final String companyName;
  final String sloganName;
  final int selectedFontIndex;
  final String? designId;
  final LogoStateData? initialLogoState;
  final String? imagePath;

  const DownloadLogo({
    super.key,
    required this.svgLogo,
    required this.companyName,
    required this.sloganName,
    this.selectedFontIndex = 0,
    this.initialLogoState,
    this.designId,
    this.imagePath,
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
//   final List<EditorState> _undoStack = [];
// final List<EditorState> _redoStack = [];

// late EditorState _currentState;
  final List<LogoStateData> _undoStack = [];
  final List<LogoStateData> _redoStack = [];
  final int _maxUndoHistory = 50;

  //   List<LogoElement> customTextElements = [];
  //   List<LogoElement> customImageElements = [];
  //   LogoElement? _getElementById(int id) {
  //   return customTextElements.firstWhereOrNull((e) => e.id == id);
  // }
  String _selectedBackgroundShape = 'Square';

  late BackgroundState _currentBackgroundState;

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

  double _opacityValue = 1.0;

  // --- UI Toggles ---
  bool _showGrid = false;
  bool _isLayersPanelVisible = false;
  bool showDropUp = false;
  bool showEffectPanel = false;

  bool showPaletteBar = false;
  int selectedPaletteIndex = -1;
  int selectedEffectIndex = -1;

  // --- Movement Panel Toggle ---
  bool isMovementPanelVisible = true;
  // Show grid while moving elements
  bool _isMoving = false;

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
              fontWeight: FontWeight.w500,
            ),
          ),
          content: const Text(
            'Do you want to save the logo to your storage or to My Design?',
            style: TextStyle(
              fontSize: 16,
              color: ThemeColors.purple,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// 👉 SAVE / UPDATE TO SUPABASE
                TextButton(
                  onPressed: () async {
                    final provider = Provider.of<SelectedColorProvider>(context,
                        listen: false);
                    int? previousSelection = provider.selectedElementId;
                    bool hadSelection = previousSelection != null;
                    if (hadSelection) provider.clearSelection();
                    // Wait for UI to clear selection box
                    if (hadSelection) {
                      await Future.delayed(const Duration(milliseconds: 50));
                      await WidgetsBinding.instance.endOfFrame;
                    }
                    try {
                      // Ensure current provider font selections are written into the state before saving
                      _currentLogoState = _currentLogoState.copyWith(
                        companyFontIndex: provider.companyFontIndex,
                        sloganFontIndex: provider.sloganFontIndex,
                      );
                      final designJson = _currentLogoState.toJson();
                      debugPrint(
                          '💾 Saving design fonts -> provider.company:${provider.companyFontIndex} provider.slogan:${provider.sloganFontIndex}');
                      debugPrint(
                          '💾 designJson companyFontIndex: ${designJson["companyFontIndex"]} sloganFontIndex: ${designJson["sloganFontIndex"]}');
                      final svc = UserDesignService();
                      if (widget.designId != null) {
                        await svc.updateDesign(
                          designId: widget.designId!,
                          updatedJson: designJson,
                          canvasKey: canvasKey,
                          updateImage: true,
                        );
                      } else {
                        await svc.saveNewDesign(
                          canvasKey: canvasKey,
                          designJson: designJson,
                        );
                      }
                      // Restore selection after save
                      if (hadSelection && previousSelection != null) {
                        provider.setSelectedElement(previousSelection);
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            children: const [
                              Icon(Icons.cloud_done, color: ThemeColors.purple),
                              SizedBox(width: 12),
                              Text(
                                'Logo saved successfully!',
                                style: TextStyle(
                                  color: ThemeColors.purple,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } catch (e) {
                      if (hadSelection && previousSelection != null) {
                        provider.setSelectedElement(previousSelection);
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            children: [
                              const Icon(Icons.error,
                                  color: ThemeColors.purple),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Error saving logo: $e')),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.designId != null ? 'Update' : 'My Design',
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColors.purple,
                    ),
                  ),
                ),

                /// 👉 SAVE TO DEVICE GALLERY (UNCHANGED)
                TextButton(
                  onPressed: () async {
                    final provider = Provider.of<SelectedColorProvider>(context,
                        listen: false);

                    int? previousSelection = provider.selectedElementId;
                    provider.clearSelection();

                    await WidgetsBinding.instance.endOfFrame;

                    // 👉 THIS LINE OPENS FORMAT SELECTION DIALOG
                    await exportCanvas(
                      context: context,
                      repaintKey: canvasKey,
                      logoState: _currentLogoState,
                    );

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
                    'Storage',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.purple,
                    ),
                  ),
                ),

                // TextButton(
                //   onPressed: () async {
                //     final provider = Provider.of<SelectedColorProvider>(context,
                //         listen: false);

                //     int? previousSelection = provider.selectedElementId;
                //     provider.clearSelection();

                //     await WidgetsBinding.instance.endOfFrame;

                //     await saveCanvasToGallery(canvasKey, isExportingNotifier);

                //     if (previousSelection != null) {
                //       provider.setSelectedElement(previousSelection);
                //     }

                //     Navigator.of(context).pop();

                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         duration: const Duration(seconds: 3),
                //         backgroundColor: Colors.white,
                //         behavior: SnackBarBehavior.floating,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //         margin: const EdgeInsets.all(16),
                //         content: Row(
                //           children: const [
                //             Icon(Icons.check_circle, color: ThemeColors.purple),
                //             SizedBox(width: 12),
                //             Expanded(
                //               child: Text(
                //                 'Logo saved successfully!',
                //                 style: TextStyle(
                //                   color: ThemeColors.purple,
                //                   fontSize: 16,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                //   child: const Text(
                //     'To Gallery',
                //     style: TextStyle(
                //       fontSize: 16,
                //       color: ThemeColors.purple,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  @override
  void initState() {
    super.initState();

    // 1️⃣ Initialize logo state first
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

    // If an initial state is provided (editing an existing design), use it
    if (widget.initialLogoState != null) {
      _currentLogoState = widget.initialLogoState!.clone();
      // Debug: log that initState received an initial logo state
      // ignore: avoid_print
      print(
          'DownloadLogo.initState -> initialLogoState companyFont:${widget.initialLogoState?.companyFontIndex} sloganFont:${widget.initialLogoState?.sloganFontIndex} selectedFontIndex:${widget.selectedFontIndex}');
      // Apply colors/backgrounds to provider after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final colorProvider =
            Provider.of<SelectedColorProvider>(context, listen: false);
        colorProvider.resetAllOutlines();
        colorProvider.resetAllColors(defaultColors: {});
        colorProvider.clearOverrides();
        colorProvider.applyLogoState(_currentLogoState);
        // ensure provider font indices explicitly match saved state
        colorProvider.setCompanyFontIndex(_currentLogoState.companyFontIndex);
        colorProvider.setSloganFontIndex(_currentLogoState.sloganFontIndex);
      });
    }

    // 2️⃣ Initialize background state safely
    // final provider =
    //     Provider.of<SelectedColorProvider>(context, listen: false);
    // _currentBackgroundState = BackgroundState(
    //   color: Colors.white,
    //   gradient: null,
    //   imagePath: null,
    //   checkerboardVisible: true,
    // );
    // // 3️⃣ Initialize combined editor state
    // _currentState = EditorState(
    //   logo: _currentLogoState.clone(),
    //   background: _currentBackgroundState.clone(),
    // );

    // Clear provider states immediately to prevent old backgrounds from persisting
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.resetAllOutlines();
    colorProvider.resetAllColors(defaultColors: {});
    colorProvider.clearOverrides();

    // Set the selected font index for company name and slogan (prefer initial state)
    final startCompanyFont =
        widget.initialLogoState?.companyFontIndex ?? widget.selectedFontIndex;
    final startSloganFont =
        widget.initialLogoState?.sloganFontIndex ?? widget.selectedFontIndex;
    colorProvider.setCompanyFontIndex(startCompanyFont);
    colorProvider.setSloganFontIndex(startSloganFont);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear undo/redo stacks and initialize with clean state
      _undoStack.clear();
      _redoStack.clear();
      _pushCurrentStateToUndoStack(clearRedo: true);
    });

    // 4️⃣ Post-frame callback for UI updates
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final colorProvider = Provider.of<SelectedColorProvider>(
    //     context,
    //     listen: false,
    //   );

    //   _undoStack.clear();
    //   _redoStack.clear();

    //   // Push initial states safely
    //   _undoStack.add(EditorState(
    //     logo: _currentLogoState.clone(),
    //     background: _currentBackgroundState.clone(),
    //   ));

    //   colorProvider.resetAllOutlines();
    //   colorProvider.resetAllColors(defaultColors: {
    //     0: Colors.black,
    //     1: Colors.black,
    //     2: Colors.white,
    //   });
    //   colorProvider.clearOverrides();
    // });
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
        title: Text(
          S.of(context).logoMaker,
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
            onPressed: () {
              final user = Supabase.instance.client.auth.currentUser;
              if (user != null) {
                _showSaveConfirmationDialog(context, _canvasKey);

                // ✅ Load rewarded ad first
                // AdMobService.loadRewarded(
                //   onLoaded: (RewardedAd ad) {
                //     ad.fullScreenContentCallback = FullScreenContentCallback(
                //       onAdDismissedFullScreenContent: (ad) {
                //         ad.dispose();
                //         // After ad is closed → show save confirmation
                //         _showSaveConfirmationDialog(context, _canvasKey);
                //       },
                //       onAdFailedToShowFullScreenContent: (ad, error) {
                //         ad.dispose();
                //         // If ad fails → still show save confirmation
                //         _showSaveConfirmationDialog(context, _canvasKey);
                //       },
                //     );

                //     // Show the rewarded ad
                //     ad.show(
                //       onUserEarnedReward:
                //           (AdWithoutView ad, RewardItem reward) {
                //         // Optional: you can give extra rewards here if needed
                //         print(
                //             'User earned reward: ${reward.amount} ${reward.type}');
                //       },
                //     );
                //   },
                // );
              } else {
                // User not logged in → show login dialog
                showCustomGoogleDialog(context);
              }
            },
            tooltip: 'Save Logo',
          )
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
                        child: ClipRect(
                          child: RepaintBoundary(
                            key: _canvasKey,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: LogoCanvas(
                                selectedShapeName: selectedShapeName,
                                isExportingNotifier: isExportingNotifier,
                                logoState: _currentLogoState,
                                svgLogo: widget.svgLogo,
                                companyName: widget.companyName,
                                sloganName: widget.sloganName,
                                // Show grid when toggled ON or while moving elements
                                showGrid: (_showGrid || _isMoving),
                                isEditingMode: true,
                                selectedElementId: selectedElement,
                                highlightedHorizontalGridLineIndex:
                                    _highlightedHorizontalGridLineIndex,
                                highlightedVerticalGridLineIndex:
                                    _highlightedVerticalGridLineIndex,
                                isLayersRibbonExtended: _isLayersPanelVisible,
                                onToggleGrid: () =>
                                    setState(() => _showGrid = !_showGrid),
                                onToggleLayersRibbon: () => setState(
                                  () => _isLayersPanelVisible =
                                      !_isLayersPanelVisible,
                                ),
                                onCanvasTap: () {
                                  setState(() {
                                    selectedElement = null;
                                  });
                                },
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
                                elementOrder: _currentLogoState.elementOrder,
                              ),
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
                          onClose: () =>
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
                          (MediaQuery.of(context).size.height > 500) ? 220 : 30,
                      color: Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            children: [
                              SizedBox(width: 4),
                              Tooltip(
                                message: "undo last change",
                                child: InkWell(
                                  onTap: _undo,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.replay,
                                      color: _undoStack.length > 1
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
                                      color: _redoStack.isNotEmpty
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
          if (selectedElement != null &&
              !showDropUp &&
              !showPaletteBar &&
              !showEffectPanel)
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
                onBringToFrontPressed: () =>
                    bringToFront(selectedElement!, _currentLogoState),
                onSendToBackPressed: () =>
                    sendToBack(selectedElement!, _currentLogoState),
                onBringForwardPressed: () =>
                    bringForward(selectedElement!, _currentLogoState),
                onSendBackwardPressed: () =>
                    sendBackward(selectedElement!, _currentLogoState),
                onSaveState: _saveState,
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
                    currentText = _currentLogoState
                        .customTexts[selectedElement! - 100].text;
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
                    final updatedCustomTexts = _currentLogoState.customTexts
                        .map((e) => e.clone())
                        .toList();

                    updatedCustomTexts[index] =
                        updatedCustomTexts[index].copyWith(text: editedText);

                    updatedState = updatedState.copyWith(
                      customTexts: updatedCustomTexts,
                    );
                  }
                  // onSaveState:
                  // _saveState;
                  // 5️⃣ Update state
                  setState(() {
                    _currentLogoState = updatedState;
                  });
                },
              ),
            ),
          // if (selectedElement == null)
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: (showDropUp || showPaletteBar || showEffectPanel)
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
                            onClose: () => setState(() {
                              showDropUp = false;
                              selectedIndex = -1;
                            }),
                            onToggleCheckerboard: (val) {
                              setState(() {
                                isCheckerboardActive = val;
                                isCheckerboardVisible = val;
                              });
                            },
                            onOpacityChanged: (val) =>
                                setState(() => checkerboardOpacity = val),
                            onShapeSelected: (shapeName) {
                              // Save current state for undo
                              _saveState(); // <- your existing undo/redo function

                              setState(() {
                                selectedShapeName = shapeName;
                              });
                            },
                            onSaveState:
                                _saveState, // Pass the save state callback
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
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 7),
                                    itemBuilder: (context, index) {
                                      final colors = paletteList[index];
                                      final isSelected =
                                          selectedPaletteIndex == index;

                                      return GestureDetector(
                                        onTap: () {
                                          final provider = Provider.of<
                                                  SelectedColorProvider>(
                                              context,
                                              listen: false);
                                          setState(() {
                                            selectedPaletteIndex = index;
                                            provider
                                                .setInitialColorsFromPalette(
                                              colors,
                                              _currentLogoState.elementOrder,
                                            );
                                          });
                                          _saveState(); // Save state for undo/redo
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: isSelected
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
                                                  children: colors
                                                      .map(
                                                        (
                                                          color,
                                                        ) =>
                                                            Container(
                                                          height: 15,
                                                          width:
                                                              double.infinity,
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
                                                            SelectedColorProvider>(
                                                          context,
                                                          listen: false,
                                                        ).setColorsRotated(
                                                          colors,
                                                          allElementIds:
                                                              _currentLogoState
                                                                  .elementOrder,
                                                        );
                                                        // Save this rotation as a separate undo step
                                                        _saveState();
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                Colors.orange,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(
                                                          2,
                                                        ),
                                                        child: const Icon(
                                                          Icons.refresh,
                                                          size: 15,
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

  void _clearSelection() {
    setState(() {
      selectedElement = null; // ya null agar nullable hai
    });
  }

  void updateOpacity(double value) {
    setState(() {
      checkerboardOpacity = value;
    });
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
                S.of(context).DoUwantToExit,
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
                  Text(
                    S.of(context).saveLogo,
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
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeColors.purple,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: saveLogoChecked
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
                                      margin: EdgeInsets.all(16),
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: ThemeColors.purple,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              S.of(context).saveLogo,
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
                      child: Text(S.of(context).saveLogo,
                          style: TextStyle(fontSize: 16)),
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

  void _setOutlineColor(String elementKey, Color color) {
    _saveState(); // save current state before change
    setState(() {
      _currentLogoState = _currentLogoState.copyWith(
        outlineColors: Map.from(_currentLogoState.outlineColors)
          ..[elementKey] = color,
      );
    });
    // _currentState = EditorState(
    //   logo: _currentLogoState.clone(),
    //   background: _currentState.background,
    // );
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

  void bringForward(int elementId, dynamic logoState) {
    final index = logoState.elementOrder.indexOf(elementId);
    if (index != -1 && index < logoState.elementOrder.length - 1) {
      logoState.elementOrder.removeAt(index);
      logoState.elementOrder.insert(index + 1, elementId);
      setState(() {});
    }
  }

  void sendBackward(int elementId, dynamic logoState) {
    final index = logoState.elementOrder.indexOf(elementId);
    if (index != -1 && index > 0) {
      logoState.elementOrder.removeAt(index);
      logoState.elementOrder.insert(index - 1, elementId);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Icon(Icons.opacity, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          activeColor: Colors.yellow,
                          value: _opacityValue,
                          min: 0,
                          max: 1,
                          onChanged: (val) {
                            setState(() {
                              _opacityValue = val;
                            });
                            updateOpacity(val);
                          },
                          onChangeEnd: (val) {
                            _saveState();
                          },
                        ),
                      ),
                    ),
                    Text(
                      "${(_opacityValue * 100).round()}%",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
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
                          setState(() {
                            selectedEffectIndex = -1;
                          });
                          Provider.of<SelectedColorProvider>(
                            context,
                            listen: false,
                          ).resetImage(); // reset image

                          // Save state for undo/redo after resetting effect
                          _saveState();
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
                    final isSelected = selectedEffectIndex == index - 1;
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedEffectIndex = index - 1;
                        });

                        final provider = Provider.of<SelectedColorProvider>(
                          context,
                          listen: false,
                        );

                        final uiImage = await loadUiImageFromAsset(imagePath);

                        provider.setImage(uiImage, assetPath: imagePath);

                        // Save state for undo/redo after applying effect
                        _saveState();
                      },
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade400,
                            width: isSelected ? 3 : 1,
                          ),
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

// --------------------old Undo/working code--------------------
  // --- State Save/Undo ---
  /// Capture provider-driven values into a new LogoStateData instance.
  LogoStateData _captureStateFromProvider() {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);

    final updatedCustomTexts =
        _currentLogoState.customTexts.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      final elementId = 100 + index;
      final Color colorFromProvider = provider.hasColorOverride(elementId)
          ? provider.getColorForElement(elementId, fallback: text.color)
          : text.color;
      return text.copyWith(color: colorFromProvider);
    }).toList();

    final updatedCustomSVGs =
        _currentLogoState.customSVGs.asMap().entries.map((entry) {
      final index = entry.key;
      final svg = entry.value;
      final elementId = 300 + index;
      final Color? colorFromProvider = provider.hasColorOverride(elementId)
          ? provider.getColorForElement(elementId,
              fallback: svg.color ?? Colors.black)
          : svg.color;
      return svg.copyWith(color: colorFromProvider);
    }).toList();

    final updatedCustomImages =
        _currentLogoState.customImages.asMap().entries.map((entry) {
      final index = entry.key;
      final img = entry.value;
      final elementId = 200 + index;
      final Color? colorFromProvider = provider.hasColorOverride(elementId)
          ? provider.getColorForElement(elementId,
              fallback: img.color ?? Colors.transparent)
          : img.color;
      final Color outlineColorFromProvider =
          provider.getOutlineColor(elementId);
      final double outlineWidthFromProvider =
          provider.getOutlineWidth(elementId);
      return img.copyWith(
          position: img.position,
          rotation: img.rotation,
          size: img.size,
          opacity: img.opacity,
          isVisible: img.isVisible,
          layerIndex: img.layerIndex,
          color: colorFromProvider,
          outlineColor: outlineColorFromProvider,
          outlineWidth: outlineWidthFromProvider,
          fit: img.fit,
          aspectRatio: img.aspectRatio);
    }).toList();

    final Map<String, Color> elementColors = {};
    final Map<String, Color> outlineColors = {};
    final Map<String, double> outlineWidths = {};

    for (int i = 0; i < updatedCustomTexts.length; i++) {
      final id = 100 + i;
      final c = updatedCustomTexts[i].color;
      elementColors['$id'] = c;
    }
    for (int i = 0; i < updatedCustomSVGs.length; i++) {
      final id = 300 + i;
      final c = updatedCustomSVGs[i].color;
      if (c != null) elementColors['$id'] = c;
    }
    for (int i = 0; i < updatedCustomImages.length; i++) {
      final id = 200 + i;
      final c = updatedCustomImages[i].color;
      if (c != null) elementColors['$id'] = c;
      final oc = updatedCustomImages[i].outlineColor;
      final ow = updatedCustomImages[i].outlineWidth;
      if (oc != null) outlineColors['$id'] = oc;
      if (ow != null && ow > 0) outlineWidths['$id'] = ow;
    }

    final imagePath = provider.assetImagePath ?? provider.imageFile?.path;

    final currentRotationX =
        Map<int, double>.from(_currentLogoState.rotationXMap);
    final currentRotationY =
        Map<int, double>.from(_currentLogoState.rotationYMap);
    final currentRotationZ =
        Map<int, double>.from(_currentLogoState.rotationZMap);

    // Explicitly determine background properties to ensure clean state capture
    final Color? newBackgroundColor = provider.selectedColor;
    final Gradient? newBackgroundGradient = provider.selectedGradient;
    final String? newBackgroundImagePath =
        provider.assetImagePath ?? provider.imageFile?.path;

    final newState = _currentLogoState.copyWith(
      logoColor: provider.logoColor,
      isLogoColorOverridden: provider.isLogoColorOverridden,
      companyNameColor: provider.companyTextColor,
      sloganColor: provider.sloganColor,
      selectedShapeName: selectedShapeName,

      // Explicitly pass the new values.
      // If the provider value is null, we pass null.
      // We also set the clear flags to true if the value is null,
      // ensuring the copyWith method overwrites any existing value with null.
      backgroundColor: newBackgroundColor,
      backgroundGradient: newBackgroundGradient,
      backgroundImagePath: newBackgroundImagePath,

      clearBackgroundColor: newBackgroundColor == null,
      clearBackgroundGradient: newBackgroundGradient == null,
      clearBackgroundImagePath: newBackgroundImagePath == null,

      customTexts: updatedCustomTexts,
      customSVGs: updatedCustomSVGs,
      customImages: updatedCustomImages,
      elementColors: elementColors,
      outlineColors: outlineColors,
      outlineWidths: outlineWidths,
      rotationXMap: currentRotationX,
      rotationYMap: currentRotationY,
      rotationZMap: currentRotationZ,
      companyFontIndex: provider.companyFontIndex,
      sloganFontIndex: provider.sloganFontIndex,
    );

    // Debug log
    // ignore: avoid_print
    print(
        '🔁 captureState -> bgColor:$newBackgroundColor bgGrad:${newBackgroundGradient != null} bgImagePath:$newBackgroundImagePath');

    return newState;
  }

  void _saveState() {
    final newState = _captureStateFromProvider();

    // Deduplicate: Only save if state actually changed
    if (_undoStack.isNotEmpty && _undoStack.last == newState) {
      return;
    }

    _redoStack.clear();

    if (_undoStack.length >= _maxUndoHistory) {
      _undoStack.removeAt(0);
    }

    _currentLogoState = newState;
    _undoStack.add(_currentLogoState.clone());

    // Force rebuild to update undo/redo button states
    setState(() {
      // Trigger rebuild to update button states based on stack lengths
    });
  }

  void _pushCurrentStateToUndoStack({bool clearRedo = false}) {
    if (clearRedo) _redoStack.clear();
    final newState = _captureStateFromProvider();

    // Deduplicate
    if (_undoStack.isNotEmpty && _undoStack.last == newState) {
      return;
    }

    _currentLogoState = newState;
    if (_undoStack.length >= _maxUndoHistory) _undoStack.removeAt(0);
    _undoStack.add(_currentLogoState.clone());
  }

  void _undo() {
    if (_undoStack.length > 1) {
      // Need at least 2 items (current + previous)
      // Capture current provider state into a LogoStateData snapshot and
      // push it onto the redo stack. Use the centralized helper so capture
      // logic stays consistent across save/undo/redo.
      final provider =
          Provider.of<SelectedColorProvider>(context, listen: false);
      final LogoStateData captured = _captureStateFromProvider();
      _redoStack.add(captured.clone());

      // Remove current state from undo stack (last item is current)
      if (_undoStack.isNotEmpty) {
        _undoStack.removeLast();
      }

      // Now get the previous state
      if (_undoStack.isNotEmpty) {
        _currentLogoState = _undoStack.last.clone();
        // Preserve user's currently selected fonts across undo of unrelated actions
        final int savedCompanyFont = provider.companyFontIndex;
        final int savedSloganFont = provider.sloganFontIndex;
        provider.applyLogoState(_currentLogoState);
        // Also explicitly apply the background so color/gradient/image are
        // applied immediately (fixes redo/undo background inconsistencies).
        _applyBackgroundFromState(BackgroundState(
          color: _currentLogoState.backgroundColor,
          gradient: _currentLogoState.backgroundGradient,
          imagePath: _currentLogoState.backgroundImagePath,
          checkerboardVisible:
              Provider.of<SelectedColorProvider>(context, listen: false)
                  .isCheckerboardVisible,
        ));
        provider.setCompanyFontIndex(savedCompanyFont);
        provider.setSloganFontIndex(savedSloganFont);

        // Restore selectedShapeName
        selectedShapeName = _currentLogoState.selectedShapeName ?? "";
      }

      // Always call setState to update button states
      setState(() {});
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      // The redo stack contains the NEXT state to restore.
      final nextState = _redoStack.removeLast();

      // We must add this state to the undo stack, so we can undo back to it later.
      // We do NOT use _pushCurrentStateToUndoStack() here, because that would
      // capture the *current* state (which is the one we are leaving: the "previous" state).
      // Since the undo stack already contains the "previous" state (as the last item),
      // adding it again would create duplicates [A, A, B].
      // Instead, we just add the new state [A, B].
      if (_undoStack.length >= _maxUndoHistory) {
        _undoStack.removeAt(0);
      }
      _undoStack.add(nextState.clone());

      // Set as current and apply
      _currentLogoState = nextState;

      // Debug: log redo target background
      // ignore: avoid_print
      print(
          '🔁 _redo -> restoring bgColor:${_currentLogoState.backgroundColor} bgGrad:${_currentLogoState.backgroundGradient != null} bgImage:${_currentLogoState.backgroundImagePath}');

      final provider =
          Provider.of<SelectedColorProvider>(context, listen: false);
      final int savedCompanyFont = provider.companyFontIndex;
      final int savedSloganFont = provider.sloganFontIndex;
      provider.applyLogoState(_currentLogoState);
      // Explicitly reapply background (color/gradient/image)
      _applyBackgroundFromState(BackgroundState(
        color: _currentLogoState.backgroundColor,
        gradient: _currentLogoState.backgroundGradient,
        imagePath: _currentLogoState.backgroundImagePath,
        checkerboardVisible:
            Provider.of<SelectedColorProvider>(context, listen: false)
                .isCheckerboardVisible,
      ));
      provider.setCompanyFontIndex(savedCompanyFont);
      provider.setSloganFontIndex(savedSloganFont);
      selectedShapeName = _currentLogoState.selectedShapeName ?? "";

      setState(() {});
    }
  }

  // --------------------- Old State Save/Undo --------------------

// void _saveState() {
//   _redoStack.clear();
//   if (_undoStack.length >= _maxUndoHistory) _undoStack.removeAt(0);
//   _undoStack.add(_currentState.clone());
// }

// void _undo() {
//   if (_undoStack.isEmpty) {
//     _showSnackBar('Nothing to undo!');
//     return;
//   }

//   _redoStack.add(_currentState.clone());
//   _currentState = _undoStack.removeLast();

//   // Apply logo
//   _currentLogoState = _currentState.logo.clone();
//   Provider.of<SelectedColorProvider>(context, listen: false)
//       .applyLogoState(_currentLogoState);

//   // Apply background
//   _applyBackgroundFromState(_currentState.background);

//   setState(() {});
//   _showSnackBar('Undo successful!');
// }

// void _redo() {
//   if (_redoStack.isEmpty) {
//     _showSnackBar('Nothing to redo!');
//     return;
//   }

//   _undoStack.add(_currentState.clone());
//   _currentState = _redoStack.removeLast();

//   _currentLogoState = _currentState.logo.clone();
//   Provider.of<SelectedColorProvider>(context, listen: false)
//       .applyLogoState(_currentLogoState);

//   _applyBackgroundFromState(_currentState.background);

//   setState(() {});
//   _showSnackBar('Redo successful!');
// }

// // Optional helper for SnackBars with cooldown
// DateTime? _lastSnackBarTime;
// void _showSnackBar(String message) {
//   final now = DateTime.now();
//   if (_lastSnackBarTime == null ||
//       now.difference(_lastSnackBarTime!) > const Duration(seconds: 2)) {
//     _lastSnackBarTime = now;
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//       );
//   }
// }

  void _applyBackgroundFromState(BackgroundState state) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    // Debug: log incoming background state
    // ignore: avoid_print
    print(
        '🔁 _applyBackgroundFromState -> image:${state.imagePath} gradient:${state.gradient != null} color:${state.color} checker:${state.checkerboardVisible}');

    provider.setBackgroundFromValues(
      color: state.color,
      gradient: state.gradient,
      imagePath: state.imagePath,
      checkerboardVisible: state.checkerboardVisible,
    );

    provider.setCheckerboardVisibility(state.checkerboardVisible);
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
        setState(() {
          final provider =
              Provider.of<SelectedColorProvider>(context, listen: false);
          // Offset new text slightly to the left and top (8px each)
          final basePos = _currentLogoState.companyNamePosition;
          final adjustedPos = basePos - const Offset(35, 35);
          final newTextElement = CustomTextElement(
            text: result,
            position: adjustedPos,
            size: 22,
            rotation: 0,
            fontIndex: provider.companyFontIndex,
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
        _saveState(); // Save state AFTER text is added
        // _currentState = EditorState(
        //   logo: _currentLogoState.clone(),
        //   background: _currentState.background,
        // );
      }
    }

    if (index == 1) {
      final selectedImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArtSelectScreen(
            images: [
              'assets/logo_images/art1.svg',
              'assets/logo_images/art2.svg',
              'assets/logo_images/art3.svg',
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
        await _addImageToCanvas(selectedImagePath);
      }
    }

    if (index == 5) {
      if (kIsWeb) {
        // Show a message that gallery picker is different on web or use web-friendly picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gallery pick not supported on this web demo')),
        );
        setState(() {
          selectedIndex = -1;
        });
        return;
      }
      final picker = ImagePicker();
      final selectedSource = await showDialog<ImageSource>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Select Image Source',
              style: TextStyle(
                  color: ThemeColors.purple, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text(
                'Camera',
                style: TextStyle(color: ThemeColors.purple, fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text(
                'Gallery',
                style: TextStyle(color: ThemeColors.purple, fontSize: 15),
              ),
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
          final config = await _showImageLayoutDialog(context, pickedFile.path);
          final newImage = CustomImageElement(
            path: pickedFile.path,
            position: _getCanvasCenter(),
            size: 100,
            rotation: 0,
            fit: config != null && config['fit'] != null
                ? config['fit'] as BoxFit
                : BoxFit.contain,
            aspectRatio:
                config != null ? config['aspectRatio'] as double? : null,
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
          // Save state AFTER adding the image so the undo stack contains the image
          _saveState();
          // _currentState = EditorState(
          //   logo: _currentLogoState.clone(),
          //   background: _currentState.background,
          // );
        }
      }
    }
  }

  Route<String> _createSlideRoute() {
    return PageRouteBuilder<String>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const TextScreen(),
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
      pageBuilder: (context, animation, secondaryAnimation) =>
          const TextScreen(),
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
      // Close dropup/effects/palette panels when element is selected
      showDropUp = false;
      showEffectPanel = false;
      showPaletteBar = false;
      selectedIndex = -1; // Reset bottom nav selection
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

  Future<void> _addImageToCanvas(String imagePath) async {
    // SVG path -> add to customSVGs (300+). Raster -> add to customImages (200+).
    if (imagePath.toLowerCase().endsWith('.svg')) {
      String svgString = '';
      try {
        if (imagePath.startsWith('assets/')) {
          svgString = await rootBundle.loadString(imagePath);
        } else {
          svgString = await File(imagePath).readAsString();
        }
      } catch (e) {
        print('Failed to load SVG: $e');
        svgString = '';
      }

      if (svgString.isNotEmpty) {
        final index = _currentLogoState.customSVGs.length;
        final newSvg = CustomSvgElement(
          svgString: svgString,
          position: _getCanvasCenter(),
          size: 120,
          rotation: 0,
        );

        setState(() {
          final updatedCustomSVGs = List<CustomSvgElement>.from(
            _currentLogoState.customSVGs,
          )..add(newSvg);
          final newElementId = 300 + index;
          final updatedElementOrder =
              List<int>.from(_currentLogoState.elementOrder)..add(newElementId);

          _currentLogoState = _currentLogoState.copyWith(
            customSVGs: updatedCustomSVGs,
            elementOrder: updatedElementOrder,
          );
        });
        // Save AFTER adding the new SVG so undo preserves it
        _saveState();
        return;
      }
      // if svgString empty, fall through to raster handler
    }

    final index = _currentLogoState.customImages.length;
    // If this is a file (likely picked from gallery), ask layout/aspect choices
    BoxFit chosenFit = BoxFit.contain;
    double? chosenAspect;
    if (!imagePath.startsWith('assets/')) {
      final cfg = await _showImageLayoutDialog(context, imagePath);
      if (cfg != null) {
        chosenFit = cfg['fit'] as BoxFit? ?? BoxFit.contain;
        chosenAspect = cfg['aspectRatio'] as double?;
      }
    }

    final newImage = CustomImageElement(
      path: imagePath,
      position: _getCanvasCenter(),
      rotation: 0,
      size: 120,
      fit: chosenFit,
      aspectRatio: chosenAspect,
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
    // Save AFTER adding the new image so undo preserves it
    _saveState();
    // _currentState = EditorState(
    //   logo: _currentLogoState.clone(),
    //   background: _currentState.background,
    // );
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
      // Only use logoColor if it has been manually overridden, otherwise null (use SVG's original color)
      final originalColor =
          provider.isLogoColorOverridden ? provider.logoColor : null;

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
      final newTopLeft = originalTopLeft +
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

      final updatedSVGs = updatedState.customSVGs.map((e) => e.clone()).toList()
        ..add(newSvgElement);

      newElementId = generateNewId(300, updatedSVGs.length - 1);

      updatedState = updatedState.copyWith(
        customSVGs: updatedSVGs,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      // Only set color override if the logo color was manually changed
      if (originalColor != null) {
        provider.setOverrideColorForElement(newElementId, originalColor);
      }
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
      // Determine if the original element had a manual override. If so,
      // preserve that color on the duplicate. If not, leave color null so
      // the SVG's embedded colors are used.
      final bool hadOverride = provider.hasColorOverride(id);
      final Color? originalColor = hadOverride
          ? provider.getColorForElement(id,
              fallback: original.color ?? Colors.black)
          : null;

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

      final updatedSVGs = updatedState.customSVGs.map((e) => e.clone()).toList()
        ..add(newSvg);
      newElementId = generateNewId(300, updatedSVGs.length - 1);

      updatedState = updatedState.copyWith(
        customSVGs: updatedSVGs,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      if (hadOverride && originalColor != null) {
        provider.setOverrideColorForElement(newElementId, originalColor);
      }
      updatedState = _duplicate3DRotation(
        oldId: id,
        newId: newElementId,
        state: updatedState,
      );

      debugPrint(
        '✅ Duplicated Custom SVG with id: $newElementId at position: $newCenterPosition',
      );
    }
    // Duplicate Custom Images (id 200–299)
    else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= updatedState.customImages.length) return;

      final original = updatedState.customImages[index].clone();

      // Calculate proper duplicate position
      final originalSize = Size(
        original.size ?? 100,
        original.size ?? 100,
      );
      final originalTopLeft = getTopLeftPosition(
        original.position,
        originalSize,
      );
      final newTopLeft = originalTopLeft + const Offset(30, 30);
      final newCenterPosition = getCenterPosition(newTopLeft, originalSize);

      // preserve provider overrides (outline + tint) similar to SVG duplication
      final outlineColor = provider.getOutlineColor(id);
      final outlineWidth = provider.getOutlineWidth(id);
      final bool hadOverride = provider.hasColorOverride(id);
      final Color? originalColor = hadOverride
          ? provider.getColorForElement(id,
              fallback: original.color ?? Colors.transparent)
          : null;

      final newImage = original.copyWith(
        position: newCenterPosition, // Store as center position
      );

      final updatedImages = updatedState.customImages
          .map((e) => e.clone())
          .toList()
        ..add(newImage);
      newElementId = generateNewId(200, updatedImages.length - 1);

      updatedState = updatedState.copyWith(
        customImages: updatedImages,
        elementOrder: [...updatedState.elementOrder, newElementId],
      );

      // Apply provider overrides to the duplicated element so color/outline persist
      provider.setOutlineColor(newElementId, outlineColor);
      provider.setOutlineWidth(newElementId, outlineWidth);
      if (hadOverride && originalColor != null) {
        provider.setOverrideColorForElement(newElementId, originalColor);
      }

      updatedState = _duplicate3DRotation(
        oldId: id,
        newId: newElementId,
        state: updatedState,
      );

      debugPrint(
        '✅ Duplicated Custom Image with id: $newElementId at position: $newCenterPosition',
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
        // fontWeight: FontWeight.w900,
        opacity: 1,
        isOutlined: outlineWidth > 0,
        outlineColor: outlineColor,
        strokeWidth: outlineWidth,
        fontIndex: provider.companyFontIndex,
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
        fontIndex: provider.sloganFontIndex,
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

    // Push post-operation state to undo stack so undo/redo capture the change
    if (_undoStack.length >= _maxUndoHistory) {
      _undoStack.removeAt(0);
    }
    _pushCurrentStateToUndoStack();

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
    // _currentState = EditorState(
    //   logo: _currentLogoState.clone(),
    //   background: _currentState.background,
    // );
  }

  void _rotateElementByTap(int id) {
    if (_isElementLocked(id)) return;
    _saveState();

    const double rotationStep = 45.0;

    setState(() {
      // Handle duplicated SVGs (IDs 300-399)
      if (id >= 300 && id < 400) {
        final currentRotation = _getElementRotation(id);
        final newRotation = (currentRotation + rotationStep) % 360;
        _updateElementRotation(id, newRotation);
      }
      // Handle custom texts (IDs 100-199)
      else if (id >= 100 && id < 200) {
        final currentRotation = _getElementRotation(id);
        final newRotation = (currentRotation + rotationStep) % 360;
        _updateElementRotation(id, newRotation);
      }
      // Handle custom images (IDs 200-299)
      else if (id >= 200 && id < 300) {
        final currentRotation = _getElementRotation(id);
        final newRotation = (currentRotation + rotationStep) % 360;
        _updateElementRotation(id, newRotation);
      }
      // Handle main elements
      else if (id == 0) {
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

    const double resizeStep = 20.0;
    const double minSize = 10.0;

    setState(() {
      // Handle duplicated SVGs (IDs 300-399)
      if (id >= 300 && id < 400) {
        final index = id - 300;
        if (index >= 0 && index < _currentLogoState.customSVGs.length) {
          final currentSize = _currentLogoState.customSVGs[index].size;
          final newSize = max(minSize, currentSize + resizeStep);
          _updateElementSize(id, newSize);
        }
      }
      // Handle custom texts (IDs 100-199)
      else if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index >= 0 && index < _currentLogoState.customTexts.length) {
          final currentSize = _currentLogoState.customTexts[index].size;
          final newSize = max(minSize, currentSize + resizeStep);
          _updateElementSize(id, newSize);
        }
      }
      // Handle custom images (IDs 200-299)
      else if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index >= 0 && index < _currentLogoState.customImages.length) {
          final currentSize =
              _currentLogoState.customImages[index].size ?? minSize;
          final newSize = max(minSize, currentSize + resizeStep);
          _updateElementSize(id, newSize);
        }
      }
      // Handle main elements
      else if (id == 0) {
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
      _isMoving = true;
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
    if (_isMoving) {
      setState(() {
        _isMoving = false;
      });
      // After finishing a drag, record the new state for undo/redo
      if (_undoStack.length >= _maxUndoHistory) {
        _undoStack.removeAt(0);
      }
      _pushCurrentStateToUndoStack();
    }
  }

  Offset _limitOffset(
    Offset original,
    Offset delta,
    Size elementSize,
    Size canvasSize,
  ) {
    final newOffset = original + delta;
    // Allow the object's center to reach the canvas edge (not just top-left)
    // This prevents large objects from being blocked at the right/bottom
    const double bottomMargin = 60.0;
    final halfWidth = elementSize.width / 2;
    final halfHeight = elementSize.height / 2;
    final clampedDx = newOffset.dx.clamp(
      -halfWidth,
      canvasSize.width - halfWidth,
    );
    final clampedDy = newOffset.dy.clamp(
      -halfHeight,
      canvasSize.height - halfHeight + bottomMargin,
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
    final elementCenterGlobal = canvasOffset +
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

  Offset _getCanvasCenter() {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      return Offset(size.width / 2, size.height / 2);
    }
    // Fallback: use MediaQuery to get screen center
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Return center of the screen, which is typically where the canvas is
    return Offset(screenWidth / 2, screenHeight / 2);
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
    // Respect user toggle but also allow alignment while dragging
    if (!(_showGrid || _isMoving)) return;

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

  /// Shows a small dialog allowing the user to choose an aspect ratio
  /// and BoxFit layout for a picked gallery image. Returns a map with
  /// keys 'fit' and 'aspectRatio' or null if cancelled.
  Future<Map<String, Object?>?> _showImageLayoutDialog(
    BuildContext ctx,
    String imagePath,
  ) async {
    BoxFit selectedFit = BoxFit.cover;
    double? selectedAspect; // null -> original

    final ImageProvider imageProvider = imagePath.startsWith('assets/')
        ? AssetImage(imagePath)
        : FileImage(File(imagePath));

    return await showDialog<Map<String, Object?>?>(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          Widget preview() {
            final previewCard = Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: selectedAspect != null
                    ? AspectRatio(
                        aspectRatio: selectedAspect!,
                        child: Container(
                          color: Colors.black,
                          child: Image(
                            image: imageProvider,
                            fit: selectedFit,
                          ),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 360,
                          child: Image(
                            image: imageProvider,
                            fit: selectedFit,
                          ),
                        ),
                      ),
              ),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: previewCard,
            );
          }

          Widget aspectButtons() {
            final items = <Map<String, dynamic>>[
              {'label': 'Original', 'value': null},
              {'label': '1:1', 'value': 1.0},
              {'label': '16:9', 'value': 16 / 9},
              {'label': '4:3', 'value': 4 / 3},
            ];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((it) {
                final bool sel = selectedAspect == it['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 32), // ⬅ height kam
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: sel ? Colors.purple : Colors.grey[200],
                        foregroundColor: sel ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: sel ? 6 : 1,
                      ),
                      onPressed: () => setState(
                          () => selectedAspect = it['value'] as double?),
                      child: Text(it['label'],
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
            );
          }

          Widget layoutButtons() {
            final layouts = <Map<String, dynamic>>[
              {
                'icon': Icons.crop_free,
                'label': 'Contain',
                'value': BoxFit.contain
              },
              {
                'icon': Icons.crop_square,
                'label': 'Cover',
                'value': BoxFit.cover
              },
              {'icon': Icons.straighten, 'label': 'Fill', 'value': BoxFit.fill},
              {
                'icon': Icons.swap_vert,
                'label': 'Fit W',
                'value': BoxFit.fitWidth
              },
              {
                'icon': Icons.swap_horiz,
                'label': 'Fit H',
                'value': BoxFit.fitHeight
              },
            ];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: layouts.map((it) {
                final bool sel = selectedFit == it['value'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32), // ⬅ height kam
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: sel ? Colors.purple : Colors.grey[200],

                        foregroundColor: sel ? Colors.white : Colors.black,
                        side: BorderSide(
                            color: sel ? Colors.white54 : Colors.white24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: sel ? 6 : 1,
                      ),
                      onPressed: () =>
                          setState(() => selectedFit = it['value'] as BoxFit),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(it['icon'], size: 18),
                          const SizedBox(height: 4),
                          Text(it['label'],
                              style: const TextStyle(fontSize: 11))
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // header
                  Row(
                    children: [
                      SizedBox(width: 10),
                      const Expanded(
                          child: Text('Preview & Layout',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context, null),
                      )
                    ],
                  ),
                  // preview
                  preview(),
                  const SizedBox(height: 8),
                  // Aspect buttons (Instagram-style pill buttons)
                  aspectButtons(),
                  const SizedBox(height: 12),
                  // Layout buttons (icons)
                  layoutButtons(),
                  const SizedBox(height: 12),
                  // actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black),
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple),
                        onPressed: () => Navigator.pop(context, {
                          'fit': selectedFit,
                          'aspectRatio': selectedAspect
                        }),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Text('Apply',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
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
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        return _currentLogoState.customSVGs[index].size;
      }
    } else if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
        return _currentLogoState.customTexts[index].size;
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        return _currentLogoState.customImages[index].size ?? 100.0;
      }
    } else if (id == 0) {
      return _currentLogoState.logoSize;
    } else if (id == 1) {
      return _currentLogoState.companyNameSize;
    } else if (id == 2) {
      return _currentLogoState.sloganSize;
    } else if (id == 3) {
      return _currentLogoState.logo2Size ?? 100.0;
    } else if (id == 4) {
      return _currentLogoState.companyName2Size ?? 24.0;
    } else if (id == 5) {
      return _currentLogoState.slogan2Size ?? 16.0;
    }

    return 0.0;
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
        print('📏 Custom text size: $size (index: $index)');
        return size;
      }
      print(
          '⚠️  Text element not found: id=$id, index=$index, length=${_currentLogoState.customTexts.length}');
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final image = _currentLogoState.customImages[index];
        final size = Size(image.size ?? 100, image.size ?? 100);
        print('📏 Custom image size: $size');
        return size;
      }
    } else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final svg = _currentLogoState.customSVGs[index];
        final size = Size(svg.size, svg.size);
        print(
            '📏 Custom SVG size: $size (id: $id, index: $index, actual size: ${svg.size})');
        return size;
      }
      print(
          '⚠️  SVG element not found: id=$id, index=$index, length=${_currentLogoState.customSVGs.length}');
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

  void _updateElementSize(int id, double newSize) {
    print('🔄 Updating element size - id: $id, newSize: $newSize');

    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final updatedSVGs = List<CustomSvgElement>.from(
          _currentLogoState.customSVGs,
        );
        updatedSVGs[index] = updatedSVGs[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(
          customSVGs: updatedSVGs,
        );
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final updatedImages = List<CustomImageElement>.from(
          _currentLogoState.customImages,
        );
        updatedImages[index] = updatedImages[index].copyWith(size: newSize);
        _currentLogoState = _currentLogoState.copyWith(
          customImages: updatedImages,
        );
      }
    } else if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState.customTexts.length) {
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

// Also check your resize gesture handler - it might not be calling _updateElementSize properly:
  void _handleResizePanUpdate(int id, DragUpdateDetails details) {
    print('🎯 Resize pan update for element: $id, details: ${details.delta}');

    // Get current size
    final currentSize = _getElementRenderedSize(id);
    print('📏 Current size: $currentSize');

    // Calculate scale factor based on drag
    // You can adjust the sensitivity here (0.01 = 1% change per pixel)
    const double sensitivity = 0.5;

    // Use diagonal drag (dx + dy) for uniform scaling
    double delta = (details.delta.dx + details.delta.dy) * sensitivity;

    // For SVGs and Logos (square elements)
    if (id == 0 || (id >= 300 && id < 400)) {
      double newSize = currentSize.width + delta;

      // Clamp to min/max values
      newSize = newSize.clamp(20.0, 500.0);

      print('📐 Resizing element $id: ${currentSize.width} -> $newSize');

      _updateElementSize(id, newSize);
    }
    // For text elements
    else if ((id >= 100 && id < 200) || id == 1 || id == 2) {
      double newSize = currentSize.width + delta;

      // Text size needs to be in font size, not pixel width
      // Convert pixel delta to font size delta
      double fontSizeChange = delta * 0.3; // Adjust this factor as needed
      double currentFontSize;

      if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index < _currentLogoState.customTexts.length) {
          currentFontSize = _currentLogoState.customTexts[index].size;
        } else {
          return;
        }
      } else if (id == 1) {
        currentFontSize = _currentLogoState.companyNameSize;
      } else if (id == 2) {
        currentFontSize = _currentLogoState.sloganSize;
      } else {
        return;
      }

      double newFontSize = currentFontSize + fontSizeChange;
      newFontSize = newFontSize.clamp(8.0, 100.0);

      print('🔤 Resizing text element $id: $currentFontSize -> $newFontSize');

      _updateElementSize(id, newFontSize);
    }
  }

  double _getElementRotation(int id) {
    print('🔄 Getting rotation for element: $id');

    // Handle duplicated SVGs (300-399)
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final rotation = _currentLogoState.customSVGs[index].rotation;
        print('   SVG rotation: $rotation');
        return rotation;
      }
    }
    // Handle custom texts (100-199)
    else if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) {
        final rotation = _currentLogoState.customTexts[index].rotation;
        print('   Text rotation: $rotation');
        return rotation;
      }
    }
    // Handle custom images (200-299)
    else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index < _currentLogoState.customImages.length) {
        final rotation = _currentLogoState.customImages[index].rotation;
        print('   Image rotation: $rotation');
        return rotation;
      }
    }

    // Handle main elements
    switch (id) {
      case 0:
        final rotation = _currentLogoState.logoRotation;
        print('   Main logo rotation: $rotation');
        return rotation;
      case 1:
        final rotation = _currentLogoState.companyNameRotation;
        print('   Company name rotation: $rotation');
        return rotation;
      case 2:
        final rotation = _currentLogoState.sloganRotation;
        print('   Slogan rotation: $rotation');
        return rotation;
      case 3:
        final rotation = _currentLogoState.logo2Rotation ?? 0;
        print('   Second logo rotation: $rotation');
        return rotation;
      case 4:
        final rotation = _currentLogoState.companyName2Rotation ?? 0;
        print('   Second company name rotation: $rotation');
        return rotation;
      case 5:
        final rotation = _currentLogoState.slogan2Rotation ?? 0;
        print('   Second slogan rotation: $rotation');
        return rotation;
      default:
        print('   Default rotation: 0');
        return 0;
    }
  }

  void _updateElementRotation(int id, double newRotation) {
    // ✅ Handle ALL elements that are in customSVGs list (including duplicated logos)
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState.customSVGs.length) {
        final updatedSVGs = List<CustomSvgElement>.from(
          _currentLogoState.customSVGs,
        );
        updatedSVGs[index] = updatedSVGs[index].copyWith(rotation: newRotation);

        setState(() {
          _currentLogoState = _currentLogoState.copyWith(
            customSVGs: updatedSVGs,
          );
        });
        // _currentState = EditorState(
        //   logo: _currentLogoState.clone(),
        //   background: _currentState.background,
        // );
        print('✅ Updated rotation for SVG id $id to $newRotation');
        return;
      } else {
        print(
            '⚠️  Cannot update rotation: ID $id (index $index) not found in customSVGs list');
      }
    } else if (id >= 200 && id < 300) {
      // Handle custom images (art images)
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState.customImages.length) {
        final updatedImages = List<CustomImageElement>.from(
          _currentLogoState.customImages,
        );
        updatedImages[index] =
            updatedImages[index].copyWith(rotation: newRotation);

        setState(() {
          _currentLogoState = _currentLogoState.copyWith(
            customImages: updatedImages,
          );
        });
        print('✅ Updated rotation for image id $id to $newRotation');
        return;
      } else {
        print(
            '⚠️  Cannot update rotation: ID $id (index $index) not found in customImages list');
      }
    } else if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < _currentLogoState.customTexts.length) {
        final updatedTexts = List<CustomTextElement>.from(
          _currentLogoState.customTexts,
        );
        updatedTexts[index] =
            updatedTexts[index].copyWith(rotation: newRotation);

        setState(() {
          _currentLogoState = _currentLogoState.copyWith(
            customTexts: updatedTexts,
          );
        });
        // _currentState = EditorState(
        //   logo: _currentLogoState.clone(),
        //   background: _currentState.background,
        // );
        print('✅ Updated rotation for text id $id to $newRotation');
      }
    } else if (id == 0) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(logoRotation: newRotation);
      });
      // _currentState = EditorState(
      //   logo: _currentLogoState.clone(),
      //   background: _currentState.background,
      // );
      print('✅ Updated rotation for main logo to $newRotation');
    } else if (id == 1) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(companyNameRotation: newRotation);
      });
      // _currentState = EditorState(
      //   logo: _currentLogoState.clone(),
      //   background: _currentState.background,
      // );
      print('✅ Updated rotation for company name to $newRotation');
    } else if (id == 2) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(sloganRotation: newRotation);
      });
      print('✅ Updated rotation for slogan to $newRotation');
    } else if (id == 3) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(logo2Rotation: newRotation);
      });
      print('✅ Updated rotation for second logo to $newRotation');
    } else if (id == 4) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(companyName2Rotation: newRotation);
      });
      print('✅ Updated rotation for second company name to $newRotation');
    } else if (id == 5) {
      setState(() {
        _currentLogoState =
            _currentLogoState.copyWith(slogan2Rotation: newRotation);
      });
      print('✅ Updated rotation for second slogan to $newRotation');
    }
  }
// ------------------------- OLD Working Code -------------------------
  // Size _getElementRenderedSize(int id) {
  //   print('📏 Getting rendered size for element: $id');

  //   if (id >= 100 && id < 200) {
  //     final index = id - 100;
  //     if (index >= 0 && index < _currentLogoState.customTexts.length) {
  //       final text = _currentLogoState.customTexts[index];
  //       final style = TextStyle(
  //         fontSize: text.size,
  //         fontWeight: FontWeight.w500,
  //       );
  //       final size = _calculateTextSize(text.text, style);
  //       print('📏 Custom text size: $size');
  //       return size;
  //     }
  //   } else if (id >= 200 && id < 300) {
  //     final index = id - 200;
  //     if (index >= 0 && index < _currentLogoState.customImages.length) {
  //       final image = _currentLogoState.customImages[index];
  //       final size = Size(image.size ?? 100, image.size ?? 100);
  //       print('📏 Custom image size: $size');
  //       return size;
  //     }
  //   } else if (id >= 300 && id < 400) {
  //     // ✅ THIS IS THE KEY FIX FOR DUPLICATED LOGOS
  //     final index = id - 300;
  //     if (index >= 0 && index < _currentLogoState.customSVGs.length) {
  //       final svg = _currentLogoState.customSVGs[index];
  //       final size = Size(svg.size, svg.size);
  //       print('📏 Custom SVG size: $size (from svg.size: ${svg.size})');
  //       return size;
  //     } else {
  //       print(
  //         '❌ Custom SVG index out of bounds: $index, total SVGs: ${_currentLogoState.customSVGs.length}',
  //       );
  //     }
  //   } else {
  //     switch (id) {
  //       case 0:
  //         final size = Size(
  //           _currentLogoState.logoSize,
  //           _currentLogoState.logoSize,
  //         );
  //         print('📏 Main logo size: $size');
  //         return size;
  //       case 1:
  //         final text = _currentLogoState.companyName ?? '';
  //         final style = TextStyle(
  //           fontSize: _currentLogoState.companyNameSize,
  //           fontWeight: FontWeight.bold,
  //         );
  //         final size = _calculateTextSize(text, style);
  //         print('📏 Company name size: $size');
  //         return size;
  //       case 2:
  //         final text = _currentLogoState.sloganName ?? '';
  //         final style = TextStyle(fontSize: _currentLogoState.sloganSize);
  //         final size = _calculateTextSize(text, style);
  //         print('📏 Slogan size: $size');
  //         return size;
  //       // ... other cases
  //     }
  //   }

  //   print('❌ Returning zero size for element: $id');
  //   return Size.zero;
  // }

  // double _getElementRotation(int id) {
  //   if (id >= 100) {
  //     final index = id - 100;
  //     if (index < _currentLogoState.customTexts.length)
  //       return _currentLogoState.customTexts[index].rotation;
  //   }
  //   switch (id) {
  //     case 0:
  //       return _currentLogoState.logoRotation;
  //     case 1:
  //       return _currentLogoState.companyNameRotation;
  //     case 2:
  //       return _currentLogoState.sloganRotation;
  //     case 3:
  //       return _currentLogoState.logo2Rotation ?? 0;
  //     case 4:
  //       return _currentLogoState.companyName2Rotation ?? 0;
  //     case 5:
  //       return _currentLogoState.slogan2Rotation ?? 0;
  //     default:
  //       return 0;
  //   }
  // }

  // void _updateElementSize(int id, double newSize) {
  //   if (id >= 100) {
  //     final index = id - 100;
  //     if (index < _currentLogoState.customTexts.length) {
  //       final updatedTexts = List<CustomTextElement>.from(
  //         _currentLogoState.customTexts,
  //       );
  //       updatedTexts[index] = updatedTexts[index].copyWith(size: newSize);
  //       _currentLogoState = _currentLogoState.copyWith(
  //         customTexts: updatedTexts,
  //       );
  //     }
  //   } else if (id == 0) {
  //     _currentLogoState = _currentLogoState.copyWith(logoSize: newSize);
  //   } else if (id == 1) {
  //     _currentLogoState = _currentLogoState.copyWith(companyNameSize: newSize);
  //   } else if (id == 2) {
  //     _currentLogoState = _currentLogoState.copyWith(sloganSize: newSize);
  //   } else if (id == 3) {
  //     _currentLogoState = _currentLogoState.copyWith(logo2Size: newSize);
  //   } else if (id == 4) {
  //     _currentLogoState = _currentLogoState.copyWith(companyName2Size: newSize);
  //   } else if (id == 5) {
  //     _currentLogoState = _currentLogoState.copyWith(slogan2Size: newSize);
  //   }
  // }

  // void _updateElementRotation(int id, double newRotation) {
  //   if (id >= 100) {
  //     final index = id - 100;
  //     if (index < _currentLogoState.customTexts.length) {
  //       final updatedTexts = List<CustomTextElement>.from(
  //         _currentLogoState.customTexts,
  //       );
  //       updatedTexts[index] = updatedTexts[index].copyWith(
  //         rotation: newRotation,
  //       );
  //       _currentLogoState = _currentLogoState.copyWith(
  //         customTexts: updatedTexts,
  //       );
  //     }
  //   } else if (id == 0) {
  //     _currentLogoState = _currentLogoState.copyWith(logoRotation: newRotation);
  //   } else if (id == 1) {
  //     _currentLogoState = _currentLogoState.copyWith(
  //       companyNameRotation: newRotation,
  //     );
  //   } else if (id == 2) {
  //     _currentLogoState = _currentLogoState.copyWith(
  //       sloganRotation: newRotation,
  //     );
  //   } else if (id == 3) {
  //     _currentLogoState = _currentLogoState.copyWith(
  //       logo2Rotation: newRotation,
  //     );
  //   } else if (id == 4) {
  //     _currentLogoState = _currentLogoState.copyWith(
  //       companyName2Rotation: newRotation,
  //     );
  //   } else if (id == 5) {
  //     _currentLogoState = _currentLogoState.copyWith(
  //       slogan2Rotation: newRotation,
  //     );
  //   }
  // }
// ----------------------------old working code -------------------------
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
