import 'package:term_buddy/util/extensions.dart';

import 'app/config.dart';

enum TerminalType {
  zsh,
  bash,
}

final extendedHistoryRegex = RegExp(r': \d+:\d+;(.*)');

class HistorySummaryEntry {
  final String command;
  int count = 0;
  DateTime? lastRun;
  final String? isAliasFor;

  HistorySummaryEntry(
    this.command,
    this.lastRun, {
    this.isAliasFor,
  });
}

class HistoryLine {
  final String command;
  final DateTime? time;
  final int count;

  HistoryLine({required this.command, required this.time, required this.count});

  //: 1676019089:0;echo $HOME
  // : 1676019096:0;echo $USER
  // : 1676037141:0;flutter pub add logger
  // : 1676039062:0;flutter clean
  // : 1676039165:0;flutter pub get
  // : 1676039695:0;flutter pub clean
  // : 1676039703:0;flutter clean
  // : 1676039714:0;flutter pub get
  static HistoryLine? fromExtendedHistory(String line) {
    final start = line.indexOf(';');
    if (start == -1) {
      return null;
    }
    final content = line.substring(start + 1);
    final secondColon = line.indexOf(':', 1);
    final time = DateTime.fromMillisecondsSinceEpoch(
        int.parse(line.substring(2, secondColon)) * 1000);
    // final time =
    //     DateTime.fromMillisecondsSinceEpoch(int.parse(timeString) * 1000);
    return HistoryLine(command: content, time: time, count: 1);
  }

  // flutter pub run auto_updater:sign_update dist/1.0.0+1/lipko_desktop-1.0.0+1-macos.zip
  // flutter build
  // flutter build macos
  // flutter build macos --release
  // flutter clean && flutter pub get
  // flutter build macos --release
  // flutter upgrade
  // cd ios
  // pod install --repo-update
  // pod install --repo-update
  // pod update PurchasesHybridCommon`
  static HistoryLine? fromSimpleLine(String line) {
    return HistoryLine(command: line, time: null, count: 1);
  }

  static HistoryLine? fromLine(String line) {
    if (line.isEmpty) {
      return null;
    }
    if (extendedHistoryRegex.hasMatch(line)) {
      return HistoryLine.fromExtendedHistory(line);
    }
    return HistoryLine.fromSimpleLine(line);
  }
}

class Alias {
  final String command;
  final String name;

  // shows where the alias is created in
  final String sourceFile;

  bool get isCompound => command.contains('&&');

  Alias({required this.command, required this.name, required this.sourceFile});

  bool get fromApp => sourceFile == bashBuddyFilePath;

  String get configLine => "alias $name='$command'";

  bool isAliasFor(String command) {
    final split = this.command.splitOnAnd();
    for (var item in split) {
      if (item == command.trim()) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'Alias{command: $command, short: $name, source: $sourceFile}';
  }

  // gstd='git stash drop'
  // gstl='git stash list'
  // gstp='git stash pop'
  // gsts='git stash show --text'
  // gstu='gsta --include-untracked'
  // gsu='git submodule update'
  // gsw='git switch'
  // gswc='git switch -c'
  // gswd='git switch $(git_develop_branch)'
  // gswm='git switch $(git_main_branch)'
  // gtl='gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'
  // gts='git tag -s'
  // gtv='git tag | sort -V'
  // gunignore='git update-index --no-assume-unchanged'
  // gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
  // gup='git pull --rebase'
  // gupa='git pull --rebase --autostash'
  // gupav='git pull --rebase --autostash -v'
  // gupom='git pull --rebase origin $(git_main_branch)'
  // gupomi='git pull --rebase=interactive origin $(git_main_branch)'
  // gupv='git pull --rebase -v'
  // gwch='git whatchanged -p --abbrev-commit --pretty=medium'
  // gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
  // history=omz_history
  // ide='open -a '\''IntelliJ IDEA'\'' .'
  // l='ls -lah'
  // la='ls -lAh'
  // ll='ls -lh'
  // ls='ls -G'
  // lsa='ls -lah'
  // md='mkdir -p'
  // rd=rmdir
  // run-help=man
  // which-command=whence
  static Alias? fromLine(String line, String sourceFile) {
    if (line.startsWith('alias ')) {
      line = line.substring(6);
    }
    final start = line.indexOf('=');
    if (start == -1) {
      return null;
    }
    final alias = line.substring(0, start);
    final command = line.substring(start + 1);
    final commandClean = command.cleanOuterQuotes();
    return Alias(command: commandClean, name: alias, sourceFile: sourceFile);
  }
}

class EnvVariableEntry {
  final String name;
  final List<String> values;

  EnvVariableEntry({required this.name, required this.values});

  EnvVariableEntry.fromValue({required String name, required String value})
      : this(name: name, values: value.split(':'));

  String get value => values.join(':');

  String get configLine => 'export $name="$value"';

  bool matchesSearch(String search) {
    return name.toLowerCase().contains(search) ||
        value.toLowerCase().contains(search);
  }
}

class PathEntry {
  final String path;
  final List<String> programs;

  PathEntry({required this.path, required this.programs});

  bool matchesSearch(String search) {
    final searchTerm = search.toLowerCase();
    return path.toLowerCase().contains(search) ||
        programs.any((element) => element.toLowerCase().contains(searchTerm));
  }
}
