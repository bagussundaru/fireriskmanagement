import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'assessment_screen.dart';

class FactoryInfoScreen extends StatefulWidget {
  const FactoryInfoScreen({super.key});

  @override
  State<FactoryInfoScreen> createState() => _FactoryInfoScreenState();
}

class _FactoryInfoScreenState extends State<FactoryInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _factoryNameController = TextEditingController();
  final _assessorController = TextEditingController();
  final _gmDirectorController = TextEditingController();
  
  String _factoryType = 'Manufacturing';
  final List<String> _factoryTypeOptions = [
    'Manufacturing',
    'Residential',
  ];

  String _workerCount = '< 100 workers';

  final List<String> _workerCountOptions = [
    '< 100 workers',
    '100-500 workers',
    '500-2000 workers',
    '> 2000 workers',
  ];

  @override
  void dispose() {
    _factoryNameController.dispose();
    _assessorController.dispose();
    _gmDirectorController.dispose();
    super.dispose();
  }

  void _startAssessment() {
    if (_formKey.currentState!.validate()) {
      final factoryInfo = FactoryInfo(
        factoryName: _factoryNameController.text,
        factoryType: _factoryType,
        workerCount: _workerCount,
        assessorName: _assessorController.text,
        gmDirector: _gmDirectorController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentScreen(factoryInfo: factoryInfo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Factory Information'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const GlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.factory,
                      color: AppTheme.goldPrimary,
                      size: 40,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Factory Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Fill in the information below to start assessment',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Factory Name
              TextFormField(
                controller: _factoryNameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Factory Name *',
                  prefixIcon: Icon(Icons.business, color: AppTheme.goldPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter factory name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Factory Type
              DropdownButtonFormField<String>(
                value: _factoryType,
                dropdownColor: AppTheme.surfaceDark,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Facility Type *',
                  prefixIcon: Icon(Icons.category, color: AppTheme.goldPrimary),
                ),
                items: _factoryTypeOptions.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _factoryType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Worker Count
              DropdownButtonFormField<String>(
                value: _workerCount,
                dropdownColor: AppTheme.surfaceDark,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Worker Count *',
                  prefixIcon: Icon(Icons.people, color: AppTheme.goldPrimary),
                ),
                items: _workerCountOptions.map((count) {
                  return DropdownMenuItem(
                    value: count,
                    child: Text(count),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _workerCount = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Assessor Name
              TextFormField(
                controller: _assessorController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Assessor Name *',
                  prefixIcon: Icon(Icons.person, color: AppTheme.goldPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter assessor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // GM/Director
              TextFormField(
                controller: _gmDirectorController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'GM/Director Name *',
                  prefixIcon: Icon(Icons.admin_panel_settings, color: AppTheme.goldPrimary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter GM/Director name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Start Button
              ElevatedButton.icon(
                onPressed: _startAssessment,
                icon: const Icon(Icons.play_arrow),
                label: const Text('START ASSESSMENT'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
