import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class Question {
  final String questionTextEn;
  final String questionTextHi;
  final bool correctAnswer;
  final String factEn;
  final String factHi;

  Question({
    required this.questionTextEn,
    required this.questionTextHi,
    required this.correctAnswer,
    required this.factEn,
    required this.factHi,
  });
}

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final List<List<Question>> _questionSets = [
    [
      Question(
        questionTextEn:
            "You should pay attention to diet during periods and eat iron-rich food.",
        questionTextHi:
            "पीरियड के दौरान खान-पान का ध्यान रखना चाहिए और आयरन-समृद्ध भोजन खाना चाहिए।",
        correctAnswer: true,
        factEn:
            "Yes! Blood loss happens during periods, so green vegetables and iron are important.",
        factHi:
            "हाँ! पीरियड के दौरान रक्त की कमी हो सकती है, इसलिए हरी सब्जियाँ और आयरन ज़रूरी हैं।",
      ),
      Question(
        questionTextEn: "Exercise is completely forbidden during periods.",
        questionTextHi: "पीरियड के दौरान व्यायाम करना बिल्कुल मना है।",
        correctAnswer: false,
        factEn: "No, light exercise and yoga can help relieve cramps.",
        factHi:
            "नहीं, हल्का व्यायाम और योग करने से ऐंठन में आराम मिल सकता है।",
      ),
      Question(
        questionTextEn:
            "Eating sour foods like lemon or pickle stops menstrual blood.",
        questionTextHi:
            "नींबू या अचार जैसे खट्टे पदार्थ खाने से पीरियड का खून रुक जाता है।",
        correctAnswer: false,
        factEn:
            "This is a myth. Citrus fruits provide vitamin C, which helps iron absorption.",
        factHi:
            "यह एक मिथक है। खट्टे फल विटामिन C देते हैं, जो आयरन अवशोषण में मदद करता है।",
      ),
      Question(
        questionTextEn:
            "Taking folic acid tablets during pregnancy is important.",
        questionTextHi:
            "गर्भावस्था के दौरान फोलिक एसिड की गोलियाँ लेना ज़रूरी होता है।",
        correctAnswer: true,
        factEn:
            "Yes, it is very important for the baby's brain and spine development.",
        factHi:
            "हाँ, यह बच्चे के दिमाग और रीढ़ की सही वृद्धि के लिए बहुत ज़रूरी है।",
      ),
      Question(
        questionTextEn:
            "Anaemia means lack of blood hemoglobin in the body.",
        questionTextHi:
            "एनीमिया का मतलब शरीर में हीमोग्लोबिन की कमी होना है।",
        correctAnswer: true,
        factEn:
            "Yes, anaemia is a major health issue and proper nutrition is essential.",
        factHi:
            "हाँ, भारत में महिलाओं में एनीमिया एक बड़ी समस्या है। सही खान-पान ज़रूरी है।",
      ),
      Question(
        questionTextEn:
            "Women can check breast lumps at home through self-exam.",
        questionTextHi:
            "महिलाएँ घर पर self-exam करके breast cancer की जाँच कर सकती हैं।",
        correctAnswer: true,
        factEn:
            "Yes, monthly self-examination can help detect lumps early.",
        factHi:
            "हाँ, हर महीने self-examination करने से किसी भी गाँठ का जल्दी पता लगाया जा सकता है।",
      ),
      Question(
        questionTextEn:
            "Using one sanitary pad for more than 12 hours is safe.",
        questionTextHi:
            "एक ही sanitary pad को 12 घंटे से ज़्यादा तक use करना safe है।",
        correctAnswer: false,
        factEn:
            "No, to avoid infection, the pad should be changed every 4-6 hours.",
        factHi:
            "नहीं, संक्रमण से बचने के लिए हर 4-6 घंटे में pad बदलना चाहिए।",
      ),
      Question(
        questionTextEn:
            "Menopause usually happens between 45 and 55 years of age.",
        questionTextHi:
            "मेनोपॉज़ आमतौर पर 45 से 55 वर्ष की उम्र में होता है।",
        correctAnswer: true,
        factEn:
            "Yes, it is a natural hormonal change that occurs in this age range.",
        factHi:
            "हाँ, यह एक प्राकृतिक हार्मोनल बदलाव है जो इस उम्र के बीच होता है।",
      ),
      Question(
        questionTextEn:
            "Weight gain and irregular periods are common symptoms of PCOS/PCOD.",
        questionTextHi:
            "PCOS/PCOD में वज़न बढ़ना और periods irregular होना आम लक्षण हैं।",
        correctAnswer: true,
        factEn:
            "Yes, this happens due to hormonal imbalance. Healthy lifestyle is important.",
        factHi:
            "हाँ, हार्मोनल असंतुलन की वजह से ऐसा होता है। इसमें healthy lifestyle ज़रूरी है।",
      ),
      Question(
        questionTextEn:
            "Drinking 2-3 liters of water daily is not important for pelvic health.",
        questionTextHi:
            "दिन में 2-3 लीटर पानी पीना pelvic health के लिए ज़रूरी नहीं है।",
        correctAnswer: false,
        factEn: "Wrong, enough water helps reduce the risk of UTI.",
        factHi:
            "गलत, पर्याप्त पानी पीने से UTI का खतरा कम होता है।",
      ),
    ],
    [
      Question(
        questionTextEn:
            "Periods are caused by the body becoming weak.",
        questionTextHi:
            "पीरियड शरीर के कमजोर होने की वजह से होते हैं।",
        correctAnswer: false,
        factEn:
            "No, periods are a natural part of the menstrual cycle.",
        factHi:
            "नहीं, पीरियड menstrual cycle का एक प्राकृतिक हिस्सा हैं।",
      ),
      Question(
        questionTextEn:
            "Eating iron-rich food can help during periods.",
        questionTextHi:
            "पीरियड के दौरान आयरन-समृद्ध भोजन खाना मददगार होता है।",
        correctAnswer: true,
        factEn:
            "Yes, it helps maintain energy and supports blood health.",
        factHi:
            "हाँ, यह ऊर्जा बनाए रखता है और रक्त स्वास्थ्य को सपोर्ट करता है।",
      ),
      Question(
        questionTextEn:
            "Bathing during periods causes infection automatically.",
        questionTextHi:
            "पीरियड में नहाने से अपने आप infection हो जाता है।",
        correctAnswer: false,
        factEn:
            "No, bathing is safe and helps maintain hygiene.",
        factHi:
            "नहीं, नहाना safe है और hygiene बनाए रखने में मदद करता है।",
      ),
      Question(
        questionTextEn:
            "Menstrual pain can sometimes be reduced with rest and light movement.",
        questionTextHi:
            "मासिक धर्म के दर्द को कभी-कभी आराम और हल्की गतिविधि से कम किया जा सकता है।",
        correctAnswer: true,
        factEn:
            "Yes, gentle activity can ease cramps for many people.",
        factHi:
            "हाँ, हल्की गतिविधि से कई लोगों को cramps में आराम मिलता है।",
      ),
      Question(
        questionTextEn: "PCOS affects only older women.",
        questionTextHi: "PCOS सिर्फ बड़ी उम्र की महिलाओं को होता है।",
        correctAnswer: false,
        factEn:
            "No, PCOS can affect women of reproductive age too.",
        factHi:
            "नहीं, PCOS प्रजनन आयु वाली महिलाओं को भी हो सकता है।",
      ),
      Question(
        questionTextEn:
            "A balanced diet is useful for reproductive health.",
        questionTextHi:
            "संतुलित आहार reproductive health के लिए उपयोगी होता है।",
        correctAnswer: true,
        factEn:
            "Yes, balanced nutrition supports overall hormonal and reproductive health.",
        factHi:
            "हाँ, संतुलित पोषण हार्मोनल और reproductive health को सपोर्ट करता है।",
      ),
      Question(
        questionTextEn:
            "Self-care during periods is unnecessary.",
        questionTextHi:
            "पीरियड के दौरान self-care ज़रूरी नहीं होती।",
        correctAnswer: false,
        factEn:
            "No, self-care can reduce discomfort and improve well-being.",
        factHi:
            "नहीं, self-care से असुविधा कम होती है और well-being बेहतर होती है।",
      ),
      Question(
        questionTextEn:
            "A doctor should be consulted if periods are extremely irregular.",
        questionTextHi:
            "अगर periods बहुत irregular हों तो doctor से consult करना चाहिए।",
        correctAnswer: true,
        factEn:
            "Yes, persistent irregularity should be checked by a doctor.",
        factHi:
            "हाँ, लगातार irregular periods को doctor से check करवाना चाहिए।",
      ),
      Question(
        questionTextEn:
            "Iron deficiency can make a person feel tired.",
        questionTextHi:
            "आयरन की कमी से इंसान थका हुआ महसूस कर सकता है।",
        correctAnswer: true,
        factEn:
            "Yes, low iron often causes fatigue and weakness.",
        factHi:
            "हाँ, आयरन की कमी से अक्सर थकान और कमजोरी होती है।",
      ),
      Question(
        questionTextEn:
            "Periods happen only once in a lifetime.",
        questionTextHi:
            "पीरियड सिर्फ ज़िंदगी में एक बार होते हैं।",
        correctAnswer: false,
        factEn:
            "No, periods occur regularly during the reproductive years.",
        factHi:
            "नहीं, periods प्रजनन वर्षों में नियमित रूप से होते हैं।",
      ),
    ],
  ];

  late List<Question> _currentGameQuestions;
  int _currentIndex = 0;
  int _score = 0;
  bool _isQuizFinished = false;
  bool? _selectedAnswer;
  bool _showFeedback = false;
  int _currentSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final random = Random();
    final setToUse = _questionSets[_currentSetIndex];
    final shuffled = List<Question>.from(setToUse)..shuffle(random);

    setState(() {
      _currentGameQuestions =
          shuffled.take(min(10, shuffled.length)).toList();
      _currentIndex = 0;
      _score = 0;
      _isQuizFinished = false;
      _selectedAnswer = null;
      _showFeedback = false;
      _currentSetIndex =
          (_currentSetIndex + 1) % _questionSets.length;
    });
  }

  void _handleAnswer(bool answer) {
    if (_selectedAnswer != null || _currentGameQuestions.isEmpty) return;

    final currentQuestion =
        _currentGameQuestions[_currentIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _showFeedback = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        if (_currentIndex <
            _currentGameQuestions.length - 1) {
          _currentIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
        } else {
          _isQuizFinished = true;
        }
      });
    });
  }

  String _buildShareText() {
    final total = _currentGameQuestions.length;
    final wrong = total - _score;
    final percent = ((_score / total) * 100).round();

    return '''
Congratulations! 🎉

Total questions attempted: $total
Correct answers: $_score
Wrong answers: $wrong
Total score: $_score/$total ($percent%)

Play this health quiz now!
''';
  }

  Future<void> _shareResult() async {
    await Share.share(_buildShareText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Outer content view background
      backgroundColor: Colors.white,// const Color(0xFF4A4F7C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10), // 10-10 leading/trailing/top/bottom
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A4F7C) ,//Colors.white, // Inner container view background
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              // Same internal padding as before
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              child: _isQuizFinished
                  ? _buildFinishView()
                  : _buildQuizView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    if (_currentGameQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _currentGameQuestions[_currentIndex];
    final total = _currentGameQuestions.length;
    final progress = (_currentIndex + 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(total),
        const SizedBox(height: 24),
        _buildProgressSection(progress, total),
        const SizedBox(height: 24),
        Expanded(child: _buildQuestionCard(question)),
        const SizedBox(height: 18),
        _buildAnswerSection(question),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'SWAMPURNA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD879F7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sahi Ya Galat',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB65BEB),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Debunk menstruation myths • मिथकों को तोड़ें',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A184D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: const Color(0xFF6E2B8E), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_outlined,
                    color: Color(0xFFC46AF2), size: 24),
                const SizedBox(width: 10),
                Text(
                  '$_score / $total',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double progress, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentIndex + 1} of $total',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.72),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor:
                const Color(0xFF3A2A45),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
                    Color(0xFFB23BE0)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A2F), Color(0xFF140C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: const Color(0xFF46304F), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF8D43E6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics:
                          const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Text(
                            question.questionTextEn,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.35,
                              fontWeight:
                                  FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            question.questionTextHi,
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              fontWeight:
                                  FontWeight.w600,
                              color: Colors.white
                                  .withOpacity(0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_showFeedback) ...[
                  const SizedBox(height: 12),
                  Flexible(
                    flex: 0,
                    child: _buildFeedbackBox(
                        question),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBox(Question question) {
    final userCorrect =
        _selectedAnswer == question.correctAnswer;

    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxHeight: 170),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: userCorrect
              ? const Color(0xFF183B2A)
              : const Color(0xFF3A1A24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: userCorrect
                ? const Color(0xFF35C46A)
                : const Color(0xFFE24C5B),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          physics:
              const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  userCorrect
                      ? 'Correct / Sahi ✅'
                      : 'Wrong / Galat ❌',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.factEn,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white
                      .withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                question.factHi,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.white
                      .withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerSection(Question question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize =
            min(78.0, constraints.maxWidth * 0.18);

        return Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _answerButton(
                icon: Icons.close,
                color: const Color(0xFFE53935),
                onTap: () =>
                    _handleAnswer(false),
                enabled: _selectedAnswer == null,
                isActive: _selectedAnswer == false,
                isCorrect:
                    question.correctAnswer == false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Click to answer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black
                          .withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      textAlign:
                          TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: 'गलत ',
                            style: TextStyle(
                                color: Color(
                                    0xFFE84C4C)),
                          ),
                          TextSpan(
                            text: ' / ',
                            style: TextStyle(
                                color: Colors
                                    .black54),
                          ),
                          TextSpan(
                            text: ' सही',
                            style: TextStyle(
                                color: Color(
                                    0xFF37D16A)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _answerButton(
                icon: Icons.check,
                color: const Color(0xFF2ECC71),
                onTap: () =>
                    _handleAnswer(true),
                enabled: _selectedAnswer == null,
                isActive: _selectedAnswer == true,
                isCorrect:
                    question.correctAnswer == true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _answerButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool enabled,
    required bool isActive,
    required bool isCorrect,
  }) {
    Color finalColor = color;
    if (!enabled) {
      if (isActive) {
        finalColor = isCorrect
            ? const Color(0xFF2ECC71)
            : const Color(0xFFE53935);
      } else {
        finalColor = const Color(0xFF5A4660);
      }
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: finalColor,
          boxShadow: [
            BoxShadow(
              color: finalColor
                  .withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon,
              color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildFinishView() {
    final total = _currentGameQuestions.length;
    final wrong = total - _score;
    final percent = ((_score / total) * 100).round();

    String message =
        'Nice job! You performed well.';
    if (_score >= 8) {
      message =
          'Excellent performance! You did great.';
    } else if (_score < 5) {
      message =
          'Good effort! Keep playing to improve more.';
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A184D),
                border: Border.all(
                    color: const Color(
                        0xFFB23BE0),
                    width: 2),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFD879F7),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$total Questions Attempted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black
                    .withOpacity(0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_score Correct • $wrong Wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black
                    .withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Game Completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD879F7),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_score/$total ($percent%)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black
                      .withOpacity(0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startNewGame,
                  icon: const Icon(Icons.refresh,
                      color: Colors.white),
                  label: const Text(
                    'Play Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB23BE0),
                    padding: const EdgeInsets
                        .symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share,
                      color:
                          Color(0xFFD879F7)),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      color:
                          Color(0xFFD879F7),
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color:
                            Color(0xFFD879F7),
                        width: 1.5),
                    padding: const EdgeInsets
                        .symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}