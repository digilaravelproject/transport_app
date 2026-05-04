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
import '../../../core/services/network/multipart.dart';

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

  // Error States
  String? regNoError;
  String? typeError;
  String? capacityError;
  String? yearError;
  String? priceError;
  String? rcNoError;
  String? rcExpiryError;
  String? insNoError;
  String? insExpiryError;
  String? permitNoError;
  String? permitExpiryError;
  String? rcFileError;
  String? insuranceFileError;
  String? permitFileError;

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments;
    isEdit = vehicle != null;
    
    if (isEdit) {
      _fillForm(vehicle!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVehicleDetails();
      });
    }
  }

  void _fillForm(VehicleModel v) {
    _regNoController.text = v.vehicleNumber;
    selectedType = vehicleTypes.contains(v.type) ? v.type : v.type;
    _capacityController.text = v.capacity.toString();
    _yearController.text = v.year;
    _perKmPriceController.text = v.perKmPrice.toString();
    _acPriceController.text = v.acPricePerKm.toString();
    
    _rcNoController.text = v.rcNumber ?? '';
    if (v.rcExpiry != null) {
      rcExpiry = v.rcExpiry;
      _rcExpiryController.text = DateFormat('dd-MM-yyyy').format(rcExpiry!);
    }
    
    _insNoController.text = v.insuranceNumber ?? '';
    if (v.insuranceExpiry != null) {
      insExpiry = v.insuranceExpiry;
      _insExpiryController.text = DateFormat('dd-MM-yyyy').format(insExpiry!);
    }
    
    _permitNoController.text = v.permitNumber ?? '';
    if (v.permitExpiry != null) {
      permitExpiry = v.permitExpiry;
      _permitExpiryController.text = DateFormat('dd-MM-yyyy').format(permitExpiry!);
    }
  }

  Future<void> _loadVehicleDetails() async {
    final updatedVehicle = await controller.fetchVehicleDetails(vehicle!.id);
    if (updatedVehicle != null) {
      setState(() {
        vehicle = updatedVehicle;
        _fillForm(vehicle!);
      });
    }
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    if (result != null) {
      setState(() {
        if (type == 'RC') {
          rcFile = result.files.first;
          rcFileError = null;
        }
        if (type == 'Insurance') {
          insuranceFile = result.files.first;
          insuranceFileError = null;
        }
        if (type == 'Permit') {
          permitFile = result.files.first;
          permitFileError = null;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime now = DateTime.now();
    DateTime initial = now;
    
    // Set initial date based on existing selection if valid
    if (type == 'RC' && rcExpiry != null && rcExpiry!.isAfter(now)) initial = rcExpiry!;
    if (type == 'Insurance' && insExpiry != null && insExpiry!.isAfter(now)) initial = insExpiry!;
    if (type == 'Permit' && permitExpiry != null && permitExpiry!.isAfter(now)) initial = permitExpiry!;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (type == 'RC') {
          rcExpiry = picked;
          _rcExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
          rcExpiryError = null;
        } else if (type == 'Insurance') {
          insExpiry = picked;
          _insExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
          insExpiryError = null;
        } else if (type == 'Permit') {
          permitExpiry = picked;
          _permitExpiryController.text = DateFormat('dd-MM-yyyy').format(picked);
          permitExpiryError = null;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      regNoError = null;
      typeError = null;
      capacityError = null;
      yearError = null;
      priceError = null;
      rcNoError = null;
      rcExpiryError = null;
      insNoError = null;
      insExpiryError = null;
      permitNoError = null;
      permitExpiryError = null;
      rcFileError = null;
      insuranceFileError = null;
      permitFileError = null;
    });

    bool hasError = false;

    if (_regNoController.text.isEmpty) {
      setState(() => regNoError = 'Vehicle number is required');
      hasError = true;
    }
    if (selectedType == null) {
      setState(() => typeError = 'Please select vehicle type');
      hasError = true;
    }
    if (_capacityController.text.isEmpty) {
      setState(() => capacityError = 'Capacity is required');
      hasError = true;
    }
    if (_yearController.text.isEmpty) {
      setState(() => yearError = 'Model year is required');
      hasError = true;
    }
    if (_perKmPriceController.text.isEmpty) {
      setState(() => priceError = 'Price is required');
      hasError = true;
    }
    if (_rcNoController.text.isEmpty) {
      setState(() => rcNoError = 'RC number is required');
      hasError = true;
    }
    if (rcExpiry == null) {
      setState(() => rcExpiryError = 'RC expiry is required');
      hasError = true;
    }
    if (_insNoController.text.isEmpty) {
      setState(() => insNoError = 'Insurance number is required');
      hasError = true;
    }
    if (insExpiry == null) {
      setState(() => insExpiryError = 'Insurance expiry is required');
      hasError = true;
    }
    if (_permitNoController.text.isEmpty) {
      setState(() => permitNoError = 'Permit number is required');
      hasError = true;
    }
    if (permitExpiry == null) {
      setState(() => permitExpiryError = 'Permit expiry is required');
      hasError = true;
    }

    // Document File Validation
    if (rcFile == null && vehicle?.rcFileUrl == null) {
      setState(() => rcFileError = 'RC document is required');
      hasError = true;
    }
    if (insuranceFile == null && vehicle?.insuranceFileUrl == null) {
      setState(() => insuranceFileError = 'Insurance policy document is required');
      hasError = true;
    }
    if (permitFile == null && vehicle?.permitFileUrl == null) {
      setState(() => permitFileError = 'Permit document is required');
      hasError = true;
    }

    if (hasError) return;

    final Map<String, String> data = {
      'registration_number': _regNoController.text,
      'type': selectedType ?? '',
      'seating_capacity': _capacityController.text,
      'model_year': _yearController.text,
      'per_km_price': _perKmPriceController.text,
      'ac_price_per_km': _acPriceController.text,
      'rc_number': _rcNoController.text,
      'rc_expiry': rcExpiry != null ? DateFormat('yyyy-MM-dd').format(rcExpiry!) : '',
      'insurance_number': _insNoController.text,
      'insurance_expiry': insExpiry != null ? DateFormat('yyyy-MM-dd').format(insExpiry!) : '',
      'permit_number': _permitNoController.text,
      'permit_expiry': permitExpiry != null ? DateFormat('yyyy-MM-dd').format(permitExpiry!) : '',
    };

    final List<MultipartDocument> files = [];

    if (rcFile != null) {
      files.add(MultipartDocument('registration_certificate', rcFile!));
    }
    if (insuranceFile != null) {
      files.add(MultipartDocument('insurance_certificate', insuranceFile!));
    }
    if (permitFile != null) {
      files.add(MultipartDocument('permit_certificate', permitFile!));
    }

    bool success;
    if (isEdit) {
      success = await controller.updateVehicle(vehicle!.id, data, files);
    } else {
      success = await controller.addVehicle(data, files);
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
                      AppInputField(
                        label: 'Vehicle Number',
                        hint: 'e.g. DL 01 AB 1234',
                        controller: _regNoController,
                        errorText: regNoError,
                        onChanged: (_) => setState(() => regNoError = null),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown('Vehicle Type', vehicleTypes, selectedType, (val) {
                        setState(() {
                          selectedType = val;
                          typeError = null;
                        });
                      }, errorText: typeError),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppInputField(
                              label: 'Seating Capacity',
                              hint: 'e.g. 36',
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              errorText: capacityError,
                              onChanged: (_) => setState(() => capacityError = null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInputField(
                              label: 'Model Year',
                              hint: 'e.g. 2022',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              errorText: yearError,
                              onChanged: (_) => setState(() => yearError = null),
                            ),
                          ),
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
                      AppInputField(
                        label: 'Per KM Price',
                        hint: 'e.g. 18.00',
                        controller: _perKmPriceController,
                        keyboardType: TextInputType.number,
                        errorText: priceError,
                        onChanged: (_) => setState(() => priceError = null),
                      ),
                      const SizedBox(height: 16),
                      AppInputField(
                        label: 'AC Price per KM (Extra)',
                        hint: 'e.g. 2.00',
                        controller: _acPriceController,
                        keyboardType: TextInputType.number,
                      ),
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
                  noError: rcNoError,
                  expiryError: rcExpiryError,
                  fileError: rcFileError,
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
                  noError: insNoError,
                  expiryError: insExpiryError,
                  fileError: insuranceFileError,
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
                  noError: permitNoError,
                  expiryError: permitExpiryError,
                  fileError: permitFileError,
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
    {String? remoteUrl, String? noError, String? expiryError, String? fileError}
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
          if (fileError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: AppText(fileError, color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 16),
          AppInputField(
            label: noLabel,
            hint: 'Enter Number',
            controller: noController,
            icon: Iconsax.hashtag,
            errorText: noError,
            onChanged: (_) {
              setState(() {
                if (type == 'RC') rcNoError = null;
                if (type == 'Insurance') insNoError = null;
                if (type == 'Permit') permitNoError = null;
              });
            },
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: 'Expiry Date',
            hint: 'DD-MM-YYYY',
            controller: expiryController,
            readOnly: true,
            icon: Iconsax.calendar_1,
            onTap: () => _selectDate(context, type),
            errorText: expiryError,
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

  Widget _buildDropdown(String label, List<String> items, String? initialVal, Function(String?) onChanged, {String? errorText}) {
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
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: errorText != null ? Colors.red : AppColors.primaryColor, width: 2),
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
