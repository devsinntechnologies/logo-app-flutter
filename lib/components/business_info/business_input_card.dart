import 'package:flutter/material.dart';

class BusinessInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final IconData icon;
  final Color iconBgColor;
  final TextEditingController controller;
  final int maxLength;
  final Function(String) onChanged;

  const BusinessInputCard({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.iconBgColor,
    required this.controller,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4A4A6A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                cursorColor: Colors.black,
                cursorHeight: 20,
                cursorWidth: 1,
                controller: controller,
                maxLength: maxLength,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  counterText: "", // Standard counter removed
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    // borderSide: BorderSide.none,
                    borderSide: BorderSide(color: Color(0xffFA83B2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    // borderSide: BorderSide.none,
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    // borderSide: BorderSide.none,
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: onChanged,
              ),
              // Custom counter on left side
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 10),
                child: Text(
                  '${controller.text.length}/$maxLength characters',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
