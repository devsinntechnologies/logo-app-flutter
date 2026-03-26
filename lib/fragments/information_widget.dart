import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';

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
  String selectedCategory = '';

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

  @override
  void dispose() {
    nameController.dispose();
    sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      S.of(context).automotiveTransportation,
      S.of(context).beautyMassage,
      S.of(context).businessConsulting,
      S.of(context).childrenEducation,
      S.of(context).entertainmentArtMusic,
      S.of(context).familyServicesCounseling,
      S.of(context).financeInsurance,
      S.of(context).foodBeverageRestaurant,
      S.of(context).healthCarePublicSafety,
      S.of(context).holidaySpecialOccasion,
      S.of(context).itEngineeringScience,
      S.of(context).legalPolitics,
      S.of(context).petsAnimal,
      S.of(context).photography,
      S.of(context).sportsFitness,
    ];
    if (selectedCategory.isEmpty || !categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              S.of(context).ChooseIndustry,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 35),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16),
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
            Text(
              S.of(context).companyName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 330,
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                maxLength: 10,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  counterText: "",
                  hintText: S.of(context).enterCompany,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
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
            Text(
              S.of(context).sloganName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 330,
              child: TextField(
                controller: sloganController,
                textAlign: TextAlign.center,
                maxLength: 20,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    // focused outline color
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  counterText: "",
                  hintText: S.of(context).enterSlogan,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
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
