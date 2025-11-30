import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 패키지

class DetailPage extends StatefulWidget {
  final String question;
  final String answer;

  const DetailPage({
    super.key,
    required this.answer,
    required this.question,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailPage();
  }
}

class _DetailPage extends State<DetailPage> {

  // 🔹 카카오톡 공유 함수
  void _shareWithKakao() async {
    // 공유할 템플릿 정의
    final FeedTemplate defaultFeed = FeedTemplate(
      content: Content(
        title: '🧐 심리 테스트 결과',
        description: '${widget.question}\n\n👉 결과: ${widget.answer}',
        imageUrl: Uri.parse(
            'https://cdn-icons-png.flaticon.com/512/2058/2058197.png'), // 썸네일 예시
        link: Link(
          webUrl: Uri.parse('https://www.google.com'),
          mobileWebUrl: Uri.parse('https://www.google.com'),
        ),
      ),
      buttons: [
        Button(
          title: '앱으로 보기',
          link: Link(
            androidExecutionParams: {'key1': 'value1'},
            iosExecutionParams: {'key1': 'value1'},
          ),
        ),
      ],
    );

    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkInstalled = await ShareClient.instance.isKakaoTalkSharingAvailable();

    if (isKakaoTalkInstalled) {
      try {
        Uri uri = await ShareClient.instance.shareDefault(template: defaultFeed);
        await ShareClient.instance.launchKakaoTalk(uri);
      } catch (error) {
        print('카카오톡 공유 실패: $error');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오톡이 설치되어 있지 않습니다 (또는 키 설정 필요).')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테스트 결과')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✨ 결과 카드
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "당신의 성향은...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    "질문: ${widget.question}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 🟡 카카오톡 공유 버튼
            ElevatedButton.icon(
              onPressed: _shareWithKakao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500), // 카카오 브랜드 컬러
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.share),
              label: const Text('카카오톡으로 결과 공유하기'),
            ),

            const SizedBox(height: 16),

            // 🏠 홈으로 버튼
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF6C63FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
              label: const Text('다른 테스트 하러 가기', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}