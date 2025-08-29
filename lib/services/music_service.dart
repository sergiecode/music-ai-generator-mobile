import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Request model for music generation
class MusicGenerationRequest {
  final String prompt;
  final int? duration;

  MusicGenerationRequest({required this.prompt, this.duration});

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    if (duration != null) 'duration': duration,
  };
}

/// Response model for music generation
class MusicGenerationResponse {
  final bool success;
  final String message;
  final String trackId;
  final String prompt;
  final int duration;
  final int estimatedProcessingTime;
  final String status;
  final String? downloadUrl;

  MusicGenerationResponse({
    required this.success,
    required this.message,
    required this.trackId,
    required this.prompt,
    required this.duration,
    required this.estimatedProcessingTime,
    required this.status,
    this.downloadUrl,
  });

  factory MusicGenerationResponse.fromJson(Map<String, dynamic> json) {
    return MusicGenerationResponse(
      success: json['success'],
      message: json['message'],
      trackId: json['track_id'],
      prompt: json['prompt'],
      duration: json['duration'],
      estimatedProcessingTime: json['estimated_processing_time'],
      status: json['status'],
      downloadUrl: json['download_url'],
    );
  }
}

/// Model for track status
class TrackStatus {
  final String trackId;
  final String status;
  final int progress;
  final String prompt;
  final int duration;
  final String createdAt;
  final String estimatedCompletion;
  final String? downloadUrl;

  TrackStatus({
    required this.trackId,
    required this.status,
    required this.progress,
    required this.prompt,
    required this.duration,
    required this.createdAt,
    required this.estimatedCompletion,
    this.downloadUrl,
  });

  factory TrackStatus.fromJson(Map<String, dynamic> json) {
    return TrackStatus(
      trackId: json['track_id'],
      status: json['status'],
      progress: json['progress'],
      prompt: json['prompt'],
      duration: json['duration'],
      createdAt: json['created_at'],
      estimatedCompletion: json['estimated_completion'],
      downloadUrl: json['download_url'],
    );
  }
}

/// Service for interacting with the Music AI Generator Backend
/// Created by Sergie Code - Software Engineer & Programming Educator
class MusicService {
  // For Windows desktop/testing, use localhost
  static const String baseUrl = 'http://localhost:8000';
  // For Android emulator, use: 'http://10.0.2.2:8000'
  // For iOS simulator, use: 'http://127.0.0.1:8000'
  // For physical device, use your computer's IP: 'http://192.168.1.XXX:8000'
  
  final http.Client _client = http.Client();

  /// Check if the backend server is healthy and accessible
  Future<bool> checkServerHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      // In production, use proper logging instead of print
      // ignore: avoid_print
      print('Health check failed: $e');
      return false;
    }
  }

  /// Generate music using the backend API
  Future<MusicGenerationResponse> generateMusic(MusicGenerationRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/music/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return MusicGenerationResponse.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Generation failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get the current status of a track by its ID
  Future<TrackStatus> getTrackStatus(String trackId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/music/status/$trackId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return TrackStatus.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Track not found');
      } else {
        throw Exception('Failed to get track status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Poll track status until completion or failure
  Stream<TrackStatus> pollTrackStatus(String trackId) async* {
    while (true) {
      try {
        final status = await getTrackStatus(trackId);
        yield status;
        
        if (status.status == 'completed' || status.status == 'failed') {
          break;
        }
        
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        throw Exception('Polling failed: $e');
      }
    }
  }

  /// Get service information from the backend
  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/music/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get service info');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}
