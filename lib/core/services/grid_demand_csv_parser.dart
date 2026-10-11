import '../models/grid_demand_sample.dart';

/// Reads Nova Scotia Power's historical hourly load CSV.
///
/// The parser expects Date/time and Load [MW] columns, but accepts them in
/// either order. These measurements are province-wide and historical; they
/// are not live demand or a household's individual electricity use.
class GridDemandCsvParser {
  const GridDemandCsvParser();

  List<GridDemandSample> parse(String csv) {
    final lines = csv.split(RegExp(r'\r?\n'));
    var dateColumn = -1;
    var demandColumn = -1;
    var headerLine = -1;

    for (var i = 0; i < lines.length; i++) {
      final columns = _splitCsvLine(lines[i]);
      final normalized = columns.map(_normalizeHeader).toList();
      dateColumn = normalized.indexWhere(
        (column) => column == 'date/time' || column == 'datetime',
      );
      demandColumn = normalized.indexWhere(
        (column) => column.contains('load') && column.contains('mw'),
      );
      if (dateColumn >= 0 && demandColumn >= 0) {
        headerLine = i;
        break;
      }
    }

    if (headerLine < 0) {
      throw const FormatException(
        'Could not find Date/time and Load [MW] columns in the CSV.',
      );
    }

    final samples = <GridDemandSample>[];
    for (var i = headerLine + 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final columns = _splitCsvLine(lines[i]);
      if (columns.length <= dateColumn || columns.length <= demandColumn) {
        throw FormatException(
          'Incomplete grid-demand row at line ' + (i + 1).toString() + '.',
        );
      }

      final time = _parseReportTime(columns[dateColumn].trim());
      final demand = double.tryParse(
        columns[demandColumn].trim().replaceAll(',', ''),
      );
      if (time == null || demand == null || !demand.isFinite || demand < 0) {
        throw FormatException(
          'Invalid grid-demand value at line ' + (i + 1).toString() + '.',
        );
      }
      samples.add(GridDemandSample(time: time, demandMw: demand));
    }

    return List.unmodifiable(samples);
  }

  String _normalizeHeader(String value) =>
      value.trim().replaceAll('"', '').toLowerCase();

  DateTime? _parseReportTime(String value) {
    final match =
        RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2})$')
            .firstMatch(value);
    if (match == null) return null;

    final month = int.parse(match[1]!);
    final day = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final hour = int.parse(match[4]!);
    final minute = int.parse(match[5]!);
    if (month < 1 || month > 12 || hour > 23 || minute > 59) return null;

    final time = DateTime(year, month, day, hour, minute);
    if (time.year != year || time.month != month || time.day != day) return null;
    return time;
  }

  List<String> _splitCsvLine(String line) {
    final columns = <String>[];
    final field = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final character = line[i];
      if (character == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (character == ',' && !inQuotes) {
        columns.add(field.toString());
        field.clear();
      } else {
        field.write(character);
      }
    }
    columns.add(field.toString());
    return columns;
  }
}
