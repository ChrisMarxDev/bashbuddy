import 'package:logger/logger.dart';

final memoryLogOutput = MemoryOutput(true);

final logger = Logger(
  output: MultiOutput([ConsoleOutput(), memoryLogOutput]),
  level: Level.verbose,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 3,
    errorMethodCount: 8,
    lineLength: 60,
    colors: false,
    printEmojis: true,
    printTime: false,
  ),
);

class MemoryOutput extends LogOutput {
  final List<String> _lines = [];

  List<String> get lines => _lines;

  final bool isActivated;

  MemoryOutput(this.isActivated);


  @override
  void output(OutputEvent event) {
    if (isActivated) {
      _lines.addAll(event.lines);
    }
  }

  String builder(int index) {
    return _lines[index];
  }

  int get length => _lines.length;

  String all() {
    return _lines.join('\n');
  }
}
