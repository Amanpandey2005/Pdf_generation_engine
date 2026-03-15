class ReportModel {
  final String title;
  final String description;
  final Map<String, String> parameters;
  final String? imagePath;
  // 🔥 Graphs ki list yahan add kar di hai
  final List<GraphData>? graphs;

  ReportModel({
    required this.title,
    required this.description,
    required this.parameters,
    this.imagePath,
    this.graphs, // Optional list
  });
}

class GraphData {
  final String type; // 'Bar', 'Pie', 'Line'
  final String title;
  final Map<String, double> values; // e.g., {"Accuracy": 94.0, "Loss": 6.0}

  GraphData({
    required this.type,
    required this.title,
    required this.values
  });
}