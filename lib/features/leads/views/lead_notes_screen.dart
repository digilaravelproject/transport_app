import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../domain/models/lead_model.dart';
import '../controllers/lead_controller.dart';

class LeadNotesScreen extends StatefulWidget {
  const LeadNotesScreen({Key? key}) : super(key: key);

  @override
  State<LeadNotesScreen> createState() => _LeadNotesScreenState();
}

class _LeadNotesScreenState extends State<LeadNotesScreen> {
  final LeadController controller = Get.find<LeadController>();
  late final LeadModel lead;
  final TextEditingController noteController = TextEditingController();
  final RxnString noteError = RxnString();

  @override
  void initState() {
    super.initState();
    lead = Get.arguments ?? (controller.leads.isNotEmpty ? controller.leads.first : LeadModel.empty());
    if (lead.id != null) {
      controller.fetchLeadNotes(lead.id!.toString());
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _showAddNoteSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Add New Note', style: AppTextStyle.subheading, fontSize: 18),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInputField(
              hint: 'Type your note here...',
              maxLines: 4,
              controller: noteController,
              autoFocus: true,
              onChanged: (value) {
                if (noteError.value != null) noteError.value = null;
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Save Note',
              onPressed: () async {
                final text = noteController.text.trim();
                if (text.isEmpty) {
                  return;
                }
                if (lead.id == null) return;
                
                final success = await controller.addLeadNote(lead.id!.toString(), text);
                if (success) {
                  noteController.clear();
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Lead Notes',
        subtitle: lead.customerName,
        onBack: () => Navigator.of(context).pop(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteSheet(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isNotesLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = controller.leadNotes;
        if (notes.isEmpty) {
          return const Center(child: AppText('No notes yet.', style: AppTextStyle.body));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _NoteItem(note: note, isLast: index == notes.length - 1);
          },
        );
      }),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final LeadNote note;
  final bool isLast;

  const _NoteItem({required this.note, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        Column(
          children: [
            const SizedBox(height: 18), // Align dot with title
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 80, // Fixed height or dynamic via intrinsic height
                color: AppColors.slate200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Note Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        note.userName, 
                        style: AppTextStyle.label, 
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText(
                        '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')} • ${note.createdAt.day}/${note.createdAt.month}',
                        style: AppTextStyle.caption,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    note.note, 
                    style: AppTextStyle.body,
                    fontSize: 14,
                    color: AppColors.textColorPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
