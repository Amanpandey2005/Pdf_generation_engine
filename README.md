# 📄 HealthCare AI Report Generator (Flutter + PDF)

## 🚀 Overview

**HealthCare AI Report Generator** is a Flutter-based module that automatically generates **professional AI analysis reports in PDF format**.
It is designed for Machine Learning / Deep Learning healthcare projects such as **Mouth Ulcer Detection, Dental Calculus Detection, or Medical Image Classification.**

The report includes:

* 🧠 AI Prediction Image
* 📊 Visual Analytics Graphs (Bar Charts)
* 📝 Description / Diagnosis Summary
* 📋 Technical Parameters Table
* 🏥 Professional Header Branding

This module helps convert **raw ML outputs into clean downloadable reports** suitable for research, presentation, or clinical documentation.

---

## ✨ Features

✅ Multi-page PDF Generation
✅ Custom Font Support
✅ Logo Header Branding
✅ AI Prediction Image Rendering
✅ Dynamic Bar Chart Visualization
✅ Safe Numeric Parsing (int / double / string %)
✅ Technical Parameter Table
✅ Error Handling & Null Safety
✅ Clean Professional Layout

---

## 🧱 Project Structure

```
lib/
│
├── pdf/
│   └── pdf_engine.dart
│
├── models/
│   └── report_model.dart
│
├── assets/
│   ├── fonts/
│   │    └── NotoSans-Regular.ttf
│   └── Logo.png
```

---

## 📦 Dependencies

Add these in `pubspec.yaml`

```yaml
dependencies:
  pdf: ^3.10.8
  printing: ^5.12.0
```

Also register assets:

```yaml
flutter:
  assets:
    - lib/assets/Logo.png
    - lib/assets/fonts/NotoSans-Regular.ttf
```

---

## 🧠 ReportModel Design

### GraphData

```dart
class GraphData {
  String title;
  Map<String, dynamic> values;

  GraphData({
    required this.title,
    required this.values,
  });
}
```

---

### ReportModel

```dart
class ReportModel {
  String title;
  String description;
  String? imagePath;
  List<GraphData>? graphs;
  Map<String, dynamic> parameters;

  ReportModel({
    required this.title,
    required this.description,
    this.imagePath,
    this.graphs,
    required this.parameters,
  });
}
```

---

## 📊 Example Graph Input

```dart
graphs: [

  GraphData(
    title: "Prediction Confidence",
    values: {
      "Ulcer": 96,
      "Healthy": 82,
      "Calculus": 21,
    },
  ),

]
```

This generates a **bar chart in PDF** comparing class confidence scores.

---

## 📋 Example Parameters Table

```dart
parameters: {
  "Model": "VGG19",
  "Accuracy": "94%",
  "Epochs": "25",
}
```

---

## 🖨️ Generate PDF

```dart
PdfEngine().generateReport(reportModel);
```

This will open **print / download preview dialog**.

---

## ⚠️ Important Notes

* Graph values must be numeric (int / double / numeric string)
* Avoid NaN or Infinite values
* Provide valid local image path
* At least **2 values required** to render chart
* Asset paths must match `pubspec.yaml`

---

## 🎯 Future Enhancements

* 📈 Line Chart (Training Curve)
* 🥧 Pie Chart (Class Distribution)
* 🔢 Dynamic Axis Scaling
* 🧩 Confusion Matrix Image Support
* 📄 Footer with Page Numbers
* 💾 Direct Save to Downloads Folder
* 🌙 Dark Theme Report Mode

---

## 👨‍💻 Use Case

Ideal for:

* Medical AI Projects
* Research Paper Demonstrations
* College Major Projects
* Internship Portfolio
* ML Model Reporting Systems

---

## ⭐ Author

Developed as part of an **AI-powered healthcare analytics reporting system using Flutter & Deep Learning models.**

---
