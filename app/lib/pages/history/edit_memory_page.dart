import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/emotion.dart';
import '../../models/memory_entry.dart';
import '../../services/voice_note_service.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../widgets/home/emotion_chart_card.dart';
import '../../l10n/app_localizations.dart';

import '../../services/localized_date.dart';

const _speedOptions = [0.5, 1.0, 1.5, 2.0];

String _persianDigits(Object input, BuildContext context) {
  return LocalizedDate.formatNumber(input, context);
}

String _formatDuration(Duration d, BuildContext context) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return LocalizedDate.formatNumber('$m:$s', context);
}

class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  _BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class EditMemoryPage extends StatefulWidget {
  final MemoryEntry entry;
  const EditMemoryPage({super.key, required this.entry});

  @override
  State<EditMemoryPage> createState() => _EditMemoryPageState();
}

class _EditMemoryPageState extends State<EditMemoryPage> {
  late final _titleController = TextEditingController(text: widget.entry.title);
  late final _noteController = TextEditingController(text: widget.entry.note);
  final _voiceNoteService = VoiceNoteService();
  final _player = AudioPlayer();
  final _random = Random();

  StreamSubscription? _stateSub, _posSub, _durSub;
  late final List<double> _waveHeights = List.generate(28, (_) => 10 + _random.nextDouble() * 26);

