import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../services/voice_note_service.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../l10n/app_localizations.dart';

/// "New Memory" page. Similar to the login page, this is a StatefulWidget
/// because it manages multiple states: recording status, elapsed time,
/// the typed note, the selected image, and the saving process status.
class NewMemoryPage extends StatefulWidget {
  const NewMemoryPage({super.key});

  @override
  State<NewMemoryPage> createState() => _NewMemoryPageState();
}

class _NewMemoryPageState extends State<NewMemoryPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _recorder = AudioRecorder();
  final _voiceNoteService = VoiceNoteService();
  final _random = Random();

  bool _isRecording = false;
  bool _hasRecording = false; // recording finished and ready to save
  String? _recordedPath;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  List<double> _waveHeights = List.filled(15, 10);

  final bool _noteExpanded = true;
  Uint8List? _imageBytes;
  String? _imageFilename;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ---------------- Audio Recording ----------------

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (!mounted) return;
        setState(() => _error = AppLocalizations.of(context)!.errorMicPermission);
        return;
      }

      // Important Note: path_provider is not implemented for web - calling it there
      // will throw an exception (without a clear UI message) and halt the function.
      // Therefore, it is skipped on web; AudioRecorder creates a blob: URL for web,
      // where the path parameter simply serves as the filename.
      final String path;
      if (kIsWeb) {
        path = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.webm';
      } else {
        final dir = await getTemporaryDirectory();
        path = '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      await _recorder.start(const RecordConfig(), path: path);

      setState(() {
        _isRecording = true;
        _hasRecording = false;
        _elapsed = Duration.zero;
        _error = null;
      });

      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
          // Decorative waveform - since real-time amplitude analysis adds
          // significant complexity, this is currently a random animation
          // to indicate that recording is in progress.
          _waveHeights = List.generate(15, (_) => 8 + _random.nextDouble() * 32);
        });
      });
    } catch (e) {
      // If a similar issue occurs elsewhere (e.g., on a physical device),
      // the error will be displayed in the UI instead of failing silently.
      debugPrint('recording start failed: $e');
      setState(() => _error = AppLocalizations.of(context)!.errorStartRecording);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _ticker?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecording = path != null;
      _recordedPath = path;
    });
  }

  String get _timerLabel {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---------------- Image Selection ----------------

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFilename = picked.name;
    });
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageFilename = null;
    });
  }

  // ---------------- Save ----------------

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.errorSaveMemory); // Or more specific
      return;
    }
    if (!_hasRecording || _recordedPath == null) {
      setState(() => _error = l10n.audioError);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _voiceNoteService.createVoiceNote(
        audioPath: _recordedPath!,
        title: title,
        note: _noteController.text,
        imageBytes: _imageBytes,
        imageFilename: _imageFilename,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true); // true indicates the memory was saved, triggering a list refresh.
    } on VoiceNoteException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (e.message == 'connectionError') {
        setState(() => _error = l10n.connectionError);
      } else if (e.message == 'sessionExpired') {
        setState(() => _error = l10n.sessionExpired);
      } else {
        setState(() => _error = l10n.errorSaveMemory);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitleField(context, l10n),
                      const SizedBox(height: 18),
                      _buildRecordCard(context, l10n),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.only(right: 2, left: 2, bottom: 12),
                        child: Text(l10n.addToMemory, style: context.sectionCount.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.ink600)),
                      ),
                      _buildNoteCard(context, l10n),
                      const SizedBox(height: 12),
                      _buildPhotoCard(context, l10n),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, style: context.pwHint.copyWith(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              _buildSaveButton(context, l10n),
            ],
          ),
        ),
      );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(11),
                boxShadow: context.colors.shadowSoft,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.close, size: 18, color: context.colors.ink900),
            ),
          ),
          Text(l10n.newMemoryTitle,
              style: context.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
          GestureDetector(
            onTap: _saving ? null : _handleSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: context.colors.shadowButton,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.save, style: context.buttonText.copyWith(fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.memoryTitleLabel, style: context.fieldLabel),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.angerBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(l10n.required, style: context.pwHint.copyWith(fontSize: 10, color: context.colors.angerFg)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            textAlign: TextAlign.start,
            style: context.fieldInput,
            decoration: InputDecoration(
              hintText: l10n.memoryTitleHint,
              hintStyle: context.fieldPlaceholder,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Column(
        children: [
          Text(
            _isRecording
                ? l10n.recordingInProgress
                : (_hasRecording ? l10n.tapToReRecord : l10n.tapToStartRecording),
            style: context.pwHint.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Text(
            _timerLabel,
            textDirection: TextDirection.ltr,
            style: context.sectionTitle.copyWith(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_waveHeights.length, (i) {
                return Container(
                  width: 3.5,
                  height: _isRecording ? _waveHeights[i] : 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.purple500, AppColors.blue700],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heroGradient,
                boxShadow: context.colors.shadowButton,
              ),
              alignment: Alignment.center,
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isRecording
                ? l10n.recordingInProgress
                : (_hasRecording ? l10n.tapToReRecord : l10n.tapToStartRecording),
            style: context.pwHint.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _optionIcon(Icons.edit_note_rounded, AppColors.purple100, AppColors.purple700),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.note, style: context.memoryTitle.copyWith(fontSize: 13.5)),
                    Text(l10n.notePlaceholder,
                        style: context.memoryMeta.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (_noteExpanded) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _noteController,
                textAlign: TextAlign.start,
                maxLines: 3,
                minLines: 2,
                style: context.memoryTranscript.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: l10n.notePlaceholder,
                  hintStyle: context.fieldPlaceholder,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_noteController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _noteController.clear()),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.delete, style: context.pwHint.copyWith(fontSize: 11)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _optionIcon(Icons.photo_camera_outlined, AppColors.blue100, AppColors.blue700),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.photo, style: context.memoryTitle.copyWith(fontSize: 13.5)),
                    Text(l10n.photoPlaceholder,
                        style: context.memoryMeta.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              if (_imageBytes == null)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.purple100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(l10n.add, style: context.aiChip.copyWith(fontSize: 12)),
                  ),
                ),
            ],
          ),
          if (_imageBytes != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionIcon(IconData icon, Color bg, Color fg) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: fg),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: _saving ? null : _handleSave,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(100),
            boxShadow: context.colors.shadowButton,
          ),
          alignment: Alignment.center,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l10n.save, style: context.buttonText),
                  ],
                ),
        ),
      ),
    );
  }
}
