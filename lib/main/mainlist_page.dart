import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_database/firebase_database.dart';
import '../sub/question_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _testRef;

  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;
  late List<String> testList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _testRef = database.ref('test');
    remoteConfigInit();
  }

  void remoteConfigInit() async {
    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
      setState(() {
        welcomeTitle = remoteConfig.getString('welcome');
        bannerUse = remoteConfig.getBool('banner');
        itemHeight = remoteConfig.getInt('item_height');
      });
    } catch (e) {
      print("Remote Config Error: $e");
    }
  }

  Future<List<String>> loadAsset() async {
    try {
      final snapshot = await _testRef.get();
      testList.clear();
      if (snapshot.exists) {
        for (var element in snapshot.children) {
          final value = element.value;
          if (value != null) {
            testList.add(jsonEncode(value));
          }
        }
      }
      return testList;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bannerUse
          ? AppBar(
        title: Text(welcomeTitle),
      )
          : null,
      body: FutureBuilder<List<String>>(
        future: loadAsset(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                Map<String, dynamic> item = jsonDecode(snapshot.data![index]);
                return _buildTestCard(item, context);
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_add, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('테스트가 없습니다.\n아래 + 버튼을 눌러 추가해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("테스트 추가"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        onPressed: () {
          // 🌟 [업그레이드] 더 재미있는 테스트 데이터 추가
          _testRef.push().set({
            "title": "🥪 샌드위치 재료로 알아보는 나의 성격",
            "question": "샌드위치에 가장 넣고 싶은 재료 하나를 골라보세요!",
            "selects": ["바삭한 베이컨", "신선한 토마토", "부드러운 치즈", "아삭한 양상추"],
            "answer": [
              "당신은 에너지가 넘치고 리더십이 있는 사람입니다!",
              "당신은 섬세하고 감수성이 풍부한 예술가 타입이에요.",
              "당신은 부드럽고 친절해 어디서나 사랑받는 평화주의자!",
              "당신은 쿨하고 정직한 성격의 소유자입니다."
            ]
          });

          _testRef.push().set({
            "title": "🏝️ 무인도 생존 아이템 테스트",
            "question": "무인도에 딱 하나만 가져갈 수 있다면?",
            "selects": ["스마트폰", "나이프", "가족사진", "두꺼운 이불"],
            "answer": [
              "당신은 세상과의 연결을 중시하는 소통왕!",
              "당신은 현실적이고 문제 해결 능력이 뛰어난 생존왕!",
              "당신은 사랑과 추억을 소중히 여기는 로맨티스트!",
              "당신은 어떤 상황에서도 편안함을 찾는 낙천가!"
            ]
          });

          _testRef.push().set({
            "title": "👻 귀신을 만났을 때 반응은?",
            "question": "자다가 눈을 떴는데 귀신과 눈이 마주쳤다면?",
            "selects": ["비명을 지른다", "다시 눈을 감고 자는 척한다", "말을 건다", "주먹을 날린다"],
            "answer": [
              "당신은 솔직하고 감정 표현이 확실한 타입!",
              "당신은 위기 상황을 회피하려는 신중파!",
              "당신은 호기심이 두려움을 이기는 4차원!",
              "당신은 행동이 앞서는 용감한 전사 타입!"
            ]
          });

          setState(() {});
        },
      ),
    );
  }

  // 🎨 카드 디자인 위젯
  Widget _buildTestCard(Map<String, dynamic> item, BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await FirebaseAnalytics.instance.logEvent(
            name: 'test_click',
            parameters: {'test_name': item['title'].toString()},
          );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QuestionPage(question: item),
          ));
        } catch (e) {
          print('Log Error: $e');
        }
      },
      child: Container(
        height: remoteConfig.getInt('item_height').toDouble() > 0
            ? remoteConfig.getInt('item_height').toDouble()
            : 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item['title'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}