class PostModel {
  final String id;
  final String? authorId;
  final String authorName;
  final String? authorTitle;
  final String? authorAvatarUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool likedByMe;

  PostModel({
    required this.id,
    this.authorId,
    required this.authorName,
    this.authorTitle,
    this.authorAvatarUrl,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.likedByMe = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, {bool likedByMe = false}) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String?,
      authorName: json['author_name'] as String? ?? 'Member',
      authorTitle: json['author_title'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      likedByMe: likedByMe,
    );
  }

  PostModel copyWith({int? likesCount, int? commentsCount, bool? likedByMe}) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorTitle: authorTitle,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      imageUrl: imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}

class CommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorName: json['author_name'] as String? ?? 'Member',
      authorAvatarUrl: json['author_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// A discoverable member for the Network tab.
class ConnectionPerson {
  final String id;
  final String name;
  final String? title;
  final String? avatarUrl;
  final String status; // none | pending | connected

  ConnectionPerson({
    required this.id,
    required this.name,
    this.title,
    this.avatarUrl,
    this.status = 'none',
  });

  ConnectionPerson copyWith({String? status}) => ConnectionPerson(
        id: id,
        name: name,
        title: title,
        avatarUrl: avatarUrl,
        status: status ?? this.status,
      );
}
