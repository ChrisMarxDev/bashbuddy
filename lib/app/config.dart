import 'package:process_run/shell.dart';

// final homeVar = shellEnvironment['HOME'];
// final homeVar = userHomePath;
// final homeVar = "~";
// write a tilde
// final homePath = homeVar != null ? '~' + homeVar.substring(homeVar.length - 1) : '~';

const bashBuddySourceLine = 'source ~/$aliasFileName';
 final bashBuddyFilePath = '$userHomePath/$aliasFileName';
const aliasFileName = '.bashbuddy';

const purchaseLicenseString = 'purchase license';

// all files in which to search for aliases and env vars
final possibleMacConfigFiles = [
  "$userHomePath/.bash_aliases",
  "$userHomePath/.bashrc",
  "$userHomePath/.profile",
  "$userHomePath/.zprofile",
  "$userHomePath/.zsh_aliases",
  "$userHomePath/.zshenv",
  "$userHomePath/.zshrc",
  "$userHomePath/.bash_profile",
  "$userHomePath/.bash_login",
];

// all files in which to add aliases and env vars
final possibleMacSourceFiles = [
  "$userHomePath/.bashrc",
  // "$userHomePath/.profile",
  // "$userHomePath/.zprofile",
  "$userHomePath/.zshrc",
];
