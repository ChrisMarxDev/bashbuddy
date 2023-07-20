// Unit test file
// Path: test/util_test.dart
// Compare this snippet from lib/main.dart:

import 'package:flutter_test/flutter_test.dart';
import 'package:term_buddy/logic/alias.dart';
import 'package:term_buddy/models.dart';
import 'package:term_buddy/util/extensions.dart';

void main() {
  test('Test Alias constructor', () {
    final testLines = [
      "gupom='git pull --rebase origin \$(git_main_branch)'",
      "gupomi='git pull --rebase=interactive origin \$(git_main_branch)'",
      "gupv='git pull --rebase -v'",
      "gwch='git whatchanged -p --abbrev-commit --pretty=medium'",
      "gwip='git add -A; git rm \$(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m \"--wip-- [skip ci]\"'",
      "history=omz_history",
      "ide='open -a '''IntelliJ IDEA''' .'",
      "l='ls -lah'",
      "la='ls -lAh'",
      "ll='ls -lh'",
      "ls='ls -G'",
      "lsa='ls -lah'",
      "md='mkdir -p'",
      "rd=rmdir",
    ];

    final aliases =
        testLines.map((line) => Alias.fromLine(line, 'testfile')).toList();
    for (var alias in aliases) {
      print(alias.toString());
      expect(alias?.command, isNotNull);
    }
    expect(aliases.length, 14);
  });

  test('split line with &&', () {
    const line =
        'git status && git add . && git commit -m "Fix bug" && git commit -m "Fix bug && do other shit"';
    final split = line.splitOnAnd();
    expect(split, [
      'git status',
      'git add .',
      'git commit -m "Fix bug"',
      'git commit -m "Fix bug && do other shit"'
    ]);
  });

  test('create history lines with extended and non extended history', () {
    final examples = [
      ': 1676019089:0;echo \$HOME',
      ': 1676019096:0;echo \$USER',
      ': 1676037141:0;flutter pub add logger',
      ': 1676039062:0;flutter clean',
      ': 1676039165:0;flutter pub get',
      'flutter pub run auto_updater:sign_update dist/1.0.0+1/lipko_desktop-1.0.0+1-macos.zip',
      'flutter build',
      'flutter build macos',
      'flutter build macos --release',
      'flutter clean && flutter pub get'
    ];

    expect(true, extendedHistoryRegex.hasMatch(examples[0]));

    final historyLines =
        examples.map((line) => HistoryLine.fromLine(line)).toList();
    for (int i = 0; i < historyLines.length; i++) {
      var line = historyLines[i];
      print(line.toString());
      expect(line?.command, isNotNull);
      if (i < 5) {
        expect(line?.time, isNotNull);
      }
    }
    expect(historyLines.length, 10);
  });

  test('test directory path regex', () {
    // give me a regex pattern directoryRegex that satisfies these tests
    final validPaths = [
      '/Users/username/Projects/term_buddy',
      'some/dir/with/some/other/dir',
      '~/some/dir/with/some/other/dir',
      r'$HOME/some/dir/with/some/other/.dir',
      r'$FLUTTERPATH/some/dir/with/some/other/.dir',
    ];
    for (var path in validPaths) {
      expect(directoryRegex.hasMatch(path), true);
    }


  });
}