  bool _loadingAudio = true, _isPlaying = false, _loadingImage = true, _saving = false, _imageChanged = false, _removeImage = false;
  String? _audioError, _error;
  Duration _position = Duration.zero, _totalDuration = Duration.zero;
  double _speed = 1.0;
  Uint8List? _imageBytes;
  String? _newImageFilename;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(milliseconds: ((widget.entry.durationSeconds ?? 0) * 1000).round());
    _loadAudio();
    _loadImage();
    _stateSub = _player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s.playing);
      if (s.processingState == ProcessingState.completed) {
        setState(() { _isPlaying = false; _position = Duration.zero; });
        _player.seek(Duration.zero); _player.pause();
      }
    });
    _posSub = _player.positionStream.listen((p) { if (mounted) setState(() => _position = p); });
    _durSub = _player.durationStream.listen((d) { if (mounted && d != null) setState(() => _totalDuration = d); });
  }

  @override
  void dispose() {
    _stateSub?.cancel(); _posSub?.cancel(); _durSub?.cancel();
    _player.dispose(); _titleController.dispose(); _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    try {
      final b = await _voiceNoteService.getAudioBytes(widget.entry.id);
      await _player.setAudioSource(_BytesAudioSource(b));
      if (mounted) setState(() => _loadingAudio = false);
    } catch (_) { if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      setState(() { _audioError = l10n.audioError; _loadingAudio = false; });
    } }
  }

  Future<void> _loadImage() async {
    if (!widget.entry.hasImage) { setState(() => _loadingImage = false); return; }
    try {
      final b = await _voiceNoteService.getImageBytes(widget.entry.id);
      if (mounted) setState(() { _imageBytes = b; _loadingImage = false; });
    } catch (_) { if (mounted) setState(() => _loadingImage = false); }
  }

  Future<void> _handleSave() async {
    final t = _titleController.text.trim();
    if (t.isEmpty) { setState(() => _error = AppLocalizations.of(context)!.errorTitleRequired); return; }
    setState(() { _saving = true; _error = null; });
    try {
      await _voiceNoteService.updateVoiceNote(id: widget.entry.id, title: t, note: _noteController.text, imageBytes: _imageChanged && !_removeImage ? _imageBytes : null, imageFilename: _newImageFilename, removeImage: _imageChanged && _removeImage);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) { if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      setState(() { _error = l10n.errorSaveMemory; _saving = false; });
    } }
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: sc.background,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(sc, l10n),
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _titleField(sc, l10n), const SizedBox(height: 18),
                _playbackCard(sc, l10n), const SizedBox(height: 18),
                _emotionCard(sc, l10n), const SizedBox(height: 18),
                Padding(padding: const EdgeInsets.only(right: 2, left: 2, bottom: 12), child: Text(l10n.addToMemory, style: context.sectionCount.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: sc.ink600))),
                _noteCard(sc, l10n), const SizedBox(height: 12),
                _photoCard(sc, l10n),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, textAlign: TextAlign.center, style: context.pwHint.copyWith(color: Colors.red))),
              ]))),
              _saveBtn(sc, l10n),
            ],
          ),
        ),
      );
  }

  Widget _topBar(SemanticColors sc, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(onTap: () => Navigator.of(context).pop(false), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: sc.surface, borderRadius: BorderRadius.circular(11), boxShadow: sc.shadowSoft), child: Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right : Icons.chevron_left, size: 20, color: sc.ink900))),
      Text(l10n.editMemoryTitle, style: context.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
      GestureDetector(onTap: _saving ? null : _handleSave, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(100), boxShadow: sc.shadowButton), child: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.saveChanges, style: context.buttonText.copyWith(fontSize: 12.5)))),
    ]),
  );

  Widget _titleField(SemanticColors sc, AppLocalizations l10n) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: sc.surface, borderRadius: BorderRadius.circular(16), boxShadow: sc.shadowSoft),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(l10n.memoryTitleLabel, style: context.fieldLabel), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: sc.dangerBg, borderRadius: BorderRadius.circular(100)), child: Text(l10n.required, style: context.pwHint.copyWith(fontSize: 10, color: sc.danger)))]),
      const SizedBox(height: 8),
      TextField(controller: _titleController, textAlign: TextAlign.start, style: context.fieldInput, decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
    ]),
  );

  Widget _playbackCard(SemanticColors sc, AppLocalizations l10n) {
    final progress = _totalDuration.inMilliseconds == 0 ? 0.0 : (_position.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(color: sc.surface, borderRadius: BorderRadius.circular(24), boxShadow: sc.shadowSoft),
      child: Column(children: [
        Text(_audioError != null ? l10n.audioError : (_loadingAudio ? l10n.audioLoading : l10n.playbackPrompt), style: context.pwHint.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, color: _audioError != null ? Colors.red : sc.ink400)),
        const SizedBox(height: 4), Text(l10n.recordedAt(LocalizedDate.formatNumber(widget.entry.timeLabel, context)), style: context.pwHint.copyWith(fontSize: 11)),
        const SizedBox(height: 16), Text('${_formatDuration(_position, context)} / ${_formatDuration(_totalDuration, context)}', style: context.sectionTitle.copyWith(fontSize: 20, fontWeight: FontWeight.w800), textDirection: TextDirection.ltr),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_waveHeights.length, (i) {
          final played = i < (_waveHeights.length * progress).round();
          return Container(width: 3, height: _isRecording ? 10 : _waveHeights[i], margin: const EdgeInsets.symmetric(horizontal: 1.2), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: played ? null : sc.line, gradient: played ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.purple500, AppColors.blue700]) : null));
        })),
        const SizedBox(height: 22),
        GestureDetector(onTap: _loadingAudio || _audioError != null ? null : () => _isPlaying ? _player.pause() : _player.play(), child: Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.heroGradient, boxShadow: sc.shadowButton), child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30))),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: _speedOptions.map((s) {
          final active = s == _speed;
          return GestureDetector(onTap: () { setState(() => _speed = s); _player.setSpeed(s); }, child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: active ? AppColors.purple100 : sc.background, borderRadius: BorderRadius.circular(100)), child: Text('${_persianDigits(s.toString().replaceAll('.0', ''), context)}x', style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.purple700 : sc.ink600))));
        }).toList()),
      ]),
    );
  }

  /// Builds the emotion chart for this specific memory entry using its emotionMix data.
  Widget _emotionCard(SemanticColors sc, AppLocalizations l10n) {
    final mix = widget.entry.emotionMix;
    final maxVal = mix.values.fold<double>(0, (a, b) => a > b ? a : b);
    final emotionLabels = {
      EmotionType.happy: l10n.happiness,
      EmotionType.sad: l10n.sadness,
      EmotionType.anger: l10n.anger,
      EmotionType.neutral: l10n.neutral,
    };
    final items = EmotionType.values.map((emotion) {
      final value = mix[emotion] ?? 0;
      final fraction = maxVal == 0 ? 0.0 : value / maxVal;
      final pct = (value * 100).round();
      return EmotionChartItem(
        emotion: emotion,
        percentLabel: l10n.percent(_persianDigits(pct, context)),
        barFraction: fraction.clamp(0.05, 1.0),
      );
    }).toList();

    return EmotionChartCard(
      title: l10n.emotionChartThisMemory,
      subtitle: l10n.dominantEmotionLabel(emotionLabels[widget.entry.dominantEmotion]!),
      badgeText: l10n.dominantEmotionLabel(emotionLabels[widget.entry.dominantEmotion]!),
      items: items,
    );
  }

  Widget _noteCard(SemanticColors sc, AppLocalizations l10n) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: sc.surface, borderRadius: BorderRadius.circular(16), boxShadow: sc.shadowSoft),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.purple700)),
        const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.note, style: context.memoryTitle.copyWith(fontSize: 13.5)), Text(l10n.notePlaceholder, style: context.memoryMeta.copyWith(fontSize: 11))])),
      ]),
      const SizedBox(height: 12),
      Container(decoration: BoxDecoration(color: sc.background, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(12), child: TextField(controller: _noteController, textAlign: TextAlign.start, maxLines: 4, minLines: 2, style: context.memoryTranscript.copyWith(fontSize: 13), decoration: InputDecoration(hintText: l10n.notePlaceholder, border: InputBorder.none, isDense: true))),
    ]),
  );

  Widget _photoCard(SemanticColors sc, AppLocalizations l10n) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: sc.surface, borderRadius: BorderRadius.circular(16), boxShadow: sc.shadowSoft),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.blue100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.blue700)),
        const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.photo, style: context.memoryTitle.copyWith(fontSize: 13.5)), Text(l10n.photoPlaceholder, style: context.memoryMeta.copyWith(fontSize: 11))])),
        if (!_loadingImage) GestureDetector(onTap: () async { final p = await ImagePicker().pickImage(source: ImageSource.gallery); if (p != null) { final b = await p.readAsBytes(); setState(() { _imageBytes = b; _newImageFilename = p.name; _imageChanged = true; _removeImage = false; }); } }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(100)), child: Text(_imageBytes != null ? l10n.change : l10n.add, style: context.aiChip.copyWith(fontSize: 12)))),
      ]),
      if (_imageBytes != null) Padding(padding: const EdgeInsets.only(top: 12), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(_imageBytes!, width: double.infinity, height: 140, fit: BoxFit.cover)), Positioned(top: 8, left: 8, child: GestureDetector(onTap: () => setState(() { _imageBytes = null; _imageChanged = true; _removeImage = true; }), child: Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white))))])),
    ]),
  );

  Widget _saveBtn(SemanticColors sc, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: GestureDetector(onTap: _saving ? null : _handleSave, child: Container(height: 56, decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(100), boxShadow: sc.shadowButton), alignment: Alignment.center, child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check, size: 18, color: Colors.white), const SizedBox(width: 8), Text(l10n.saveChanges, style: context.buttonText)]))),
  );

  bool get _isRecording => false; // Dummy for waveform
}