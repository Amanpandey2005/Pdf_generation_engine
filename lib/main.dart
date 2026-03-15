import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/report_model.dart';
import 'pdf engine/pdf_engine.dart'; // Note: Space hata kar underscore use karein

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ReportScreen(),
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _accuracyController = TextEditingController();
  final TextEditingController _datasetController = TextEditingController();

  // 🔥 Graphs ke liye naye controllers
  final TextEditingController _graphTitleController = TextEditingController();
  final TextEditingController _graphValueController = TextEditingController();
  String _selectedGraphType = 'Bar';
  List<GraphData> _addedGraphs = [];

  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool _includeTable = false;
  bool _includeGraphs = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Report Generator Pro"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TABLE SECTION ---
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: SwitchListTile(
                title: const Text("Include Technical Table?", style: TextStyle(fontWeight: FontWeight.bold)),
                value: _includeTable,
                onChanged: (val) => setState(() => _includeTable = val),
              ),
            ),
            if (_includeTable) ...[
              const SizedBox(height: 10),
              _buildSmallTextField(_modelController, "Model Name"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildSmallTextField(_accuracyController, "Accuracy")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSmallTextField(_datasetController, "Dataset")),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // --- 🔥 DYNAMIC GRAPHS SECTION 🔥 ---
            Card(
              elevation: 2,
              color: Colors.green[50],
              child: SwitchListTile(
                title: const Text("Add Charts & Graphs?", style: TextStyle(fontWeight: FontWeight.bold)),
                value: _includeGraphs,
                onChanged: (val) => setState(() => _includeGraphs = val),
              ),
            ),
            if (_includeGraphs) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedGraphType,
                      decoration: const InputDecoration(labelText: "Graph Type"),
                      items: ['Bar', 'Line'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _selectedGraphType = val!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildSmallTextField(_graphTitleController, "Class Name")),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSmallTextField(_graphValueController, "Value (0-100)")),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green, size: 35),
                          onPressed: () {
                            if (_graphTitleController.text.isNotEmpty && _graphValueController.text.isNotEmpty) {
                              setState(() {
                                _addedGraphs.add(GraphData(
                                    type: _selectedGraphType,
                                    title: _graphTitleController.text,
                                    values: { _graphTitleController.text: double.tryParse(_graphValueController.text) ?? 0.0 }
                                ));
                                _graphTitleController.clear();
                                _graphValueController.clear();
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // Added Graphs Preview
              Wrap(
                spacing: 8,
                children: _addedGraphs.map((g) => Chip(
                  label: Text("${g.title}: ${g.values.values.first}"),
                  onDeleted: () => setState(() => _addedGraphs.remove(g)),
                  deleteIcon: const Icon(Icons.cancel, size: 18),
                )).toList(),
              ),
            ],

            const SizedBox(height: 20),
            const Text("Select Clinical Image:", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                child: _selectedImagePath == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.blueAccent))
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover)),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Findings/Description:", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(controller: _contentController, maxLines: 4, decoration: const InputDecoration(hintText: "Enter analysis...", border: OutlineInputBorder())),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text("GENERATE PDF", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () async {
                  if (_contentController.text.isEmpty) return;

                  try {
                    Map<String, String> tableData = {};
                    if (_includeTable) {
                      tableData["Model"] = _modelController.text;
                      tableData["Accuracy"] = _accuracyController.text;
                      tableData["Dataset"] = _datasetController.text;
                    }

                    final report = ReportModel(
                      title: "AI Analysis Report",
                      description: _contentController.text,
                      imagePath: _selectedImagePath,
                      parameters: tableData,
                      graphs: _includeGraphs ? _addedGraphs : [], // 🔥 Graphs bheje ja rahe hain
                    );

                    await PdfEngine().generateReport(report);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}