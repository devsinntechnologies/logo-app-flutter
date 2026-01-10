import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class CreateLogoButton extends StatelessWidget {
  const CreateLogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>DownloadLogo(svgLogo: "", companyName: "", sloganName: "")));
        // SnackBar snackBar = const SnackBar(
        //   content: Text('Create Logo button pressed!'),
        //   duration: Duration(milliseconds: 100),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Container(
        height: 160, // ✔️ This sets the height
        // width: 210,
        decoration: BoxDecoration(
          // color: const Color(0xFF5FD3F3),
                    gradient: ThemeColors.greenBlue,
      
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
                 padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // optional
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/createLogo.png',
                    width: 40,
                    // height: 40,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Create Logo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Icon(Icons.chevron_right, color: Colors.white,size: 35,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
