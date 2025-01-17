import 'package:spegniti/spegniti.dart' as spegniti;
import 'dart:io';
import 'dart:async';

void main(List<String> arguments) {
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

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  // Calcola il tempo rimanente fino all'ora specificata
  //DateTime now = DateTime.now();
  //DateTime shutdownTime = DateTime(now.year, now.month, now.day, hour, minute);

  spegniti.now = DateTime.now();
  spegniti.shutdownTime = DateTime(
      spegniti.now!.year, spegniti.now!.month, spegniti.now!.day, hour, minute);

  if (spegniti.shutdownTime!.isBefore(spegniti.now!)) {
    spegniti.shutdownTime = spegniti.shutdownTime!
        .add(Duration(days: 1)); // Imposta per il giorno successivo
  }
/*
  // Countdown
  Timer.periodic(Duration(seconds: 1), (timer) {
    Duration duration = shutdownTime.difference(DateTime.now());

    if (duration.isNegative) {
      timer.cancel();
      Process.run('shutdown', ['/f', '/s', '/t', '0']).then((result) {
        print('Sistema in fase di spegnimento...');
      });
    } else {
      print(
          'Tempo rimanente: ${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}');
    }
  });
  */
  // Countdown
  Timer.periodic(Duration(seconds: 1), spegniti.go);
}
