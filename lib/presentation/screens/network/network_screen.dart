import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/post_model.dart';
import '../../../providers/feed_provider.dart';
import '../../widgets/common/neo_card.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(suggestedPeopleProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Grow your network')),
      body: peopleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _NetworkError(
          onRetry: () => ref.read(suggestedPeopleProvider.notifier).load(),
        ),
        data: (people) {
          if (people.isEmpty) {
            return const _NetworkEmpty();
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(suggestedPeopleProvider.notifier).load(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'People you may know',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...people.asMap().entries.map(
                      (entry) => _PersonCard(
                        person: entry.value,
                        onConnect: () => ref
                            .read(suggestedPeopleProvider.notifier)
                            .connect(entry.value.id),
                      )
                          .animate(delay: (entry.key * 50).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final ConnectionPerson person;
  final VoidCallback onConnect;

  const _PersonCard({required this.person, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final connected = person.status == 'connected';
    final pending = person.status == 'pending';
    return NeoCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GradientAvatar(name: person.name, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (person.title != null)
                  Text(
                    person.title!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ConnectButton(
            connected: connected,
            pending: pending,
            onTap: (connected || pending) ? null : onConnect,
          ),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final bool connected;
  final bool pending;
  final VoidCallback? onTap;

  const _ConnectButton({
    required this.connected,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label = connected ? 'Connected' : (pending ? 'Pending' : 'Connect');
    final bool filled = !connected && !pending;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: filled ? null : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(100),
          boxShadow: filled ? AppShadows.glow(AppColors.primary) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              connected
                  ? Icons.check
                  : (pending ? Icons.schedule : Icons.person_add_alt_1),
              size: 15,
              color: filled ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkEmpty extends StatelessWidget {
  const _NetworkEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'No one to show yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'As more members join, they\'ll appear here for you to connect with.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkError extends StatelessWidget {
  final VoidCallback onRetry;
  const _NetworkError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Could not load people. Make sure the network tables and profile read policy are set up in Supabase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
