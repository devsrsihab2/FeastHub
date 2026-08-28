import 'dart:async';
import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/data/repositories/meal_repository.dart';
import 'package:first_project/model/meal.dart';
import 'package:first_project/screens/meal_details_screen.dart';
import 'package:first_project/widgets/app_image.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MealRepository _mealRepo = MealRepository();

  Timer? _debounceTimer;
  List<Meal> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _currentQuery = '';
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _currentQuery = trimmed;
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      final results = await _mealRepo.search(trimmed);
      if (mounted && _currentQuery == trimmed) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Search meals, ingredients...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentQuery.isEmpty) {
      return _EmptySearchPrompt();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 64, color: AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                'No results for "$_currentQuery"',
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different meal name or ingredient.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
            style: AppTextStyles.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (ctx, i) => _SearchResultTile(
              meal: _searchResults[i],
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Find your next meal', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Search by meal name, cuisine,\nor ingredients.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  const _SearchResultTile({required this.meal, required this.index});
  final Meal meal;
  final int index;

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 30), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (ctx, animation, secondary) => FadeTransition(
                opacity: animation,
                child: MealDetailsScreen(meal: meal),
              ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Hero(
                  tag: 'meal_image_${meal.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AppImage(
                      imageUrl: meal.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholderIconSize: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.star, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            meal.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.schedule_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            AppFormatters.duration(meal.duration),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.price(meal.price),
                        style: AppTextStyles.priceSmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
