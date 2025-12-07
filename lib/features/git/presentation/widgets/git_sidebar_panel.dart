import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_bloc.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_state.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_event.dart';
import 'package:doc_viewer_app/features/git/domain/entities/git_commit.dart';
import 'package:doc_viewer_app/features/git/domain/entities/git_status.dart';
import 'package:doc_viewer_app/features/git/presentation/widgets/commit_changes_dialog.dart';
import 'package:doc_viewer_app/core/theme/seez_theme.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';
import 'package:intl/intl.dart';

/// Git sidebar panel showing repository status, commits, and actions
class GitSidebarPanel extends StatelessWidget {
  final String currentTheme;

  const GitSidebarPanel({
    super.key,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitBloc, GitState>(
      builder: (context, state) {
        if (state is GitInitial) {
          return _buildNotARepo(context);
        }

        if (state is GitOperationError) {
          return _buildError(context, state.message);
        }

        if (state is RepositoryStatusLoaded) {
          return _buildRepoStatus(context, state.status);
        }

        if (state is CommitHistoryLoaded) {
          return _buildCommitHistory(context, state.commits);
        }

        return _buildLoading(context);
      },
    );
  }

  Widget _buildNotARepo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Git Repository', CupertinoIcons.arrow_branch),
          const SizedBox(height: 16),
          Text(
            'This folder is not a Git repository',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SeezTheme.subtitleBrown,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Show clone dialog
              },
              icon: const Icon(CupertinoIcons.cloud_download, size: 16),
              label: const Text('Clone Repository'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SeezTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Git Error', CupertinoIcons.exclamationmark_triangle),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SeezTheme.dangerLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SeezTheme.danger),
            ),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: SeezTheme.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildRepoStatus(BuildContext context, GitStatus status) {
    final modifiedFiles = status.modified.length;
    final addedFiles = status.added.length;
    final deletedFiles = status.deleted.length;
    final untrackedFiles = status.untracked.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Git Repository', CupertinoIcons.arrow_branch),
          const SizedBox(height: 12),

          // Current branch
          _buildInfoRow(
            'Branch',
            status.currentBranch ?? 'main',
            CupertinoIcons.arrow_branch,
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // File changes
          _buildSectionTitle('Changes', CupertinoIcons.doc_text),
          const SizedBox(height: 12),

          if (status.hasUncommittedChanges) ...[
            if (modifiedFiles > 0)
              _buildFileStatusRow('Modified', modifiedFiles, Colors.orange),
            if (addedFiles > 0)
              _buildFileStatusRow('Added', addedFiles, Colors.green),
            if (deletedFiles > 0)
              _buildFileStatusRow('Deleted', deletedFiles, Colors.red),
            if (untrackedFiles > 0)
              _buildFileStatusRow('Untracked', untrackedFiles, Colors.grey),
            const SizedBox(height: 16),
            _buildActionButtons(context, status),
          ] else
            Text(
              'No uncommitted changes',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: SeezTheme.subtitleBrown,
                fontStyle: FontStyle.italic,
              ),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Quick actions
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildCommitHistory(BuildContext context, List<GitCommit> commits) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Recent Commits', CupertinoIcons.time),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: commits.length,
              itemBuilder: (context, index) {
                final commit = commits[index];
                return _buildCommitItem(commit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitItem(GitCommit commit) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SeezTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SeezTheme.mediumBrownBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            commit.message.split('\n').first,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SeezTheme.darkBrownText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                CupertinoIcons.person,
                size: 12,
                color: SeezTheme.subtitleBrown,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  commit.author,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: SeezTheme.subtitleBrown,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(commit.timestamp),
            style: GoogleFonts.inter(
              fontSize: 10,
              color: SeezTheme.subtitleBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            commit.oid.substring(0, 7),
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: SeezTheme.subtitleBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: SeezTheme.primaryBrown,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SeezTheme.darkBrownText,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: SeezTheme.subtitleBrown,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: SeezTheme.subtitleBrown,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SeezTheme.darkBrownText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFileStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SeezTheme.darkBrownText,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GitStatus status) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCommitDialog(context, status),
            icon: const Icon(CupertinoIcons.checkmark_circle, size: 16),
            label: const Text('Commit Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeezTheme.primaryBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDiscardDialog(context),
            icon: const Icon(CupertinoIcons.xmark_circle, size: 16),
            label: const Text('Discard Changes'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  void _showCommitDialog(BuildContext context, GitStatus status) async {
    AppLogger.info('Opening commit dialog from sidebar', tag: 'GitSidebarPanel');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CommitChangesDialog(
        modifiedFiles: status.modified,
        addedFiles: status.added,
        deletedFiles: status.deleted,
      ),
    );

    if (result != null && context.mounted) {
      final message = result['message'] as String;
      final files = result['files'] as List<String>;

      AppLogger.success(
        'Commit initiated from sidebar',
        tag: 'GitSidebarPanel',
        data: 'Files: ${files.length}, Message: $message',
      );

      context.read<GitBloc>().add(CommitChangesEvent(
        message: message,
        files: files,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Committing ${files.length} file(s)...'),
          backgroundColor: SeezTheme.primaryBrown,
        ),
      );
    }
  }

  void _showDiscardDialog(BuildContext context) async {
    AppLogger.info('Showing discard changes confirmation', tag: 'GitSidebarPanel');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes'),
        content: const Text(
          'Are you sure you want to discard all uncommitted changes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppLogger.warning('User confirmed discard changes', tag: 'GitSidebarPanel');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discard changes not yet implemented'),
          backgroundColor: Colors.orange,
        ),
      );
      // TODO: Implement git reset --hard or similar
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions', CupertinoIcons.bolt),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          context,
          'Pull',
          CupertinoIcons.cloud_download,
          () => context.read<GitBloc>().add(const PullEvent()),
        ),
        _buildQuickActionButton(
          context,
          'Push',
          CupertinoIcons.cloud_upload,
          () => context.read<GitBloc>().add(const PushEvent()),
        ),
        _buildQuickActionButton(
          context,
          'View History',
          CupertinoIcons.time,
          () => context.read<GitBloc>().add(const GetCommitHistoryEvent(limit: 10)),
        ),
        _buildQuickActionButton(
          context,
          'Refresh Status',
          CupertinoIcons.refresh,
          () => context.read<GitBloc>().add(const GetRepositoryStatusEvent()),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(label),
          ),
          style: TextButton.styleFrom(
            foregroundColor: SeezTheme.primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }
}
