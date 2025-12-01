import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/bottom_navigation_buttons.dart';
import 'package:logo_app_flutter/components/step_trail_widget.dart';
import 'package:logo_app_flutter/fragments/choose_fonts_widget.dart';
import 'package:logo_app_flutter/fragments/information_widget.dart';
import 'package:logo_app_flutter/fragments/template_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class DesignInputScreen extends StatefulWidget {
  const DesignInputScreen({super.key});

  @override
  State<DesignInputScreen> createState() => _DesignInputScreenState();
}

class _DesignInputScreenState extends State<DesignInputScreen> {
  int selectedFontIndex = 0;
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<String> stepTitles = ["Information", "Choose Fonts", "Template"];

  String companyName = '';
  String slogan = '';
  String category = 'Beauty & Massage';

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (companyName.isEmpty || slogan.isEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Please enter both Company Name and Slogan.'),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
        return;
      }
    }

    if (_currentStep < stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _scrollController.animateTo(
        (_currentStep * 120).toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _scrollController.animateTo(
        (_currentStep * 120).toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you really want to go back to the Home Screen?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',style: TextStyle(color: ThemeColors.purple),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: const Text('Yes',style: TextStyle(color: ThemeColors.purple),),
            ),
          ],
        );
      },
    );
  }

  TextStyle _getFontStyleByIndex(int index) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto();
      case 1:
        return GoogleFonts.pacifico();
      case 2:
        return GoogleFonts.poppins();
      case 3:
        return GoogleFonts.dancingScript();
      case 4:
        return GoogleFonts.satisfy();
      case 5:
        return GoogleFonts.lato();
      case 6:
        return GoogleFonts.orbitron();
      case 7:
        return GoogleFonts.openSans();
      case 8:
        return GoogleFonts.bebasNeue();
      case 9:
        return GoogleFonts.pressStart2p();
      default:
        return GoogleFonts.roboto();
    }
  }

  Widget _buildStepContent(int index) {
    switch (index) {
      case 0:
        return InformationWidget(
          onSave: (String name, String slogan, String category) {
            setState(() {
              companyName = name;
              this.slogan = slogan;
              this.category = category;
            });
          },
        );
      case 1:
        return ChooseFontsWidget(
          onFontSelected: (int index) {
            setState(() {
              selectedFontIndex = index;
            });
          },
        );
      case 2:
        return TemplateWidget(
          companyName: companyName,
          slogan: slogan,
          category: category,
          selectedFontIndex: selectedFontIndex,
          fontStyle: _getFontStyleByIndex(selectedFontIndex),
          fontFamily: '',
        );
      default:
        return const Center(child: Text('Unknown Step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: BottomNavigationButtons(
        currentStep: _currentStep,
        totalSteps: stepTitles.length,
        onNext: _nextStep,
        onBack: _prevStep,
        onFinish: () => Navigator.pop(context),
        companyName: companyName,
        slogan: slogan,
      ),

      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Auto Design'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showExitConfirmationDialog,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            StepTrailWidget(
              currentStep: _currentStep,
              stepTitles: stepTitles,
              scrollController: _scrollController,
            ),
            const Divider(height: 1),
            const SizedBox(height: 10),
            SizedBox(
              height: screenHeight* 0.72,
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stepTitles.length,
                itemBuilder: (context, index) => _buildStepContent(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
