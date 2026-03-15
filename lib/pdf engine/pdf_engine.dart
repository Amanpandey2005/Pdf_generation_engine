import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_model.dart';

class PdfEngine {
  Future<void> generateReport(ReportModel report) async {
    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load("lib/assets/fonts/NotoSans-Regular.ttf");
      final myFont = pw.Font.ttf(fontData);

      final logoData = await rootBundle.load('lib/assets/Logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: myFont, bold: myFont),
          header: (context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 40, height: 40),
                  pw.Text("HealthCare AI Report", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Divider(),
            ],
          ),
          build: (context) => [
            pw.Header(
              level: 0,
              text: report.title,
              textStyle: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),

            if (report.imagePath != null && File(report.imagePath!).existsSync())
              pw.Center(
                child: pw.Container(
                  height: 200,
                  margin: const pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Image(
                    pw.MemoryImage(File(report.imagePath!).readAsBytesSync()),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

            pw.Paragraph(
              text: report.description,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 2.0),
            ),

            // 🔥 UPDATED: Unified Graph Section
            if (report.graphs != null && report.graphs!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text("Visual Analytics Summary:",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 10),
              _buildUnifiedChart(report.graphs!),
            ],

            if (report.parameters.isNotEmpty) ...[
              pw.SizedBox(height: 25),
              pw.Text("Technical Parameters:",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellStyle: const pw.TextStyle(fontSize: 10),
                data: <List<String>>[
                  ['S.No', 'Parameter', 'Value'],
                  ...report.parameters.entries.toList().asMap().entries.map((entry) {
                    return [
                      (entry.key + 1).toString(),
                      entry.value.key,
                      entry.value.value,
                    ];
                  }).toList(),
                ],
              ),
            ],
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("Error in PdfEngine: $e");
    }
  }

  // 🛠️ Chart Logic Fix: Scaling and Height Fixed
  pw.Widget _buildUnifiedChart(List<GraphData> graphs) {
    final List<String> labels = [];
    final List<pw.PointChartValue> points = [];

    for (int i = 0; i < graphs.length; i++) {
      final graph = graphs[i];
      if (graph.values.isNotEmpty) {
        final String label = graph.title;
        final double value = graph.values.values.first;
        final double safeValue = (value.isNaN || value.isInfinite) ? 0.0 : value;

        labels.add(label);
        // 🔥 Sab points ko ek hi dataset ke liye taiyaar karna
        points.add(pw.PointChartValue(i.toDouble(), safeValue));
      }
    }

    if (points.isEmpty) return pw.SizedBox();

    return pw.Container(
      height: 220,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis(
            List<double>.generate(labels.length, (index) => index.toDouble()),
            format: (v) {
              int idx = v.toInt();
              if (idx >= 0 && idx < labels.length) return labels[idx];
              return "";
            },
            textStyle: const pw.TextStyle(fontSize: 7),
          ),
          yAxis: pw.FixedAxis.fromStrings(
            ['0','20','40','60','80','100'],
          ),
        ),
        datasets: [
          pw.BarDataSet(
            color: PdfColors.blue700,
            width: 15,
            data: points, // 🔥 Saare points ek saath pass kiye
          ),
        ],
      ),
    );
  }
}