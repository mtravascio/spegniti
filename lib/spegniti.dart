import 'dart:io';
import 'dart:async';

DateTime? now;
DateTime? shutdownTime;

void go(Timer timer) {
  Duration duration = shutdownTime!.difference(DateTime.now());

  if (duration.isNegative) {
    timer.cancel();
    Process.run('shutdown', ['/f', '/s', '/t', '0']).then((result) {
      print('Sistema in fase di spegnimento...');
    });
  } else {
    print(
        'Tempo rimanente: ${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}');
  }
}
