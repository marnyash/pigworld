import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportExportService {
  Future<String> exportReport({
    required String reportName,
    required String format,
    required Map<String, dynamic> data,
  }) async {
    final normalizedFormat = format.trim().toLowerCase();
    final safeName = reportName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    final directory = await _downloadsDirectory();
    final extension = _extensionFor(normalizedFormat);
    final filePath =
        '${directory.path}/${safeName}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final file = File(filePath);

    switch (normalizedFormat) {
      case 'pdf':
        await _writePdf(file, reportName, data);
        break;
      case 'csv':
        await file.writeAsString(_buildCsv(data));
        break;
      case 'json':
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(data),
        );
        break;
      case 'txt':
        await file.writeAsString(_buildTextReport(data));
        break;
      case 'xlsx':
        await _writeXlsx(file, data);
        break;
      default:
        await file.writeAsString(_buildTextReport(data));
    }

    return file.path;
  }

  Future<Directory> _downloadsDirectory() async {
    if (kIsWeb) {
      return await getTemporaryDirectory();
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        return downloadsDir;
      }
    }

    return await getApplicationDocumentsDirectory();
  }

  String _extensionFor(String format) {
    switch (format) {
      case 'pdf':
        return 'pdf';
      case 'csv':
        return 'csv';
      case 'json':
        return 'json';
      case 'txt':
        return 'txt';
      case 'xlsx':
        return 'xlsx';
      default:
        return 'txt';
    }
  }

  Future<void> _writePdf(
    File file,
    String reportName,
    Map<String, dynamic> data,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final rows = <pw.TableRow>[
            pw.TableRow(
              children: [
                pw.Text(
                  'Field',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Value',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            ...data.entries.map(
              (entry) => pw.TableRow(
                children: [pw.Text(entry.key), pw.Text(entry.value.toString())],
              ),
            ),
          ];

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                reportName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(border: pw.TableBorder.all(), children: rows),
            ],
          );
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _writeXlsx(File file, Map<String, dynamic> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];
    sheet.appendRow([TextCellValue('Field'), TextCellValue('Value')]);

    for (final entry in data.entries) {
      sheet.appendRow([
        TextCellValue(entry.key),
        TextCellValue(entry.value.toString()),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Unable to generate XLSX report');
    }

    await file.writeAsBytes(bytes);
  }

  String _buildCsv(Map<String, dynamic> data) {
    final rows = [
      ['Field', 'Value'],
      ...data.entries.map((entry) => [entry.key, entry.value.toString()]),
    ];

    final csv = rows
        .map((row) {
          final escaped = row
              .map((cell) {
                final value = cell.toString();
                if (value.contains(',') ||
                    value.contains('"') ||
                    value.contains('\n')) {
                  return '"${value.replaceAll('"', '""')}"';
                }
                return value;
              })
              .join(',');
          return escaped;
        })
        .join('\n');

    return '$csv\n';
  }

  String _buildTextReport(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Pig World Report');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    for (final entry in data.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }

    return buffer.toString();
  }
}
