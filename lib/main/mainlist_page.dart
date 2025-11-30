import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _testRef = database.ref('test');
    remoteConfigInit();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
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
                        Text(
                          '테스트가 없습니다.\n아래 + 버튼을 눌러 추가해주세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          if (_isBannerAdReady)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("전체 테스트 추가"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        onPressed: () {
          // 1. [기존] 애완동물 테스트
          _testRef.push().set({
            "title": "당신이 좋아하는 애완동물은?",
            "question": "무인도에 도착했는데, 상자를 열었을 때 보이는 것은?",
            "selects": ["생존 키트", "휴대폰", "텐트", "무인도에서 살아남기"],
            "answer": [
              "당신은 현실주의!",
              "당신은 동반자를 좋아하는 강아지형!",
              "당신은 공간을 공유하는 고양이형!",
              "당신은 자유로운 앵무새형!"
            ]
          });

          // 2. [기존] MBTI 테스트
          _testRef.push().set({
            "title": "5초 MBTI I/E 편",
            "question": "친구와 함께 간 미술관 당신이라면?",
            "selects": ["말이 많아짐", "생각이 많아짐"],
            "answer": ["당신의 성향은 E", "당신의 성향은 I"]
          });

          // 3. [기존] 연애 성향 테스트
          _testRef.push().set({
            "title": "당신은 어떤 사랑을 하고 싶나요?",
            "question": "목욕을 할 때 가장 먼저 비누칠하는 곳은?",
            "selects": ["머리", "상체", "하체"],
            "answer": [
              "당신은 자만추형이에요.",
              "당신은 소개팅형이에요.",
              "당신은 운명형이에요."
            ]
          });

          // 4. [신규] 탕수육 테스트
          _testRef.push().set({
            "title": "🍖 탕수육 먹을 때 당신의 선택은?",
            "question": "탕수육 소스가 따로 나왔다! 당신의 행동은?",
            "selects": ["냅다 붓는다 (부먹)", "하나씩 찍어 먹는다 (찍먹)", "간장에만 찍어 먹는다", "안 먹고 지켜본다"],
            "answer": [
              "당신은 융통성 있고 낙천적인 평화주의자!",
              "당신은 자신의 영역을 중요시하는 신중한 원칙주의자!",
              "당신은 본연의 맛을 즐길 줄 아는 고독한 미식가!",
              "당신은 상황을 먼저 파악하는 관찰력이 뛰어난 전략가!"
            ]
          });

          // 5. [신규] 좀비 아포칼립스 테스트
          _testRef.push().set({
            "title": "🧟‍♂️ 좀비 사태 발생! 당신의 무기는?",
            "question": "눈앞에 좀비 떼가 나타났다! 당장 집어들 무기는?",
            "selects": ["야구방망이", "저격용 라이플", "프라이팬", "구급상자"],
            "answer": [
              "당신은 앞장서서 돌격하는 용감한 행동대장!",
              "당신은 뒤에서 상황을 통제하는 냉철한 리더!",
              "당신은 요리도 하고 좀비도 잡는 생활력 만렙 생존자!",
              "당신은 다친 동료를 챙기는 따뜻한 마음씨의 힐러!"
            ]
          });

          // 6. [신규] 로또 당첨 테스트
          _testRef.push().set({
            "title": "💰 로또 1등 100억 당첨! 가장 먼저 할 일은?",
            "question": "통장에 100억이 꽂혔다. 지금 당장 무엇을 할까?",
            "selects": ["당장 회사에 사표 낸다", "강남에 건물부터 보러 간다", "아무에게도 말하지 않고 저축한다", "친구들 다 불러서 파티한다"],
            "answer": [
              "당신은 자유를 갈망하는 영혼! (퇴사 기원 1일차)",
              "당신은 미래를 내다보는 야망 있는 투자가!",
              "당신은 신중하고 비밀이 많은 현실적인 부자!",
              "당신은 기쁨을 함께 나누는 의리파!"
            ]
          });

          setState(() {});
        },
      ),
    );
  }

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