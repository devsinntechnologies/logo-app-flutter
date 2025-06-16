import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  late Offset logoPosition;
  late Offset companyNamePosition;
  late Offset sloganPosition;

  // State variable for grid visibility
  bool _showGrid = false;
  // NEW: State variable for layers ribbon extension
  bool _isLayersRibbonExtended = false;

  @override
  void initState() {
    super.initState();
    logoPosition = const Offset(150, 100);
    companyNamePosition = const Offset(160, 200);
    sloganPosition = const Offset(150, 240);
  }

  bool isEditing = false;
  int? selectedElement;
  int selectedIndex = 0;

  double logoSize = 100;
  double companyNameSize = 20;
  double sloganSize = 18;

  double logoRotation = 0;
  double companyNameRotation = 0;
  double sloganRotation = 0;

  final double dragLimit = 300;

  Offset _limitOffset(Offset original, Offset delta) {
    final newOffset = original + delta;
    if (newOffset.dy > dragLimit) {
      return Offset(newOffset.dx, dragLimit);
    }
    return newOffset;
  }

  void _deleteElement() {
    setState(() {
      // In a real app, you would remove the element from a list here
      selectedElement = null; // Deselect
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Element deleted!')));
    });
  }

  void _splitElement() {
    setState(() {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Element split!')));
    });
  }

  void _rotateElement() {
    setState(() {
      if (selectedElement == 0) {
        logoRotation += 45;
        if (logoRotation >= 360) logoRotation = 0;
      } else if (selectedElement == 1) {
        companyNameRotation += 45;
        if (companyNameRotation >= 360) companyNameRotation = 0;
      } else if (selectedElement == 2) {
        sloganRotation += 45;
        if (sloganRotation >= 360) sloganRotation = 0;
      }
    });
  }

  void _resizeElement() {
    setState(() {
      if (selectedElement == 0) {
        logoSize = logoSize == 100 ? 150 : 100;
      } else if (selectedElement == 1) {
        companyNameSize = companyNameSize == 20 ? 30 : 20;
      } else if (selectedElement == 2) {
        sloganSize = sloganSize == 18 ? 26 : 18;
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
    required VoidCallback onTap,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(alignment.x * 15, alignment.y * 15),
        child: GestureDetector(
          onTap: onTap,
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

  // scaffold
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
            icon: const Icon(Icons.save, size: 40),
            onPressed: _showSaveOptions,
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 40),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
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
          ),
        ],
      ),

      // Main content
      body: Stack(
        children: [
          // This container provides the basic white background for the canvas area
          Container(height: 500, width: double.infinity, color: Colors.white),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Grid lines as the first child of the Stack
                    if (_showGrid)
                      CustomPaint(
                        painter: _GridPainter(
                          gridColor: Colors.black, // Adjust grid color
                        ),
                        // Size.infinite will make it fill the parent Stack's bounds
                        size: Size.infinite,
                      ),

                    // Floating Grid Toggle Button (ribbon style - top right)
                    Positioned(
                      top: 20, // Adjust vertical position
                      right: 0, // Flush with the right edge
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showGrid = !_showGrid;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700, // Darker grey for the ribbon
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25.0),    // Curved top-left
                              bottomLeft: Radius.circular(25.0), // Curved bottom-left
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(-2, 2), // Shadow for bulging effect from right
                              ),
                            ],
                          ),
                          child: Icon(
                            _showGrid ? Icons.grid_off : Icons.grid_on, // Icon changes based on state
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    // --- NEW: Floating Layers Ribbon Button (top left) ---
                    Positioned(
                      top: 20, // Adjust vertical position, same as grid button
                      left: 0, // Flush with the left edge
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLayersRibbonExtended = !_isLayersRibbonExtended;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), // Smooth animation duration
                          width: _isLayersRibbonExtended ? 180.0 : 60.0, // Expanded vs. retracted width
                          height: 44.0, // Fixed height for the ribbon
                          curve: Curves.easeInOut, // Smooth animation curve
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700, // Darker grey for the ribbon
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(25.0),    // Curved top-right
                              bottomRight: Radius.circular(25.0), // Curved bottom-right
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(2, 2), // Shadow for bulging effect from left
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Wrap content
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0), // Padding for the icon
                                child: Icon(
                                  _isLayersRibbonExtended
                                      ? Icons.arrow_back_ios // Left arrow when extended
                                      : Icons.layers, // Layers icon when retracted
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              if (_isLayersRibbonExtended) // Show text only when extended
                                Expanded( // Allows text to fill remaining space
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                                    child: Text(
                                      'No Layers Found',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      softWrap: false, // Prevent text from wrapping
                                      overflow: TextOverflow.fade, // Fade if text is too long during animation
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // --- END NEW ---

                    // Company Name
                    Positioned(
                      left: companyNamePosition.dx,
                      top: companyNamePosition.dy,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedElement = 1;
                          });
                        },
                        onPanUpdate: isEditing && selectedElement == 1
                            ? (details) {
                          setState(() {
                            companyNamePosition = _limitOffset(
                              companyNamePosition,
                              details.delta,
                            );
                          });
                        }
                            : null,
                        child: Container(
                          decoration: selectedElement == 1
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
                                angle: companyNameRotation * 3.14159 / 180,
                                child: Text(
                                  widget.companyName,
                                  style: TextStyle(
                                    fontSize: companyNameSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (selectedElement == 1 && isEditing) ...[
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
                                    onTap: _rotateElement,
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
                                    onTap: _resizeElement,
                                    alignment: Alignment.bottomRight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Slogan
                    Positioned(
                      left: sloganPosition.dx,
                      top: sloganPosition.dy,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedElement = 2;
                          });
                        },
                        onPanUpdate: isEditing && selectedElement == 2
                            ? (details) {
                          setState(() {
                            sloganPosition = _limitOffset(
                              sloganPosition,
                              details.delta,
                            );
                          });
                        }
                            : null,
                        child: Container(
                          decoration: selectedElement == 2
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
                                angle: sloganRotation * 3.14159 / 180,
                                child: Text(
                                  widget.sloganName,
                                  style: TextStyle(
                                    fontSize: sloganSize,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              if (selectedElement == 2 && isEditing) ...[
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
                                    onTap: _rotateElement,
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
                                    onTap: _resizeElement,
                                    alignment: Alignment.bottomRight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Logo
                    Positioned(
                      left: logoPosition.dx,
                      top: logoPosition.dy,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedElement = 0;
                          });
                        },
                        onPanUpdate: isEditing && selectedElement == 0
                            ? (details) {
                          setState(() {
                            logoPosition = _limitOffset(
                              logoPosition,
                              details.delta,
                            );
                          });
                        }
                            : null,
                        child: Container(
                          decoration: selectedElement == 0
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
                                angle: logoRotation * 3.14159 / 180,
                                child: SvgPicture.string(
                                  widget.svgLogo,
                                  height: logoSize,
                                  width: logoSize,
                                ),
                              ),
                              if (selectedElement == 0 && isEditing) ...[
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
                                    onTap: _rotateElement,
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
                                    onTap: _resizeElement,
                                    alignment: Alignment.bottomRight,
                                  ),
                                ),
                              ],
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
                  Container(height: 300, color: Colors.grey.shade200)
                ],
              ),
            ],
          ),
        ],
      ),

      //bottom bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    isEditing = !isEditing;
                    selectedIndex = 0;
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

            return GestureDetector(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      iconData,
                      color: isSelected ? Colors.black : Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// CustomPainter for drawing the fixed 4x4 dotted grid
class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  // Define properties for dotted lines
  final double _dashWidth = 4.0; // Length of each dash segment
  final double _dashSpace = 4.0; // Length of space between dashes
  final double _strokeWidth = 2.0; // Thickness of the dotted line

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = gridColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke; // Ensure it draws lines

    // Calculate fixed spacing for a 4x4 grid
    // For 4 columns/rows, we need 5 lines (0, 1/4, 2/4, 3/4, 4/4)
    final double colStep = size.width / 4;
    final double rowStep = size.height / 4;

    // Draw horizontal dotted lines (5 lines for 4 rows)
    for (int i = 0; i <= 4; i++) {
      final double y = i * rowStep;
      double currentX = 0;
      while (currentX < size.width) {
        double segmentEnd = currentX + _dashWidth;
        // Ensure the last dash doesn't draw beyond the canvas width
        if (segmentEnd > size.width) {
          segmentEnd = size.width;
        }
        canvas.drawLine(Offset(currentX, y), Offset(segmentEnd, y), paint);
        currentX += _dashWidth + _dashSpace;
      }
    }

    // Draw vertical dotted lines (5 lines for 4 columns)
    for (int i = 0; i <= 4; i++) {
      final double x = i * colStep;
      double currentY = 0;
      while (currentY < size.height) {
        double segmentEnd = currentY + _dashWidth;
        // Ensure the last dash doesn't draw beyond the canvas height
        if (segmentEnd > size.height) {
          segmentEnd = size.height;
        }
        canvas.drawLine(Offset(x, currentY), Offset(x, segmentEnd), paint);
        currentY += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    // Only repaint if the grid color changes.
    // Dashing properties are fixed within the painter.
    return oldDelegate.gridColor != gridColor;
  }
}