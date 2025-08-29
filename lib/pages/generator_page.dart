import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/music_service.dart';

/// Main page for music generation
/// Created by Sergie Code - Software Engineer & Programming Educator
class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final _promptController = TextEditingController();
  final _musicService = MusicService();
  
  double _duration = 30;
  bool _isGenerating = false;
  bool _isServerOnline = false;
  String? _error;
  TrackStatus? _currentTrack;

  @override
  void initState() {
    super.initState();
    _checkServerHealth();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _musicService.dispose();
    super.dispose();
  }

  /// Check if the backend server is accessible
  Future<void> _checkServerHealth() async {
    try {
      final isOnline = await _musicService.checkServerHealth();
      setState(() {
        _isServerOnline = isOnline;
        if (!isOnline) {
          _error = 'Cannot connect to server. Please ensure the backend is running.';
        }
      });
    } catch (e) {
      setState(() {
        _isServerOnline = false;
        _error = 'Server connection failed: $e';
      });
    }
  }

  /// Generate music with the current prompt and duration
  Future<void> _generateMusic() async {
    if (_promptController.text.trim().isEmpty || _isGenerating || !_isServerOnline) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _currentTrack = null;
    });

    try {
      final request = MusicGenerationRequest(
        prompt: _promptController.text.trim(),
        duration: _duration.round(),
      );

      final response = await _musicService.generateMusic(request);
      
      // Start polling for status updates
      _pollTrackStatus(response.trackId);
      
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = e.toString();
      });
    }
  }

  /// Poll track status until completion
  void _pollTrackStatus(String trackId) {
    _musicService.pollTrackStatus(trackId).listen(
      (status) {
        setState(() {
          _currentTrack = status;
          
          if (status.status == 'completed' || status.status == 'failed') {
            _isGenerating = false;
            if (status.status == 'failed') {
              _error = 'Music generation failed. Please try again.';
            }
          }
        });
      },
      onError: (error) {
        setState(() {
          _isGenerating = false;
          _error = error.toString();
        });
      },
    );
  }

  /// Download or open the generated track
  Future<void> _downloadTrack() async {
    if (_currentTrack?.downloadUrl != null) {
      final uri = Uri.parse(_currentTrack!.downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showAlert('Error', 'Could not open download link');
      }
    }
  }

  /// Reset the form and state
  void _reset() {
    setState(() {
      _promptController.clear();
      _duration = 30;
      _currentTrack = null;
      _error = null;
      _isGenerating = false;
    });
  }

  /// Clear current error
  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  /// Show alert dialog
  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('🎵 Music AI Generator'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildServerStatus(),
              const SizedBox(height: 24),
              _buildGenerationForm(),
              const SizedBox(height: 24),
              if (_error != null) _buildErrorDisplay(),
              if (_currentTrack != null) _buildProgressDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the header section
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Music AI Generator',
          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Created by Sergie Code',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.secondaryLabel,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'AI Tools for Musicians',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.secondaryLabel,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build server status indicator
  Widget _buildServerStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isServerOnline 
          ? CupertinoColors.systemGreen.withOpacity(0.1) 
          : CupertinoColors.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isServerOnline 
            ? CupertinoColors.systemGreen 
            : CupertinoColors.systemRed,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isServerOnline 
              ? CupertinoIcons.checkmark_circle 
              : CupertinoIcons.xmark_circle,
            color: _isServerOnline 
              ? CupertinoColors.systemGreen 
              : CupertinoColors.systemRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isServerOnline ? 'Server Online' : 'Server Offline',
              style: TextStyle(
                color: _isServerOnline 
                  ? CupertinoColors.systemGreen 
                  : CupertinoColors.systemRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!_isServerOnline)
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              onPressed: _checkServerHealth,
              child: const Icon(CupertinoIcons.refresh, size: 20),
            ),
        ],
      ),
    );
  }

  /// Build the generation form
  Widget _buildGenerationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prompt Input
        Text(
          'Music Description',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _promptController,
          placeholder: 'Describe the music you want to generate...\ne.g., "energetic rock", "relaxing piano melody"',
          maxLines: 3,
          enabled: !_isGenerating && _isServerOnline,
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
        ),
        const SizedBox(height: 24),
        
        // Duration Slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${_duration.round()} seconds',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            CupertinoSlider(
              value: _duration,
              min: 5,
              max: 300,
              divisions: 59,
              onChanged: _isGenerating ? null : (value) {
                setState(() => _duration = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5s',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '300s (5min)',
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Generate Button
        CupertinoButton.filled(
          onPressed: (!_isGenerating && 
                     _isServerOnline && 
                     _promptController.text.trim().isNotEmpty)
              ? _generateMusic
              : null,
          child: _isGenerating
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CupertinoActivityIndicator(color: CupertinoColors.white),
                    SizedBox(width: 8),
                    Text('Generating...'),
                  ],
                )
              : const Text('🎵 Generate Music'),
        ),
      ],
    );
  }

  /// Build error display
  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemRed),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle, 
            color: CupertinoColors.systemRed
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _clearError,
            child: const Icon(
              CupertinoIcons.xmark, 
              color: CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress display
  Widget _buildProgressDisplay() {
    final track = _currentTrack!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generation Progress',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Track Info
          _buildInfoRow('Track ID', track.trackId),
          _buildInfoRow('Prompt', track.prompt),
          _buildInfoRow('Duration', '${track.duration} seconds'),
          _buildInfoRow('Status', track.status.toUpperCase()),
          
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress:',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${track.progress}%',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: track.progress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: track.status == 'completed' 
                          ? CupertinoColors.systemGreen 
                          : track.status == 'failed'
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          if (track.status == 'completed' && track.downloadUrl != null)
            CupertinoButton.filled(
              onPressed: _downloadTrack,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.cloud_download, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text('Download Track'),
                ],
              ),
            ),
          
          if (track.status == 'completed' || track.status == 'failed')
            const SizedBox(height: 8),
          
          if (track.status == 'completed' || track.status == 'failed')
            CupertinoButton(
              onPressed: _reset,
              child: const Text('🔄 Generate Another'),
            ),
        ],
      ),
    );
  }

  /// Build info row for track details
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
