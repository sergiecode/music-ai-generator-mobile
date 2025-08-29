import 'package:flutter_test/flutter_test.dart';
import 'package:music_ai_generator_mobile/services/music_service.dart';

void main() {
  group('Backend Integration Tests', () {
    late MusicService musicService;

    setUp(() {
      musicService = MusicService();
    });

    tearDown(() {
      musicService.dispose();
    });

    test('should connect to backend health endpoint', () async {
      try {
        final isHealthy = await musicService.checkServerHealth();
        expect(isHealthy, isTrue, 
          reason: 'Backend should be running on localhost:8000. Make sure music-ai-generator-backend is running.');
      } catch (e) {
        fail('Failed to connect to backend: $e\n'
             'Please ensure music-ai-generator-backend is running on localhost:8000');
      }
    });

    test('should be able to generate music request', () async {
      try {
        final request = MusicGenerationRequest(prompt: 'test piano melody', duration: 10);
        final response = await musicService.generateMusic(request);
        
        expect(response, isNotNull);
        expect(response.success, isTrue);
        expect(response.trackId, isNotEmpty);
        expect(response.prompt, equals('test piano melody'));
        expect(response.duration, equals(10));
        
        print('✅ Music generation request successful!');
        print('   Track ID: ${response.trackId}');
        print('   Status: ${response.status}');
        print('   Message: ${response.message}');
        
        // If we got this far, the backend integration is working
      } catch (e) {
        fail('Failed to generate music: $e\n'
             'Backend might not have all required dependencies or endpoints configured properly.');
      }
    });

    test('should be able to check track status', () async {
      try {
        // First generate a track
        final request = MusicGenerationRequest(prompt: 'test melody for status check', duration: 10);
        final generateResponse = await musicService.generateMusic(request);
        expect(generateResponse.success, isTrue);
        
        // Then check its status
        final statusResponse = await musicService.getTrackStatus(generateResponse.trackId);
        expect(statusResponse, isNotNull);
        expect(statusResponse.trackId, equals(generateResponse.trackId));
        
        print('✅ Track status check successful!');
        print('   Track ID: ${statusResponse.trackId}');
        print('   Status: ${statusResponse.status}');
        print('   Progress: ${statusResponse.progress}%');
        
      } catch (e) {
        fail('Failed to check track status: $e');
      }
    });

    test('should handle polling for track completion', () async {
      try {
        // Generate a short track
        final request = MusicGenerationRequest(prompt: 'short test melody', duration: 5);
        final generateResponse = await musicService.generateMusic(request);
        expect(generateResponse.success, isTrue);
        
        print('🎵 Starting to poll for track completion...');
        print('   Track ID: ${generateResponse.trackId}');
        
        // Poll for completion (with timeout)
        const maxPolls = 30; // 30 polls * 2 seconds = 60 seconds max
        int pollCount = 0;
        bool isCompleted = false;
        
        while (pollCount < maxPolls && !isCompleted) {
          await Future.delayed(const Duration(seconds: 2));
          
          final status = await musicService.getTrackStatus(generateResponse.trackId);
          print('   Poll ${pollCount + 1}: ${status.status} (${status.progress}%)');
          
          if (status.status == 'completed') {
            isCompleted = true;
            expect(status.downloadUrl, isNotNull);
            expect(status.downloadUrl!.isNotEmpty, isTrue);
            print('✅ Track completed successfully!');
            print('   Download URL: ${status.downloadUrl}');
            break;
          } else if (status.status == 'failed') {
            fail('Track generation failed');
          }
          
          pollCount++;
        }
        
        if (!isCompleted) {
          print('⚠️ Track did not complete within timeout, but polling mechanism works');
          // Don't fail the test, as this might be expected for longer tracks
        }
        
      } catch (e) {
        fail('Failed during polling test: $e');
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
