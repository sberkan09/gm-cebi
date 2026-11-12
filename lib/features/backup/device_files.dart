/// Files in and out of the app through the system: the share sheet, the
/// "save as" dialog and the file picker. Behind an interface so widget tests
/// can fake it ([deviceFilesProvider]). None of these needs a permission:
/// the system dialogs hand the app just the one file the user chose.
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'backup.dart';

abstract class DeviceFiles {
  /// Shares [bytes] as a file named [fileName] through the share sheet.
  /// False if the user dismissed it (where the platform tells).
  Future<bool> shareFile(Uint8List bytes, {required String fileName, required String mimeType});

  /// Shares plain text through the share sheet.
  Future<void> shareText(String text, {String? subject});

  /// "Dosyaya kaydet": the system's save dialog. False if cancelled.
  Future<bool> saveFile(Uint8List bytes, {required String fileName, required String mimeType});

  /// Lets the user pick one .json file and returns its bytes, or null if
  /// cancelled. Throws a [BackupException] for a file over [maxBytes].
  Future<Uint8List?> pickJson({int maxBytes = maxBackupBytes});
}

class SystemDeviceFiles implements DeviceFiles {
  const SystemDeviceFiles();

  @override
  Future<bool> shareFile(Uint8List bytes, {required String fileName, required String mimeType}) async {
    final r = await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
      fileNameOverrides: [fileName],
      subject: fileName,
    ));
    return r.status != ShareResultStatus.dismissed;
  }

  @override
  Future<void> shareText(String text, {String? subject}) => SharePlus.instance.share(ShareParams(text: text, subject: subject));

  @override
  Future<bool> saveFile(Uint8List bytes, {required String fileName, required String mimeType}) async =>
      await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType) != null;

  @override
  Future<Uint8List?> pickJson({int maxBytes = maxBackupBytes}) async {
    final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
    if (f == null) return null;
    final size = f.lengthSync() ?? await f.length();
    if (size != null && size > maxBytes) throw const BackupException(tooLargeMessage);
    return f.readAsBytes();
  }
}

/// Overridden in widget tests with a fake.
final deviceFilesProvider = Provider<DeviceFiles>((ref) => const SystemDeviceFiles());
