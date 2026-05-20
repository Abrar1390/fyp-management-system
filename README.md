# Final Year Project (FYP) Management System

A production-ready, cross-platform mobile and web application engineered to completely digitalize and streamline the lifecycle of university Final Year Projects (FYPs). This application effectively eliminates administrative overhead by transitioning traditional manual, paper-based tracking, and fragmented email chains into a unified real-time ecosystem.

Built using **Flutter (3.x)** and powered by a reactive **Firebase** infrastructure , the system dynamically adapts based on discrete user permissions, delivering optimized workflows for students, supervisors, and administrators.

---

## 🚀 System Architecture & Key Features

### 🔒 Identity & Access Control

* 
**Role-Based Provisioning:** Native multi-tenant authentication mapping users to custom Student, Supervisor, or Admin profiles directly during registration.


* 
**State Persistence:** Secure, session-managed login cycles allowing persistent app access across system restarts without repeating authentication.


* 
**Client-Side Validation:** Form inputs validated through customized regular expressions and length parameters before interacting with network APIs.



### 👨‍🎓 Student Capabilities

* 
**Full CRUD Project Engine:** Complete operational authority over project data models, allowing students to seamlessly create, read, update, and delete project entries.


* 
**Real-Time Progress Tracking:** Chronologically sequenced task logs nested directly inside distinct project records to simplify progress timelines.


* 
**Adaptive Monitoring Metrics:** Interactive dashboards with automated chart components highlighting milestone completions and looming deadlines.



### 👨‍🏫 Supervisor Insights

* 
**Centralized Command Centers:** Comprehensive operational dashboards providing clear overviews of all active student project groups assigned to that supervisor.


* 
**Live Assessment Flows:** Interface mechanisms allowing supervisors to drop real-time textual feedback and immediately update project status indicators (e.g., Approve/Reject).



### ⚡ Real-Time Synchronization Layer

* 
**Reactive UI Re-Rendering:** Implemented utilizing Flutter `StreamBuilder` components bound cleanly to live Firestore snapshots. Any modifications pushed by a supervisor instantly update student views across the network without polling delays.



---

## 🛠️ Tech Stack & Core Libraries

| Technology Layer | Solution Platform | Primary Architectural Purpose |
| --- | --- | --- |
| **Core Core Engine** | Flutter 3.x / Dart 3.x | Compiles multi-platform native UI from a singular codebase.

 |
| **Identity Management** | Firebase Authentication | Secure user sign-up, role selection, and persistent logging.

 |
| **Data Architecture** | Cloud Firestore | Real-time, cloud-hosted document database for reactive sync.

 |
| **State Management** | Provider Package | Decouples business logic layer entirely from rendering layouts.

 |
| **Visual Analytics** | FL Chart | Dynamically calculates and renders project execution statistics.

 |
| **Micro-Animations** | Flutter Animate / Lottie | Smooth contextual view-state shifts and visual transitions.

 |

---

## 🗂️ Production Folder Directory Structure

The repository relies on a modular feature-by-layer structure, clearly segregating core services, data entities, view controllers, and ui mockups:

```text
lib/
├── core/
[cite_start]│   └── theme/               # Application styling and color definitions [cite: 56]
[cite_start]├── models/                  # Concrete data schema models [cite: 58]
[cite_start]│   ├── activity_model.dart  # Formats user action trails [cite: 59]
[cite_start]│   ├── feedback_model.dart  # Structures supervisor annotations [cite: 61]
[cite_start]│   ├── progress_model.dart  # Manages tracking milestone points [cite: 72]
[cite_start]│   ├── project_model.dart   # Outlines full project parameters [cite: 73]
[cite_start]│   └── user_model.dart      # Maps corporate user metadata [cite: 75]
[cite_start]├── providers/               # Application reactive state management blocks [cite: 77]
[cite_start]│   ├── auth_provider.dart   # Processes ongoing global login states [cite: 79]
[cite_start]│   ├── project_provider.dart# Orchestrates repository CRUD workflows [cite: 81]
[cite_start]│   └── theme_provider.dart  # Dispatches user-preference runtime modes [cite: 82]
[cite_start]├── services/                # Low-level infrastructure cloud wrappers [cite: 85]
[cite_start]│   ├── auth_service.dart    # Manages upstream security calls [cite: 87]
[cite_start]│   ├── firestore_service.dart# Executes real-time document queries [cite: 94]
[cite_start]│   └── storage_service.dart # Interacts with file storage pipelines [cite: 95]
└── ui/                      # Responsive visual interface layouts
    [cite_start]├── admin/               # Administrative cluster views [cite: 97]
    [cite_start]├── auth/                # Sign-in and onboarding interfaces [cite: 104]
    [cite_start]├── shared/              # Reusable design elements and cards [cite: 109]
    [cite_start]├── student/             # Interactive student workspaces [cite: 141]
    [cite_start]└── supervisor/          # Review portals and feedback matrices [cite: 153]

```

