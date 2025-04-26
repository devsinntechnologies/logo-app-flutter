import 'package:flutter/material.dart';

class DesignInputScreen extends StatefulWidget {
  const DesignInputScreen({super.key});

  @override
  State<DesignInputScreen> createState() => _DesignInputScreenState();
}

class _DesignInputScreenState extends State<DesignInputScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Design'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            _currentStep >= 0
                                ? Colors.yellow
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('1')),
                    ),
                    SizedBox(height: 4),
                    Text('Info', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 1 ? Colors.yellow : Colors.grey[300],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            _currentStep >= 1
                                ? Colors.yellow
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('2')),
                    ),
                    SizedBox(height: 4),
                    Text('Fonts', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 2 ? Colors.yellow : Colors.grey[300],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            _currentStep >= 2
                                ? Colors.yellow
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('3')),
                    ),
                    SizedBox(height: 4),
                    Text('Review', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _currentStep == 0
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'CHOOSE INDUSTRY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Beauty & Massage'),
                                Icon(Icons.check, color: Colors.blue),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: Text(
                              'YOUR COMPANY NAME',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Hm Beauty', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text(
                            'SLOGAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Beauty for everyone',
                            style: TextStyle(fontSize: 16),
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep = 1;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('NEXT'),
                                  Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : _currentStep == 1
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'CHOOSE FONT',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Elegant Font'),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Modern Font'),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Classic Font'),
                          ),
                          Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep = 2;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('NEXT'),
                                  Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'REVIEW & FINISH',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Company: Hm Beauty',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Slogan: Beauty for everyone',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Selected Industry: Beauty & Massage',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Selected Font: Elegant Font',
                            style: TextStyle(fontSize: 16),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('FINISH'),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
