## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# BreathCoach 

Application interactive d’entraînement au **contrôle du souffle pour l’apprentissage de la flûte**.

Le projet vise à créer un **outil pédagogique ludique**, inspiré des jeux musicaux, qui aide les musiciens à :

- contrôler leur **pression d’air**
- visualiser le **souffle nécessaire pour chaque note**
- s’entraîner avec une **partition animée**

L’application affiche une partition qui défile et compare le souffle du joueur avec le souffle attendu pour chaque note.

---

# Objectif du projet

Dans l’apprentissage des instruments à vent (flûte, saxophone, etc.), le contrôle du souffle est essentiel mais difficile à visualiser.

Ce projet propose un **assistant musical interactif** permettant de :

- mesurer le souffle
- afficher le niveau de souffle en temps réel
- comparer avec le souffle attendu
- fournir un retour immédiat (Perfect / Good / Miss)

L’objectif final est de créer un **coach d’entraînement pour instruments à vent**.

---

# Fonctionnalités actuelles

- Partition musicale animée
- Notes qui défilent sous un curseur
- Jauge de souffle dynamique
- Indicateur de souffle attendu
- Système de score
- Feedback type jeu musical :
  - PERFECT
  - GOOD
  - MISS
- Système de combo

---

# Technologies utilisées

Le projet utilise :

- **Flutter** → framework pour créer l’application
- **Dart** → langage de programmation
- **Bravura** → police musicale (SMuFL)

Flutter permet de créer des applications pour :

- ordinateur
- web
- mobile

à partir d’un seul code.

---

# Structure du projet

Principaux dossiers :

BreathCoach  
│  
├─ lib/  
│   └─ main.dart        → code principal de l'application  
│  
├─ fonts/  
│   └─ Bravura.otf      → police musicale  
│  
├─ pubspec.yaml         → configuration Flutter  
│  
├─ android/  
├─ ios/  
├─ macos/  
├─ linux/  
└─ web/  

Le fichier principal à modifier est :

lib/main.dart

---

# Installer Flutter (si nécessaire)

Si Flutter n’est pas installé :

https://docs.flutter.dev/get-started/install

Puis vérifier l’installation avec :

flutter doctor

---

# Lancer l’application

1️ Cloner le projet

git clone https://github.com/mousques-01/BreathCoach.git

2️ Aller dans le dossier

cd BreathCoach

3️ Installer les dépendances

flutter pub get

4️ Lancer l’application

flutter run

---

# Contribution au projet

Si vous souhaitez modifier le projet :

1️ créer une branche

git checkout -b nouvelle-fonction

2️ faire vos modifications

3️ envoyer la branche

git push origin nouvelle-fonction

4️ créer une **Pull Request** sur GitHub.

---

## Utilisation du Bluetooth dans Flutter

Pour connecter le capteur de souffle à l’application, nous utiliserons le **Bluetooth Low Energy (BLE)**.

Dans Flutter, cela se fait à l’aide d’une bibliothèque appelée :

flutter_blue_plus

### 1. Ajouter la bibliothèque

Dans le fichier `pubspec.yaml`, ajouter :

```yaml
dependencies:
  flutter_blue_plus: ^1.31.15
```

Puis installer les dépendances :

```
flutter pub get
```

---

### 2. Scanner les appareils Bluetooth

L’application peut rechercher les appareils Bluetooth disponibles :

```dart
FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

FlutterBluePlus.scanResults.listen((results) {
  for (ScanResult r in results) {
    print(r.device.name);
  }
});
```

Cela permet de détecter l’appareil (par exemple l’ESP32 connecté au capteur).

---

### 3. Se connecter à l’appareil

Une fois l’appareil trouvé, l’application peut s’y connecter :

```dart
await device.connect();
```

---

### 4. Recevoir les données du capteur

Le microcontrôleur envoie des valeurs de souffle (par exemple `0.45`).  
Flutter peut les recevoir et les utiliser pour mettre à jour l’interface :

```dart
characteristic.value.listen((value) {
  String data = String.fromCharCodes(value);
  double breath = double.parse(data);
});
```

Cette valeur pourra ensuite être utilisée pour mettre à jour :

- la **jauge de souffle**
- le **score**
- le **feedback musical (Perfect / Good / Miss)**

---

### Objectif

À terme, le système complet fonctionnera ainsi :

Souffle du musicien  
↓  
Capteur de pression  
↓  
Microcontrôleur (ESP32)  
↓  
Bluetooth  
↓  
Application Flutter  
↓  
Analyse du souffle et feedback musical

---

# Améliorations prévues

Fonctionnalités à développer :

- connexion avec un **capteur de pression / souffle**
- ajout de **vraies partitions**
- niveaux de difficulté
- bibliothèque de musiques
- affichage des **doigtés de flûte**
- mode entraînement personnalisé
- analyse du souffle en temps réel

---

# Auteurs

Projet réalisé dans le cadre d’un projet académique.

