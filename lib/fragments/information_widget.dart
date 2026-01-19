import 'package:flutter/material.dart';

class InformationWidget extends StatefulWidget {
  final Function(String, String, String) onSave;
  final String? initialName;
  final String? initialSlogan;
  final String? initialCategory;

  const InformationWidget({
    super.key,
    required this.onSave,
    this.initialName,
    this.initialSlogan,
    this.initialCategory,
  });

  @override
  State<InformationWidget> createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();
  String selectedCategory = 'Beauty & Massage';

  @override
  void initState() {
    super.initState();
    // Load initial values if provided
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      nameController.text = widget.initialName!;
    }
    if (widget.initialSlogan != null && widget.initialSlogan!.isNotEmpty) {
      sloganController.text = widget.initialSlogan!;
    }
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      selectedCategory = widget.initialCategory!;
    }
  }

  final List<String> categories = [
    'Automotive & Transportation',
    'Beauty & Massage',
    'Business & Consulting',
    'Children & Education',
    'Entertainment, Art & Music',
    'Family Services & Counseling',
    'Finance & Insurance',
    'Food, Beverage & Restaurant',
    'Health Care & Public Safety',
    'Holiday & Special Occasion',
    'IT, Engineering & Science',
    'Legal & Politics',
    'Pets & Animal',
    'Photography',
    'Sports & Fitness',
  ];

  @override
  void dispose() {
    nameController.dispose();
    sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "CHOOSE INDUSTRY",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 35),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                    widget.onSave(
                      nameController.text,
                      sloganController.text,
                      selectedCategory,
                    );
                  },
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "YOUR COMPANY NAME",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 330,
              child: TextField(
                style: TextStyle(
                  color: Colors.black, // This makes the text black
                ),
                controller: nameController,
                textAlign: TextAlign.center,
                maxLength: 10,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  counterText: "",
                  hintText: 'Enter your company name',
                  hintStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (text) {
                  widget.onSave(text, sloganController.text, selectedCategory);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "SLOGAN",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 330,
              child: TextField(
                style: TextStyle(
                  color: Colors.black, // This makes the text black
                ),
                controller: sloganController,
                textAlign: TextAlign.center,
                maxLength: 20,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    // focused outline color
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  counterText: "",
                  hintText: 'Enter your slogan',
                  hintStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (text) {
                  widget.onSave(nameController.text, text, selectedCategory);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
