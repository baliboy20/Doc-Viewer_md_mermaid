import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/git_credentials.dart';

/// Dialog for cloning a Git repository
class CloneRepositoryDialog extends StatefulWidget {
  const CloneRepositoryDialog({super.key});

  @override
  State<CloneRepositoryDialog> createState() => _CloneRepositoryDialogState();
}

class _CloneRepositoryDialogState extends State<CloneRepositoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _pathController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _sshUsernameController = TextEditingController();
  final _publicKeyPathController = TextEditingController();
  final _privateKeyPathController = TextEditingController();
  final _passphraseController = TextEditingController();

  CredentialType _credentialType = CredentialType.none;
  bool _obscurePassword = true;
  bool _obscureToken = true;
  bool _obscurePassphrase = true;

  @override
  void dispose() {
    _urlController.dispose();
    _pathController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    _sshUsernameController.dispose();
    _publicKeyPathController.dispose();
    _privateKeyPathController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _pathController.text = result;
      });
    }
  }

  Future<void> _pickFile(TextEditingController controller, String dialogTitle) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        controller.text = result.files.first.path!;
      });
    }
  }

  GitCredentials? _buildCredentials() {
    switch (_credentialType) {
      case CredentialType.none:
        return null;
      case CredentialType.usernamePassword:
        return UsernamePasswordCredentials(
          username: _usernameController.text,
          password: _passwordController.text,
        );
      case CredentialType.token:
        return PersonalAccessTokenCredentials(
          token: _tokenController.text,
          username: _usernameController.text.isEmpty
              ? null
              : _usernameController.text,
        );
      case CredentialType.ssh:
        return SshKeyCredentials(
          username: _sshUsernameController.text,
          publicKeyPath: _publicKeyPathController.text,
          privateKeyPath: _privateKeyPathController.text,
          passphrase: _passphraseController.text.isEmpty
              ? null
              : _passphraseController.text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Clone Repository',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // Repository URL
                Text(
                  'Repository URL:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'https://github.com/user/repo.git',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a repository URL';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Local Path
                Text(
                  'Local Path:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pathController,
                        decoration: const InputDecoration(
                          hintText: '/path/to/clone/directory',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a local path';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(CupertinoIcons.folder),
                      onPressed: _pickDirectory,
                      tooltip: 'Browse',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Credentials Section
                Text(
                  'Authentication:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Credential Type Selector
                SegmentedButton<CredentialType>(
                  segments: const [
                    ButtonSegment(
                      value: CredentialType.none,
                      label: Text('None'),
                    ),
                    ButtonSegment(
                      value: CredentialType.usernamePassword,
                      label: Text('Password'),
                    ),
                    ButtonSegment(
                      value: CredentialType.token,
                      label: Text('Token'),
                    ),
                    ButtonSegment(
                      value: CredentialType.ssh,
                      label: Text('SSH'),
                    ),
                  ],
                  selected: {_credentialType},
                  onSelectionChanged: (Set<CredentialType> selection) {
                    setState(() {
                      _credentialType = selection.first;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Credential Fields
                if (_credentialType == CredentialType.usernamePassword) ...[
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username:',
                    hint: 'Enter username',
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'Password:',
                    hint: 'Enter password',
                    obscure: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ] else if (_credentialType == CredentialType.token) ...[
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username (optional):',
                    hint: 'git (for GitHub)',
                    required: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _tokenController,
                    label: 'Personal Access Token:',
                    hint: 'ghp_xxxxxxxxxxxx',
                    obscure: _obscureToken,
                    onToggle: () {
                      setState(() {
                        _obscureToken = !_obscureToken;
                      });
                    },
                  ),
                ] else if (_credentialType == CredentialType.ssh) ...[
                  _buildTextField(
                    controller: _sshUsernameController,
                    label: 'Username:',
                    hint: 'git',
                  ),
                  const SizedBox(height: 12),
                  _buildFilePickerField(
                    controller: _publicKeyPathController,
                    label: 'Public Key:',
                    hint: '~/.ssh/id_rsa.pub',
                    dialogTitle: 'Select Public Key',
                  ),
                  const SizedBox(height: 12),
                  _buildFilePickerField(
                    controller: _privateKeyPathController,
                    label: 'Private Key:',
                    hint: '~/.ssh/id_rsa',
                    dialogTitle: 'Select Private Key',
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _passphraseController,
                    label: 'Passphrase (optional):',
                    hint: 'Enter passphrase if key is encrypted',
                    obscure: _obscurePassphrase,
                    required: false,
                    onToggle: () {
                      setState(() {
                        _obscurePassphrase = !_obscurePassphrase;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final result = CloneRepositoryResult(
                            url: _urlController.text,
                            localPath: _pathController.text,
                            credentials: _buildCredentials(),
                          );
                          Navigator.pop(context, result);
                        }
                      },
                      child: const Text('Clone'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildFilePickerField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String dialogTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(CupertinoIcons.doc),
              onPressed: () => _pickFile(controller, dialogTitle),
              tooltip: 'Browse',
            ),
          ],
        ),
      ],
    );
  }
}

/// Type of credential for authentication
enum CredentialType {
  none,
  usernamePassword,
  token,
  ssh,
}

/// Result from the clone repository dialog
class CloneRepositoryResult {
  final String url;
  final String localPath;
  final GitCredentials? credentials;

  CloneRepositoryResult({
    required this.url,
    required this.localPath,
    this.credentials,
  });
}
