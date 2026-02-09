import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';
import '../theme/app_theme.dart';

/// 항상 표시되는 미니 뮤직 플레이어
/// - 대기 상태: 음악 아이콘 + "감정을 선택하고 음악을 들어보세요"
/// - 재생 상태: 이모지 + 제목 + 일시정지/건너뛰기/정지 버튼
/// - 일시정지 상태: 이모지 + 제목 + 재생/건너뛰기/정지 버튼
class MiniMusicPlayer extends StatelessWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicService>();
    final hasMusic = music.hasActiveSession;
    final emotionColor = hasMusic
        ? (AppColors.emotionColors[music.currentEmotion] ?? AppColors.primary)
        : AppColors.primary;

    final progress = music.duration.inMilliseconds > 0
        ? (music.position.inMilliseconds / music.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: hasMusic ? Colors.white : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: hasMusic
                ? emotionColor.withAlpha(40)
                : Colors.grey.withAlpha(20),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 프로그레스 바 (음악 재생 시에만)
          if (hasMusic)
            SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: emotionColor.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(emotionColor),
              ),
            )
          else
            SizedBox(
              height: 3,
              child: Container(color: Colors.grey.withAlpha(15)),
            ),

          // 컨트롤 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: hasMusic
                ? _buildActivePlayer(music, emotionColor)
                : _buildIdlePlayer(),
          ),
        ],
      ),
    );
  }

  /// 대기 상태 — 음악 미선택
  Widget _buildIdlePlayer() {
    return Row(
      children: [
        // 음악 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: AppColors.primary.withAlpha(120),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // 안내 텍스트
        Expanded(
          child: Text(
            '감정을 선택하고 음악을 들어보세요',
            style: TextStyle(
              fontFamily: 'BareunBatang',
              fontSize: 13,
              color: AppColors.textSecondary.withAlpha(150),
            ),
          ),
        ),
      ],
    );
  }

  /// 활성 상태 — 음악 재생 중 또는 일시정지
  Widget _buildActivePlayer(MusicService music, Color emotionColor) {
    return Row(
      children: [
        // 감정 이모지 배지
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: emotionColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: emotionColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              music.currentEmotion ?? '',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 제목 + 상태
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                music.currentMusicTitle,
                style: const TextStyle(
                  fontFamily: 'BareunBatang',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  // 상태 표시점
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: music.isPlaying
                          ? AppColors.success
                          : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    music.isPlaying
                        ? '재생 중 · ${_formatDuration(music.position)}'
                        : '일시정지 · ${_formatDuration(music.position)}',
                    style: TextStyle(
                      fontFamily: 'BareunBatang',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 재생/일시정지 버튼
        _buildButton(
          icon: music.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onTap: () => music.togglePlayPause(),
          color: emotionColor,
          size: 38,
          iconSize: 24,
          filled: true,
        ),
        const SizedBox(width: 4),
        // 다음 곡
        _buildButton(
          icon: Icons.skip_next_rounded,
          onTap: () => music.skipToNext(),
          color: AppColors.textSecondary,
          size: 32,
          iconSize: 20,
        ),
        const SizedBox(width: 4),
        // 정지
        _buildButton(
          icon: Icons.stop_rounded,
          onTap: () => music.stopMusic(),
          color: AppColors.textSecondary,
          size: 32,
          iconSize: 18,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double size = 32,
    double iconSize = 20,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? color.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
