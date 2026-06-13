import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/post_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feed_provider.dart';
import '../../widgets/common/neo_card.dart';
import '../../widgets/feed/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final profile = ref.watch(profileProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(feedProvider.notifier).load(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    AppDimensions.paddingL,
                    AppDimensions.paddingL,
                    AppDimensions.paddingS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your network',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/network'),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: const Icon(Icons.people_alt_outlined,
                              color: AppColors.textPrimary, size: 22),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                ),
              ),
              // Composer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    AppDimensions.paddingS,
                    AppDimensions.paddingL,
                    AppDimensions.paddingM,
                  ),
                  child: NeoCard(
                    onTap: () => _openComposer(context, ref),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GradientAvatar(name: profile?.fullName, size: 42),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Share an update or a win...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 20),
                      ],
                    ),
                  ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ),
              ),
              feedAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(child: _FeedEmpty());
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingL,
                      0,
                      AppDimensions.paddingL,
                      AppDimensions.paddingXL,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            onLike: () =>
                                ref.read(feedProvider.notifier).toggleLike(post.id),
                            onComment: () =>
                                _openComments(context, ref, post),
                          )
                              .animate(delay: (index * 60).ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.08, end: 0);
                        },
                        childCount: posts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Could not load the feed. Make sure the posts table is set up in Supabase.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => ref.read(feedProvider.notifier).load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openComposer(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ComposerSheet(),
    );
  }

  void _openComments(BuildContext context, WidgetRef ref, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(post: post),
    );
  }
}

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.feed_outlined, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to share something with your network.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ComposerSheet extends ConsumerStatefulWidget {
  const _ComposerSheet();

  @override
  ConsumerState<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends ConsumerState<_ComposerSheet> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  bool _posting = false;
  Uint8List? _imageBytes;
  String _imageExt = 'jpg';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      setState(() {
        _imageBytes = bytes;
        _imageExt = (ext == 'jpeg') ? 'jpg' : ext;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the image picker.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _imageBytes == null) return;
    setState(() => _posting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      String? imageUrl;
      if (_imageBytes != null) {
        final userId = ref.read(currentUserProvider)?.id;
        if (userId != null) {
          imageUrl = await ref.read(feedServiceProvider).uploadPostImage(
                userId,
                _imageBytes!,
                extension: _imageExt,
              );
        }
      }
      await ref.read(feedProvider.notifier).createPost(text, imageUrl: imageUrl);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Posted to your network 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _posting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not publish. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GradientAvatar(name: profile?.fullName, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    profile?.fullName ?? 'You',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'What do you want to talk about?',
              ),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                child: Stack(
                  children: [
                    Image.memory(
                      _imageBytes!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageBytes = null),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _imageBytes == null ? 'Add photo' : 'Change photo',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Post',
              icon: Icons.send_rounded,
              isLoading: _posting,
              onTap: _post,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final PostModel post;
  const _CommentsSheet({required this.post});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    setState(() => _sending = true);
    final profile = ref.read(profileProvider).value;
    try {
      await ref.read(feedServiceProvider).addComment(
            postId: widget.post.id,
            userId: userId,
            profile: profile,
            content: text,
          );
      _controller.clear();
      ref.invalidate(commentsProvider(widget.post.id));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: commentsAsync.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        'No comments yet. Start the conversation!',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientAvatar(name: c.authorName, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.content,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Failed to load comments'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