---

## 📊 Database Schema Design

Cloud Firestore is configured as a document-driven NoSQL architecture using the following hierarchical collection layout:

### 🏢 `users` (Collection)

Stores critical baseline user profiles populated instantly upon account registration.

* 
`uid` (String): Unique identity token matching Firebase Auth profiles.


* 
`name` (String): Display name of the user.


* 
`email` (String): Registered institutional contact email address.


* 
`role` (String): Operational clearance tag (`student` | `supervisor` | `admin`).


* 
`department` (String): Academic department tracking.


* 
`semester` (String): Current academic semester level.



### 📂 `projects` (Collection)

Tracks top-level metrics for all final year project applications registered in the application.

* 
`projectid` (String): Unique document ID auto-generated by the database framework.


* 
`studentUid` (String): Implicit structural link directly binding the record to its student creator.


* 
`title` (String): Full academic title of the proposed FYP.


* 
`description` (String): In-depth summary of project objectives.


* 
`technologies` (String): Comma-separated array or listing of implementation libraries.


* 
`supervisorName` (String): Explicitly named academic internal guide.


* 
`progressStatus` (String): Project operational phase toggle (`Pending` | `In Progress` | `Completed`).


* 
`submittedAt` (Timestamp): Server-side ingestion marker tracking project timeline initialization.



#### 🧾 `projects/{id}/progressUpdate` (Sub-Collection)

A hierarchical relational sub-collection managing independent weekly status logs for specific target project entries.

* 
`week` (String): Numerical marker indexing tracking periods (e.g., "Week 03").


* 
`taskDescription` (String): Detailed text block describing weekly activity goals.


* 
`completedTasks` (String): Concrete item deliverables checked off during the tracking window.



---

## 🛠️ Step-by-Step Installation & Local Deployment Guide

Follow these sequential blocks to establish an isolated development environment matching production targets:

### 1. Environmental Prerequisites

Ensure your host device possesses the standardized Flutter SDK profile before pulling files:

```bash
# Verify system environment matches Flutter 3.x dependencies
flutter doctor

```

### 2. Repository Cloning & Dependency Initialization

Clone the target directory structure and fetch all specified build tracking scripts:

```bash
# Pull the project from remote version host
git clone https://github.com/Abrar1390/fyp-management-system.git

# Step into the deployment route root
cd fyp-management-system

# Clean development caches and resolve configuration dependencies
flutter pub get

```

### 3. Injecting Firebase Infrastructure Identifiers

The system requires specific backend integration configuration parameters to establish persistent communication pipelines:

🤖 Android Build Integration 

1. Register your corresponding app package format parameters (e.g., `com.example.fyp_manager`) within your personal Firebase Control Console.


2. Download your assigned platform configuration map file titled `google-services.json`.


3. Move the downloaded file asset directly into your target local directory path:



`android/app/google-services.json` 



🌐 Cross-Platform Web Integration 

1. Ensure the FlutterFire Command Line Engine is globally operational on your terminal.


2. Run automated project scaffolding configurations to generate missing environmental configuration files automatically:


```bash
flutterfire configure

```


3. This dynamically formats and constructs your platform config file under `lib/firebase_options.dart`.



### 4. Direct App Ingestion & Runtime Launch

Deploy the code modules onto your active terminal testing components:

```bash
# Launch compiling process across targeting emulators
flutter run

```

---

## 👨‍💻 Developed By

* 
**Abrar Hussain** *Department of Computer Science, National University of Modern Languages (NUML), Islamabad* 


*System ID:* `NUML-F24-40316` | *Roll Number:* `I-ADC9248336`
