import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/bottom_navigation_buttons.dart';
import 'package:logo_app_flutter/components/step_trail_widget.dart';
import 'package:logo_app_flutter/fragments/choose_fonts_widget.dart';
import 'package:logo_app_flutter/fragments/customize_widget.dart';
import 'package:logo_app_flutter/fragments/information_widget.dart';
import 'package:logo_app_flutter/fragments/review_widget.dart';

class DesignInputScreen extends StatefulWidget {
  const DesignInputScreen({super.key});

  @override
  State<DesignInputScreen> createState() => _DesignInputScreenState();
}

class _DesignInputScreenState extends State<DesignInputScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<String> stepTitles = ["Information", "Choose Fonts", "Template"];

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
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildStepContent(int index) {
    switch (index) {
      case 0:
        return InformationWidget();
      case 1:
        return ChooseFontsWidget();
      case 2:
        return ReviewWidget();
      case 3:
        return CustomizeWidget();
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
      ),
      appBar: AppBar(
        title: const Text('Auto Design'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
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
