// import 'package:flutter/material.dart';
// import 'package:logo_app_flutter/components/bottom_navigation_buttons.dart';
// import 'package:logo_app_flutter/components/step_trail_widget.dart';
// import 'package:logo_app_flutter/fragments/choose_fonts_widget.dart';
// import 'package:logo_app_flutter/fragments/information_widget.dart';
// import 'package:logo_app_flutter/fragments/template_widget.dart';

// class DesignInputScreen extends StatefulWidget {
//   const DesignInputScreen({super.key});

//   @override
//   State<DesignInputScreen> createState() => _DesignInputScreenState();
// }

// class _DesignInputScreenState extends State<DesignInputScreen> {
//   int selectedFontIndex = 0;
//   int _currentStep = 0;
//   final PageController _pageController = PageController();
//   final ScrollController _scrollController = ScrollController();

//   List<String> stepTitles = ["Information", "Choose Fonts", "Template"];

//   // Add these fields to store user input
//   String companyName = '';
//   String slogan = '';
//   String category = 'Beauty & Massage'; // Default category

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _nextStep() {
//     if (_currentStep < stepTitles.length - 1) {
//       setState(() {
//         _currentStep++;
//       });
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       _scrollController.animateTo(
//         (_currentStep * 120).toDouble(),
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _prevStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep--;
//       });
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       _scrollController.animateTo(
//         (_currentStep * 120).toDouble(),
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _showExitConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Are you sure?'),
//           content: const Text(
//             'Do you really want to go back to the Home Screen?',
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 Navigator.pop(context); // Go back to Home Screen
//               },
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildStepContent(int index) {
//     switch (index) {
//       case 0:
//         return InformationWidget(
//           onSave: (String name, String slogan, String category) {
//             setState(() {
//               companyName = name;
//               this.slogan = slogan;
//               this.category = category;
//             });
//           },
//         );
//       case 1:
//         return ChooseFontsWidget(
//           onFontSelected: (int index) {
//             setState(() {
//               selectedFontIndex = index;
//             });
//             print('Selected font index: $index');
//           },
//         );

      
//       case 2:
//         return 
//         TemplateWidget(
//           companyName: companyName,
//           slogan: slogan,
//           category: category,
//           fontFamily: _getFontFamilyFromIndex(selectedFontIndex),
//           selectedFontIndex: selectedFontIndex,
//         );

//       default:
//         return const Center(child: Text('Unknown Step'));
//     }
//   }

 

//   TextStyle _getGoogleFontByIndex(int index) {
//   switch (index) {
//     case 0:
//       return GoogleFonts.roboto();
//     case 1:
//       return GoogleFonts.pacifico();
//     case 2:
//       return GoogleFonts.poppins();
//     case 3:
//       return GoogleFonts.dancingScript();
//     case 4:
//       return GoogleFonts.satisfy();
//     case 5:
//       return GoogleFonts.lato();
//     case 6:
//       return GoogleFonts.orbitron();
//     case 7:
//       return GoogleFonts.openSans();
//     case 8:
//       return GoogleFonts.bebasNeue();
//     case 9:
//       return GoogleFonts.pressStart2p();
//     default:
//       return GoogleFonts.roboto();
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationButtons(
//         currentStep: _currentStep,
//         totalSteps: stepTitles.length,
//         onNext: _nextStep,
//         onFinish: () => Navigator.pop(context),
//         onBack: _prevStep, // Call _prevStep to go back
//       ),
//       appBar: AppBar(
//         title: const Text('Auto Design'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed:
//               _showExitConfirmationDialog, // Show dialog when back button is pressed
//         ),
//       ),
//       body: Column(
//         children: [
//           const Divider(height: 1),
//           StepTrailWidget(
//             currentStep: _currentStep,
//             stepTitles: stepTitles,
//             scrollController: _scrollController,
//           ),
//           const Divider(height: 1),
//           const SizedBox(height: 10),
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: stepTitles.length,
//               itemBuilder: (context, index) => _buildStepContent(index),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/bottom_navigation_buttons.dart';
import 'package:logo_app_flutter/components/step_trail_widget.dart';
import 'package:logo_app_flutter/fragments/choose_fonts_widget.dart';
import 'package:logo_app_flutter/fragments/information_widget.dart';
import 'package:logo_app_flutter/fragments/template_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to go back to the Home Screen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: const Text('Yes'),
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
    return Scaffold(
      bottomNavigationBar: BottomNavigationButtons(
        currentStep: _currentStep,
        totalSteps: stepTitles.length,
        onNext: _nextStep,
        onFinish: () => Navigator.pop(context),
        onBack: _prevStep,
      ),
      appBar: AppBar(
        title: const Text('Auto Design'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showExitConfirmationDialog,
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          StepTrailWidget(
            currentStep: _currentStep,
            stepTitles: stepTitles,
            scrollController: _scrollController,
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stepTitles.length,
              itemBuilder: (context, index) => _buildStepContent(index),
            ),
          ),
        ],
      ),
    );
  }
}
