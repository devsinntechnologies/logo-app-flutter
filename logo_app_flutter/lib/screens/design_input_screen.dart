import 'package:flutter/material.dart';

// Main StatefulWidget for the Design Input Screen
class DesignInputScreen extends StatefulWidget {
  const DesignInputScreen({super.key});

  @override
  State<DesignInputScreen> createState() => _DesignInputScreenState();
}

// State class for DesignInputScreen
class _DesignInputScreenState extends State<DesignInputScreen> {
  int _currentStep = 0; // Tracks the current step
  final PageController _pageController =
      PageController(); // Controls the PageView
  final ScrollController _scrollController =
      ScrollController(); // Controls the horizontal scroll

  // Titles for each step
  List<String> stepTitles = [
    "Information",
    "Choose Fonts",
    "Review",
    "Customize",
    "Download",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Moves to the next step
  void _nextStep() {
    if (_currentStep < stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Scrolls forward in the step indicator
      _scrollController.animateTo(
        (_currentStep * 120).toDouble(),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Moves to the previous step
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Scrolls backward in the step indicator
      _scrollController.animateTo(
        (_currentStep * 120).toDouble(),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context); // Exits the screen if on the first step
    }
  }

  // Builds a single step indicator
  Widget _buildStep(int index) {
    bool isCompleted = index < _currentStep; // Checks if the step is completed
    bool isActive = index == _currentStep; // Checks if the step is active

    return Row(
      children: [
        Row(
          children: [
            // Step circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isCompleted || isActive ? Colors.orange : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}', // Step number
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Step title
            Text(
              stepTitles[index],
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
        // Connector line between steps
        if (index != stepTitles.length - 1)
          Container(
            width: 80,
            height: 2,
            color: index < _currentStep ? Colors.orange : Colors.grey[300],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Design'), // AppBar title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ), // Back button
      ),
      body: Column(
        children: [
          const Divider(height: 1), // Divider above the step indicator
          // Step indicator container
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  stepTitles.length,
                  (index) => _buildStep(index), // Builds each step indicator
                ),
              ),
            ),
          ),
          const Divider(height: 1), // Divider below the step indicator
          // PageView for step content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Disables user swipe
              itemCount: stepTitles.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    'Step ${index + 1}: ${stepTitles[index]}', // Displays step content
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep < stepTitles.length - 1)
                  ElevatedButton(
                    onPressed: _nextStep, // Next button
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next'),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Finish button
                    },
                    child: Text('Finish'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
