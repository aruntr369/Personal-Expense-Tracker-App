Personal Finance Tracker
A modern, local-first Flutter application designed to help you effortlessly track your personal income and expenses. Built with a focus on clean architecture and a user-friendly interface, this app provides powerful tools to manage your finances, set spending limits, and visualize your financial habits.

✨ Features
Dashboard Overview: A beautiful home screen with a gradient card showing your total income, expenses, and current balance at a glance.

Add Transactions: Easily add income and expense entries through a clean and intuitive modal form.

Interactive Charts:

Spending by Category: A dynamic donut chart to visualize your spending breakdown by category. Toggle between monthly, weekly, and daily views.

Monthly Overview: A bar chart comparing your total income vs. expenses for each week of the current month.

Daily Transaction View: A horizontal calendar strip on the dashboard to quickly view all transactions for a specific day.

Configurable Spending Limits: Set monthly spending limits for any expense category. The app will show a warning on the dashboard if you exceed a limit and will ask for confirmation before adding an expense that goes over budget.

Detailed Summary: A comprehensive summary page with a list of all your transactions, grouped by date with sticky headers.

Powerful Filtering & Sorting:

Search: Instantly find transactions by searching their description.

Filter: Filter your transaction list by category and a specific date.

Sort: Sort all transactions by date in either ascending or descending order.

Local-First Storage: All your financial data is stored securely and privately on your device using Hive.

📸 Screenshots

<img src="/screenshots/s1.png" width="200"><img src="/screenshots/s2.png" width="200"><img src="/screenshots/s3.png" width="200">


🛠️ Tech Stack & Architecture
This project is built using modern Flutter development practices and a robust, scalable architecture.

Framework: Flutter

Architecture: Clean Architecture

State Management: BLoC (using flutter_bloc)

Local Storage: Hive (A lightweight and fast key-value database)

Dependency Injection: get_it (Service Locator)

Routing: auto_route (For clean and type-safe navigation)

Charting: fl_chart (A powerful and customizable charting library)

🚀 Getting Started
Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

Prerequisites
You must have the Flutter SDK installed on your machine. For more information, see the Flutter documentation.

Installation
Clone the repository:

git clone https://github.com/aruntr369/Personal-Expense-Tracker-App
cd Personal-Expense-Tracker-App

Install dependencies:

flutter pub get

Run the build_runner:
This project uses code generation for Hive models and routing. Run the following command to generate the necessary files:

flutter pub run build_runner build --delete-conflicting-outputs

Run the app:

flutter run

📂 Project Structure
The project follows the principles of Clean Architecture, separating the code into three distinct layers:

lib/
├── core/                   # Core utilities, dependency injection, routing
├── data/                   # Data layer (repositories, data sources, models)
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                 # Domain layer (entities, use cases, repository contracts)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/           # Presentation layer (UI, BLoCs)
├── bloc/
├── pages/
└── widgets/

Domain Layer: Contains the core business logic and entities of the app. It is completely independent of any frameworks.

Data Layer: Implements the repository contracts defined in the domain layer and handles all communication with data sources (like Hive).

Presentation Layer: Contains all the UI elements (widgets, pages) and the BLoC components that manage the UI state.
