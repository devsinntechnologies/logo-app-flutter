import 'package:flutter/material.dart';

class InformationWidget extends StatefulWidget {
  final Function(String, String, String) onSave;

  const InformationWidget({super.key, required this.onSave});

  @override
  State<InformationWidget> createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();
  String selectedCategory = 'Beauty & Massage';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "CHOOSE INDUSTRY",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                ),
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  // ✅ Theme-aware container colors
                  color: isDark ? Colors.grey[850] : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 35,
                      color: Theme.of(context).textTheme.bodyLarge?.color, 
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, 
                      fontSize: 16,
                    ),
                    dropdownColor: isDark ? Colors.grey[850] : Colors.white, 
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                      widget.onSave(nameController.text, sloganController.text, selectedCategory);
                    },
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color, 
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Text(
                "YOUR COMPANY NAME",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 330,
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your company name',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey, 
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white, 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (text) {
                    widget.onSave(text, sloganController.text, selectedCategory);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "SLOGAN",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 330,
                child: TextField(
                  controller: sloganController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color, 
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your slogan',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey, 
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white, 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ),
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
      ),
    );
  }
}