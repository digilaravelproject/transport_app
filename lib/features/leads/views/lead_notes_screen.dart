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

class LeadNotesScreen extends GetView<LeadController> {
  const LeadNotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LeadModel lead = Get.arguments ?? controller.leads.first;
    final noteController = TextEditingController();

    // Mock notes
    final notes = [
      LeadNote(id: '1', leadId: lead.id!, note: 'Customer called regarding discount. Offered 5% off.', userName: 'Admin', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      LeadNote(id: '2', leadId: lead.id!, note: 'Sent quotation via WhatsApp.', userName: 'Firoz', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ].obs;

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
              children: [
                AppInputField(
                  hint: 'Add a new note...',
                  maxLines: 3,
                  controller: noteController,
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Add Note',
                  height: 40,
                  onPressed: () {
                    if (noteController.text.isNotEmpty) {
                      notes.insert(0, LeadNote(
                        id: DateTime.now().toString(),
                        leadId: lead.id!,
                        note: noteController.text,
                        userName: 'Firoz',
                        createdAt: DateTime.now(),
                      ));
                      noteController.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          // Notes Timeline
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteItem(note: note, isLast: index == notes.length - 1);
              },
            )),
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
                          '${note.createdAt.hour}:${note.createdAt.minute} • ${note.createdAt.day}/${note.createdAt.month}', 
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
