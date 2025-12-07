import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_bloc.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_state.dart';

/// Displays current Git repository status in the app bar
class GitStatusIndicator extends StatelessWidget {
  const GitStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitBloc, GitState>(
      builder: (context, state) {
        if (state is! RepositoryStatusLoaded) {
          return const SizedBox.shrink();
        }

        final status = state.status;
        final hasChanges = status.hasUncommittedChanges;
        final modifiedCount = status.modified.length +
                             status.added.length +
                             status.deleted.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hasChanges
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasChanges
                  ? Colors.orange.withValues(alpha: 0.5)
                  : Colors.green.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.arrow_branch,
                size: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                status.currentBranch ?? 'main',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasChanges) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$modifiedCount',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
