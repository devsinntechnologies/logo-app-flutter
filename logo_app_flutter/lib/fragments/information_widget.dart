import 'package:flutter/material.dart';

class InformationWidget extends StatefulWidget {
  @override
  _InformationWidgetState createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter, // keep it at top
          child: Container(
            height: 60, // Set fixed height
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 35,
                  color: Colors.black,
                ),
                style: TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items:
                    categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),

        Text(
          "YOUR COMPANY NAME",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8), // Space between text and text field
        SizedBox(
          width: 330,
          // height: 50,
          child: TextField(
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter your company name',
            ),
          ),
        ),
        SizedBox(height: 16), // Space between text field and next button
        Text(
          "SLOGAN",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8), // Space between text and text field
        SizedBox(
          width: 330,
          // height: 50,
          child: TextField(
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter your slogan',
            ),
          ),
        ),
      ],
    );
  }
}
