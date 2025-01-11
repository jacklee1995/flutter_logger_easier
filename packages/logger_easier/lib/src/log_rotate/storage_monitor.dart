import 'dart:io' show Directory, Process, Platform;

class StorageMonitor {
  final int minimumFreeSpace;

  StorageMonitor({required this.minimumFreeSpace});

  Future<bool> hasEnoughSpace(String path) async {
    try {
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('df', ['-B1', path]);
        return _parseUnixDfOutput(result.stdout, minimumFreeSpace);
      } else if (Platform.isWindows) {
        final result = await Process.run('powershell',
            ['-command', '(Get-PSDrive ${path.split(':')[0]}).Free']);
        return _parseWindowsDriveSpace(result.stdout, minimumFreeSpace);
      }
      return true;
    } catch (e) {
      print('Error checking storage space: $e');
      return true;
    }
  }

  bool _parseUnixDfOutput(String output, int minSpace) {
    final lines = output.split('\n');
    if (lines.length < 2) return true;

    final parts =
        lines[1].split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length < 4) return true;

    final availableSpace = int.tryParse(parts[3]);
    return availableSpace == null || availableSpace >= minSpace;
  }

  bool _parseWindowsDriveSpace(String output, int minSpace) {
    final freeSpace = int.tryParse(output.trim());
    return freeSpace == null || freeSpace >= minSpace;
  }
}
