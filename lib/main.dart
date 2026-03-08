import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BreathCoachApp());
}

class BreathCoachApp extends StatelessWidget {
  const BreathCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BreathCoach",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeMenu(),
    );
  }
}

////////////////////////////////////////////////////////////
/// MENU PRINCIPAL
////////////////////////////////////////////////////////////

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  Widget button(BuildContext context, String text, IconData icon, Widget page) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: SizedBox(
        width: 260,
        height: 55,

        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(text),

          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );

          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 20),

                const Text(
                  "BreathCoach",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 60),

                button(context, "Commencer un exercice", Icons.play_arrow, const ExercisePage()),

                button(context, "Entraînement", Icons.fitness_center, const TrainingPage()),

                button(context, "Mode analyse", Icons.analytics, const AnalysisPage()),

                button(context, "Historique", Icons.show_chart, const HistoryPage()),

                button(context, "Présentation du projet", Icons.info, const AboutPage()),

                button(context, "Mode d'emploi", Icons.menu_book, const HelpPage()),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// EXERCICE
////////////////////////////////////////////////////////////

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {

  double offset = 0;

  double playerBreath = 0.5;
  double expectedBreath = 0.35;

  int score = 0;
  int combo = 0;

  String feedback = "";
  String currentNote = "";

  final melody = [

   {"x":200.0,"y":75.0,"breath":0.30,"note":"G"},
   {"x":260.0,"y":65.0,"breath":0.40,"note":"A"},
   {"x":320.0,"y":55.0,"breath":0.50,"note":"B"},
   {"x":380.0,"y":45.0,"breath":0.60,"note":"C"},
   {"x":440.0,"y":55.0,"breath":0.50,"note":"B"},
   {"x":500.0,"y":65.0,"breath":0.40,"note":"A"},
   {"x":560.0,"y":75.0,"breath":0.30,"note":"G"},

  ];

  @override
  void initState(){

    super.initState();

    Timer.periodic(const Duration(milliseconds:40),(timer){

      setState((){

        /// défilement partition
        offset -= 1.5;

        /// souffle joueur simulé
        double targetBreath = 0.2 + Random().nextDouble()*0.6;
        playerBreath += (targetBreath - playerBreath) * 0.03;

        /// NOTE ACTIVE basée sur la progression

        int noteIndex = ((-offset) ~/ 60) % melody.length;

        expectedBreath = melody[noteIndex]["breath"] as double;
        currentNote = melody[noteIndex]["note"] as String;

        /// zones scoring

        double zone = 0.07;
        double perfect = 0.02;

        double lower = expectedBreath - zone;
        double upper = expectedBreath + zone;

        double pLow = expectedBreath - perfect;
        double pHigh = expectedBreath + perfect;

        if(playerBreath >= pLow && playerBreath <= pHigh){

          feedback = "PERFECT";
          score += 10;
          combo++;

        }

        else if(playerBreath >= lower && playerBreath <= upper){

          feedback = "GOOD";
          score += 5;
          combo++;

        }

        else{

          feedback = "MISS";
          combo = 0;

        }

      });

    });

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: const Text("Exercice")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// PARTITION

            Card(
              elevation:3,

              child: Container(
                height:200,
                padding:const EdgeInsets.all(20),

                child: Stack(

                  children: [

                    Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index)=>Container(
                          margin:const EdgeInsets.symmetric(vertical:6),
                          height:2,
                          color:Colors.black,
                        ),
                      ),
                    ),

                    const Positioned(
                      left:10,
                      top:50,
                      child:Text(
                        "𝄞",
                        style:TextStyle(
                          fontSize:70,
                          fontFamily:"Bravura",
                        ),
                      ),
                    ),

                    const Positioned(
                      left:420,
                      top:0,
                      bottom:0,
                      child:VerticalDivider(
                        thickness:3,
                        color:Colors.red,
                      ),
                    ),

                    ...melody.map((note){

                      double noteX = (note["x"] as double) + offset;
                      bool active = (noteX - 420).abs() < 25;

                      return Positioned(

                        left: noteX,
                        top: note["y"] as double,

                        child: Text(
                          "𝅘𝅥",
                          style: TextStyle(
                            fontFamily:"Bravura",
                            fontSize: active ? 48 : 40,
                            color: active ? Colors.blue : Colors.black,
                          ),
                        ),

                      );

                    }).toList(),

                  ],
                ),
              ),
            ),

            const SizedBox(height:30),

            /// INFO NOTE

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  "Note : $currentNote",
                  style: const TextStyle(
                    fontSize:18,
                    fontWeight:FontWeight.bold,
                  ),
                ),

                const SizedBox(height:4),

                Text(
                  "Souffle cible pour $currentNote : ${expectedBreath.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize:16),
                ),

              ],
            ),

            const SizedBox(height:20),

            /// BARRE DE SOUFFLE

            Card(
              elevation:3,

              child: Padding(
                padding:const EdgeInsets.all(20),

                child: Stack(

                  children: [

                    /// barre grise

                    Container(
                      width:600,
                      height:24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300,
                      ),
                    ),

                    /// zone verte (goal)

                    Positioned(
                      left: expectedBreath * 600 - 40,
                      child: Container(
                        width:80,
                        height:24,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// souffle joueur (jaune)

                    Positioned(
                      left: playerBreath * 600 - 4,
                      child: Container(
                        width:8,
                        height:24,
                        color: Colors.yellow,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height:20),

            Text(
              feedback,
              style: const TextStyle(
                fontSize:28,
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:6),

            Text(
              "Combo : $combo",
              style: const TextStyle(fontSize:18),
            ),

            const SizedBox(height:6),

            Text(
              "Score : $score",
              style: const TextStyle(
                fontSize:24,
                fontWeight:FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}


////////////////////////////////////////////////////////////
/// ENTRAINEMENT
////////////////////////////////////////////////////////////

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  Widget exercise(BuildContext context,
      String title, String description) {

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.play_arrow),

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TrainingExercisePage(title: title),
            ),
          );

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Entraînement")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            exercise(context,
                "Note longue",
                "Maintenir un souffle stable"),

            exercise(context,
                "Piano",
                "Souffle faible contrôlé"),

            exercise(context,
                "Forte",
                "Souffle puissant"),

            exercise(context,
                "Stabilité",
                "Maintenir une pression constante"),

          ],

        ),
      ),
    );
  }
}

