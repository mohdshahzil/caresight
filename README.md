# CareSight

**AI-Driven Risk Prediction for Chronic Care Patients**

CareSight is a Flutter mobile application designed to help healthcare professionals predict and manage risks for chronic care patients using AI-driven insights. The app provides a comprehensive dashboard for monitoring patient cohorts across different medical conditions.

## Features

### 🏥 **Multi-Condition Support**
- **Maternal Care**: Monitor pregnancy-related risks and complications
- **Cardiovascular**: Track heart health and cardiovascular risk factors
- **Diabetes**: Manage diabetes-related risks and glucose monitoring
- **Arthritis**: Monitor joint health and mobility risks

### 📊 **AI-Powered Analytics**
- **Risk Prediction**: AI-driven risk scoring for each patient
- **Visual Analytics**: Interactive charts and graphs for data visualization
- **Risk Distribution**: Cohort-level risk analysis with pie charts and bar graphs
- **Trend Analysis**: Vitals tracking over time with line charts

### 🔍 **Explainable AI**
- **Global Explanations**: Feature importance across the entire model
- **Local Explanations**: Patient-specific risk factor analysis
- **Clinician-Friendly**: Simple, understandable explanations for medical professionals

### 📈 **Performance Metrics**
- **Model Evaluation**: AUROC, AUPRC, and calibration scores
- **Confusion Matrix**: Detailed performance breakdown
- **Additional Metrics**: Precision, recall, and F1-score analysis

### 📁 **Data Management**
- **File Upload**: Support for CSV, PDF, and JSON patient data files
- **Simulated Processing**: Prototype file upload with success feedback
- **Data Visualization**: Patient cohort management and filtering

## Design Principles

### 🎨 **Healthcare Psychology**
- **Calming Colors**: Blues and greens for trust and health
- **Risk Alerts**: Orange and yellow accents for attention-grabbing warnings
- **Clean Interface**: Minimal, professional design for clinical environments

### 📱 **Mobile-First Design**
- **Responsive Layout**: Optimized for mobile devices
- **Intuitive Navigation**: Bottom navigation and drawer menu
- **Smooth Animations**: Professional transitions and interactions

## Technical Stack

- **Framework**: Flutter 3.7.0+
- **Charts**: fl_chart for data visualization
- **File Handling**: file_picker for data uploads
- **State Management**: Provider pattern
- **Architecture**: Clean separation of concerns with models, screens, and utilities

## Project Structure

```
lib/
├── constants/          # App colors and theme configuration
├── models/            # Data models for patients and metrics
├── screens/           # UI screens and navigation
├── utils/             # Dummy data and utility functions
├── widgets/           # Reusable UI components
└── main.dart         # Application entry point
```

## Getting Started

1. **Prerequisites**
   - Flutter SDK 3.7.0 or higher
   - Dart SDK
   - Android Studio or VS Code with Flutter extensions

2. **Installation**
   ```bash
   git clone <repository-url>
   cd caresight
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

## Screens Overview

### 🏠 **Landing Screen**
- App branding and tagline
- Professional healthcare design
- Entry point to dashboard

### 📊 **Main Dashboard**
- Condition-based navigation tabs
- Patient cohort overview
- Risk distribution charts
- Quick access to all features

### 👤 **Patient Detail Screen**
- Individual patient information
- Vitals tracking over time
- Top 3 risk drivers
- Recommended actions

### 📤 **Upload Data Screen**
- File selection interface
- Support for multiple formats
- Upload progress and feedback

### 📈 **Evaluation Metrics Screen**
- Model performance indicators
- Confusion matrix visualization
- Additional performance metrics

### 🧠 **Explainability Screen**
- Global feature importance
- Local patient explanations
- Clinician-friendly insights

## Dummy Data

The application includes comprehensive dummy data for all supported conditions:
- **9 Sample Patients** across all conditions
- **Realistic Risk Scores** and medical data
- **Varied Risk Levels** (low, medium, high)
- **Detailed Vitals** with 30-day historical data
- **Risk Drivers** with importance percentages
- **Actionable Recommendations** for each patient

## Future Enhancements

- Real API integration for live data
- Advanced filtering and search capabilities
- Export functionality for reports
- Push notifications for high-risk alerts
- Multi-language support
- Offline data synchronization

## Contributing

This is a prototype application designed for demonstration purposes. For production use, additional security, validation, and integration features would be required.

## License

This project is created for educational and demonstration purposes.
