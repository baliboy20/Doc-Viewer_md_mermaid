import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/core/theme/seez_theme.dart';

/// Dialog for committing changes to Git repository
class CommitChangesDialog extends StatefulWidget {
  final List<String> modifiedFiles;
  final List<String> addedFiles;
  final List<String> deletedFiles;

  const CommitChangesDialog({
    super.key,
    required this.modifiedFiles,
    required this.addedFiles,
    required this.deletedFiles,
  });

  @override
  State<CommitChangesDialog> createState() => _CommitChangesDialogState();
}

class _CommitChangesDialogState extends State<CommitChangesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final Set<String> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    // Pre-select all modified and added files
    _selectedFiles.addAll(widget.modifiedFiles);
    _selectedFiles.addAll(widget.addedFiles);
    _selectedFiles.addAll(widget.deletedFiles);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFiles = [
      ...widget.modifiedFiles,
      ...widget.addedFiles,
      ...widget.deletedFiles,
    ];

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_seal,
                    color: SeezTheme.primaryBrown,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Commit Changes',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SeezTheme.darkBrownText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Commit message field
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Commit Message',
                  hintText: 'Enter a descriptive commit message...',
                  helperText: 'Required: Describe what changes you made and why',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: SeezTheme.parchmentBackground,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: SeezTheme.darkBrownText,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Commit message cannot be empty';
                  }
                  if (value.trim().length < 10) {
                    return 'Commit message must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Files to commit
              Text(
                'Files to Commit (${_selectedFiles.length} selected)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SeezTheme.darkBrownText,
                ),
              ),

              const SizedBox(height: 12),

              // File list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: SeezTheme.mediumBrownBorder),
                    borderRadius: BorderRadius.circular(8),
                    color: SeezTheme.parchmentBackground,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allFiles.length,
                    itemBuilder: (context, index) {
                      final file = allFiles[index];
                      final isSelected = _selectedFiles.contains(file);
                      final isModified = widget.modifiedFiles.contains(file);
                      final isAdded = widget.addedFiles.contains(file);

                      Color statusColor;
                      String statusLabel;
                      if (isModified) {
                        statusColor = Colors.orange;
                        statusLabel = 'M';
                      } else if (isAdded) {
                        statusColor = Colors.green;
                        statusLabel = 'A';
                      } else {
                        statusColor = Colors.red;
                        statusLabel = 'D';
                      }

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedFiles.add(file);
                            } else {
                              _selectedFiles.remove(file);
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: SeezTheme.darkBrownText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: SeezTheme.subtitleBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedFiles.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one file to commit'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop({
                          'message': _messageController.text.trim(),
                          'files': _selectedFiles.toList(),
                        });
                      }
                    },
                    icon: const Icon(CupertinoIcons.checkmark_circle, size: 18),
                    label: Text(
                      'Commit',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SeezTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
