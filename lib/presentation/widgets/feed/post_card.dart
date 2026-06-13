import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../common/neo_card.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientAvatar(name: post.authorName, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (post.authorTitle != null)
                      Text(
                        post.authorTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                post.timeAgo,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: AppColors.backgroundSurface,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  );
                },
                errorBuilder: (context, _, __) => Container(
                  height: 160,
                  alignment: Alignment.center,
                  color: AppColors.backgroundSurface,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.textMuted, size: 32),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (post.likesCount > 0 || post.commentsCount > 0) ...[
            Row(
              children: [
                if (post.likesCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryGradient),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.thumb_up,
                        size: 10, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likesCount}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
                const Spacer(),
                if (post.commentsCount > 0)
                  Text(
                    '${post.commentsCount} comments',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
            const Divider(height: 22),
          ],
          Row(
            children: [
              _ActionButton(
                icon: post.likedByMe
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                label: 'Like',
                active: post.likedByMe,
                onTap: onLike,
              ),
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comment',
                onTap: onComment,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: onComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
