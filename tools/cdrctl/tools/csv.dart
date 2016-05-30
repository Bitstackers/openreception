import 'dart:io';

main() async {
  final String csv = await new File('../callpricing/teletakster.csv').readAsString();
  final List<String> lines = csv.split('\n');

  lines.forEach((String line) {
    final List<String> parts = line.split(',');
    final String code = '00' + parts[0].trim();
    final String perSecond =
        (((double.parse(parts[1].replaceAll('"', '')) * 100) / 60.0) + 0.05).toStringAsPrecision(3);
    final String setup = parts[2].replaceAll('"', '').trim();

    print('"${code}": {"setup": ${setup}, "persecond": ${perSecond}},');
  });
}
