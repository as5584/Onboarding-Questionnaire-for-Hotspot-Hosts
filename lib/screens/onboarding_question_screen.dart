// lib/screens/onboarding_question_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as AudioPlayers;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // ← Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  final List<int> selectedExperienceIds;
  final String hostDescription;

  const OnboardingQuestionScreen({
    Key? key,
    required this.selectedExperienceIds,
    required this.hostDescription,
  }) : super(key: key);

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  // -------------------------------------------------------------------------
  // Text
  // -------------------------------------------------------------------------
  final TextEditingController _questionCtrl = TextEditingController();
  final int _questionCharLimit = 600;

  // -------------------------------------------------------------------------
  // Audio Recording
  // -------------------------------------------------------------------------
  late final AudioRecorder _audioRecorder;
  String? _recordedAudioPath;
  bool _isRecordingAudio = false;
  Timer? _audioTimer;
  int _audioDurationSec = 0;

  // Audio Playback
  final AudioPlayers.AudioPlayer _audioPlayer = AudioPlayers.AudioPlayer();
  Duration _audioPosition = Duration.zero;
  Duration _audioTotal = Duration.zero;
  bool _isPlayingAudio = false;

  // -------------------------------------------------------------------------
  // Video Recording
  // -------------------------------------------------------------------------
  List<CameraDescription>? _cameras;
  CameraController? _cameraCtrl;
  String? _recordedVideoPath;
  bool _isRecordingVideo = false;
  Timer? _videoTimer;
  int _videoDurationSec = 0;
  bool _cameraReady = false;

  // Video Playback
  VideoPlayerController? _videoCtrl;
  bool _videoInitialized = false;

  // -------------------------------------------------------------------------
  // Waveform
  // -------------------------------------------------------------------------
  RecorderController? _waveformController; // ← Nullable
  bool _waveformInitialized = false;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();

    // Only initialize waveform on mobile (Android/iOS)
    if (!kIsWeb) {
      _waveformController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;
    }

    _questionCtrl.addListener(_onTextChanged);
    _initCamera();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _questionCtrl.removeListener(_onTextChanged);
    _questionCtrl.dispose();
    _audioTimer?.cancel();
    _videoTimer?.cancel();
    _waveformController?.dispose();
    _audioRecorder.dispose();
    _cameraCtrl?.dispose();
    _audioPlayer.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  // -------------------------------------------------------------------------
  // Audio Player Setup
  // -------------------------------------------------------------------------
  void _setupAudioPlayer() {
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _audioPosition = pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _audioTotal = dur);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == AudioPlayers.PlayerState.playing;
        });
      }
    });
  }

  // -------------------------------------------------------------------------
  // Camera init
  // -------------------------------------------------------------------------
  Future<void> _initCamera() async {
    if (kIsWeb) {
      _showSnackBar('Camera not supported on web');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras?.isNotEmpty ?? false) {
        _cameraCtrl = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        await _cameraCtrl!.initialize();
        if (mounted) setState(() => _cameraReady = true);
      }
    } catch (e) {
      _showSnackBar('Camera error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PERMISSIONS
  // -------------------------------------------------------------------------
  Future<bool> _requestPermission(Permission permission) async {
    if (kIsWeb) return false;

    var status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(permission);
      return false;
    }

    _showSnackBar('Permission denied: ${permission.toString()}');
    return false;
  }

  void _showPermissionDeniedDialog(Permission permission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'This app needs ${permission == Permission.microphone ? 'microphone' : 'camera'} access. '
              'Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // FILE HELPERS
  // -------------------------------------------------------------------------
  Future<void> _deleteFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
        debugPrint('Deleted file: $path');
      } catch (e) {
        debugPrint('Failed to delete file: $e');
      }
    }
  }

  // -------------------------------------------------------------------------
  // AUDIO RECORDING
  // -------------------------------------------------------------------------
  Future<void> _startAudio() async {
    if (kIsWeb) {
      _showSnackBar('Audio recording not supported on web');
      return;
    }

    if (!await _requestPermission(Permission.microphone)) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    try {
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      // Start waveform *before* recording (RecorderController handles file)
      if (_waveformController != null) {
        await _waveformController!.start(path: path);
        if (mounted) setState(() => _waveformInitialized = true);
      }
    } catch (e) {
      _showSnackBar('Failed to start audio recording');
      debugPrint('Start audio error: $e');
      return;
    }

    setState(() {
      _isRecordingAudio = true;
      _recordedAudioPath = path;
      _audioDurationSec = 0;
    });
    _startAudioTimer();
  }

  Future<void> _stopAudio() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      debugPrint('Stop audio recorder error: $e');
    }

    if (_waveformController != null) {
      try {
        await _waveformController!.stop();
      } catch (e) {
        debugPrint('Stop waveform controller error: $e');
      }
    }

    _audioTimer?.cancel();
    if (mounted) {
      setState(() {
        _isRecordingAudio = false;
        _waveformInitialized = false;
      });
    }
  }

  Future<void> _cancelAudio() async {
    await _stopAudio();
    await _deleteFile(_recordedAudioPath);
    await _audioPlayer.stop();
    setState(() {
      _isRecordingAudio = false;
      _recordedAudioPath = null;
      _audioDurationSec = 0;
      _audioPosition = Duration.zero;
      _audioTotal = Duration.zero;
      _waveformInitialized = false;
    });
  }

  Future<void> _deleteAudio() async {
    await _audioPlayer.stop();
    await _deleteFile(_recordedAudioPath);
    setState(() {
      _recordedAudioPath = null;
      _audioDurationSec = 0;
      _audioPosition = Duration.zero;
      _audioTotal = Duration.zero;
    });
  }

  void _startAudioTimer() {
    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _audioDurationSec++);
      }
    });
  }

  Future<void> _toggleAudioPlayback() async {
    if (_recordedAudioPath == null) return;

    if (_isPlayingAudio) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AudioPlayers.DeviceFileSource(_recordedAudioPath!));
    }
  }

  // -------------------------------------------------------------------------
  // VIDEO RECORDING
  // -------------------------------------------------------------------------
  Future<void> _startVideo() async {
    if (kIsWeb) {
      _showSnackBar('Video recording not supported on web');
      return;
    }

    if (!await _requestPermission(Permission.camera)) return;
    if (_cameraCtrl == null || !_cameraReady) {
      _showSnackBar('Camera not ready');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _cameraCtrl!.startVideoRecording();
    } catch (e) {
      _showSnackBar('Failed to start video recording');
      debugPrint('Start video error: $e');
      return;
    }

    setState(() {
      _isRecordingVideo = true;
      _recordedVideoPath = path;
      _videoDurationSec = 0;
    });
    _startVideoTimer();
  }

  Future<void> _stopVideo() async {
    if (_cameraCtrl == null || !_cameraCtrl!.value.isRecordingVideo) {
      if (mounted) {
        setState(() => _isRecordingVideo = false);
      }
      return;
    }

    XFile? file;
    try {
      file = await _cameraCtrl!.stopVideoRecording();
    } catch (e) {
      debugPrint('Stop video error: $e');
    }

    _videoTimer?.cancel();

    if (file != null && await File(file.path).exists()) {
      if (mounted) {
        setState(() {
          _recordedVideoPath = file?.path;
          _isRecordingVideo = false;
        });
        _initVideoPlayer(file.path);
      }
    } else {
      if (mounted) {
        setState(() => _isRecordingVideo = false);
      }
    }
  }

  void _initVideoPlayer(String path) {
    _videoCtrl?.dispose();
    _videoCtrl = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoInitialized = true);
        }
      }).catchError((e) {
        debugPrint('Video init error: $e');
      });
  }

  Future<void> _cancelVideo() async {
    if (_cameraCtrl?.value.isRecordingVideo == true) {
      try {
        await _cameraCtrl!.stopVideoRecording();
      } catch (e) {
        debugPrint('Cancel video stop error: $e');
      }
    }

    _videoTimer?.cancel();
    await _deleteFile(_recordedVideoPath);
    _videoCtrl?.dispose();
    if (mounted) {
      setState(() {
        _isRecordingVideo = false;
        _recordedVideoPath = null;
        _videoDurationSec = 0;
        _videoInitialized = false;
      });
    }
  }

  Future<void> _deleteVideo() async {
    _videoCtrl?.pause();
    _videoCtrl?.dispose();
    await _deleteFile(_recordedVideoPath);
    if (mounted) {
      setState(() {
        _recordedVideoPath = null;
        _videoDurationSec = 0;
        _videoInitialized = false;
      });
    }
  }

  void _startVideoTimer() {
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _videoDurationSec++);
      }
    });
  }

  // -------------------------------------------------------------------------
  // UI HELPERS
  // -------------------------------------------------------------------------
  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fmtDuration(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {bool active = false, Color? activeColor}) {
    return IconButton(
      icon: Icon(
        icon,
        color: active ? (activeColor ?? Colors.red) : Colors.white70,
      ),
      onPressed: onTap,
      iconSize: 30,
      padding: const EdgeInsets.all(15),
      splashRadius: 25,
    );
  }

  Widget _deleteBtn(VoidCallback onTap) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
      onPressed: onTap,
      padding: const EdgeInsets.all(10),
      splashRadius: 20,
    );
  }

  // -------------------------------------------------------------------------
  // AUDIO PLAYBACK UI
  // -------------------------------------------------------------------------
  Widget _audioPlaybackUI() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlayingAudio ? Icons.pause : Icons.play_arrow,
            color: Colors.red,
          ),
          onPressed: _toggleAudioPlayback,
        ),
        Expanded(
          child: Slider(
            value: _audioPosition.inSeconds.toDouble()
                .clamp(0, _audioTotal.inSeconds.toDouble()),
            min: 0,
            max: _audioTotal.inSeconds.toDouble() > 0
                ? _audioTotal.inSeconds.toDouble()
                : 1,
            onChanged: (val) {
              _audioPlayer.seek(Duration(seconds: val.toInt()));
            },
            activeColor: Colors.red, // Active color for slider
            inactiveColor: Colors.white70, // Inactive color for slider
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding
          child: Text(
            '${_fmtDuration(_audioPosition)} / ${_fmtDuration(_audioTotal)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // VIDEO PLAYBACK UI
  // -------------------------------------------------------------------------
  Widget _videoPlaybackUI() {
    if (!_videoInitialized || _videoCtrl == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    return Column(
      children: [
        // Video Player with Aspect Ratio
        AspectRatio(
          aspectRatio: _videoCtrl!.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for video player
            child: VideoPlayer(_videoCtrl!),
          ),
        ),
        // Video Progress Bar
        VideoProgressIndicator(
          _videoCtrl!,
          allowScrubbing: true,
          colors: VideoProgressColors(playedColor: Colors.red, bufferedColor: Colors.white70),
        ),
        // Playback Controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding around controls
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _videoCtrl!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.red, // Red icon for play/pause
                  size: 40, // Larger icon size
                ),
                onPressed: () {
                  setState(() {
                    _videoCtrl!.value.isPlaying
                        ? _videoCtrl!.pause()
                        : _videoCtrl!.play();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // RECORDED TILE
  // -------------------------------------------------------------------------
  Widget _recordedTile({
    required IconData icon,
    required String label,
    required String duration,
    required Widget playbackWidget,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical margin
      padding: const EdgeInsets.all(10.0), // Reduced padding
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E).withOpacity(0.8), // Consistent dark background
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.red, size: 24),
                  const SizedBox(width: 8.0),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0, // Slightly larger font for label
                    ),
                  ),
                ],
              ),
              Text(
                duration,
                style: const TextStyle(color: Colors.white70, fontSize: 12.0), // Smaller font for duration
              ),
              _deleteBtn(onDelete),
            ],
          ),
          const SizedBox(height: 10.0), // Spacing between header and playback
          playbackWidget,
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // AUDIO RECORDING UI
  // -------------------------------------------------------------------------
  Widget _audioRecordingUI() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Recording Audio...',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                _fmt(_audioDurationSec),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Row(
                children: [
                  _iconBtn(Icons.cancel, _cancelAudio),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.stop_circle_outlined, _stopAudio,
                      active: true, activeColor: Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!kIsWeb && _waveformInitialized && _waveformController != null)
            AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width - 80, 60),
              recorderController: _waveformController!,
              waveStyle: const WaveStyle(
                waveColor: Colors.redAccent,
                showDurationLabel: false,
                spacing: 6,
                showBottom: false,
                extendWaveform: true,
                showMiddleLine: false,
                waveThickness: 3,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
              enableGesture: false,
            )
          else
            const SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'Waveform not available on web',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // VIDEO RECORDING UI
  // -------------------------------------------------------------------------
  Widget _videoRecordingUI() {
    if (!_cameraReady) {
      return const Center(
        child: Text(
          'Initializing Camera...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        if (_isRecordingVideo)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _cameraCtrl!.value.aspectRatio,
              child: CameraPreview(_cameraCtrl!),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.videocam, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Recording Video...',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                _fmt(_videoDurationSec),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Row(
                children: [
                  _iconBtn(Icons.cancel, _cancelVideo),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.stop, _stopVideo,
                      active: true, activeColor: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // SUBMIT
  // -------------------------------------------------------------------------
  void _onNextPressed() {
    debugPrint('=== ONBOARDING SUBMISSION ===');
    debugPrint('Question: ${_questionCtrl.text}');
    debugPrint('Audio: $_recordedAudioPath');
    debugPrint('Video: $_recordedVideoPath');
    debugPrint('Experiences: ${widget.selectedExperienceIds}');
    debugPrint('Description: ${widget.hostDescription}');
    _showSnackBar('Submitted! Check console.');
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _questionCtrl.text.isNotEmpty;
    final hasAudio = _recordedAudioPath != null && _audioDurationSec > 0;
    final hasVideo = _recordedVideoPath != null && _videoDurationSec > 0;
    final isRecording = _isRecordingAudio || _isRecordingVideo;
    final nextEnabled = hasText || hasAudio || hasVideo;
    final showMicBtn = !kIsWeb && !hasAudio && !_isRecordingVideo;
    final showCamBtn = !kIsWeb && !hasVideo && !_isRecordingAudio;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Progress indicator using _WavyLinePainter for animation
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.pink.shade300, Colors.purple.shade400, Colors.deepPurple.shade500],
              stops: [0.0, 0.5, 1.0],
              tileMode: TileMode.clamp,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: CustomPaint(
              size: Size(150, 40), // Adjust size as needed
              painter: _WavyLinePainter(
                progress: 0.6, // Set progress for this screen (e.g., 60%)
                waveColor: Colors.purple.shade400, // Use a color that fits the theme
                backgroundColor: Colors.grey.shade800.withOpacity(0.5), // Background color for the line
              ),
            ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why do you want to host with us?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your intent and what motivates you to create experiences.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _questionCtrl,
                maxLength: _questionCharLimit,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Start typing here',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1E1E1E).withOpacity(0.8), // Darker background
                  contentPadding: const EdgeInsets.all(12),
                  // Removed counterText here as it's handled below for better control
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_questionCtrl.text.length}/$_questionCharLimit',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Recorded Assets (when *not* recording)
            if (!isRecording) ...[
              if (hasAudio)
                _recordedTile(
                  icon: Icons.play_circle_filled,
                  label: 'Audio Recorded',
                  duration: _fmt(_audioDurationSec),
                  playbackWidget: _audioPlaybackUI(),
                  onDelete: _deleteAudio,
                ),
              if (hasVideo)
                _recordedTile(
                  icon: Icons.play_circle_filled,
                  label: 'Video Recorded',
                  duration: _fmt(_videoDurationSec),
                  playbackWidget: _videoPlaybackUI(),
                  onDelete: _deleteVideo,
                ),
            ],

            // Live Recorder UI (when recording)
            if (isRecording)
              _isRecordingAudio ? _audioRecordingUI() : _videoRecordingUI(),

            // Bottom Controls
            const SizedBox(height: 10),
            // Custom Bottom Control Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E).withOpacity(0.8), // Dark background for the bar
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Mic and Camera buttons
                  Row(
                    children: [
                      // Microphone Button
                      if (showMicBtn)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _iconBtn(
                            Icons.mic,
                            () async {
                              if (_isRecordingAudio) {
                                await _stopAudio();
                              } else if (hasAudio) {
                                await _deleteAudio();
                                await _startAudio();
                              } else {
                                await _startAudio();
                              }
                            },
                            active: _isRecordingAudio,
                            activeColor: Colors.red,
                          ),
                        ),
                      if (showMicBtn) const SizedBox(width: 12),
                      // Camera Button
                      if (showCamBtn)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _iconBtn(
                            Icons.videocam,
                            () async {
                              if (_isRecordingVideo) {
                                await _stopVideo();
                              } else if (hasVideo) {
                                await _deleteVideo();
                                await _startVideo();
                              } else {
                                await _startVideo();
                              }
                            },
                            active: _isRecordingVideo,
                            activeColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  // Right side: Next Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: nextEnabled ? 120 : 50, // Adjust width based on enabled state
                    child: ElevatedButton(
                      onPressed: nextEnabled ? _onNextPressed : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.transparent, // Use background color for gradient
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black.withOpacity(0.6),
                        elevation: nextEnabled ? 5 : 0,
                      ),
                      child: nextEnabled
                          ? ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [Colors.pink.shade300, Colors.purple.shade400, Colors.deepPurple.shade500],
                                  stops: const [0.0, 0.5, 1.0],
                                  tileMode: TileMode.clamp,
                                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            )
                          : const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for the animated wavy line progress indicator
class _WavyLinePainter extends CustomPainter {
  final double progress;
  final Color waveColor;
  final Color backgroundColor;

  _WavyLinePainter({
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    final path = Path();
    path.moveTo(0, size.height / 2);

    final double waveHeight = size.height / 2;
    final double waveFrequency = 3;
    final double waveLength = size.width / waveFrequency;

    // Draw the wavy line based on progress
    for (double i = 0; i < size.width * progress; i += waveLength / 10) {
      path.quadraticBezierTo(
        i + waveLength / 4,
        size.height / 2 - waveHeight,
        i + waveLength / 2,
        size.height / 2,
      );
      path.quadraticBezierTo(
        i + 3 * waveLength / 4,
        size.height / 2 + waveHeight,
        i + waveLength,
        size.height / 2,
      );
    }
    
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _WavyLinePainter && oldDelegate.progress != progress;
  }
}

extension on RecorderController {
  Future<void> start({required String path}) async {}
}
