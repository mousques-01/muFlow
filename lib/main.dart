import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

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

  Widget button(
    BuildContext context,
    String text,
    IconData icon,
    Widget page,
  ) {
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
              MaterialPageRoute(
                builder: (_) => page,
              ),
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
              mainAxisAlignment:
                  MainAxisAlignment.center,
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
                button(
                  context,
                  "Commencer un exercice",
                  Icons.play_arrow,
                  const ExercisePage(),
                ),
                button(
                  context,
                  "Entraînement",
                  Icons.fitness_center,
                  const TrainingPage(),
                ),
                button(
                  context,
                  "Mode analyse",
                  Icons.analytics,
                  const AnalysisPage(),
                ),
                button(
                  context,
                  "Historique",
                  Icons.show_chart,
                  const HistoryPage(),
                ),
                button(
                  context,
                  "Présentation du projet",
                  Icons.info,
                  const AboutPage(),
                ),
                button(
                  context,
                  "Mode d'emploi",
                  Icons.menu_book,
                  const HelpPage(),
                ),
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

  final String title;

  const ExercisePage({
    super.key,
    this.title = "Contrôle du souffle",
  });

  @override
  State<ExercisePage> createState() =>
      _ExercisePageState();

}

class _ExercisePageState
    extends State<ExercisePage> {

  ////////////////////////////////////////////////////////////
  /// BLUETOOTH
  ////////////////////////////////////////////////////////////

  SerialPort? port;

  String serialBuffer = "";

  ////////////////////////////////////////////////////////////
  /// SOUFFLE
  ////////////////////////////////////////////////////////////

  double breath = 0.0;

  ////////////////////////////////////////////////////////////
  /// ZONE CIBLE
  ////////////////////////////////////////////////////////////

  double targetMin = 0.20;
  double targetMax = 0.45;

  ////////////////////////////////////////////////////////////
  /// EXERCICE
  ////////////////////////////////////////////////////////////

  int requiredSeconds = 10;

  double secondsInZone = 0;

  bool calibrationFinished = false;

  bool exerciseCompleted = false;

  DateTime? zoneStartTime;

  ////////////////////////////////////////////////////////////
  /// FILTRE PASSE BAS
  ////////////////////////////////////////////////////////////

  double previousFiltered = 0;

  double lowPassFilter(double input) {

    double alpha = 0.03;

    previousFiltered =
        alpha * input +
        (1 - alpha) *
            previousFiltered;

    return previousFiltered;

  }

  ////////////////////////////////////////////////////////////
  /// INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {

    super.initState();

    connectBluetooth();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      showExerciseDialog();

    });

  }

  ////////////////////////////////////////////////////////////
  /// CONFIGURATION
  ////////////////////////////////////////////////////////////

  void showExerciseDialog() {

    final minController =
        TextEditingController(
      text: targetMin.toString(),
    );

    final maxController =
        TextEditingController(
      text: targetMax.toString(),
    );

    final durationController =
        TextEditingController(
      text: requiredSeconds.toString(),
    );

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) {

        return AlertDialog(

          title:
              const Text(
            "Configuration",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(

                controller:
                    minController,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Borne min",
                ),

              ),

              const SizedBox(
                  height: 10),

              TextField(

                controller:
                    maxController,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Borne max",
                ),

              ),

              const SizedBox(
                  height: 10),

              TextField(

                controller:
                    durationController,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Durée (s)",
                ),

              ),

            ],

          ),

          actions: [

            ElevatedButton(

              onPressed: () {

                setState(() {

                  targetMin =
                      double.tryParse(
                            minController
                                .text,
                          ) ??
                          0.20;

                  targetMax =
                      double.tryParse(
                            maxController
                                .text,
                          ) ??
                          0.45;

                  requiredSeconds =
                      int.tryParse(
                            durationController
                                .text,
                          ) ??
                          10;
                });

                Navigator.pop(
                  context,
                );

              },

              child:
                  const Text("OK"),

            ),

          ],

        );

      },

    );

  }

  ////////////////////////////////////////////////////////////
  /// BLUETOOTH
  ////////////////////////////////////////////////////////////

  void connectBluetooth() {

    try {

      port = SerialPort("COM3");

      bool opened =
          port!.openReadWrite();

      if (opened) {

        final reader =
            SerialPortReader(port!);

        reader.stream.listen((data) {

          try {

            serialBuffer +=
                String.fromCharCodes(data);

            List<String> lines =
                serialBuffer.split('\n');

            serialBuffer =
                lines.last;

            for (int i = 0;
                i < lines.length - 1;
                i++) {

              String received =
                  lines[i].trim();

              if (received.isEmpty) {
                continue;
              }

              double adc =
                  double.tryParse(
                        received,
                      ) ??
                      0.0;

              adc = adc.clamp(
                0.0,
                4095.0,
              );

              double voltage =
                  (adc / 4095.0) *
                      3.3;

              double filtered =
                  lowPassFilter(
                    voltage,
                  );

              double normalized =
                  (2.77 - filtered) /
                      (2.77 - 2.40);

              normalized =
                  normalized.clamp(
                0.0,
                1.0,
              );

              if (!mounted) return;

              setState(() {

                breath =
                    normalized;

                //////////////////////////////////////
                /// CALIBRAGE
                //////////////////////////////////////

                if (!calibrationFinished &&
                    breath <= 0.05) {

                  calibrationFinished =
                      true;

                }

                //////////////////////////////////////
                /// TEMPS DANS ZONE
                //////////////////////////////////////

                if (calibrationFinished &&
                    !exerciseCompleted &&
                    breath >= targetMin &&
                    breath <= targetMax) {

                  zoneStartTime ??=
                      DateTime.now();

                  secondsInZone =
                      DateTime.now()
                              .difference(
                                zoneStartTime!,
                              )
                              .inMilliseconds /
                          1000.0;

                  if (secondsInZone >=
                      requiredSeconds) {

                    exerciseCompleted =
                        true;

                  }

                }

                else {

                  zoneStartTime =
                      null;

                  if (!exerciseCompleted) {

                    secondsInZone =
                        0;

                  }

                }

              });

            }

          }

          catch (e) {

            print(e);

          }

        });

      }

    }

    catch (e) {

      print(e);

    }

  }


  ////////////////////////////////////////////////////////////
  /// DISPOSE
  ////////////////////////////////////////////////////////////

  @override
  void dispose() {

    port?.close();

    super.dispose();

  }

  ////////////////////////////////////////////////////////////
  /// BUILD
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(

        child: Padding(

          padding:
              const EdgeInsets.all(30),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              //////////////////////////////////////////////////
              /// TITRE
              //////////////////////////////////////////////////

              const Text(

                "Maintenir le trait noir dans la zone verte",

                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),

                textAlign:
                    TextAlign.center,

              ),

              const SizedBox(height: 60),

              //////////////////////////////////////////////////
              /// BARRE
              //////////////////////////////////////////////////

              Container(

                width: 550,
                height: 90,

                decoration: BoxDecoration(

                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                          12),

                ),

                child: Stack(

                  children: [

                    //////////////////////////////////////////////
                    /// ZONE VERTE
                    //////////////////////////////////////////////

                    Positioned(

                      left:
                          targetMin * 550,

                      width:
                          (targetMax -
                                  targetMin) *
                              550,

                      top: 0,
                      bottom: 0,

                      child: Container(

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.green
                                  .withOpacity(
                                      0.4),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),

                        ),

                      ),

                    ),

                    //////////////////////////////////////////////
                    /// TRAIT NOIR
                    //////////////////////////////////////////////

                    Positioned(

                      left:
                          (breath * 545)
                              .clamp(
                                  0.0,
                                  545.0),

                      top: 0,
                      bottom: 0,

                      child: Container(

                        width: 5,

                        color:
                            Colors.black,

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 50),

              //////////////////////////////////////////////////
              /// VALEUR
              //////////////////////////////////////////////////

              Text(

                "Souffle normalisé : ${breath.toStringAsFixed(2)}",

                style: const TextStyle(
                  fontSize: 22,
                ),

              ),

              const SizedBox(height: 15),

              //////////////////////////////////////////////////
              /// TEMPS
              //////////////////////////////////////////////////

              Text(

                "Temps dans la zone : ${secondsInZone.toStringAsFixed(1)} s",

                style: const TextStyle(
                  fontSize: 22,
                ),

              ),

              const SizedBox(height: 10),

              Text(

                "Objectif : $requiredSeconds s",

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),

              ),

              const SizedBox(height: 25),

              //////////////////////////////////////////////////
              /// FEEDBACK
              //////////////////////////////////////////////////

              if (!calibrationFinished)

                const Text(

                  "Calibration : relâchez complètement le souffle",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(

                    color:
                        Colors.orange,

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,

                  ),

                )

              else if (exerciseCompleted)

                const Text(

                  "EXERCICE RÉUSSI",

                  style: TextStyle(

                    color:
                        Colors.green,

                    fontSize: 36,

                    fontWeight:
                        FontWeight.bold,

                  ),

                )

              else if (breath >= targetMin &&
                       breath <= targetMax)

                const Text(

                  "BON CONTRÔLE",

                  style: TextStyle(

                    color:
                        Colors.green,

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,

                  ),

                )

              else

                const Text(

                  "HORS ZONE",

                  style: TextStyle(

                    color:
                        Colors.red,

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

            ],

          ),

        ),

      ),

    );

  }

}


