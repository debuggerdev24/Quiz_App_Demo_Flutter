import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:mcq_demo_task/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../provider/quiz_provider.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.lightBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.blue.shade800,

            title: Text(
              provider.lesson?.title ?? "Quiz App",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            elevation: 8,
            shadowColor: AppColors.primaryColor.withValues(alpha: 0.5),
            //todo Add a simple progress indicator (assuming provider has a current index)
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: 1.0 / provider.lesson!.activities.length,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                    color: AppColors.primaryColor,
                  ),
                )
              : provider.lesson == null
              ? FadeIn(
                  child: const Center(
                    child: Text(
                      "Failed to load lesson",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //todo 1. Question Card with enhanced styling
                        ZoomIn(
                          duration: const Duration(milliseconds: 600),
                          child: Card(
                            color: AppColors.secondaryColor,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                spacing: 12,

                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question 1 / ${provider.lesson!.activities.length}', // Added progress text
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.primaryColor.withOpacity(
                                        0.8,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  //todo 2. Bolder, larger question text
                                  Text(
                                    provider.lesson!.activities[0].question,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        //todo 2. Animated Label - Slide from Left
                        FadeInLeft(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'Choose your answer:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        //todo Animated Options List
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                provider.lesson!.activities[0].options.length,
                            itemBuilder: (context, index) {
                              final option =
                                  provider.lesson!.activities[0].options[index];

                              return FadeInRight(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(
                                  milliseconds: 400 + (index * 150),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: AnimatedOptionCard(
                                    key: ValueKey(
                                      '$option-${provider.selectedAnswer}-${provider.hasAnswered}',
                                    ),
                                    option: option,
                                    provider: provider,
                                    // primaryColor: null,
                                    primaryColor:
                                        AppColors.primaryColor, // Pass color
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        //todo Animated Try Again Button
                        if (provider.hasAnswered)
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                              ), // Increased space
                              child: ElevatedButton(
                                onPressed: provider.resetQuiz,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8, // Enhanced button shadow
                                ),
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

//todo Custom Animated Option Card Widget
class AnimatedOptionCard extends StatelessWidget {
  final String option;
  final QuizProvider provider;
  final Color primaryColor;

  const AnimatedOptionCard({
    super.key,
    required this.option,
    required this.provider,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.selectedAnswer == option;
    final hasAnswered = provider.hasAnswered;

    //todo Define vibrant correct/incorrect colors
    Color baseColor = Colors.white;
    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];

    //todo Get color from provider (assuming provider.getOptionColor is updated)
    Color containerColor = provider.getOptionColor(option);

    //todo Default/Unselected state styling
    if (!hasAnswered) {
      containerColor = baseColor;
      if (isSelected) {
        containerColor = primaryColor.withValues(alpha: 0.1);
        shadows = [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
      }
    } else {
      //todo Answered state: make correct/incorrect feedback pop more
      if (containerColor == Colors.green) {
        shadows = [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ];
      } else if (containerColor == Colors.red) {
        shadows = [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ];
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      // 3. Enhanced Decoration
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16), // More rounded
        border: Border.all(
          color: isSelected && !hasAnswered
              ? primaryColor
              : Colors.transparent, // Highlight selected before checking
          width: 3,
        ),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : () => provider.handleAnswer(option),
          borderRadius: BorderRadius.circular(16),
          // 2. Increased padding for a more spacious look
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: containerColor == baseColor
                          ? Colors.black87
                          : containerColor == Colors.green
                          ? Colors.white
                          : containerColor == Colors.red
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                _buildIcon(provider), // Pass provider for icon
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(QuizProvider provider) {
    final icon = provider.getOptionIcon(option);

    if (icon == null) {
      return const SizedBox(width: 30, height: 30);
    }

    //todo Simple fade in animation for icons
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Icon(
        icon,
        color: provider.getOptionIconColor(option),
        size: 30, // Slightly larger icon
      ),
    );
  }
}
