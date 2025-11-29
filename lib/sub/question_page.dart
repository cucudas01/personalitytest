import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../detail/detail_page.dart';

class QuestionPage extends StatefulWidget {
  final Map<String, dynamic> question;

  const QuestionPage({super.key, required this.question});

  @override
  State<StatefulWidget> createState() {
    return _QuestionPage();
  }
}

class _QuestionPage extends State<QuestionPage> {
  String title = '';
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    title = widget.question['title'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('질문')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // 💬 질문 텍스트
              Text(
                widget.question['question'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 🔢 보기 리스트 (커스텀 버튼)
              Expanded(
                child: ListView.separated(
                  itemCount: (widget.question['selects'] as List<dynamic>).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildOptionButton(index, widget.question['selects'][index]);
                  },
                ),
              ),

              // 👉 결과 보기 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedOption == null
                      ? null
                      : () async {
                    try {
                      await FirebaseAnalytics.instance.logEvent(
                        name: "personal_select",
                        parameters: {
                          "test_name": title,
                          "select": selectedOption ?? 0,
                        },
                      );
                      if (mounted) {
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              answer: widget.question['answer'][selectedOption],
                              question: widget.question['question'],
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('결과 확인하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String text) {
    bool isSelected = selectedOption == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}