class TrainingExercisePage extends StatefulWidget {

  final String title;

  const TrainingExercisePage({
    super.key,
    required this.title,
  });

  @override
  State<TrainingExercisePage> createState()
      => _TrainingExercisePageState();
}

class _TrainingExercisePageState
    extends State<TrainingExercisePage> {

  double breath = 0.5;

  @override
  void initState() {

    super.initState();

    Timer.periodic(const Duration(milliseconds: 200), (timer) {

      setState(() {

        breath += (Random().nextDouble() - 0.5) * 0.05;
        breath = breath.clamp(0.2, 0.9);

      });

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Maintenir le souffle dans la zone verte",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 300,

              child: LinearProgressIndicator(
                value: breath,
                minHeight: 20,
                color: Colors.green,
              ),
            ),

          ],

        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ANALYSE
////////////////////////////////////////////////////////////

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {

  List<double> history = List.generate(40, (index) => 0.5);
  int pressure = 340;

  double get breath => history.last;

  double get average =>
      history.reduce((a, b) => a + b) / history.length;

  double get stability {

    double avg = average;

    double variance = history
        .map((v) => pow(v - avg, 2))
        .reduce((a, b) => a + b) / history.length;

    return sqrt(variance);

  }

  @override
  void initState() {

    super.initState();

    Timer.periodic(const Duration(milliseconds: 300), (timer) {

      setState(() {

        double next = history.last +
            (Random().nextDouble() - 0.5) * 0.05;

        next = next.clamp(0.2, 0.9);

        history.removeAt(0);
        history.add(next);

        pressure = 320 + Random().nextInt(60);

      });

    });

  }

  Widget dataRow(String name, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Analyse du souffle")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Card(
              elevation: 3,
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(20),

                child: CustomPaint(
                  painter: BreathGraph(history),
                  size: Size.infinite,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(

                  children: [

                    dataRow(
                        "Souffle instantané",
                        breath.toStringAsFixed(2)),

                    dataRow(
                        "Souffle moyen",
                        average.toStringAsFixed(2)),

                    dataRow(
                        "Stabilité",
                        stability.toStringAsFixed(3)),

                    dataRow(
                        "Pression capteur",
                        pressure.toString()),

                  ],

                ),
              ),
            )

          ],

        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HISTORIQUE
////////////////////////////////////////////////////////////

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Historique")),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          historyCard(
              "Frère Jacques",
              78,
              [0.35,0.55,0.58,0.42,0.47],
              [0.4,0.5,0.6,0.4,0.5]),

          historyCard(
              "Exercice souffle long",
              84,
              [0.5,0.52,0.53,0.55,0.57],
              [0.5,0.5,0.5,0.5,0.5]),

        ],
      ),
    );
  }

  Widget historyCard(
      String title,
      int score,
      List<double> real,
      List<double> ideal) {

    return Card(

      margin: const EdgeInsets.only(bottom: 20),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text("Score : $score"),

            const SizedBox(height: 20),

            SizedBox(
              height: 180,

              child: CustomPaint(
                painter: ComparisonGraph(real, ideal),
                size: Size.infinite,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PRESENTATION
////////////////////////////////////////////////////////////

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget section(String title, String text) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(text),

        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Présentation du projet")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            const Text(
              "BreathCoach",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            section(
              "Objectif du projet",
              "BreathCoach est une application pédagogique destinée "
              "à aider les musiciens à vent (flûte, saxophone, etc.) "
              "à mieux comprendre et contrôler leur souffle.",
            ),

            section(
              "Pourquoi mesurer le souffle ?",
              "Le contrôle du souffle est essentiel pour les instruments "
              "à vent. Il influence directement :\n"
              "• l'intensité (piano / forte)\n"
              "• la stabilité du son\n"
              "• la durée des notes\n"
              "• la qualité du timbre.",
            ),

            section(
              "Principe du système",
              "Le musicien souffle dans l'instrument.\n"
              "Un capteur mesure la pression ou le débit d'air.\n"
              "Les données sont envoyées via Bluetooth vers l'application.\n"
              "L'application compare ensuite le souffle réel "
              "au souffle attendu pour chaque note.",
            ),

            section(
              "Fonctionnalités du prototype",
              "• partition animée\n"
              "• feedback pédagogique en temps réel\n"
              "• analyse du souffle\n"
              "• historique des exercices\n"
              "• entraînement ciblé du souffle",
            ),

            section(
              "Contexte du projet",
              "Ce prototype est développé dans le cadre d'un projet "
              "académique visant à explorer l'utilisation des technologies "
              "numériques pour l'apprentissage musical.",
            ),

          ],

        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// GRAPHES
////////////////////////////////////////////////////////////

class BreathGraph extends CustomPainter{

  final List<double> data;

  BreathGraph(this.data);

  @override
  void paint(Canvas canvas,Size size){

    final paint=Paint()
      ..color=Colors.indigo
      ..strokeWidth=3
      ..style=PaintingStyle.stroke;

    final path=Path();

    for(int i=0;i<data.length;i++){

      double x=i*size.width/data.length;
      double y=size.height-data[i]*size.height;

      if(i==0){
        path.moveTo(x,y);
      }else{
        path.lineTo(x,y);
      }

    }

    canvas.drawPath(path,paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;

}

class ComparisonGraph extends CustomPainter{

  final List<double> real;
  final List<double> ideal;

  ComparisonGraph(this.real,this.ideal);

  @override
  void paint(Canvas canvas,Size size){

    final realPaint=Paint()
      ..color=Colors.blue
      ..strokeWidth=3
      ..style=PaintingStyle.stroke;

    final idealPaint=Paint()
      ..color=Colors.green
      ..strokeWidth=3
      ..style=PaintingStyle.stroke;

    final realPath=Path();
    final idealPath=Path();

    for(int i=0;i<real.length;i++){

      double x=i*size.width/real.length;

      double yr=size.height-real[i]*size.height;
      double yi=size.height-ideal[i]*size.height;

      if(i==0){
        realPath.moveTo(x,yr);
        idealPath.moveTo(x,yi);
      }else{
        realPath.lineTo(x,yr);
        idealPath.lineTo(x,yi);
      }

    }

    canvas.drawPath(realPath,realPaint);
    canvas.drawPath(idealPath,idealPaint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;

}

/////////////////////////////////////////////////////////////
/// MODE D'EMPLOI
/////////////////////////////////////////////////////////////

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Widget step(String title, String description) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(description),

        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Mode d'emploi")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            const Text(
              "Comment utiliser BreathCoach",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            step(
              "1. Choisir un exercice",
              "Dans le menu principal, sélectionner 'Commencer un exercice'. "
              "La partition animée apparaît et défile sous le curseur.",
            ),

            step(
              "2. Suivre la partition",
              "Chaque note possède un niveau de souffle recommandé. "
              "L'objectif est de maintenir le souffle dans la zone idéale.",
            ),

            step(
              "3. Interpréter la barre de souffle",
              "La barre de souffle change de couleur :\n"
              "Vert : souffle correct\n"
              "Jaune : proche de la cible\n"
              "Rouge : trop faible ou trop fort",
            ),

            step(
              "4. Feedback en temps réel",
              "Le système affiche 'Perfect', 'Good' ou 'Miss' selon "
              "la précision du souffle par rapport à la valeur attendue.",
            ),

            step(
              "5. Analyse du souffle",
              "Le mode analyse permet d'observer les données techniques "
              "du souffle : stabilité, moyenne et évolution dans le temps.",
            ),

            step(
              "6. Historique",
              "La section historique permet de revoir les exercices passés "
              "et de comparer le souffle réel avec le souffle idéal.",
            ),

          ],

        ),
      ),
    );
  }
}