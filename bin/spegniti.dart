import 'package:spegniti/spegniti.dart' as spegniti;
import 'dart:io';
import 'dart:async';

void main(List<String> arguments) async {
  String? timeInput;

  if (arguments.isEmpty) {
    print("Scrivi l'ora in formato HH:MM");

    timeInput = stdin.readLineSync();

    if (timeInput != null && timeInput.isEmpty) {
      print("Uso: spegniti.exe HH:MM");
      exit(1);
    }
  } else {
    timeInput = arguments[0];
  }

  List<String> timeParts = timeInput!.split(':');

  if (timeParts.length != 2) {
    print('Formato ora non valido. Usa HH:MM.');
    exit(1);
  }

  if (Platform.isMacOS) {
    print("E' richiesta la pwd di amministratore per spegnere!:");
    spegniti.sudoPwd = await getPassword();
    if (spegniti.sudoPwd!.isEmpty) {
      print('Password non inserita, spegnimento interrotto!');
      exit(1);
    }
    bool isValidPassword = await validateSudoPassword(spegniti.sudoPwd!);

    if (!isValidPassword) {
      print('Password Errata!');
      exit(1);
    }
  }

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  spegniti.now = DateTime.now();
  spegniti.shutdownTime = DateTime(
      spegniti.now!.year, spegniti.now!.month, spegniti.now!.day, hour, minute);

  if (spegniti.shutdownTime!.isBefore(spegniti.now!)) {
    spegniti.shutdownTime = spegniti.shutdownTime!
        .add(Duration(days: 1)); // Imposta per il giorno successivo
  }

  Timer.periodic(Duration(seconds: 1), spegniti.go);
}

Future<String> getPassword() async {
  List<int> passwordChars = [];

  stdout.write('Inserisci la password: ');
  stdin.echoMode = false;
  stdin.lineMode = false;

  while (true) {
    int charCode = stdin.readByteSync();
    if (charCode == 10 || charCode == 13) {
      break;
    }
    if (charCode == 127) {
      if (passwordChars.isNotEmpty) {
        passwordChars.removeLast();
        stdout.write('\b \b');
      }
    } else {
      passwordChars.add(charCode);
      stdout.write('*');
    }
  }

  stdin.echoMode = true;
  stdin.lineMode = true;

  print('');

  return String.fromCharCodes(passwordChars);
}

Future<bool> validateSudoPassword(String password) async {
  try {
    Process process = await Process.start(
      'sudo',
      ['-S', '-v'],
      mode: ProcessStartMode.normal,
      workingDirectory: Directory.current.path,
    );

    process.stdin.writeln(password);
    //print(password);

    final timeoutDuration = Duration(seconds: 5);
    await Future.any([
      process.exitCode,
      Future.delayed(timeoutDuration, () {
        process.kill();
        //print('Timeout!');
      })
    ]);

    int exitCode = await process.exitCode;
    //print(exitCode);
    return exitCode == 0;
  } catch (e) {
    print('Password Errata!');
    return false;
  }
}
