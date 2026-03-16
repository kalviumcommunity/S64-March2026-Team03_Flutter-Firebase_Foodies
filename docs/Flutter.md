🌱 FarmTrack – Flutter & Dart Basics
📌 Project Overview

FarmTrack is a mobile application designed to improve transparency in farm-to-home delivery systems. The app allows customers to track their orders in real-time through a clear status timeline, ensuring better trust between farmers, delivery services, and customers.

This project is developed using Flutter for cross-platform mobile development and Firebase (planned backend) for authentication, data storage, and real-time updates.

This repository contains the initial Flutter setup and a basic UI screen, which will serve as the foundation for future development in Sprint #2.

🚀 Technologies Used

Flutter – Cross-platform mobile development framework

Dart – Programming language used by Flutter

Android Studio / VS Code – Development environment

Flutter SDK – Required to run and build Flutter apps

⚙️ Flutter Environment Setup

Follow these steps to set up Flutter locally.

1️⃣ Install Flutter SDK

Download Flutter SDK from the official website:

https://flutter.dev/docs/get-started/install

Extract the Flutter folder and add it to your system PATH.

Example (Windows):

C:\src\flutter\bin
2️⃣ Install Android Studio or VS Code

Install either:

Android Studio

Install Android SDK

Install Android Emulator

Install Flutter & Dart plugins

OR

VS Code
Install extensions:

Flutter

Dart

3️⃣ Verify Installation

Run the following command:

flutter doctor

Expected output should confirm that Flutter, Dart, Android SDK, and emulator are correctly installed.

Example:

Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter
[✓] Android toolchain
[✓] Chrome
[✓] VS Code / Android Studio
🛠️ Creating the Flutter Project

Create a new Flutter project using:

flutter create farmtrack

Navigate into the project folder:

cd farmtrack

Run the application:

flutter run

This launches the default Flutter Demo App on an emulator or physical device.

📂 Project Folder Structure

A well-organized folder structure helps maintain clean code and makes scaling the application easier.

lib/
│
├── main.dart
│
├── screens/
│   └── welcome_screen.dart
│
├── widgets/
│   └── custom_button.dart
│
├── models/
│   └── order_model.dart
│
└── services/
    └── firebase_service.dart
📁 Folder Explanation
lib/

The main directory containing all Dart code used in the Flutter application.

main.dart

This is the entry point of the Flutter application.

Responsibilities:

Initializes the app

Runs the root widget using runApp()

Defines the starting screen of the application

Example:

void main() {
  runApp(MyApp());
}
screens/

Contains individual UI screens/pages of the application.

Examples:

Welcome Screen

Login Screen

Order Tracking Screen

Profile Screen

Keeping screens separate improves readability and maintainability.

Example:

screens/
welcome_screen.dart
login_screen.dart
widgets/

Stores reusable UI components.

Instead of rewriting UI code repeatedly, reusable widgets can be created and reused across screens.

Examples:

Custom Buttons

App Bars

Cards

Input Fields

Example:

widgets/
custom_button.dart
order_card.dart
models/

Contains data models that define the structure of application data.

Example:

models/
order_model.dart
user_model.dart

Example model:

class Order {
  final String orderId;
  final String status;

  Order({required this.orderId, required this.status});
}
services/

Handles backend services and business logic.

This folder will later contain:

Firebase authentication

Firestore database operations

API calls

Example:

services/
firebase_service.dart
auth_service.dart
🧠 Naming Conventions Used

To maintain consistency and readability, the following naming conventions are used:

Element	Convention	Example
File Names	snake_case	welcome_screen.dart
Class Names	PascalCase	WelcomeScreen
Variables	camelCase	orderStatus
Widgets	PascalCase	CustomButton

Benefits:

Improves readability

Maintains Flutter community standards

Helps large teams collaborate easily

📱 Simple Flutter UI Implementation

The default Flutter counter app was replaced with a custom Welcome Screen.

Features implemented:

Scaffold

AppBar

Column layout

Text widget

Icon/Image

ElevatedButton

setState() to change UI state

Example UI Code
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  String message = "Welcome to FarmTrack";

  void changeMessage() {
    setState(() {
      message = "Start Tracking Your Farm Deliveries!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FarmTrack"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              message,
              style: TextStyle(fontSize: 24),
            ),

            SizedBox(height: 20),

            Icon(
              Icons.agriculture,
              size: 80,
              color: Colors.green,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: changeMessage,
              child: Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}

This demonstrates understanding of:

Flutter widgets

State management

Dart syntax

UI layout