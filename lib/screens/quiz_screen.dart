import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/quiz_provider.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blueAccent.shade700,
            title: Text(
              provider.lesson?.title ?? "Quiz App",
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            elevation: 2,
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(strokeCap: StrokeCap.round),
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
                        //todo Animated Question Card
                        ZoomIn(
                          duration: const Duration(milliseconds: 600),
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    provider.lesson!.activities[0].question,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Animated Label - Slide from Left
                        FadeInLeft(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'Choose your answer:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        //todo Animated Options List
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                provider.lesson!.activities[0].options.length,
                            itemBuilder: (context, index) {
                              final option =
                                  provider.lesson!.activities[0].options[index];

                              //todo Staggered slide animation for each option
                              return FadeInRight(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(
                                  milliseconds: 400 + (index * 150),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: AnimatedOptionCard(
                                    key: ValueKey(
                                      '$option-${provider.hasAnswered}',
                                    ),
                                    option: option,
                                    provider: provider,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Animated Try Again Button
                        if (provider.hasAnswered)
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton(
                                onPressed: provider.resetQuiz,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(fontSize: 16),
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
class AnimatedOptionCard extends StatefulWidget {
  final String option;
  final QuizProvider provider;

  const AnimatedOptionCard({
    super.key,
    required this.option,
    required this.provider,
  });

  @override
  State<AnimatedOptionCard> createState() => _AnimatedOptionCardState();
}

class _AnimatedOptionCardState extends State<AnimatedOptionCard> {
  bool _shouldShake = false;

  @override
  void didUpdateWidget(AnimatedOptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake when answer is revealed and this option is wrong
    if (!oldWidget.provider.hasAnswered && widget.provider.hasAnswered) {
      final isSelected = widget.provider.selectedAnswer == widget.option;
      final correctAnswer = widget.provider.lesson!.activities[0].answer;
      final isWrong = isSelected && widget.option != correctAnswer;

      if (isWrong) {
        setState(() {
          _shouldShake = true;
        });

        // Reset shake state after animation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _shouldShake = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.provider.selectedAnswer == widget.option;
    final hasAnswered = widget.provider.hasAnswered;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.provider.getOptionColor(widget.option),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blueAccent.shade700 : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blueAccent.shade700.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered
              ? null
              : () => widget.provider.handleAnswer(widget.option),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.option,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildIcon(),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply shake animation if wrong answer
    if (_shouldShake) {
      return ElasticIn(
        duration: const Duration(milliseconds: 500),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildIcon() {
    final icon = widget.provider.getOptionIcon(widget.option);

    if (icon == null) {
      return const SizedBox(width: 28, height: 28);
    }

    // Simple fade in animation for icons
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        icon,
        color: widget.provider.getOptionIconColor(widget.option),
        size: 28,
      ),
    );
  }
}
