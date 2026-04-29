import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/upload_box.dart';
import '../domain/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';
import '../../../core/utils/file_converter.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({Key? key}) : super(key: key);

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  late VehicleModel? vehicle;
  bool isEdit = false;

  final List<String> vehicleTypes = ['AC Sleeper', 'Non-AC Sleeper', 'AC Seater', 'Non-AC Seater', 'Luxury Volvo'];
  String? selectedType;
  
  PlatformFile? rcFile;
  PlatformFile? insuranceFile;
  PlatformFile? permitFile;

  // Controllers
  final _regNoController = TextEditingController();
  final _capacityController = TextEditingController();
  final _yearController = TextEditingController();
  final _perKmPriceController = TextEditingController();
  final _acPriceController = TextEditingController();
  
  final _rcNoController = TextEditingController();
  final _rcExpiryController = TextEditingController();
  final _insNoController = TextEditingController();
  final _insExpiryController = TextEditingController();
  final _permitNoController = TextEditingController();
  final _permitExpiryController = TextEditingController();

  DateTime? rcExpiry;
  DateTime? insExpiry;
  DateTime? permitExpiry;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments;
    isEdit = vehicle != null;
    
    if (isEdit) {
      _regNoController.text = vehicle!.vehicleNumber;
      selectedType = vehicleTypes.contains(vehicle!.type) ? vehicle!.type : vehicle!.type;
      _capacityController.text = vehicle!.capacity.toString();
      _yearController.text = vehicle!.year;
      _perKmPriceController.text = vehicle!.perKmPrice.toString();
      _acPriceController.text = vehicle!.acPricePerKm.toString();
      
      _rcNoController.text = vehicle!.rcNumber ?? '';
      if (vehicle!.rcExpiry != null) {
        rcExpiry = vehicle!.rcExpiry;
        _rcExpiryController.text = DateFormat('dd-MM-yyyy').format(rcExpiry!);
      }
      
      _insNoController.text = vehicle!.insuranceNumber ?? '';
      if (vehicle!.insuranceExpiry != null) {
        insExpiry = vehicle!.insuranceExpiry;
        _insExpiryController.text = DateFormat('dd-MM-yyyy').format(insExpiry!);
      }
      
      _permitNoController.text = vehicle!.permitNumber ?? '';
      if (vehicle!.permitExpiry != null) {
        permitExpiry = vehicle!.permitExpiry;
        _permitExpiryController.text = DateFormat('dd-MM-yyyy').format(permitExpiry!);
      }
    }
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    if (result != null) {
      setState(() {
        if (type == 'RC') rcFile = result.files.first;
        if (type == 'Insurance') insuranceFile = result.files.first;
        if (type == 'Permit') permitFile = result.files.first;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (type == 'RC') {
          rcExpiry = picked;
          _rcExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
        } else if (type == 'Insurance') {
          insExpiry = picked;
          _insExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
        } else if (type == 'Permit') {
          permitExpiry = picked;
          _permitExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_regNoController.text.isEmpty || selectedType == null) {
      Get.snackbar('Error', 'Please fill required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final Map<String, dynamic> data = {
      'registration_number': _regNoController.text,
      'type': selectedType,
      'seating_capacity': int.tryParse(_capacityController.text) ?? 0,
      'model_year': int.tryParse(_yearController.text) ?? DateTime.now().year,
      'per_km_price': double.tryParse(_perKmPriceController.text) ?? 0.0,
      'ac_price_per_km': double.tryParse(_acPriceController.text) ?? 0.0,
      'rc_number': _rcNoController.text,
      'rc_expiry': rcExpiry != null ? DateFormat('yyyy-MM-dd').format(rcExpiry!) : null,
      'insurance_number': _insNoController.text,
      'insurance_expiry': insExpiry != null ? DateFormat('yyyy-MM-dd').format(insExpiry!) : null,
      'permit_number': _permitNoController.text,
      'permit_expiry': permitExpiry != null ? DateFormat('yyyy-MM-dd').format(permitExpiry!) : null,
    };

    // Convert files to base64
    if (rcFile?.path != null) {
      data['registration_certificate'] = await FileConverter.toBase64(rcFile!.path!);
    }
    if (insuranceFile?.path != null) {
      data['insurance_certificate'] = await FileConverter.toBase64(insuranceFile!.path!);
    }
    if (permitFile?.path != null) {
      data['permit_certificate'] = await FileConverter.toBase64(permitFile!.path!);
    }

    bool success;
    if (isEdit) {
      success = await controller.updateVehicle(vehicle!.id, data);
    } else {
      success = await controller.addVehicle(data);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _capacityController.dispose();
    _yearController.dispose();
    _perKmPriceController.dispose();
    _acPriceController.dispose();
    _rcNoController.dispose();
    _rcExpiryController.dispose();
    _insNoController.dispose();
    _insExpiryController.dispose();
    _permitNoController.dispose();
    _permitExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(title: isEdit ? 'Update Vehicle' : 'Add New Vehicle'),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Vehicle Information'),
                AppCard(
                  child: Column(
                    children: [
                      _buildTextField('Vehicle Number', 'e.g. DL 01 AB 1234', controller: _regNoController),
                      const SizedBox(height: 16),
                      _buildDropdown('Vehicle Type', vehicleTypes, selectedType, (val) => setState(() => selectedType = val)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Seating Capacity', 'e.g. 36', controller: _capacityController, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField('Model Year', 'e.g. 2022', controller: _yearController, keyboardType: TextInputType.number)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Pricing Information'),
                AppCard(
                  child: Column(
                    children: [
                      _buildTextField('Per KM Price', 'e.g. 18.00', controller: _perKmPriceController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField('AC Price per KM (Extra)', 'e.g. 2.00', controller: _acPriceController, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Required Documents'),
                _buildDocumentSection(
                  'Registration Certificate (RC)',
                  rcFile,
                  _rcNoController,
                  _rcExpiryController,
                  () => _pickDocument('RC'),
                  'RC Number',
                  'RC',
                  remoteUrl: vehicle?.rcFileUrl,
                ),
                _buildDocumentSection(
                  'Insurance Policy',
                  insuranceFile,
                  _insNoController,
                  _insExpiryController,
                  () => _pickDocument('Insurance'),
                  'Policy Number',
                  'Insurance',
                  remoteUrl: vehicle?.insuranceFileUrl,
                ),
                _buildDocumentSection(
                  'Permit Details',
                  permitFile,
                  _permitNoController,
                  _permitExpiryController,
                  () => _pickDocument('Permit'),
                  'Permit Number',
                  'Permit',
                  remoteUrl: vehicle?.permitFileUrl,
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: isEdit ? 'Update Vehicle' : 'Save Vehicle',
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 12),
                AppButton.outline(
                  text: 'Cancel',
                  onPressed: () => Get.back(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
    );
  }

  Widget _buildDocumentSection(
    String label,
    PlatformFile? file,
    TextEditingController noController,
    TextEditingController expiryController,
    VoidCallback onUpload,
    String noLabel,
    String type,
    {String? remoteUrl}
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.document_text, size: 18, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              AppText(label, style: AppTextStyle.subheading, fontSize: 14, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 16),
          UploadBox(
            label: 'Photo Copy',
            isUploaded: file != null || remoteUrl != null,
            localPath: file?.path,
            remoteUrl: file == null ? remoteUrl : null,
            fileName: file?.name,
            onTap: onUpload,
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: noLabel,
            hint: 'Enter Number',
            controller: noController,
            icon: Iconsax.hashtag,
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: 'Expiry Date',
            hint: 'DD-MM-YYYY',
            controller: expiryController,
            readOnly: true,
            icon: Iconsax.calendar_1,
            onTap: () => _selectDate(context, type),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: AppText(
        title,
        style: AppTextStyle.subheading,
        fontSize: 14,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? initialVal, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: AppTextStyle.body, fontSize: 13, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(initialVal) ? initialVal : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: AppText('Select $label', style: AppTextStyle.body, color: AppColors.textColorHint),
          items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, style: AppTextStyle.body))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
