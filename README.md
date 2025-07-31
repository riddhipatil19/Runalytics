# 🏃‍♂️ Runalytics (Runn-Tracker)

A cross-platform Run Tracking application built using **Flutter** for the frontend and **Spring Boot** for the backend. The app allows users to track their runs, view history, and manage profiles with secure authentication.

> **My Contribution:** I developed the complete **backend implementation** using Spring Boot. The Flutter frontend was developed by my teammate.

---

## 📲 Features

### User Features:
- ✅ Sign up / Log in with JWT authentication
- 🏃 Start & stop run sessions
- 🗺️ View route maps and run history (if GPS is integrated)
- 📊 Dashboard with basic stats
- 👤 Profile management

### Backend Features (My Implementation):
- ✅ Secure RESTful API using Spring Security & JWT
- ✅ Modular architecture with DTOs, Services, Repositories
- ✅ User registration and authentication system
- ✅ Run data management (CRUD operations)
- ✅ Global error handling and validation
- ✅ Swagger API documentation
- ✅ Database integration with JPA/Hibernate

---

## 🛠 Tech Stack

| Layer     | Technology |
|-----------|-------|
| Frontend  | Flutter (Dart) |
| Backend   | Spring Boot (Java) |
| Auth      | JWT (Token-based) |
| Database  | MySQL |
| API Docs  | Swagger |

---

## 🗂️ Project Structure

### Backend (`runntrackerbackend/`)
```
├── config/
├── controller/
├── dto/
├── entity/
├── exception/
├── repo/
├── security/
├── service/
└── RunnTrackerBackendApplication.java
```

### Frontend (`runn-tracker-frontend/`)
```
├── lib/
│   ├── api/
│   ├── pages/
│   ├── provider/
│   ├── styles/
│   └── util/
├── assets/
├── android/ ios/ web/ windows/ macos/ linux/
└── pubspec.yaml
```

---

## 🚀 Getting Started

### 🔧 Prerequisites

- **Flutter SDK** installed: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Java 17+**
- **Maven**
- **MySQL DB** 
- Android Studio / VSCode (for Flutter)

---

### 🖥️ Backend Setup

```bash
cd runntrackerbackend
# Open in IDE (e.g., IntelliJ)
# Configure DB in `application.properties`
mvn clean install
mvn spring-boot:run
```

🔐 The backend uses JWT-based auth. Test APIs using Swagger at http://localhost:8080/swagger-ui/.

### 📱 Frontend Setup

```bash
cd runn-tracker-frontend
flutter pub get
flutter run
```

To run on Android:
```bash
flutter run -d android
```

To run on web:
```bash
flutter run -d chrome
```

---

## 🔐 API Endpoints (Spring Boot)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/login` | Login and receive JWT |
| GET | `/api/runs` | Get all user runs |
| POST | `/api/runs` | Add new run |
| GET | `/api/user/profile` | Get user info |

---

## 🧪 Testing

- Use Postman or Swagger to test endpoints.
- For Flutter, widget tests are in `test/widget_test.dart`.

---

## 🤝 Contributors

- **Riddhi Patil** - Backend Development (Spring Boot, API, Database, Authentication)
- **Hridaya** - Frontend Development (Flutter App)

---

## 📄 My Role & Contributions

As the backend developer for this project, I was responsible for:

- **API Design & Development:** Created RESTful endpoints for user management and run tracking
- **Authentication System:** Implemented JWT-based secure authentication
- **Database Design:** Designed and implemented the database schema using JPA/Hibernate
- **Security:** Configured Spring Security for API protection
- **Documentation:** Created comprehensive API documentation using Swagger
- **Error Handling:** Implemented global exception handling and validation
- **Testing:** Ensured API reliability through proper testing strategies

---

## ✨ Feedback

Feel free to open issues or submit pull requests to improve the app!