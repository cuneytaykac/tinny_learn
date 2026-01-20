import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/games/quiz_provider.dart';
import '../../widgets/quiz/quiz_option_card.dart';

class QuizScreen extends StatelessWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(category: category),
      child: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: category.color,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(color: AppTheme.primaryTextColor),
              title: Text(
                '${category.nameTr} Bulmaca',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: provider.playQuestionSound,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volume_up_rounded,
                                size: 40,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'Hangisi "${provider.targetItem.nameTr}"?',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isFlag = category.type == CategoryType.flag;
                            final optionsList =
                                provider.options.map((item) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isFlag ? 12 : 0,
                                    ),
                                    child: QuizOptionCard(
                                      item: item,
                                      isSelected:
                                          provider.selectedItemId == item.id,
                                      isCorrect: provider.isCorrect,
                                      isFlag: isFlag,
                                      width:
                                          isFlag
                                              ? 320
                                              : constraints.maxWidth * 0.45,
                                      height: isFlag ? 200 : 160,
                                      onTap:
                                          () => provider.handleOptionTap(item),
                                    ),
                                  );
                                }).toList();

                            return SingleChildScrollView(
                              child:
                                  isFlag
                                      ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: optionsList,
                                      )
                                      : Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        alignment: WrapAlignment.center,
                                        children: optionsList,
                                      ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: provider.confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