/////////////////////////////////////////////////////////////
/// TRAINING
////////////////////////////////////////////////////////////

class TrainingPage extends StatelessWidget {

  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return const TrainingExercisePage(
      title: "Contrôle du souffle",
    );

  }

}

////////////////////////////////////////////////////////////
/// EXERCICE
////////////////////////////////////////////////////////////

class TrainingExercisePage
    extends StatefulWidget {

  final String title;

  const TrainingExercisePage({
    super.key,
    required this.title,
  });

  @override
  State<TrainingExercisePage>
      createState() =>
          _TrainingExercisePageState();

}

class _TrainingExercisePageState
    extends State<
        TrainingExercisePage> {

  ////////////////////////////////////////////////////////////
  /// PORT
  ////////////////////////////////////////////////////////////

  SerialPort? port;

  ////////////////////////////////////////////////////////////
  /// BUFFER SERIE
  ////////////////////////////////////////////////////////////

  String serialBuffer = "";

  ////////////////////////////////////////////////////////////
  /// SIGNAL
  ////////////////////////////////////////////////////////////

  double rawAdc = 0;

  double breath = 0;

  ////////////////////////////////////////////////////////////
  /// FPS UI
  ////////////////////////////////////////////////////////////

  DateTime lastUpdate =
      DateTime.now();

  ////////////////////////////////////////////////////////////
  /// PASSE-BAS
  ////////////////////////////////////////////////////////////

  double filteredSignal =
      3350;

  double lowPassFilter(
      double input) {

    //////////////////////////////////////////////////////////
    /// FILTRE LISSE
    //////////////////////////////////////////////////////////

    double alpha = 0.12;

    filteredSignal =
        alpha * input +
        (1 - alpha) *
            filteredSignal;

    return filteredSignal;

  }

  ////////////////////////////////////////////////////////////
  /// HISTORIQUE FILTRE
  ////////////////////////////////////////////////////////////

  List<double> history = [];

  ////////////////////////////////////////////////////////////
  /// INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {

    super.initState();

    connectBluetooth();

  }

  ////////////////////////////////////////////////////////////
  /// BLUETOOTH
  ////////////////////////////////////////////////////////////

  void connectBluetooth() {

    try {

      port =
          SerialPort("COM3");

      bool opened =
          port!
              .openReadWrite();

      if (opened) {

        final reader =
            SerialPortReader(
                port!);

        reader.stream.listen(
            (data) {

          try {

            serialBuffer +=
                String
                    .fromCharCodes(
                        data);

            List<String>
                lines =
                serialBuffer
                    .split(
                        '\n');

            serialBuffer =
                lines.last;

            for (int i = 0;
                i <
                    lines.length -
                        1;
                i++) {

              String received =
                  lines[i]
                      .trim();

              if (received
                  .isEmpty) {
                continue;
              }

              //////////////////////////////////////////////////
              /// ADC
              //////////////////////////////////////////////////

              double adc =
                  double.tryParse(
                        received,
                      ) ??
                      0;

              adc =
                  adc.clamp(
                0,
                4095,
              );

              rawAdc = adc;

              //////////////////////////////////////////////////
              /// PASSE-BAS
              //////////////////////////////////////////////////

              double filtered =
                  lowPassFilter(
                      adc);

              //////////////////////////////////////////////////
              /// HISTORIQUE
              /// ~250 ms
              //////////////////////////////////////////////////

              history.add(
                  filtered);

              if (history
                      .length >
                  5) {

                history
                    .removeAt(
                        0);

              }

              //////////////////////////////////////////////////
              /// PENTE
              //////////////////////////////////////////////////

              double slope =
                  0;

              if (history
                      .length >=
                  5) {

                slope =
                    history
                            .first -
                        history
                            .last;

              }

              //////////////////////////////////////////////////
              /// GARDE CHUTES
              //////////////////////////////////////////////////

              if (slope <
                  0) {

                slope = 0;

              }

              //////////////////////////////////////////////////
              /// NORMALISATION
              //////////////////////////////////////////////////

              double normalized =
                  slope /
                      120.0;

              normalized =
                  normalized
                      .clamp(
                          0.0,
                          1.0);

              //////////////////////////////////////////////////
              /// FPS UI
              //////////////////////////////////////////////////

              if (DateTime.now()
                      .difference(
                          lastUpdate)
                      .inMilliseconds <
                  50) {

                continue;

              }

              lastUpdate =
                  DateTime
                      .now();

              if (!mounted)
                return;

              setState(() {

                breath =
                    normalized;

              });

            }

          } catch (e) {

            print(e);

          }

        });

      }

    } catch (e) {

      print(e);

    }

  }

  ////////////////////////////////////////////////////////////
  /// DISPOSE
  ////////////////////////////////////////////////////////////

  @override
  void dispose() {

    port?.close();

    super.dispose();

  }

  ////////////////////////////////////////////////////////////
  /// BUILD
  ////////////////////////////////////////////////////////////

  @override
  Widget build(
      BuildContext context) {

    double minRadius =
        15;

    double maxRadius =
        170;

    double currentRadius =
        minRadius +
            breath *
                (maxRadius -
                    minRadius);

    double targetRadius =
        90;

    bool inTarget =
        breath > 0.35 &&
            breath < 0.60;

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        title:
            Text(
                widget.title),

      ),

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [

            const Text(

              "Stabilise ton souffle",

              style:
                  TextStyle(

                color:
                    Colors.white,

                fontSize:
                    30,

                fontWeight:
                    FontWeight
                        .bold,

              ),

            ),

            const SizedBox(
                height: 60),

            //////////////////////////////////////////////////
            /// CERCLES
            //////////////////////////////////////////////////

            SizedBox(

              width: 450,
              height: 450,

              child: Stack(

                alignment:
                    Alignment
                        .center,

                children: [

                  ////////////////////////////////////////////
                  /// CIBLE
                  ////////////////////////////////////////////

                  Container(

                    width:
                        targetRadius *
                            2,

                    height:
                        targetRadius *
                            2,

                    decoration:
                        BoxDecoration(

                      shape:
                          BoxShape
                              .circle,

                      color:
                          Colors
                              .green
                              .withOpacity(
                                  0.18),

                      border:
                          Border
                              .all(

                        color:
                            Colors
                                .green,

                        width:
                            4,

                      ),

                    ),

                  ),

                  ////////////////////////////////////////////
                  /// CERCLE
                  ////////////////////////////////////////////

                  Container(

                    width:
                        currentRadius *
                            2,

                    height:
                        currentRadius *
                            2,

                    decoration:
                        BoxDecoration(

                      shape:
                          BoxShape
                              .circle,

                      color:
                          Colors
                              .white
                              .withOpacity(
                                  0.92),

                      boxShadow: [

                        BoxShadow(

                          color:
                              Colors
                                  .white
                                  .withOpacity(
                                      0.25),

                          blurRadius:
                              25,

                          spreadRadius:
                              8,

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(
                height: 40),

            //////////////////////////////////////////////////
            /// FEEDBACK
            //////////////////////////////////////////////////

            Text(

              inTarget
                  ? "BON CONTRÔLE"
                  : "AJUSTE TON SOUFFLE",

              style:
                  TextStyle(

                color: inTarget
                    ? Colors
                        .green
                    : Colors
                        .orange,

                fontSize:
                    30,

                fontWeight:
                    FontWeight
                        .bold,

              ),

            ),

            const SizedBox(
                height: 25),

            //////////////////////////////////////////////////
            /// DEBUG
            //////////////////////////////////////////////////

            Text(

              "ADC : ${rawAdc.toStringAsFixed(0)}",

              style:
                  const TextStyle(

                color: Colors
                    .white70,

                fontSize:
                    20,

              ),

            ),

            const SizedBox(
                height: 10),

            Text(

              "Breath : ${breath.toStringAsFixed(2)}",

              style:
                  const TextStyle(

                color: Colors
                    .white38,

                fontSize:
                    16,

              ),

            ),

          ],

        ),

      ),

    );

  }

}


////////////////////////////////////////////////////////////
/// ANALYSE BLUETOOTH
////////////////////////////////////////////////////////////

class AnalysisPage extends StatefulWidget {

  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() =>
      _AnalysisPageState();

}

class _AnalysisPageState
    extends State<AnalysisPage> {

  ////////////////////////////////////////////////////////////
  /// PORT COM
  ////////////////////////////////////////////////////////////

  SerialPort? port;

  ////////////////////////////////////////////////////////////
  /// SIGNALS
  ////////////////////////////////////////////////////////////

  List<double> rawSignal =
      List.generate(120, (i) => 0);

  List<double> filteredSignal =
      List.generate(120, (i) => 0);

  ////////////////////////////////////////////////////////////
  /// SIGNAL ULTRA LISSÉ
  ////////////////////////////////////////////////////////////

  List<double> lowPass4HzSignal =
      List.generate(120, (i) => 0);

  ////////////////////////////////////////////////////////////
  /// STATUS
  ////////////////////////////////////////////////////////////

  String status = "Déconnecté";

  ////////////////////////////////////////////////////////////
  /// BUFFER SÉRIE
  ////////////////////////////////////////////////////////////

  String serialBuffer = "";

  ////////////////////////////////////////////////////////////
  /// FILTRE SIMPLE
  ////////////////////////////////////////////////////////////

  double previousFiltered = 0;

  double lowPassFilter(double input) {

    double alpha = 0.08;

    previousFiltered =
        alpha * input +
        (1 - alpha) *
            previousFiltered;

    return previousFiltered;

  }

  ////////////////////////////////////////////////////////////
  /// SUPER LISSAGE
  ////////////////////////////////////////////////////////////

  List<double> smoothingBuffer = [];

  double ultraSmooth(double input) {

    //////////////////////////////////////////////////////////
    /// AJOUTE VALEUR
    //////////////////////////////////////////////////////////

    smoothingBuffer.add(input);

    //////////////////////////////////////////////////////////
    /// FENÊTRE
    //////////////////////////////////////////////////////////

    if (smoothingBuffer.length > 40) {

      smoothingBuffer.removeAt(0);

    }

    //////////////////////////////////////////////////////////
    /// MOYENNE
    //////////////////////////////////////////////////////////

    double sum = 0;

    for (double v in smoothingBuffer) {

      sum += v;

    }

    return sum /
        smoothingBuffer.length;

  }

  ////////////////////////////////////////////////////////////
  /// INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {

    super.initState();

    print(
      SerialPort.availablePorts,
    );

    connectBluetooth();

  }

  ////////////////////////////////////////////////////////////
  /// BLUETOOTH
  ////////////////////////////////////////////////////////////

  void connectBluetooth() {

    try {

      ////////////////////////////////////////////////////////
      /// COM3 = ESP32
      ////////////////////////////////////////////////////////

      port = SerialPort("COM3");

      bool opened =
          port!.openReadWrite();

      if (opened) {

        setState(() {

          status =
              "muFLOW connecté";

        });

        final reader =
            SerialPortReader(port!);

        //////////////////////////////////////////////////////
        /// BUFFER SÉRIE
        //////////////////////////////////////////////////////

        reader.stream.listen((data) {

          try {

            //////////////////////////////////////////////////
            /// AJOUTE AU BUFFER
            //////////////////////////////////////////////////

            serialBuffer +=
                String.fromCharCodes(data);

            //////////////////////////////////////////////////
            /// SPLIT LIGNES
            //////////////////////////////////////////////////

            List<String> lines =
                serialBuffer.split('\n');

            //////////////////////////////////////////////////
            /// GARDE DERNIÈRE LIGNE
            //////////////////////////////////////////////////

            serialBuffer = lines.last;

            //////////////////////////////////////////////////
            /// TRAITE LIGNES COMPLÈTES
            //////////////////////////////////////////////////

            for (int i = 0;
                i < lines.length - 1;
                i++) {

              String received =
                  lines[i].trim();

              if (received.isEmpty) {
                continue;
              }

              print(received);

              //////////////////////////////////////////////////
              /// ADC BRUT
              //////////////////////////////////////////////////

              double adc =
                  double.tryParse(
                        received,
                      ) ??
                      0.0;

              adc = adc.clamp(
                0.0,
                4095.0,
              );

              //////////////////////////////////////////////////
              /// ADC → VOLTS
              //////////////////////////////////////////////////

              double voltage =
                  (adc / 4095.0) *
                      3.3;

              //////////////////////////////////////////////////
              /// FILTRE SIMPLE
              //////////////////////////////////////////////////

              double filtered =
                  lowPassFilter(
                    voltage,
                  );

              //////////////////////////////////////////////////
              /// ULTRA LISSAGE
              //////////////////////////////////////////////////

              double filtered4Hz =
                  ultraSmooth(
                    voltage,
                  );

              if (!mounted) return;

              setState(() {

                //////////////////////////////////////////////////
                /// SIGNAL BRUT
                //////////////////////////////////////////////////

                rawSignal.removeAt(0);

                rawSignal.add(
                  voltage,
                );

                //////////////////////////////////////////////////
                /// SIGNAL FILTRÉ
                //////////////////////////////////////////////////

                filteredSignal
                    .removeAt(0);

                filteredSignal.add(
                  filtered,
                );

                //////////////////////////////////////////////////
                /// SIGNAL ULTRA LISSÉ
                //////////////////////////////////////////////////

                lowPass4HzSignal
                    .removeAt(0);

                lowPass4HzSignal.add(
                  filtered4Hz,
                );

              });

            }

          }

          catch (e) {

            print(e);

          }

        });

      }

      else {

        setState(() {

          status =
              "Impossible d'ouvrir COM3";

        });

      }

    }

    catch (e) {

      print(e);

      setState(() {

        status =
            "Erreur Bluetooth";

      });

    }

  }

  @override
  void dispose() {

    port?.close();

    super.dispose();

  }

  ////////////////////////////////////////////////////////////
  /// GRAPH CARD
  ////////////////////////////////////////////////////////////

  Widget graphCard(
    String title,
    List<double> signal,
    Color color,
  ) {

    return Card(

      elevation: 3,

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              title,

              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),

            ),

            const SizedBox(height: 20),

            SizedBox(

              height: 220,

              child: CustomPaint(

                painter: SignalGraph(
                  signal,
                  color,
                ),

                size: Size.infinite,

              ),

            ),

          ],

        ),

      ),

    );

  }

  ////////////////////////////////////////////////////////////
  /// BUILD
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
              "Analyse Bluetooth",
            ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: ListView(

          children: [

            Card(

              child: Padding(

                padding:
                    const EdgeInsets.all(
                        14),

                child: Row(

                  children: [

                    const Icon(
                      Icons.bluetooth,
                    ),

                    const SizedBox(
                        width: 10),

                    Text(status),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            /// SIGNAL BRUT
            //////////////////////////////////////////////////

            graphCard(
              "Signal brut",
              rawSignal,
              Colors.red,
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            /// SIGNAL FILTRÉ
            //////////////////////////////////////////////////

            graphCard(
              "Signal filtré",
              filteredSignal,
              Colors.green,
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            /// SIGNAL ULTRA LISSÉ
            //////////////////////////////////////////////////

            graphCard(
              "Souffle stabilisé",
              lowPass4HzSignal,
              Colors.blue,
            ),

          ],

        ),

      ),

    );

  }

}

////////////////////////////////////////////////////////////
/// HISTORIQUE
////////////////////////////////////////////////////////////

class HistoryPage extends StatefulWidget {

  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();

}

class _HistoryPageState
    extends State<HistoryPage> {

  SerialPort? port;

  String serialBuffer = "";

  List<double> rawSignal =
      List.generate(120, (_) => 0);

  List<double> filteredSignal =
      List.generate(120, (_) => 0);

  List<double> smoothSignal =
      List.generate(120, (_) => 0);

  double previousFiltered = 0;

  List<double> smoothingBuffer = [];

  //////////////////////////////////////////////////////
  /// PASSE BAS
  //////////////////////////////////////////////////////

  double lowPassFilter(double input) {

    const double alpha = 0.08;

    previousFiltered =
        alpha * input +
        (1 - alpha) *
            previousFiltered;

    return previousFiltered;

  }

  //////////////////////////////////////////////////////
  /// MOYENNE GLISSANTE
  //////////////////////////////////////////////////////

  double ultraSmooth(double input) {

    smoothingBuffer.add(input);

    if (smoothingBuffer.length > 40) {

      smoothingBuffer.removeAt(0);

    }

    double sum = 0;

    for (double v in smoothingBuffer) {

      sum += v;

    }

    return sum /
        smoothingBuffer.length;

  }

  @override
  void initState() {

    super.initState();

    connectBluetooth();

  }

  void connectBluetooth() {

    try {

      port = SerialPort("COM3");

      if (!port!.openReadWrite()) {
        return;
      }

      final reader =
          SerialPortReader(port!);

      reader.stream.listen((data) {

        serialBuffer +=
            String.fromCharCodes(data);

        List<String> lines =
            serialBuffer.split('\n');

        serialBuffer = lines.last;

        for (int i = 0;
            i < lines.length - 1;
            i++) {

          String received =
              lines[i].trim();

          if (received.isEmpty) {
            continue;
          }

          double adc =
              double.tryParse(
                    received,
                  ) ??
                  0;

          adc = adc.clamp(
            0,
            4095,
          );

          double voltage =
              (adc / 4095.0) *
                  3.3;

          double filtered =
              lowPassFilter(
            voltage,
          );

          double smooth =
              ultraSmooth(
            voltage,
          );

          if (!mounted) {
            return;
          }

          setState(() {

            rawSignal.removeAt(0);
            rawSignal.add(
              voltage,
            );

            filteredSignal
                .removeAt(0);

            filteredSignal.add(
              filtered,
            );

            smoothSignal
                .removeAt(0);

            smoothSignal.add(
              smooth,
            );

          });

        }

      });

    } catch (_) {}

  }

  @override
  void dispose() {

    port?.close();

    super.dispose();

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Historique",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
                20),

        child: Card(

          child: Padding(

            padding:
                const EdgeInsets.all(
                    20),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const Text(

                  "Comparaison des signaux",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),

                ),

                const SizedBox(
                    height: 10),

                const Row(

                  children: [

                    Icon(
                      Icons.circle,
                      color:
                          Colors.red,
                      size: 12,
                    ),

                    SizedBox(
                        width: 5),

                    Text("Brut"),

                    SizedBox(
                        width: 20),

                    Icon(
                      Icons.circle,
                      color: Colors
                          .green,
                      size: 12,
                    ),

                    SizedBox(
                        width: 5),

                    Text("Filtré"),

                    SizedBox(
                        width: 20),

                    Icon(
                      Icons.circle,
                      color:
                          Colors.blue,
                      size: 12,
                    ),

                    SizedBox(
                        width: 5),

                    Text(
                        "Stabilisé"),

                  ],

                ),

                const SizedBox(
                    height: 20),

                Expanded(

                  child: CustomPaint(

                    painter:
                        TripleGraph(

                      rawSignal,

                      filteredSignal,

                      smoothSignal,

                    ),

                    size:
                        Size.infinite,

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

class TripleGraph extends CustomPainter {

  final List<double> raw;
  final List<double> filtered;
  final List<double> smooth;

  TripleGraph(
    this.raw,
    this.filtered,
    this.smooth,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    //////////////////////////////////////////////////////
    /// MIN / MAX COMMUNS
    //////////////////////////////////////////////////////

    List<double> all = [

      ...raw,
      ...filtered,
      ...smooth,

    ];

    double minValue =
        all.reduce(min);

    double maxValue =
        all.reduce(max);

    //////////////////////////////////////////////////////
    /// GRILLE
    //////////////////////////////////////////////////////

    final grid = Paint()

      ..color = Colors.grey.withOpacity(0.2)

      ..strokeWidth = 1;

    final textPainter = TextPainter(

      textDirection:
          TextDirection.ltr,

    );

    //////////////////////////////////////////////////////
    /// AXE Y + VALEURS EN VOLTS
    //////////////////////////////////////////////////////

    for (int i = 0; i < 5; i++) {

      double y =
          i * size.height / 4;

      canvas.drawLine(

        Offset(40, y),

        Offset(
          size.width,
          y,
        ),

        grid,

      );

      double value =

          maxValue -

          (i *
              (maxValue -
                      minValue) /
              4);

      textPainter.text = TextSpan(

        text:
            "${value.toStringAsFixed(2)} V",

        style: const TextStyle(

          color: Colors.black,

          fontSize: 11,

        ),

      );

      textPainter.layout();

      textPainter.paint(

        canvas,

        Offset(
          0,
          y - 8,
        ),

      );

    }

    //////////////////////////////////////////////////////
    /// COURBES
    //////////////////////////////////////////////////////

    drawSignal(

      canvas,
      size,

      raw,

      Colors.red,

      minValue,
      maxValue,

    );

    drawSignal(

      canvas,
      size,

      filtered,

      Colors.green,

      minValue,
      maxValue,

    );

    drawSignal(

      canvas,
      size,

      smooth,

      Colors.blue,

      minValue,
      maxValue,

    );

  }

  //////////////////////////////////////////////////////
  /// DESSIN D'UNE COURBE
  //////////////////////////////////////////////////////

  void drawSignal(

    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double minValue,
    double maxValue,

  ) {

    final paint = Paint()

      ..color = color

      ..strokeWidth = 2

      ..style =
          PaintingStyle.stroke;

    final path = Path();

    for (
      int i = 0;
      i < data.length;
      i++
    ) {

      ////////////////////////////////////////////////////
      /// DÉCALAGE DE 40 PX POUR
      /// LAISSER LA PLACE À L'AXE Y
      ////////////////////////////////////////////////////

      double x =

          40 +

          i *

              (size.width - 40) /

              data.length;

      ////////////////////////////////////////////////////
      /// NORMALISATION
      ////////////////////////////////////////////////////

      double normalized =

          (data[i] - minValue) /

          (maxValue -
                  minValue +
              0.0001);

      normalized =
          normalized.clamp(
              0.0,
              1.0);

      double y =

          size.height -

          normalized *
              size.height;

      if (i == 0) {

        path.moveTo(
          x,
          y,
        );

      }

      else {

        path.lineTo(
          x,
          y,
        );

      }

    }

    canvas.drawPath(
      path,
      paint,
    );

  }

  @override
  bool shouldRepaint(
      CustomPainter oldDelegate) {

    return true;

  }

}
////////////////////////////////////////////////////////////
/// ABOUT
////////////////////////////////////////////////////////////

class AboutPage extends StatelessWidget {

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
              "Présentation",
            ),
      ),

      body: const Padding(

        padding:
            EdgeInsets.all(20),

        child: Text(
          "BreathCoach aide les musiciens à contrôler leur souffle.",
        ),

      ),

    );

  }

}

////////////////////////////////////////////////////////////
/// GRAPHES
////////////////////////////////////////////////////////////

class SignalGraph extends CustomPainter {

  final List<double> data;

  final Color color;

  SignalGraph(
    this.data,
    this.color,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke;

    final grid = Paint()
      ..color = Colors.grey
          .withOpacity(0.2)
      ..strokeWidth = 1;

    //////////////////////////////////////////////////////
    /// AUTO ZOOM
    //////////////////////////////////////////////////////

    double minValue =
        data.reduce(min);

    double maxValue =
        data.reduce(max);

    //////////////////////////////////////////////////////
    /// TEXTE
    //////////////////////////////////////////////////////

    final textPainter =
        TextPainter(
      textDirection:
          TextDirection.ltr,
    );

    //////////////////////////////////////////////////////
    /// GRILLE + ÉCHELLES
    //////////////////////////////////////////////////////

    for (int i = 0; i < 5; i++) {

      double y =
          i * size.height / 4;

      canvas.drawLine(

        Offset(40, y),

        Offset(
          size.width,
          y,
        ),

        grid,

      );

      double value =
          maxValue -
          (i *
              (maxValue -
                      minValue) /
              4);

      textPainter.text = TextSpan(

        text:
            value.toStringAsFixed(2),

        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
        ),

      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(0, y - 8),
      );

    }

    //////////////////////////////////////////////////////
    /// SIGNAL
    //////////////////////////////////////////////////////

    final path = Path();

    for (int i = 0;
        i < data.length;
        i++) {

      double x =
          40 +
          i *
              (size.width - 40) /
              data.length;

      ////////////////////////////////////////////////////
      /// NORMALISATION
      ////////////////////////////////////////////////////

      double normalized =
          (data[i] - minValue) /
          (maxValue -
                  minValue +
              0.0001);

      normalized =
          normalized.clamp(
              0.0, 1.0);

      double y =
          size.height -
              (normalized *
                  size.height);

      if (i == 0) {

        path.moveTo(x, y);

      }

      else {

        path.lineTo(x, y);

      }

    }

    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {

    return true;

  }

}

////////////////////////////////////////////////////////////
/// COMPARAISON
////////////////////////////////////////////////////////////

class ComparisonGraph
    extends CustomPainter {

  final List<double> real;

  final List<double> ideal;

  ComparisonGraph(
    this.real,
    this.ideal,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final realPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke;

    final idealPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style =
          PaintingStyle.stroke;

    final realPath = Path();

    final idealPath = Path();

    for (int i = 0;
        i < real.length;
        i++) {

      double x =
          i *
              size.width /
              real.length;

      double yr =
          size.height -
              real[i] *
                  size.height;

      double yi =
          size.height -
              ideal[i] *
                  size.height;

      if (i == 0) {

        realPath.moveTo(x, yr);

        idealPath.moveTo(x, yi);

      }

      else {

        realPath.lineTo(x, yr);

        idealPath.lineTo(x, yi);

      }

    }

    canvas.drawPath(
      realPath,
      realPaint,
    );

    canvas.drawPath(
      idealPath,
      idealPaint,
    );

  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {

    return true;

  }

}

////////////////////////////////////////////////////////////
/// HELP
////////////////////////////////////////////////////////////

class HelpPage extends StatelessWidget {

  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar:
          AppBar(
            title:
                const Text("Help"),
          ),

      body: const Padding(

        padding:
            EdgeInsets.all(20),

        child: Text(
          "Choisir un exercice puis souffler.",
        ),

      ),

    );

  }

}