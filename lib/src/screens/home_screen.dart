import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_notes_app/src/providers/auth_provider.dart';
import 'package:flutter_notes_app/src/providers/notes_provider.dart';
import 'package:flutter_notes_app/src/providers/settings_provider.dart';
import 'package:flutter_notes_app/src/localization/app_localizations.dart';
import 'package:flutter_notes_app/src/models/note_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).t('logout')),
        content: Text(AppLocalizations.of(context).t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).t('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final notesProvider = context.read<NotesProvider>();
      notesProvider.clearNotes();

      // Sign out
      await authProvider.signOut();

      if (mounted) {
        widget.onLogout();
      }
    }
  }

  /// Handle add note button press.
  Future<void> _handleAddNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('please_enter_note')),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('user_not_authenticated')),
        ),
      );
      return;
    }

    final success = await notesProvider.addNote(
      content: _noteController.text.trim(),
      userId: userId,
    );

    if (mounted) {
        if (success) {
        _noteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('note_added_successfully')),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notesProvider.errorMessage ?? 'Failed to add note',
            ),
          ),
        );
      }
    }
  }

  /// Handle delete note.
  Future<void> _handleDeleteNote(String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).t('delete_note')),
        content: Text(AppLocalizations.of(context).t('delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notesProvider = context.read<NotesProvider>();
      final success = await notesProvider.deleteNote(noteId: noteId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).t('note_deleted_successfully')),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                notesProvider.errorMessage ?? 'Failed to delete note',
              ),
            ),
          );
        }
      }
    }
  }

  /// Format date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    return Scaffold(
      // allow theme to control scaffold background
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('my_notes')),
        // use theme's AppBar colors
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // User email display
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).t('Login as'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                            ),
                      ),
                      Text(
                        authProvider.userEmail ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notes list and input
          Expanded(
            child: userId == null
                ? const Center(
                    child: Text('User not authenticated'),
                  )
                : StreamBuilder<List<NoteModel>>(
                    stream: context.read<NotesProvider>().getNotesStream(
                          userId: userId,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final notes = snapshot.data ?? [];

                      return Column(
                        children: [
                          // Add note input
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _noteController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).t('add_new_note'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FloatingActionButton(
                                  onPressed: _handleAddNote,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),

                          // Notes list
                          Expanded(
                            child: notes.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.note_outlined,
                                            size: 64,
                                            color: Theme.of(context).disabledColor,
                                          ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppLocalizations.of(context).t('no_notes_yet'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context).t('add_first_note'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: notes.length,
                                    itemBuilder: (context, index) {
                                      final note = notes[index];
                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Note content
                                              Text(
                                                note.content,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),

                                              // Note metadata and delete button
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatDate(note.createdAt),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                                        ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _handleDeleteNote(
                                                          note.id,
                                                        ),
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          color: Theme.of(context).colorScheme.error,
                                                          size: 20,
                                                        ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final sp = context.watch<SettingsProvider>();
        final isDark = sp.themeMode == ThemeMode.dark;
        final isEnglish = sp.locale.languageCode == 'en';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).t('settings'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(AppLocalizations.of(context).t('dark_mode')),
                value: isDark,
                onChanged: (v) => settings.toggleDarkMode(v),
              ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).t('language')),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).t('english')),
                    selected: isEnglish,
                    onSelected: (_) => settings.setLocale(const Locale('en')),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).t('bangla')),
                    selected: !isEnglish,
                    onSelected: (_) => settings.setLocale(const Locale('bn')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
