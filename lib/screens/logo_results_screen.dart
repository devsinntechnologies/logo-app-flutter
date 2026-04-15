import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/dashboard/dashboard_card.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:logo_app_flutter/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:logo_app_flutter/components/logo_results/logo_detail_dialog.dart';
import '../provider/business_info_provider.dart';
import '../provider/logo_results_provider.dart';
import '../components/logo_results/logo_result_card.dart';

class LogoResultsScreen extends StatelessWidget {
  const LogoResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F9),
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF1F1F39), size: 20),
            ),
          ),
        ),
       
        title: const Text(
          'Your Logos',
          style: TextStyle(
            color: Color(0xFF1F1F39),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Consumer<BusinessInfoProvider>(
              builder: (context, info, child) {
                return GestureDetector(
                  onTap: () => context.read<LogoResultsProvider>().fetchLogos(
                        info.businessName,
                        info.slogan,
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh_outlined,
                        color: Color(0xFF1F1F39), size: 20),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2), child: DividerContainer()
            //  Container(
            //   height: 2,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Color(0xFFFF8A65),
            //         Color(0xFFE91E63),
            //         Color(0xFF9C27B0)
            //       ],
            //     ),
            //   ),
            // ),

            ),
      ),
      body: Consumer<LogoResultsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE91E63)),
                  SizedBox(height: 20),
                  Text(
                    'Generating more logos...',
                    style: TextStyle(
                      color: Color(0xFF4A4A6A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.generatedLogos.isEmpty) {
            return const Center(
              child: Text(
                'No logos generated yet.',
                style: TextStyle(color: Color(0xFF4A4A6A)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Consumer<BusinessInfoProvider>(
                  builder: (context, info, child) {
                    return Text(
                      'We generated ${provider.generatedLogos.length} unique logos for ${info.businessName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4A4A6A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 35),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 25,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: provider.generatedLogos.length,
                  itemBuilder: (context, index) {
                    final logo = provider.generatedLogos[index];
                    return LogoResultCard(
                      name: logo.name,
                      svg: logo.svg,
                      colors: logo.colors,
                      isFavorite: logo.isFavorite,
                      onFavoriteTap: () => provider.toggleFavorite(index),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => LogoDetailDialog(
                            name: logo.name,
                            svg: logo.svg,
                            colors: logo.colors,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
