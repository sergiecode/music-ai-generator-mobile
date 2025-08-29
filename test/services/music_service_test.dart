import 'package:flutter_test/flutter_test.dart';
import 'package:music_ai_generator_mobile/services/music_service.dart';

void main() {
  group('MusicService Models', () {
    group('MusicGenerationRequest', () {
      test('should create request with prompt only', () {
        final request = MusicGenerationRequest(prompt: 'test music');
        
        expect(request.prompt, equals('test music'));
        expect(request.duration, isNull);
      });

      test('should create request with prompt and duration', () {
        final request = MusicGenerationRequest(
          prompt: 'energetic rock',
          duration: 60,
        );
        
        expect(request.prompt, equals('energetic rock'));
        expect(request.duration, equals(60));
      });

      test('should convert to JSON correctly', () {
        final request = MusicGenerationRequest(
          prompt: 'test music',
          duration: 30,
        );
        
        final json = request.toJson();
        
        expect(json, equals({
          'prompt': 'test music',
          'duration': 30,
        }));
      });

      test('should convert to JSON without duration when null', () {
        final request = MusicGenerationRequest(prompt: 'test music');
        
        final json = request.toJson();
        
        expect(json, equals({'prompt': 'test music'}));
        expect(json.containsKey('duration'), isFalse);
      });
    });

    group('MusicGenerationResponse', () {
      test('should create from JSON correctly', () {
        final json = {
          'success': true,
          'message': 'Generation started',
          'track_id': 'track_123',
          'prompt': 'test music',
          'duration': 30,
          'estimated_processing_time': 45,
          'status': 'processing',
          'download_url': null,
        };

        final response = MusicGenerationResponse.fromJson(json);

        expect(response.success, isTrue);
        expect(response.message, equals('Generation started'));
        expect(response.trackId, equals('track_123'));
        expect(response.prompt, equals('test music'));
        expect(response.duration, equals(30));
        expect(response.estimatedProcessingTime, equals(45));
        expect(response.status, equals('processing'));
        expect(response.downloadUrl, isNull);
      });

      test('should create from JSON with download URL', () {
        final json = {
          'success': true,
          'message': 'Generation completed',
          'track_id': 'track_456',
          'prompt': 'rock music',
          'duration': 60,
          'estimated_processing_time': 90,
          'status': 'completed',
          'download_url': 'http://example.com/track_456.mp3',
        };

        final response = MusicGenerationResponse.fromJson(json);

        expect(response.success, isTrue);
        expect(response.status, equals('completed'));
        expect(response.downloadUrl, equals('http://example.com/track_456.mp3'));
      });
    });

    group('TrackStatus', () {
      test('should create from JSON correctly', () {
        final json = {
          'track_id': 'track_789',
          'status': 'processing',
          'progress': 75,
          'prompt': 'classical music',
          'duration': 120,
          'created_at': '2025-08-28T10:00:00Z',
          'estimated_completion': '2025-08-28T10:02:00Z',
          'download_url': null,
        };

        final status = TrackStatus.fromJson(json);

        expect(status.trackId, equals('track_789'));
        expect(status.status, equals('processing'));
        expect(status.progress, equals(75));
        expect(status.prompt, equals('classical music'));
        expect(status.duration, equals(120));
        expect(status.createdAt, equals('2025-08-28T10:00:00Z'));
        expect(status.estimatedCompletion, equals('2025-08-28T10:02:00Z'));
        expect(status.downloadUrl, isNull);
      });

      test('should handle completed status with download URL', () {
        final json = {
          'track_id': 'track_complete',
          'status': 'completed',
          'progress': 100,
          'prompt': 'electronic beats',
          'duration': 45,
          'created_at': '2025-08-28T09:00:00Z',
          'estimated_completion': '2025-08-28T09:01:30Z',
          'download_url': 'http://example.com/track_complete.mp3',
        };

        final status = TrackStatus.fromJson(json);

        expect(status.status, equals('completed'));
        expect(status.progress, equals(100));
        expect(status.downloadUrl, equals('http://example.com/track_complete.mp3'));
      });

      test('should handle failed status', () {
        final json = {
          'track_id': 'track_failed',
          'status': 'failed',
          'progress': 0,
          'prompt': 'invalid prompt',
          'duration': 30,
          'created_at': '2025-08-28T11:00:00Z',
          'estimated_completion': '2025-08-28T11:01:00Z',
          'download_url': null,
        };

        final status = TrackStatus.fromJson(json);

        expect(status.status, equals('failed'));
        expect(status.progress, equals(0));
        expect(status.downloadUrl, isNull);
      });
    });
  });

  group('MusicService', () {
    late MusicService musicService;

    setUp(() {
      musicService = MusicService();
    });

    tearDown(() {
      musicService.dispose();
    });

    test('should have correct base URL', () {
      expect(MusicService.baseUrl, equals('http://10.0.2.2:8000'));
    });

    test('should create service instance', () {
      expect(musicService, isNotNull);
      expect(musicService, isA<MusicService>());
    });

    test('should dispose properly', () {
      // Test that dispose doesn't throw
      expect(() => musicService.dispose(), returnsNormally);
    });

    group('URL validation', () {
      test('should have valid base URL format', () {
        final url = MusicService.baseUrl;
        expect(url.startsWith('http://'), isTrue);
        expect(url.contains(':'), isTrue);
        expect(url.contains('8000'), isTrue);
      });

      test('should construct correct health endpoint', () {
        final url = '${MusicService.baseUrl}/health';
        expect(url, equals('http://10.0.2.2:8000/health'));
      });

      test('should construct correct generate endpoint', () {
        final url = '${MusicService.baseUrl}/music/generate';
        expect(url, equals('http://10.0.2.2:8000/music/generate'));
      });

      test('should construct correct status endpoint', () {
        const trackId = 'test_track_123';
        final url = '${MusicService.baseUrl}/music/status/$trackId';
        expect(url, equals('http://10.0.2.2:8000/music/status/test_track_123'));
      });
    });
  });

  group('Input Validation Tests', () {
    test('should validate prompt requirements', () {
      // Test empty prompt
      final emptyRequest = MusicGenerationRequest(prompt: '');
      expect(emptyRequest.prompt, isEmpty);

      // Test whitespace-only prompt
      final whitespaceRequest = MusicGenerationRequest(prompt: '   ');
      expect(whitespaceRequest.prompt, equals('   '));

      // Test valid prompt
      final validRequest = MusicGenerationRequest(prompt: 'energetic rock music');
      expect(validRequest.prompt, equals('energetic rock music'));
      expect(validRequest.prompt.length, greaterThan(0));
    });

    test('should validate duration requirements', () {
      // Test minimum duration
      final minDuration = MusicGenerationRequest(prompt: 'test', duration: 5);
      expect(minDuration.duration, equals(5));

      // Test maximum duration
      final maxDuration = MusicGenerationRequest(prompt: 'test', duration: 300);
      expect(maxDuration.duration, equals(300));

      // Test typical duration
      final normalDuration = MusicGenerationRequest(prompt: 'test', duration: 60);
      expect(normalDuration.duration, equals(60));

      // Test no duration (should be null)
      final noDuration = MusicGenerationRequest(prompt: 'test');
      expect(noDuration.duration, isNull);
    });

    test('should validate prompt length constraints', () {
      // Test very long prompt (500+ characters)
      final longPrompt = 'a' * 501;
      final longRequest = MusicGenerationRequest(prompt: longPrompt);
      expect(longRequest.prompt.length, equals(501));

      // Test normal length prompt
      final normalPrompt = 'relaxing piano melody for meditation and focus';
      final normalRequest = MusicGenerationRequest(prompt: normalPrompt);
      expect(normalRequest.prompt.length, lessThan(500));
      expect(normalRequest.prompt.length, greaterThan(0));
    });
  });

  group('Error Handling Tests', () {
    test('should handle malformed JSON responses', () {
      expect(() {
        final invalidJson = {'invalid': 'structure'};
        MusicGenerationResponse.fromJson(invalidJson);
      }, throwsA(isA<TypeError>()));
    });

    test('should handle missing required fields in JSON', () {
      expect(() {
        final incompleteJson = {
          'success': true,
          // Missing required fields
        };
        MusicGenerationResponse.fromJson(incompleteJson);
      }, throwsA(isA<TypeError>()));
    });

    test('should handle null values in JSON', () {
      final jsonWithNulls = {
        'track_id': 'track_123',
        'status': 'processing',
        'progress': 50,
        'prompt': 'test',
        'duration': 30,
        'created_at': '2025-08-28T10:00:00Z',
        'estimated_completion': '2025-08-28T10:01:00Z',
        'download_url': null,
      };

      expect(() {
        TrackStatus.fromJson(jsonWithNulls);
      }, returnsNormally);

      final status = TrackStatus.fromJson(jsonWithNulls);
      expect(status.downloadUrl, isNull);
    });
  });

  group('Status Progression Tests', () {
    test('should represent valid status progression', () {
      final statuses = ['processing', 'completed', 'failed'];
      
      for (final status in statuses) {
        final json = {
          'track_id': 'track_test',
          'status': status,
          'progress': status == 'completed' ? 100 : status == 'failed' ? 0 : 50,
          'prompt': 'test music',
          'duration': 30,
          'created_at': '2025-08-28T10:00:00Z',
          'estimated_completion': '2025-08-28T10:01:00Z',
          'download_url': status == 'completed' ? 'http://example.com/track.mp3' : null,
        };

        final trackStatus = TrackStatus.fromJson(json);
        expect(trackStatus.status, equals(status));
        
        if (status == 'completed') {
          expect(trackStatus.progress, equals(100));
          expect(trackStatus.downloadUrl, isNotNull);
        } else if (status == 'failed') {
          expect(trackStatus.downloadUrl, isNull);
        }
      }
    });

    test('should handle progress values correctly', () {
      final progressValues = [0, 25, 50, 75, 100];
      
      for (final progress in progressValues) {
        final json = {
          'track_id': 'track_progress',
          'status': progress == 100 ? 'completed' : 'processing',
          'progress': progress,
          'prompt': 'test music',
          'duration': 30,
          'created_at': '2025-08-28T10:00:00Z',
          'estimated_completion': '2025-08-28T10:01:00Z',
          'download_url': null,
        };

        final status = TrackStatus.fromJson(json);
        expect(status.progress, equals(progress));
        expect(status.progress, inInclusiveRange(0, 100));
      }
    });
  });
}
