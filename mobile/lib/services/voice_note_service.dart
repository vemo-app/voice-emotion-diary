 import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'token_storage.dart';

class VoiceNoteException implements Exception {
  final String message;
  VoiceNoteException(this.message);
}

class VoiceNoteService {
  /// [audioPath] is the output of AudioRecorder.stop():
  /// - Mobile: A local file path.
  /// - Web: A blob: URL.
  /// [imageBytes] is obtained via XFile.readAsBytes(), which works cross-platform.
  Future<void> createVoiceNote({
    required String audioPath,
    required String title,
    String? note,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest('POST', ApiClient.uri('/voice-notes'));

    request.headers['ngrok-skip-browser-warning'] = 'true';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    if (note != null && note.trim().isNotEmpty) {
      request.fields['note'] = note.trim();
    }

    request.files.add(await _audioPart(audioPath));

    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFilename ?? 'photo.jpg',
      ));
    }

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }

    if (streamed.statusCode == 200 || streamed.statusCode == 201) {
      return;
    }
    if (streamed.statusCode == 401) {
      throw VoiceNoteException('sessionExpired');
    }
    throw VoiceNoteException('errorSaveMemory');
  }

  Future<http.MultipartFile> _audioPart(String path) async {
    if (kIsWeb) {
      // On web, path is a blob: URL; we read bytes via http.readBytes.
      final bytes = await http.readBytes(Uri.parse(path));
      return http.MultipartFile.fromBytes('file', bytes, filename: 'voice_note.webm');
    }
    // On mobile, path is a local file path handled by MultipartFile.fromPath.
    return http.MultipartFile.fromPath('file', path);
  }

  /// Edits an existing memory (PATCH /voice-notes/{id}). Always sends title/note.
  /// imageBytes is sent only if a new image is selected; removeImage is true
  /// if the existing image should be deleted without replacement.
  Future<void> updateVoiceNote({
    required String id,
    required String title,
    String? note,
    Uint8List? imageBytes,
    String? imageFilename,
    bool removeImage = false,
  }) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest('PATCH', ApiClient.uri('/voice-notes/$id'));

    request.headers['ngrok-skip-browser-warning'] = 'true';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['note'] = note?.trim() ?? '';
    if (removeImage && imageBytes == null) {
      request.fields['remove_image'] = 'true';
    }
    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFilename ?? 'photo.jpg',
      ));
    }

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }

    if (streamed.statusCode == 200) return;
    if (streamed.statusCode == 401) {
      throw VoiceNoteException('sessionExpired');
    }
    if (streamed.statusCode == 404) {
      throw VoiceNoteException('errorMemoryNotFound');
    }
    throw VoiceNoteException('errorGeneric');
  }

  /// Fetches audio bytes for playback (GET /voice-notes/{id}/download).
  Future<Uint8List> getAudioBytes(String id) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri('/voice-notes/$id/download'), headers: headers);
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }
    if (response.statusCode == 200) return response.bodyBytes;
    throw VoiceNoteException('errorDownloadAudio');
  }

  /// Fetches memory image bytes (GET /voice-notes/{id}/image).
  /// Returns null if no image is found (404).
  Future<Uint8List?> getImageBytes(String id) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri('/voice-notes/$id/image'), headers: headers);
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }
    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 404) return null;
    throw VoiceNoteException('errorDownloadPhoto');
  }

  /// Deletes a memory (DELETE /voice-notes/{id}), including its audio and image files.
  Future<void> deleteVoiceNote(String id) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.delete(ApiClient.uri('/voice-notes/$id'), headers: headers);
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }
    if (response.statusCode == 204) return;
    if (response.statusCode == 404) {
      throw VoiceNoteException('errorMemoryNotFound');
    }
    if (response.statusCode == 401) {
      throw VoiceNoteException('sessionExpired');
    }
    throw VoiceNoteException('errorDeleteMemory');
  }

  /// Requests AI feedback for a memory (POST /voice-notes/{id}/feedback).
  /// Returns existing feedback if available, otherwise generates it via LLM.
  /// Returns 409 if the memory is still being processed.
  Future<String> requestFeedback(String id) async {
    final token = await TokenStorage.getToken();
    final headers = {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final http.Response response;
    try {
      response = await http.post(ApiClient.uri('/voice-notes/$id/feedback'), headers: headers);
    } catch (_) {
      throw VoiceNoteException('connectionError');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final feedback = json['feedback'] as String?;
      if (feedback == null || feedback.isEmpty) {
        throw VoiceNoteException('errorNoFeedback');
      }
      return feedback;
    }
    if (response.statusCode == 409) {
      throw VoiceNoteException('errorProcessing');
    }
    if (response.statusCode == 401) {
      throw VoiceNoteException('sessionExpired');
    }
    if (response.statusCode == 404) {
      throw VoiceNoteException('errorMemoryNotFound');
    }
    throw VoiceNoteException('errorGeneric');
  }
}
