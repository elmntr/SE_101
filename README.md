🍗 Cross-Platform Inventory Management System for Chicken Joo
🌟 Project Overview
This is a user-friendly, cross-platform inventory management solution developed for Chicken Joo to manage stock across its franchise branches and central commissary. The primary objective is to provide the owner with full visibility into all inventories and automate low-stock alerts.
Key Features

Cross-Platform Access: Built using React Native to support both desktop (Windows) and mobile platforms
Offline-First Operation: The system must remain fully functional offline, requiring an internet connection only for data synchronization
Role-Based Access Control (RBAC): Restricts features and data access based on user roles (Admin, Franchisee, Employee)
Automated Alerts: Sends alarms/notifications to the admin when inventory falls below a customizable threshold
Commissary Management: Allows tracking of raw materials, mixed ingredients, and automatic computation of required raw ingredients
Consolidated Reporting: Generates daily, weekly, and monthly inventory reports across all branches and the commissary

💻 Technical Stack and Environment
CategoryComponentDetailsDevelopment FrameworkReact NativeMandated framework for cross-platform compatibilityTarget PlatformsWindows & Mobile (Android/iOS)Designed to run on test devices like Windows PCs and Android/iOS devicesBackend / Sync ServerNode.js + Cloud DatabaseRequired for the centralized database and syncing operations (e.g., Firebase/PostgreSQL)Local Data StorageLocal DatabaseEssential for the offline-first requirement
System Security Requirements

User authentication via username and password
Data must be encrypted (AES-256 for local storage, TLS for transfer)
Immediate access revocation for terminated franchise accounts

🛠️ Internal Deployment and Setup
These steps are intended for developers and QA engineers setting up the project locally.
Prerequisites
Ensure required tools like React Native, necessary compilers, and test devices are available.
Clone Repository
bashgit clone [INTERNAL_REPO_URL]
cd cross-platform-inventory
Install Dependencies
bashnpm install
# or yarn install
Configuration
Configure the connection details for the central Sync Server (Cloud DB).
Running the Application

Android: npx react-native run-android
Windows/Desktop: npx react-native run-windows (or applicable desktop command)

🗺️ Project Phases and Milestones (Scrum Framework)
The project follows an Agile - Scrum Framework with the following phases and deliverables:
PhaseModule / DeliverableDeadlinePhase 1Franchisee Inventory App (offline first, reports, low-stock alerts)October 22, 2025Phase 2Admin Monitoring DashboardNovember 5, 2025Phase 3Commissary Inventory ModuleNovember 26, 2025Phase 4Syncing & IntegrationDecember 17, 2025Phase 5Testing & DeploymentJanuary 7, 2026
Performance Goals

Dashboards (branch, admin, commissary) shall load within 3 seconds
Reports must generate within 5 seconds
Data must synchronize with the central server within 10 seconds once internet connection is available
