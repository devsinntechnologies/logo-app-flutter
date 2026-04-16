import 'package:flutter/material.dart';

class BusinessInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final Widget icon;
  final Color iconBgColor;
  final Color borderBgColor;

  final TextEditingController controller;
  final int maxLength;
  final Function(String) onChanged;

  const BusinessInputCard({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.iconBgColor,
    required this.borderBgColor,
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0.1,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: icon
                  // Icon(icon, color: Colors.white, size: 22),
                  ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                    color: Color(0xFF4A4A6A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                cursorHeight: 20,
                cursorWidth: 1,
                controller: controller,
                maxLength: maxLength,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                  counterText: "", // Standard counter removed
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    // borderSide: BorderSide.none,
                    borderSide: BorderSide(color: borderBgColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    // borderSide: BorderSide.none,
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
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
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
