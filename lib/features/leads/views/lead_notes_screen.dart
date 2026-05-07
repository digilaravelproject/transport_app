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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Lead Notes',
        subtitle: lead.customerName,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Add Note Section
          AppCard(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInputField(
                      hint: 'Add a new note...',
                      maxLines: 3,
                      controller: noteController,
                      errorText: noteError.value,
                      onChanged: (value) {
                        if (noteError.value != null) noteError.value = null;
                      },
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Add Note',
                  height: 40,
                  onPressed: () async {
                    final text = noteController.text.trim();
                    if (text.isEmpty) {
                      noteError.value = 'Please enter a note';
                      return;
                    }
                    if (lead.id == null) return;
                    
                    noteError.value = null;
                    final success = await controller.addLeadNote(lead.id!.toString(), text);
                    if (success) {
                      noteController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          // Notes Timeline
          Expanded(
            child: Obx(() {
              if (controller.isNotesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final notes = controller.leadNotes;
              if (notes.isEmpty) {
                return const Center(child: AppText('No notes yet.', style: AppTextStyle.body));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _NoteItem(note: note, isLast: index == notes.length - 1);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final LeadNote note;
  final bool isLast;

  const _NoteItem({required this.note, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.slate200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Note Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(note.userName, style: AppTextStyle.label, color: AppColors.primaryColor),
                        AppText(
                          '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')} • ${note.createdAt.day}/${note.createdAt.month}',
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(note.note, style: AppTextStyle.body),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
