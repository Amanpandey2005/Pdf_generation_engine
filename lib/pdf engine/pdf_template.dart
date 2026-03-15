import 'package:pdf/widgets.dart' as pw;
import '../models/report_model.dart';
import 'pdf_renderer.dart';

class PdfTemplate {
  final PdfRenderer renderer = PdfRenderer();

  pw.MultiPage buildPage(ReportModel report) {
    return pw.MultiPage(
      build: (context) => [
        renderer.buildTitle(report.title),
        pw.SizedBox(height: 20),
        renderer.buildContent(report.description),
      ],
    );
  }
}