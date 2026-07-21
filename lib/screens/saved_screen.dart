import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import 'assessment_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Assessment> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    final drafts = await LocalStorageService.getDrafts();
    setState(() {
      _drafts = drafts.where((d) => !d.isCompleted).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteDraft(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete Draft', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to delete this assessment draft?', 
          style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.riskHigh)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.deleteDraft(id);
      _loadDrafts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Saved Drafts'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary))
          : _drafts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_document,
                        size: 80,
                        color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved drafts',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDrafts,
                  color: AppTheme.goldPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _drafts.length,
                    itemBuilder: (context, index) {
                      final draft = _drafts[index];
                      // Calculate progress
                      final totalAnswers = draft.answers.length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            draft.factoryInfo.factoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Last modified: ${DateFormat('dd/MM/yyyy HH:mm').format(draft.createdAt)}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.assignment_turned_in, size: 16, color: AppTheme.goldPrimary),
                                  const SizedBox(width: 4),
                                  Text('$totalAnswers Questions Answered', style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.riskHigh),
                            onPressed: () => _deleteDraft(draft.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssessmentScreen(
                                  factoryInfo: draft.factoryInfo,
                                  draftId: draft.id,
                                ),
                              ),
                            ).then((_) => _loadDrafts());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
