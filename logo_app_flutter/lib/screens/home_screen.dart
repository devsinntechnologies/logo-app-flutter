import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/components/GridButtons/auto_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/create_logo_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_logo_button.dart';
import 'package:logo_app_flutter/components/drawer_items.dart';
import 'package:logo_app_flutter/screens/google_sign_in_button.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: (MediaQuery.of(context).size.height > 500) ? 260 : 150,
              decoration: BoxDecoration(
                // color: Color(0xff16182D),

                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xFF16182D),
                //     Color(0xFF2A2D4F),
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
                gradient: ThemeColors.customGradient
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(
                      "assets/icons/SmartLogoMaker.png",
                    ),
                    // child: Image.asset(
                    //   "assets/icons/SmartLogoMaker.png",
                    //   width:
                    //       (MediaQuery.of(context).size.height > 500) ? 100 : 70,
                    // ),
                  ),
                  // if(MediaQuery.of(context).size.height > 500)
                  // const SizedBox(height: 30),
                  // if(MediaQuery.of(context).size.height > 500)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Smart Logo Maker",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  // DrawerItem(icon: Icons.workspace_premium, text: "Get PRO"),
                  // DrawerItem(icon: Icons.image, text: "My Logo"),

                  DrawerItem(icon: Icons.design_services, text: "My Design"),
                  DrawerItem(icon: Icons.create, text: "Create Logo"),
                  DrawerItem(icon: Icons.auto_awesome, text: "Auto Design"),
                  DrawerItem(icon: Icons.language, text: "Language"),
                  // DrawerItem(icon: Icons.apps, text: "More Apps"),
                  DrawerItem(icon: Icons.share, text: "Share"),
                  DrawerItem(icon: Icons.privacy_tip, text: "Privacy Policy"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: Image.asset(
                            "assets/icons/menu.png",
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                  ),
                  Center(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/logo_app.png',
                          // width: 30,
                          height: 30,
                        ),
                        // const SizedBox(width:2),
                        Text(
                          'SmartLogoMaker',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                 GoogleSignInButton(),
                  // SizedBox(width: 1),
                ],
              ),
              const SizedBox(height: 23),
              // GestureDetector(
              //   onTap: () {
              //     SnackBar snackBar = const SnackBar(
              //       content: Text('Template button pressed!'),
              //       duration: Duration(milliseconds: 100),
              //     );
              //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //   },
              //   child: Container(
              //     width: 330,
              //     height: 100,
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       // color: const Color(0xFF5FD3F3),
              //       gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //           Color(0xFFF96C8B), // Pinkish red
              //           Color(0xFFF99FBC),
              //         ],
              //       ),
              //       borderRadius: BorderRadius.circular(30),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.25),
              //           blurRadius: 10,
              //           spreadRadius: 3,
              //           offset: const Offset(2, 4),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center, // optional
              //       children: [
              //         Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Image.asset(
              //               'assets/icons/color-palette.png',
              //               width: 40,
              //               height: 40,
              //             ),
              //             SizedBox(width: 20),
              //             Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   textAlign: TextAlign.start,
              //                   'Template',
              //                   style: GoogleFonts.poppins(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.w600,
              //                     fontSize: 13,
              //                   ),
              //                 ),
              //                 Text(
              //                   'Edit and Save Logo Template',
              //                   style: GoogleFonts.poppins(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.normal,
              //                     fontSize: 13,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //         const Spacer(),
              //         Column(
              //           children: [
              //             const Icon(Icons.chevron_right, color: Colors.white),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            
              AutoDesignButton(),
              SizedBox(height: 4),
          
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Expanded(child: CreateLogoButton()), 
                  SizedBox(width: 10),
                  Expanded(child: MyDesignButton())],
                ),
              ),
              SizedBox(height: 30),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [MyLogoButton(), MyDesignButton()],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
