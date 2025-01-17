import 'dart:io';
import 'dart:async';

DateTime? now;
DateTime? shutdownTime;
String? sudoPwd;

void go(Timer timer) async {
  Duration duration = shutdownTime!.difference(DateTime.now());

  if (duration.isNegative) {
    timer.cancel();
    if (Platform.isWindows) {
      Process.run('shutdown', ['/f', '/s', '/t', '0']).then((result) {});
    } else if (Platform.isLinux) {
      Process.run('poweroff', []);
    } else if (Platform.isMacOS) {
      var process = await Process.start('sudo', ['-S', 'shutdown', '-h', 'now'],
          mode: ProcessStartMode.normal);
      process.stdin.writeln(sudoPwd);
    }
    print('Sistema in fase di spegnimento...');
  } else {
    print(
        'Tempo rimanente: ${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}');
  }
}
