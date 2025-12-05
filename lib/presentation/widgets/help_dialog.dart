import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  static const String helpContent = '''
# GitHub Documentation Workflow Guide

## Overview

This guide covers the complete workflow for managing documentation using two complementary tools:

- **Rome Doc Viewer** - A specialized markdown editor for viewing, editing, and annotating documentation files
- **GitHub Desktop** - Version control software for managing document changes and synchronization

**Core Workflow**: Use GitHub Desktop to synchronize the repository, Rome Doc Viewer to create and annotate content, then GitHub Desktop again to save and share your changes.

---

## Part A: Initial Setup

### 1. Install GitHub Desktop

* Download from [desktop.github.com](https://desktop.github.com)
* Sign in with your GitHub account
* Navigate to File → Clone Repository
* Select your repository and choose a local folder location
* This creates a local working copy of all documentation on your computer

### 2. Configure Rome Doc Viewer

* Launch the Rome Doc Viewer application
* Click "Select Documentation Folder"
* Choose the local repository folder created in step 1
* The file tree will populate in the left sidebar

---

## Part B: Working with Rome Doc Viewer

### Purpose

Rome Doc Viewer is your primary interface for **content operations**: viewing, editing, and annotating markdown documentation. All content work happens here.

### Navigation and Interface

**File Tree (Left Sidebar)**
* Expand/collapse folders by clicking folder names
* Click any `.md` file to view its rendered content
* Supports `.mermaid` diagram files

**Header Controls**
* **Folder icon** - Switch documentation folder
* **Refresh icon** - Reload file tree after external changes
* **Text format icon** - Adjust rendering preferences (fonts, code styling)
* **Paintbrush icon** - Change display theme (Seez, Light, Dark)

### Editing Content

Rome Doc Viewer renders markdown for reading but allows direct editing of the underlying files. Changes are saved to the local repository folder and will be detected by GitHub Desktop for version control.

### Annotation System

Annotations provide a structured method for adding commentary, questions, and notes without modifying the primary document content.

**Creating Annotations**

Two methods are available:

1. **Text selection method**: Highlight text → Right-click → "Add Annotation"
2. **Manual method**: Click the floating "+" button (bottom right corner)

Required fields:
* **Anchor Text** - The text snippet this annotation references (auto-filled with text selection method)
* **Note** - Your annotation content
* **Color** - Visual categorization (yellow, red, blue, green, orange, purple)
* **Tags** - Optional organizational labels

**Viewing and Managing Annotations**

* **Left gutter** - Colored bookmark icons indicate annotation locations
* **Badge counter** (top right) - Shows total annotation count
* Click gutter icons to view individual annotations
* Click badge counter to view all annotations
* Edit or delete via buttons in the annotation detail view
* Collapse/expand gutter using chevron at top

**Annotation Storage**

Annotations are embedded in a special section at the end of each markdown file, making them portable and version-controlled alongside the content.

**Recommended Color Conventions**

* **Red** - Questions requiring resolution or identified issues
* **Orange** - Critical information or warnings
* **Yellow** - General notes and observations
* **Blue** - External references or citations
* **Green** - Approved decisions or confirmations
* **Purple** - Action items or tasks

---

## Part C: Version Control with GitHub Desktop

### Purpose

GitHub Desktop handles **version control operations**: synchronizing changes, tracking revisions, and coordinating with collaborators. Use this tool before and after working in Rome Doc Viewer.

### Standard Workflow Sequence

**1. Pull Latest Changes (Before Editing)**

* Open GitHub Desktop
* Click **Fetch origin** to check for updates
* If changes exist, click **Pull origin**
* This ensures you're working with the most recent version

**2. Create/Edit Content in Rome Doc Viewer**

Work in Rome Doc Viewer as needed (covered in Part B).

**3. Commit Changes**

* Return to GitHub Desktop
* Review the list of changed files in the left panel
* Write a descriptive commit message in the summary field
  * Examples: "Updated business requirements analysis", "Added annotations to technical specification"
* Click **Commit to main**

**4. Push Changes**

* Click **Push origin** to upload your changes to GitHub
* Changes are now available to all collaborators

### Understanding Git Operations

**Pull**: Downloads the latest version from GitHub to your local repository. Always perform this operation before beginning work to avoid conflicts.

**Commit**: Creates a checkpoint of your current changes in the local repository. This operation is local only and does not affect the shared repository.

**Push**: Uploads committed changes from your local repository to GitHub, making them available to collaborators.

---

## Part D: Best Practices and Troubleshooting

### Workflow Best Practices

**Version Control Discipline**
* Always pull before beginning work
* Commit changes in logical units with clear messages
* Push commits promptly after creation
* Coordinate with collaborators when making substantial changes

**File Organization**
* Maintain consistent naming conventions: lowercase, hyphens for spaces (e.g., `business-analysis.md`)
* Use folder structure to organize related documents
* Avoid renaming files without coordination - this breaks references

**Commit Message Standards**
* Use descriptive summaries that explain the nature of changes
* Format suggestion: `[Category] Brief description`
  * Examples: `[Requirements] Added capability 3 specifications`, `[Architecture] Updated system diagram`

### Common Scenarios and Solutions

| Scenario | Cause | Resolution |
|----------|-------|----------|
| **"Push rejected"** | Remote repository has changes not present locally | Pull origin, resolve any conflicts, then push again |
| **Conflict markers in file (`<<<<` `====` `>>>>`)** | Concurrent edits to the same file section | Open file, select correct version for conflicted sections, remove markers, commit resolution |
| **Changes not appearing in GitHub Desktop** | Files not saved in Rome Doc Viewer | Ensure files are saved, click refresh in GitHub Desktop |
| **Lost uncommitted work** | Application crash or accidental revert | Check file system - unsaved editor work may be recoverable from temporary files |

### Conflict Resolution

When two people edit the same file section, Git cannot automatically merge the changes. You'll see conflict markers:

```
<<<<<<< HEAD
Your version of the text
=======
Collaborator's version of the text
>>>>>>> branch-name
```

Resolution process:
1. Open the file in a text editor
2. Review both versions
3. Decide which content to keep (or merge both)
4. Delete the conflict markers (`<<<<`, `====`, `>>>>`)
5. Save the file
6. Commit the resolution in GitHub Desktop

### Preventing Conflicts

* Coordinate editing schedules for frequently-modified files
* Work in different files when possible
* Pull frequently to stay synchronized
* Communicate about large-scale changes

### Data Recovery

GitHub's version control ensures all committed work is preserved. If needed:

* **Recover deleted files**: View file history on GitHub.com → Restore previous version
* **Revert changes**: Right-click file in GitHub Desktop → Discard changes (for uncommitted work) or revert commit (for committed work)
* **Review history**: Use the History tab in GitHub Desktop to see all past commits

---

## Additional Resources

* **Markdown Syntax**: [markdownguide.org](https://www.markdownguide.org)
* **GitHub Desktop Documentation**: [docs.github.com/desktop](https://docs.github.com/desktop)
* **Git Concepts**: [git-scm.com/doc](https://git-scm.com/doc)

---

*Last Updated: December 2025*
''';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 28,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Florence Documentation Help',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Markdown(
                data: helpContent,
                selectable: true,
                onTapLink: (text, url, title) {
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium,
                  h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  a: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                  ),
                  code: TextStyle(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tableBorder: TableBorder.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  tableHead: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  blockquotePadding: const EdgeInsets.all(8),
                  blockquoteDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
