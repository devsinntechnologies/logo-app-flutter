
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
      height: 100,
      child: BottomAppBar(
        color: Colors.black,
        child: Row(
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

            return Expanded(
              child: GestureDetector(
                onTap: () => onItemSelected(index),
                child: SizedBox.expand(
                  child: Container(
                    color: isSelected ? Colors.white : Colors.transparent,
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
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}