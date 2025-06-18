import 'package:flutter/material.dart';

typedef BottomNavItemTapCallback = void Function(int index);

class LogoBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final BottomNavItemTapCallback onItemSelected;

  const LogoBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
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
            default:
              iconData = Icons.image;
              label = 'Images';
              break;
          }

          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 60,
              color: isSelected ? Colors.white : Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    color: isSelected ? Colors.black : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.black : Colors.white,
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
