// import 'dart:typed_data';

// import 'package:moneytrail/transaction_item.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class PdfService {
//   Future<Uint8List> generateTransactionPdf(
//     List<TransactionItem> transactions,
//   ) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Header(
//                 level: 0,
//                 child: pw.Text(
//                   'Transaction History',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 context: context,
//                 data: <List<String>>[
//                   <String>['Date', 'Title', 'Category', 'Type', 'Amount'],
//                   ...transactions.map((item) {
//                     return [
//                       item.date.toString().substring(0, 10),
//                       item.title,
//                       item.category,
//                       item.isExpense ? 'Expense' : 'Income',
//                       'RM${item.amount.toStringAsFixed(2)}',
//                     ];
//                   }),
//                 ],
//                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 headerDecoration: const pw.BoxDecoration(
//                   color: PdfColors.grey300,
//                 ),
//                 cellAlignment: pw.Alignment.centerLeft,
//                 cellAlignments: {4: pw.Alignment.centerRight},
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   // Future<void> printTransactionPdf(List<TransactionItem> transactions) async {
//   //   final pdfBytes = await generateTransactionPdf(transactions);
//   //   await Printing.layoutPdf(
//   //     onLayout: (PdfPageFormat format) async => pdfBytes,
//   //     name: 'MoneyTrail_History_${DateTime.now().millisecondsSinceEpoch}',
//   //   );
//   // }
// }
