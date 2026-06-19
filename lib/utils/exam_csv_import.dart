import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../models/exam.dart';

const kCsvTemplateName = 'template_soal.csv';

const kCsvTemplateContent =
    'type,prompt,points,option1,option2,option3,option4,option5,correctIndex,correctIndexes,trueFalseAnswers,sampleAnswer\r\n'
    'multipleChoice,Ibu kota Indonesia adalah?,10,Jakarta,Bandung,Surabaya,Medan,,1,,,\r\n'
    'multipleChoiceComplex,"Berikut yang termasuk bilangan prima (pilih semua yang benar):",10,2,3,4,5,,"1;2;4",,\r\n'
    'trueFalse,Tentukan Benar atau Salah pernyataan berikut:,10,"2 + 2 = 4",Bumi mengelilingi matahari,Matahari terbit dari barat,,,"Benar;Benar;Salah",,\r\n'
    'essay,Jelaskan apa yang dimaksud dengan demokrasi Pancasila!,20,,,,,,,,Demokrasi Pancasila adalah sistem demokrasi berdasarkan nilai-nilai Pancasila.';

// Keterangan kolom CSV:
// type          : multipleChoice | multipleChoiceComplex | trueFalse | essay
// prompt        : teks pertanyaan/soal
// points        : nilai poin (angka)
// option1-5     : opsi jawaban (PG/Kompleks) atau pernyataan (Benar/Salah)
// correctIndex  : nomor opsi benar 1-based, untuk multipleChoice
// correctIndexes: nomor-nomor opsi benar dipisah ";" 1-based, untuk multipleChoiceComplex. Contoh: 1;3
// trueFalseAnswers: "Benar" atau "Salah" dipisah ";", untuk trueFalse. Contoh: Benar;Salah;Benar
// sampleAnswer  : kunci/rubrik jawaban, untuk essay

class CsvImportResult {
  final List<ExamQuestion> questions;
  final List<String> errors;

  const CsvImportResult({required this.questions, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
  bool get hasQuestions => questions.isNotEmpty;
}

CsvImportResult parseQuestionsFromCsv(String content) {
  final questions = <ExamQuestion>[];
  final errors = <String>[];
  const uuid = Uuid();

  final normalized =
      content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();

  List<List<dynamic>> rows;
  try {
    rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(normalized);
  } catch (e) {
    return CsvImportResult(
        questions: [], errors: ['Format CSV tidak valid: $e']);
  }

  if (rows.isEmpty) {
    return CsvImportResult(questions: [], errors: ['File kosong']);
  }

  for (var i = 1; i < rows.length; i++) {
    final rowNum = i + 1;
    final rawRow = rows[i];

    if (rawRow.isEmpty ||
        (rawRow.length == 1 && rawRow[0].toString().trim().isEmpty)) {
      continue;
    }

    final row = List<String>.generate(
      12,
      (j) => j < rawRow.length ? rawRow[j].toString().trim() : '',
    );

    final typeStr = row[0];
    final prompt = row[1];
    final points = int.tryParse(row[2]) ?? 10;
    final opts = [row[3], row[4], row[5], row[6], row[7]]
        .where((s) => s.isNotEmpty)
        .toList();
    final correctIndexStr = row[8];
    final correctIndexesStr = row[9];
    final trueFalseStr = row[10];
    final sampleAnswer = row[11];

    if (prompt.isEmpty) {
      errors.add('Baris $rowNum: kolom prompt (pertanyaan) kosong, dilewati');
      continue;
    }

    QuestionType type;
    switch (typeStr) {
      case 'multipleChoice':
        type = QuestionType.multipleChoice;
      case 'multipleChoiceComplex':
        type = QuestionType.multipleChoiceComplex;
      case 'trueFalse':
        type = QuestionType.trueFalse;
      case 'essay':
        type = QuestionType.essay;
      default:
        errors.add(
          'Baris $rowNum: jenis soal "$typeStr" tidak dikenal, dianggap Pilihan Ganda',
        );
        type = QuestionType.multipleChoice;
    }

    switch (type) {
      case QuestionType.multipleChoice:
        if (opts.length < 2) {
          errors.add(
              'Baris $rowNum: Pilihan Ganda butuh minimal 2 opsi, dilewati');
          continue;
        }
        final ci = (int.tryParse(correctIndexStr) ?? 1) - 1;
        questions.add(ExamQuestion(
          id: uuid.v4(),
          type: type,
          prompt: prompt,
          options: opts,
          correctIndex: ci.clamp(0, opts.length - 1),
          points: points,
        ));

      case QuestionType.multipleChoiceComplex:
        if (opts.length < 2) {
          errors.add(
              'Baris $rowNum: Pilihan Ganda Kompleks butuh minimal 2 opsi, dilewati');
          continue;
        }
        final cis = correctIndexesStr.isEmpty
            ? <int>[0]
            : correctIndexesStr
                .split(';')
                .map((s) => (int.tryParse(s.trim()) ?? 1) - 1)
                .where((i) => i >= 0 && i < opts.length)
                .toList();
        if (cis.isEmpty) {
          errors.add(
              'Baris $rowNum: Pilihan Ganda Kompleks tidak ada jawaban benar yang valid');
        }
        questions.add(ExamQuestion(
          id: uuid.v4(),
          type: type,
          prompt: prompt,
          options: opts,
          correctIndexes: cis,
          points: points,
        ));

      case QuestionType.trueFalse:
        if (opts.isEmpty) {
          errors.add(
              'Baris $rowNum: Benar/Salah butuh minimal 1 pernyataan, dilewati');
          continue;
        }
        final rawAnswers = trueFalseStr.isEmpty
            ? List.filled(opts.length, true)
            : trueFalseStr
                .split(';')
                .map((s) => s.trim().toLowerCase() != 'salah')
                .toList();
        while (rawAnswers.length < opts.length) {
          rawAnswers.add(true);
        }
        questions.add(ExamQuestion(
          id: uuid.v4(),
          type: type,
          prompt: prompt,
          options: opts,
          trueFalseAnswers: rawAnswers.sublist(0, opts.length),
          points: points,
        ));

      case QuestionType.essay:
        questions.add(ExamQuestion(
          id: uuid.v4(),
          type: type,
          prompt: prompt,
          sampleAnswer: sampleAnswer.isEmpty ? null : sampleAnswer,
          points: points,
        ));
    }
  }

  return CsvImportResult(questions: questions, errors: errors);
}
