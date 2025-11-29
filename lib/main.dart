import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'DEBUG' 띠 제거
      title: '심리 테스트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PsychologyTestScreen(),
    );
  }
}

class PsychologyTestScreen extends StatefulWidget {
  const PsychologyTestScreen({super.key});

  @override
  State<PsychologyTestScreen> createState() => _PsychologyTestScreenState();
}

class _PsychologyTestScreenState extends State<PsychologyTestScreen> {
  // 간단한 테스트용 질문
  String question = "주말에 갑자기 친구가 약속을 취소했다면?";

  // 버튼을 눌렀을 때 실행될 함수
  void selectAnswer(String answer) {
    setState(() {
      question = "선택한 답변: $answer\n\n(테스트 성공! 앱이 잘 작동합니다.)";
    });

    // 화면 하단에 알림 메시지 띄우기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("'$answer'을(를) 선택하셨습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("심리 테스트 과제"),
        backgroundColor: Colors.blue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.stretch, // 가로 꽉 채우기
          children: [
            // 질문 텍스트
            Text(
              question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50), // 여백

            // 답변 버튼 1
            ElevatedButton(
              onPressed: () => selectAnswer("앗싸! 집에서 쉰다"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              child: const Text("A. 앗싸! 집에서 쉰다 (내향형)", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10), // 버튼 사이 여백

            // 답변 버튼 2
            ElevatedButton(
              onPressed: () => selectAnswer("다른 친구에게 연락한다"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              child: const Text("B. 다른 친구에게 연락해본다 (외향형)", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}