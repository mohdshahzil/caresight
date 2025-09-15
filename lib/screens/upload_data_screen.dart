import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';

class UploadDataScreen extends StatefulWidget {
  const UploadDataScreen({super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  bool _isUploading = false;
  String? _uploadedFileName;
  String? _uploadStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Upload Patient Data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload CSV, PDF, or JSON files containing patient data for AI analysis',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // Upload Area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Upload Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 60,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upload Title
                    Text(
                      'Select Files to Upload',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Supported Formats
                    Text(
                      'Supported formats: CSV, PDF, JSON',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Upload Button
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickFiles,
                        icon:
                            _isUploading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.upload_file),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Choose Files',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upload Status
                    if (_uploadStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _uploadStatus!.contains('success')
                                  ? AppColors.lightGreen.withOpacity(0.1)
                                  : AppColors.riskOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _uploadStatus!.contains('success')
                                    ? AppColors.lightGreen
                                    : AppColors.riskOrange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _uploadStatus!.contains('success')
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color:
                                  _uploadStatus!.contains('success')
                                      ? AppColors.lightGreen
                                      : AppColors.riskOrange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _uploadStatus!.contains('success')
                                        ? 'Upload Successful'
                                        : 'Upload Failed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _uploadStatus!.contains('success')
                                              ? AppColors.lightGreen
                                              : AppColors.riskOrange,
                                    ),
                                  ),
                                  if (_uploadedFileName != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'File: $_uploadedFileName',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // File Format Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Format Requirements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormatInfo(
                      'CSV',
                      'Patient data with columns for demographics, vitals, and lab results',
                    ),
                    _buildFormatInfo(
                      'PDF',
                      'Medical reports, discharge summaries, and clinical notes',
                    ),
                    _buildFormatInfo(
                      'JSON',
                      'Structured patient data in JSON format with standardized fields',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatInfo(String format, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = null;
      _uploadedFileName = null;
    });

    try {
      // Simulate file picking delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would use FilePicker.platform.pickFiles()
      // For this prototype, we'll simulate the file selection
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Simulate upload process
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _uploadedFileName = file.name;
          _uploadStatus =
              'File uploaded successfully! Data is being processed for AI analysis.';
          _isUploading = false;
        });
      } else {
        setState(() {
          _uploadStatus = 'No file selected';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: ${e.toString()}';
        _isUploading = false;
      });
    }
  }
}
