import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final int maxTags;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onChanged,
    this.maxTags = 3,
  });

  // 기본 제공 태그 (대폭 확장)
  static const List<String> availableTags = [
    // 일/학업
    '직장', '학교', '공부', '시험', '과제', '회의', '발표', '야근', '면접', '프로젝트', '수업', '알바',
    // 관계
    '가족', '친구', '연인', '혼자', '동료', '선후배', '모임', '데이트', '통화',
    // 스포츠
    '축구', '농구', '야구', '배드민턴', '테니스', '골프', '수영', '달리기', '등산', '헬스', '요가',
    '필라테스', '자전거', '볼링', '탁구', '스키', '서핑', '클라이밍',
    // 활동/취미
    '운동', '취미', '여행', '식사', '산책', '독서', '게임', '영화', '음악감상', '요리',
    '카페', '그림', '사진', '글쓰기', '공연', '전시', '노래방', '드라이브', '낚시', '캠핑',
    // 생활
    '집', '이동 중', '약속', '쇼핑', '청소', '출퇴근', '병원', '미용실', '은행',
    // 상태/기타
    '날씨', '건강', '수면', '돈', '미래걱정', '회상', '음주', '다이어트', '명상',
  ];

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _query => _searchController.text.trim();

  List<String> get _filteredTags {
    final q = _query.toLowerCase();
    return TagSelector.availableTags
        .where((tag) =>
            !widget.selectedTags.contains(tag) &&
            (q.isEmpty || tag.toLowerCase().contains(q)))
        .toList();
  }

  // 커스텀 태그 추가 가능 여부
  bool get _canAddCustom {
    final q = _query;
    if (q.isEmpty || q.length > 10) return false;
    if (widget.selectedTags.contains(q)) return false;
    // 이미 목록에 정확히 있으면 커스텀 아님
    if (TagSelector.availableTags.contains(q)) return false;
    return true;
  }

  void _selectTag(String tag) {
    if (widget.selectedTags.length >= widget.maxTags) return;
    final updated = List<String>.from(widget.selectedTags)..add(tag);
    widget.onChanged(updated);
    _searchController.clear();
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  void _removeTag(String tag) {
    final updated = List<String>.from(widget.selectedTags)..remove(tag);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Row(
          children: [
            Text(
              '상황 태그',
              style: AppTextStyles.headline2.copyWith(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.selectedTags.length}/${widget.maxTags}',
              style: TextStyle(
                fontSize: 13,
                color: widget.selectedTags.length >= widget.maxTags
                    ? AppColors.warning
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '선택사항 · 직접 입력도 가능해요',
          style: AppTextStyles.subtitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 12),

        // 선택된 태그 칩들
        if (widget.selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // 검색 입력
        if (widget.selectedTags.length < widget.maxTags)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showSuggestions
                    ? AppColors.accent
                    : AppColors.primary.withAlpha(80),
                width: _showSuggestions ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) {
                // 엔터 치면 커스텀 태그 추가
                final tag = value.trim();
                if (tag.isNotEmpty &&
                    tag.length <= 10 &&
                    !widget.selectedTags.contains(tag)) {
                  _selectTag(tag);
                }
              },
              decoration: InputDecoration(
                hintText: '태그 검색 또는 직접 입력...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withAlpha(150),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

        // 검색 결과 + 커스텀 입력 옵션
        if (_showSuggestions && widget.selectedTags.length < widget.maxTags) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withAlpha(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                // 커스텀 태그 추가 옵션
                if (_canAddCustom)
                  InkWell(
                    onTap: () => _selectTag(_query),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '"$_query" 추가',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 기본 태그 목록
                ..._filteredTags.take(15).map((tag) {
                  return InkWell(
                    onTap: () => _selectTag(tag),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
