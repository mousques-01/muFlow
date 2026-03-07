import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const BreathCoachApp());
}

class BreathCoachApp extends StatelessWidget {
  const BreathCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreathCoach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double playerBreath = 0.5;
  double expectedBreath = 0.5;
  int score = 0;
  int combo = 0;
  String feedback = "";

  void updateGame(double breath, double expected, String fb, int sc, int cb) {
    setState(() {
      playerBreath = breath;
      expectedBreath = expected;
      feedback = fb;
      score = sc;
      combo = cb;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 900,
            padding: const EdgeInsets.all(30),

            child: Column(
              children: [

                const SizedBox(height: 20),

                const Text(
                  "BreathCoach",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Suivez la partition et contrôlez votre souffle",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                /// PARTITION
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          const Color(0xFFF0F2F8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: FluteStaff(
                      onGameUpdate: updateGame,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// SOUFFLE
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Niveau de souffle",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Stack(
                          children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: playerBreath,
                                minHeight: 24,
                                color: Colors.blueAccent,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),

                            Positioned(
                              left: expectedBreath * 760,
                              top: -6,
                              bottom: -6,
                              child: Container(
                                width: 6,
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orangeAccent.withOpacity(0.7),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: feedback == "PERFECT"
                                ? Colors.green
                                : feedback == "GOOD"
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Combo : $combo",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Score : $score",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FluteStaff extends StatefulWidget {

  final Function(double,double,String,int,int) onGameUpdate;

  const FluteStaff({super.key, required this.onGameUpdate});

  @override
  State<FluteStaff> createState() => _FluteStaffState();
}

class _FluteStaffState extends State<FluteStaff> {

  double offset = 0;

  double playerBreath = 0.5;
  double targetBreath = 0.5;
  double expectedBreath = 0.5;

  int score = 0;
  int combo = 0;
  String feedback = "";

  final List<Map<String, double>> melody = [
    {"x": 200, "y": 100, "breath": 0.40},
    {"x": 260, "y": 90,  "breath": 0.50},
    {"x": 320, "y": 80,  "breath": 0.60},
    {"x": 380, "y": 100, "breath": 0.40},
    {"x": 440, "y": 100, "breath": 0.40},
    {"x": 500, "y": 90,  "breath": 0.50},
    {"x": 560, "y": 80,  "breath": 0.60},
    {"x": 620, "y": 100, "breath": 0.40},
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 30), (timer) {

      setState(() {

        offset -= 1.5;

        /// souffle simulé
        targetBreath = 0.4 + (DateTime.now().second % 5) / 10;
        playerBreath += (targetBreath - playerBreath) * 0.05;

        for (var note in melody) {

          double noteX = note["x"]! + offset;

          if ((noteX - 420).abs() < 2) {

            expectedBreath = note["breath"]!;

            double diff = (playerBreath - expectedBreath).abs();

            if (diff < 0.05) {
              feedback = "PERFECT";
              score += 10;
              combo++;
            }
            else if (diff < 0.15) {
              feedback = "GOOD";
              score += 5;
              combo++;
            }
            else {
              feedback = "MISS";
              combo = 0;
            }

            widget.onGameUpdate(
              playerBreath,
              expectedBreath,
              feedback,
              score,
              combo,
            );

          }

        }

        if (offset < -250) {
          offset = 0;
        }

      });

    });

  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [

        /// portée
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              height: 2,
              color: Colors.black,
            ),
          ),
        ),

        /// clé de sol
        const Positioned(
          left: 10,
          top: 70,
          child: Text(
            "𝄞",
            style: TextStyle(fontSize: 60),
          ),
        ),

        /// curseur musical
        const Positioned(
          left: 420,
          top: 0,
          bottom: 0,
          child: Column(
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.red, size: 30),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        /// notes
        ...melody.map((note) {

          double noteX = note["x"]! + offset;

          bool nearCursor = (noteX - 420).abs() < 15;

          return Positioned(
            left: noteX,
            top: note["y"]!,
            child: Text(
              "𝅘𝅥",
              style: TextStyle(
                fontFamily: "Bravura",
                fontSize: nearCursor ? 48 : 40,
                color: nearCursor ? Colors.blue : Colors.black,
                shadows: nearCursor
                    ? [
                        const Shadow(
                          color: Colors.blueAccent,
                          blurRadius: 10,
                        )
                      ]
                    : [],
              ),
            ),
          );

        }).toList(),

      ],
    );
  }
}