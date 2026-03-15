import 'package:pdf/widgets.dart' as pw;

class PdfRenderer {

  pw.Widget buildTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget buildContent(String content) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        content,
        style: pw.TextStyle(fontSize: 16),
      ),
    );
  }
}