// import 'package:flutter/material.dart';

// typedef BottomNavItemTapCallback = void Function(int index);

// class LogoBottomNavBar extends StatefulWidget {
//   final int selectedIndex;
//   final BottomNavItemTapCallback onItemSelected;
//   final bool hasTapped;

//   const LogoBottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemSelected,
//     required this.hasTapped,
//   });

//   @override
//   State<LogoBottomNavBar> createState() => _LogoBottomNavBarState();
// }

// class _LogoBottomNavBarState extends State<LogoBottomNavBar> {
//   int? expandedIndex;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: SizedBox(
//         height: 70,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List.generate(6, (index) {
//             IconData iconData;
//             String label;

//             switch (index) {
//               case 0:
//                 iconData = Icons.layers;
//                 label = 'Background';

//                 break;
//               case 1:
//                 iconData = Icons.article_rounded;
//                 label = 'Art';
//                 break;
//               case 2:
//                 iconData = Icons.text_fields_outlined;
//                 label = 'Text';
//                 break;
//               case 3:
//                 iconData = Icons.edit;
//                 label = 'Effects';

//                 break;
//                 case 4:
//                 iconData = Icons.palette;
//                 label = 'Palette';

//                 break;
//               case 5:
//               default:
//                 iconData = Icons.image;
//                 label = 'Images';

//                 break;
//             }

//             final isSelected = widget.selectedIndex == index;
//              final isExpanded = expandedIndex == index;

//             return GestureDetector(
//               onTap: () => widget.onItemSelected(index),
//               child: Container(
//                 // margin: EdgeInsets.only(bottom: 20),
//                 width: MediaQuery.of(context).size.width / 6,
//                 height: 60,
//                 color: isSelected && widget.hasTapped ? Colors.white : Colors.black,

//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       iconData,
//                       color:
//                           isSelected && widget.hasTapped ? Colors.black : Colors.white,

//                       size: 20,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         color:
//                             isSelected && widget.hasTapped
//                                 ? Colors.black
//                                 : Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

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
    return Container(
      height: 60,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          IconData iconData;
          String label;

          switch (index) {
            case 0:
              iconData = Icons.layers;
              label = 'Background';
              break;
            case 1:
              iconData = Icons.article_rounded;
              label = 'Art';
              break;
            case 2:
              iconData = Icons.text_fields_outlined;
              label = 'Text';
              break;
            case 3:
              iconData = Icons.edit;
              label = 'Effects';
              break;
            case 4:
              iconData = Icons.palette;
              label = 'Palette';
              break;
            default:
              iconData = Icons.image;
              label = 'Images';
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
              color:
                  (isSelected && widget.hasTapped && widget.selectedIndex != -1)
                      ? Colors.white
                      : Colors.black,

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
                            : Colors.white,

                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 25,
                    child:
                        isScrollEnabled
                            ? SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected && widget.hasTapped
                                          ? Colors.black
                                          : Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              label,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected && widget.hasTapped
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
