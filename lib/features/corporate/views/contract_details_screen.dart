import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/multipart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../routes/route_helper.dart';
import '../controllers/corporate_controller.dart';
import '../domain/models/company_model.dart';

class ContractDetailsScreen extends StatefulWidget {
  const ContractDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  final CorporateController controller = Get.find<CorporateController>();
  late CompanyModel company;

  @override
  void initState() {
    super.initState();
    company = Get.arguments;
    // Load fresh details from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVendorDetails(company.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Contract Details',
        subtitle: company.name,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadVendorDetails(company.id),
        color: AppColors.primaryColor,
        child: Obx(() {
          if (controller.isDetailsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final vendor = controller.selectedVendor.value ?? company;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContractInfo(vendor),
                const SizedBox(height: 24),
                _buildSectionHeader('Assigned Vehicles', () async {
                  if (controller.assignedVehicles.length >= vendor.quantity) {
                    CustomSnackbar.showInfo('Limit reached: You can only assign ${vendor.quantity} vehicles.');
                    return;
                  }
                  final result = await Get.toNamed(RouteHelper.getAssignVehicleToContractRoute(), arguments: vendor.id);
                  if (result == true) {
                    controller.loadVendorDetails(vendor.id);
                  }
                }, isLimitReached: controller.assignedVehicles.length >= vendor.quantity),
                _buildAssignedVehicles(),
                const SizedBox(height: 24),
                _buildSectionHeader('Assigned Driver', () async {
                  if (controller.assignedDrivers.length >= vendor.quantity) {
                    CustomSnackbar.showInfo('Limit reached: You can only assign ${vendor.quantity} drivers.');
                    return;
                  }
                  final result = await Get.toNamed(RouteHelper.getAssignDriverToContractRoute(), arguments: vendor.id);
                  if (result == true) {
                    controller.loadVendorDetails(vendor.id);
                  }
                }, isLimitReached: controller.assignedDrivers.length >= vendor.quantity),
                _buildAssignedDriver(),
                const SizedBox(height: 24),
                _buildSectionHeader('Billing History', () => _showAddBillModal(context)),
                _buildBillingHistory(),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAddBillModal(BuildContext context) {
    final invoiceController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    
    XFile? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Add New Bill', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
                      IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    label: 'Invoice Number',
                    hint: 'e.g. INV-2024-025',
                    icon: Iconsax.document_text,
                    controller: invoiceController,
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    label: 'Billing Amount',
                    hint: '0.00',
                    icon: Iconsax.card,
                    keyboardType: TextInputType.number,
                    controller: amountController,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: AppInputField(
                        label: 'Billing Date',
                        hint: 'YYYY-MM-DD',
                        icon: Iconsax.calendar_1,
                        controller: dateController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText('Upload Bill Image', style: AppTextStyle.body, fontWeight: FontWeight.bold),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setModalState(() {
                          selectedFile = image;
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
                      ),
                      child: selectedFile != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb 
                              ? Image.network(selectedFile!.path, fit: BoxFit.cover)
                              : Image.file(File(selectedFile!.path), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.image, color: AppColors.textColorSecondary),
                              const SizedBox(height: 4),
                              AppText('JPG, PNG supported', style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => AppButton(
                    text: 'Create Invoice',
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      if (invoiceController.text.isEmpty || amountController.text.isEmpty || dateController.text.isEmpty) {
                        CustomSnackbar.showError('Please fill all fields');
                        return;
                      }

                      Map<String, String> body = {
                        'invoice_number': invoiceController.text,
                        'amount': amountController.text,
                        'billing_date': dateController.text,
                        'status': 'pending',
                      };

                      List<MultipartBody> files = [];
                      if (selectedFile != null) {
                        files.add(MultipartBody('file', selectedFile));
                      }

                      bool success = await controller.addVendorBill(company.id, body, files);
                      if (success) {
                        Get.back();
                      }
                    },
                  )),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildContractInfo(CompanyModel vendor) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(vendor.phone ?? 'No Contract No.', style: AppTextStyle.subheading, color: AppColors.primaryColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: vendor.isActive ? AppColors.successColor.withOpacity(0.1) : AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(vendor.isActive ? 'Active' : 'Inactive', style: AppTextStyle.caption, color: vendor.isActive ? AppColors.successColor : AppColors.errorColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Vendor', vendor.name),
          _buildInfoRow('Contract Person', vendor.contactPerson ?? 'N/A'),
          _buildInfoRow(
            'Period',
            '${formatDate(vendor.startDate)} to ${formatDate(vendor.endDate)}',
          ),
          _buildInfoRow('Duty Type', vendor.dutyType ?? 'N/A'),
          _buildInfoRow('Vehicle Type', vendor.vehicleTypeName ?? 'N/A'),
          _buildInfoRow('Quantity', vendor.quantity.toString()),
          _buildInfoRow('Monthly Amount', '₹ ${vendor.monthlyAmount.toStringAsFixed(2)}', isAmount: true),
        ],
      ),
    );
  }


  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: AppTextStyle.body, color: AppColors.textColorSecondary),
          AppText(
            value,
            style: isAmount ? AppTextStyle.subheading : AppTextStyle.body,
            color: isAmount ? AppColors.primaryColor : AppColors.textColorPrimary,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd, {bool isLimitReached = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(title, style: AppTextStyle.subheading),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLimitReached ? AppColors.slate200 : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLimitReached ? Icons.block_rounded : Iconsax.add, 
                    size: 16, 
                    color: isLimitReached ? AppColors.textColorSecondary : AppColors.primaryColor
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    isLimitReached ? 'Limit Reached' : 'Add', 
                    style: AppTextStyle.caption, 
                    color: isLimitReached ? AppColors.textColorSecondary : AppColors.primaryColor, 
                    fontWeight: FontWeight.bold
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedVehicles() {
    return Obx(() {
      final vendor = controller.selectedVendor.value ?? company;
      if (controller.assignedVehicles.isEmpty) {
        return const AppCard(
          padding: EdgeInsets.all(20),
          child: Center(child: AppText('No vehicles assigned', style: AppTextStyle.caption)),
        );
      }
      return AppCard(
        child: Column(
          children: controller.assignedVehicles.asMap().entries.map((entry) {
            final int idx = entry.key;
            final vehicle = entry.value;
            return Column(
              children: [
                _buildVehicleItem(
                  vehicle['registration_number'] ?? 'N/A',
                  vehicle,
                  vehicle['id'].toString(),
                  vendor.id,
                  isLast: idx == controller.assignedVehicles.length - 1,
                ),
                if (idx < controller.assignedVehicles.length - 1) const Divider(height: 1),
              ],
            );
          }).toList(),
        ),
      );
    });
  }


  Widget _buildAssignedDriver() {
    return Obx(() {
      final vendor = controller.selectedVendor.value ?? company;
      if (controller.assignedDrivers.isEmpty) {
        return const AppCard(
          padding: EdgeInsets.all(20),
          child: Center(
            child: AppText(
              'No drivers assigned',
              style: AppTextStyle.caption,
            ),
          ),
        );
      }

      return AppCard(
        child: Column(
          children: controller.assignedDrivers.asMap().entries.map((entry) {
            final idx = entry.key;
            final driver = entry.value;

            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text(
                    driver['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        driver['phone'] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        driver['address'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _showRemoveDriverDialog(vendor.id, driver['id'].toString(), driver['name'] ?? 'Unknown'),
                  ),
                ),
                if (idx < controller.assignedDrivers.length - 1)
                  const Divider(height: .5, color: Colors.grey),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  void _showRemoveDriverDialog(String vId, String driverId, String driverName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText('Remove Driver', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
        content: AppText('Are you sure you want to remove driver $driverName from this vendor?', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeDriver(vId, driverId);
            },
            child: const AppText('Remove', color: AppColors.errorColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(String vehicleNo, Map<String, dynamic> vehicle, String vehicleId, String vId, {bool isLast = false}) {
    final String seating = vehicle['seating_capacity']?.toString() ?? 'N/A';
    final String year = vehicle['model_year']?.toString() ?? 'N/A';
    final String price = vehicle['per_km_price']?.toString() ?? '0.00';
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 2 : 2, top: 2, left: 8, right: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.bus, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(vehicleNo, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText(
                  '$seating Seater • $year • ₹$price/km',
                  style: AppTextStyle.caption,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.errorColor),
            onPressed: () => _showRemoveVehicleDialog(vId, vehicleId, vehicleNo),
          ),
        ],
      ),
    );
  }

  void _showRemoveVehicleDialog(String vId, String vehicleId, String vehicleNo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText('Remove Vehicle', style: AppTextStyle.subheading, fontWeight: FontWeight.bold),
        content: AppText('Are you sure you want to remove vehicle $vehicleNo from this vendor?', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: AppColors.textColorSecondary),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeVehicle(vId, vehicleId);
            },
            child: const AppText('Remove', color: AppColors.errorColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistory() {
    return Obx(() {
      if (controller.billingHistory.isEmpty) {
        return const AppCard(
          padding: EdgeInsets.all(16),
          child: Center(child: AppText('No billing history', style: AppTextStyle.caption)),
        );
      }
      return AppCard(
        child: Column(
          children: controller.billingHistory.asMap().entries.map((entry) {
            final int idx = entry.key;
            final inv = entry.value;
            return Column(
              children: [
                _buildInvoiceItem(
                  inv['invoice_number'] ?? 'N/A',
                  inv['amount']?.toString() ?? '0.00',
                  inv['status'] ?? '',
                  inv['billing_date'] ?? 'N/A',
                  filePath: inv['file_path'],
                //  filePath: "${AppConstants.imageBaseUrl}${inv['file_path'] ?? ''}",
                ),
                if (idx < controller.billingHistory.length - 1) const Divider(height: 1),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildInvoiceItem(String invNo, String amount, String status, String date, {String? filePath}) {
    bool isPaid = status.toLowerCase() == 'paid';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap:
            filePath != null && filePath.isNotEmpty
              ? () => _showImageDialog(filePath)
              : null,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Iconsax.document_text, color: isPaid ? AppColors.successColor : AppColors.warningColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(invNo, style: AppTextStyle.body, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                AppText(date.split('T').first, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText('₹$amount', style: AppTextStyle.body, fontWeight: FontWeight.bold),
              const SizedBox(height: 4),
              AppText(
                status.toUpperCase(),
                style: AppTextStyle.caption,
                color: isPaid ? AppColors.successColor : AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Iconsax.document_download, size: 20, color: AppColors.primaryColor),
            onPressed: () {
              if (filePath != null && filePath.isNotEmpty) {
                _showImageDialog(filePath);
              } else {
                Get.snackbar('Download', 'No file available for this invoice',
                  snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String filePath) {
    // Construct full URL if relative
    String imageUrl = filePath.startsWith('http') 
      ? filePath 
      : 'https://beige-stingray-620454.hostingersite.com/storage/$filePath';

    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const AppText('Image Preview', color: Colors.white, fontSize: 16),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: AppText('Failed to load image', style: AppTextStyle.body, color: Colors.white),
            ),
          ),
        ),
      ),
    ));
  }
}
