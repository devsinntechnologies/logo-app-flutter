import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

typedef BottomNavItemTapCallback = void Function(int index);

class LogoBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final BottomNavItemTapCallback onItemSelected;
  final bool hasTapped;

  const LogoBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.hasTapped,
  });

  @override
  State<LogoBottomNavBar> createState() => _LogoBottomNavBarState();
}

class _LogoBottomNavBarState extends State<LogoBottomNavBar> {
  int? scrollableIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // if (MediaQuery.of(context).size.height > 500)
          // if (widget.selectedIndex != -1)
          //   Container(height: 60, color: Colors.grey.shade200),
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                IconData iconData;
                String label;
      
                switch (index) {
                  case 0:
                    iconData = Icons.layers;
                    label =  S.of(context).background;
                    break;
                  case 1:
                    iconData = Icons.article_rounded;
                    label = S.of(context).art;
                    break;
                  case 2:
                    iconData = Icons.text_fields_outlined;
                    label = S.of(context).text;
                    break;
                  case 3:
                    iconData = Icons.edit;
                    label = S.of(context).effects;
                    break;
                  case 4:
                    iconData = Icons.palette;
                    label = S.of(context).palette;
                    break;
                  default:
                    iconData = Icons.image;
                    label = S.of(context).images;
                    break;
                }
      
                final isSelected = widget.selectedIndex == index;
                final isScrollEnabled = scrollableIndex == index;
      
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      scrollableIndex = (scrollableIndex == index) ? null : index;
                    });
      
                    if (widget.selectedIndex == index) {
                      widget.onItemSelected(-1);
                    } else {
                      widget.onItemSelected(index);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: 60,
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          color:
                              (isSelected &&
                                      widget.hasTapped &&
                                      widget.selectedIndex != -1)
                                  ? Colors.black
                                  : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 25,
                          child: AutoScrollText(
                            text: label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected && widget.hasTapped
                                      ? Colors.black
                                      : Colors.grey.shade600,
                            ),
                            scroll:
                                isSelected &&
                                widget.hasTapped, // scroll only on white
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool scroll; // true when selected

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    required this.scroll,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
      if (_controller.hasClients) {
        _controller.jumpTo(
          _animationController.value * _controller.position.maxScrollExtent,
        );
      }
    });

    if (widget.scroll) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scroll != oldWidget.scroll) {
      if (widget.scroll) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _controller.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Text(widget.text, style: widget.style),
    );
  }
}
