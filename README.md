# Breath Trainer

Application de visualisation et d'entraînement du souffle destinée aux musiciens pratiquant des instruments à vent.

Le projet combine un capteur thermique, un microcontrôleur ESP32 et une application Flutter afin de mesurer, traiter et visualiser le souffle de l'utilisateur en temps réel.

---

# Présentation du projet

Le contrôle du souffle constitue une compétence essentielle pour la pratique des instruments à vent. Cependant, cette grandeur est difficile à quantifier et repose principalement sur les sensations du musicien.

L'objectif de ce projet est de développer un dispositif permettant de mesurer le souffle de manière objective et de fournir un retour visuel immédiat à l'utilisateur.

Le système permet :

* la mesure du souffle à l'aide d'un capteur thermique ;
* la transmission des données par Bluetooth ;
* le traitement numérique du signal ;
* la visualisation en temps réel du souffle ;
* la réalisation d'exercices de maintien du souffle.

Le dispositif a été conçu pour reproduire des conditions proches de la pratique réelle grâce à l'utilisation d'un bec spécialement développé pour les instruments à vent.

---

# Architecture du système

Le fonctionnement général du système est le suivant :

```text
Souffle du musicien
        ↓
Capteur thermique
        ↓
ESP32
        ↓
Bluetooth série
        ↓
Application Flutter
        ↓
Traitement du signal
        ↓
Visualisation et exercices
```

---

# Fonctionnalités

## Analyse du signal

Une interface d'analyse permet de visualiser différentes représentations du signal respiratoire :

* Signal brut
* Signal filtré par filtre passe-bas
* Signal stabilisé par moyenne glissante
* Comparaison simultanée des trois signaux

Cette interface a été utilisée pour caractériser le comportement du capteur et ajuster les paramètres de filtrage.

## Exercices respiratoires

L'application propose un exercice interactif de contrôle du souffle.

L'utilisateur doit maintenir son niveau de souffle à l'intérieur d'une zone cible pendant une durée définie.

Paramètres configurables :

* Niveau cible
* Largeur de la zone
* Durée de maintien
* Temps objectif

L'application affiche également :

* Le souffle normalisé
* Le temps passé dans la zone
* L'état de réussite de l'exercice

---

# Traitement du signal

Le capteur thermique utilisé est particulièrement sensible aux variations de température générées par le souffle. Cette sensibilité permet de détecter précisément l'activité respiratoire mais rend également le système vulnérable aux perturbations extérieures.

Afin d'obtenir un signal exploitable, plusieurs traitements numériques sont appliqués :

* Conversion ADC → tension
* Filtre passe-bas numérique
* Moyenne glissante
* Normalisation du signal

Les valeurs de référence utilisées pour la normalisation ont été déterminées expérimentalement :

| État                | Tension |
| ------------------- | ------- |
| Repos               | 2.62 V  |
| Expiration soutenue | 2.30 V  |

Le signal normalisé est ensuite converti en une valeur comprise entre 0 et 1 afin d'être utilisée par les exercices respiratoires.

---

# Technologies utilisées

## Logiciel

* Flutter
* Dart

## Matériel

* ESP32
* Capteur thermique
* Bluetooth série
* Bec instrumenté imprimé en 3D

---

# Structure du projet

```text
lib/
│
├── main.dart
│
├── analysis_page.dart
├── exercise_page.dart
├── history_page.dart
│
└── widgets/
```

Le point d'entrée principal de l'application est :

```text
lib/main.dart
```

---

# Installation

## Cloner le projet

```bash
git clone <repository>
```

## Installer les dépendances

```bash
flutter pub get
```

## Lancer l'application

```bash
flutter run
```

---

# Configuration du port Bluetooth

L'application communique avec l'ESP32 via un port série Bluetooth.

Dans la version actuelle du projet, le port utilisé correspond à la configuration de développement :

```dart
SerialPort("COM3")
```

Le nom du port série dépend de chaque ordinateur. Avant d'exécuter l'application, il est donc nécessaire de modifier cette valeur afin qu'elle corresponde au port attribué à votre module Bluetooth.

Par exemple :

```dart
SerialPort("COM5")
```

ou

```dart
SerialPort("COM7")
```

Sous Windows, le port utilisé peut être identifié dans :

```text
Gestionnaire de périphériques
    └── Ports (COM et LPT)
```

Une fois le numéro du port identifié, il suffit de remplacer la valeur `"COM3"` dans le code source.

> Remarque : le projet utilise actuellement une connexion Bluetooth série classique (SPP) et non Bluetooth Low Energy (BLE).

---

# Résultats

Le projet a permis de développer un prototype fonctionnel capable :

* d'acquérir le signal respiratoire en temps réel ;
* de transmettre les mesures via Bluetooth ;
* de filtrer et stabiliser le signal ;
* de proposer des exercices interactifs de contrôle du souffle.

Une évaluation réalisée avec une professionnelle de la musique a confirmé la pertinence du dispositif pour les instruments à anche simple et double tels que le saxophone, la clarinette ou le hautbois.

---

# Perspectives d'amélioration

Les évolutions envisagées comprennent :

* Adaptation à différents instruments à vent
* Niveaux de difficulté personnalisables
* Miniaturisation du dispositif
* Version autonome avec indicateurs lumineux
* Calibration spécifique selon l'utilisateur
* Enregistrement et suivi des performances

---

# Auteurs

Projet réalisé dans le cadre d'un projet multidisciplinaire à la HEIG-VD.
Code réalisé par Mousquès Noémie