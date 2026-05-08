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
import '../../../core/widgets/vehicle_type_dropdown.dart';
import '../widgets/upload_box.dart';
import '../domain/models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';
import '../controllers/vehicle_type_controller.dart';
import '../../../core/services/network/multipart.dart';
import '../../../core/utils/app_validators.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({Key? key}) : super(key: key);

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late VehicleModel? vehicle;
  bool isEdit = false;

  PlatformFile? rcFile;
  PlatformFile? insuranceFile;
  PlatformFile? permitFile;

  // Error States
  String? rcFileError;
  String? insuranceFileError;
  String? permitFileError;
  String? vehicleTypeError;

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

  void _onVehicleTypeSelected(int? id, String displayName) {
    if (id != null) {
      vehicleTypeError = null;
      final vehicleTypeController = Get.find<VehicleTypeController>();
      final selectedType = vehicleTypeController.vehicleTypes.firstWhereOrNull(
        (type) => type.id == id
      );
      
      if (selectedType != null) {
        controller.selectedVehicleTypeId.value = id;
        controller.selectedVehicleType.value = displayName;
        
        _capacityController.text = selectedType.capacity.toString();
        _perKmPriceController.text = selectedType.perKmPrice.toString();
        _acPriceController.text = selectedType.acPricePerKm.toString();
        
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    vehicle = Get.arguments;
    isEdit = vehicle != null;
    
    VehicleTypeDropdown.ensureController();
    
    if (isEdit) {
      _fillForm(vehicle!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVehicleDetails();
      });
    }
  }

  void _fillForm(VehicleModel v) {
    _regNoController.text = v.vehicleNumber;
    _yearController.text = v.year;

    if (v.vehicleTypeId != null) {
      controller.selectedVehicleTypeId.value = v.vehicleTypeId;
    } else if (v.type.isNotEmpty) {
      final vehicleTypeController = Get.find<VehicleTypeController>();
      final matchingType = vehicleTypeController.vehicleTypes.firstWhereOrNull(
        (t) => t.name.toLowerCase() == v.type.toLowerCase(),
      );
      if (matchingType != null) {
        controller.selectedVehicleTypeId.value = matchingType.id;
        controller.selectedVehicleType.value = matchingType.name;
      }
    }

    _capacityController.text = v.capacity.toString();
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
    setState(() {
      rcFileError = null;
      insuranceFileError = null;
      permitFileError = null;
      vehicleTypeError = null;
    });

    bool isValid = _formKey.currentState!.validate();

    if (controller.selectedVehicleTypeId.value == null || controller.selectedVehicleTypeId.value == 0) {
      setState(() => vehicleTypeError = 'Vehicle Type is required');
      isValid = false;
    }

    if (rcFile == null && vehicle?.rcFileUrl == null) {
      setState(() => rcFileError = 'RC document is required');
      isValid = false;
    }
    if (insuranceFile == null && vehicle?.insuranceFileUrl == null) {
      setState(() => insuranceFileError = 'Insurance policy is required');
      isValid = false;
    }

    if (!isValid) return;

    final Map<String, String> data = {
      'registration_number': _regNoController.text,
      'type': controller.selectedVehicleTypeId.value.toString(),
      'vehicle_type_id': controller.selectedVehicleTypeId.value.toString(),
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
    if (rcFile != null) files.add(MultipartDocument('registration_certificate', rcFile!));
    if (insuranceFile != null) files.add(MultipartDocument('insurance_certificate', insuranceFile!));
    if (permitFile != null) files.add(MultipartDocument('permit_certificate', permitFile!));

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Vehicle Information', style: AppTextStyle.subheading, fontSize: 13, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                        const SizedBox(height: 12),
                        AppInputField(
                          label: 'Vehicle Number',
                          hint: 'e.g. DL 01 AB 1234',
                          controller: _regNoController,
                          validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Vehicle Number'),
                        ),
                        const SizedBox(height: 8),
                        AppInputField(
                          label: 'Model Year',
                          hint: 'e.g. 2022',
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Model Year'),
                        ),
                        const SizedBox(height: 8),
                        VehicleTypeDropdown(
                          selectedId: controller.selectedVehicleTypeId,
                          onChanged: _onVehicleTypeSelected,
                          errorText: vehicleTypeError,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem('Seats', _capacityController.text),
                              _buildVerticalDivider(),
                              _buildInfoItem('Price/KM', '₹${_perKmPriceController.text}'),
                              _buildVerticalDivider(),
                              _buildInfoItem('AC Extra', '₹${_acPriceController.text}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildDocumentSection(
                    'Registration Certificate (RC)',
                    rcFile,
                    _rcNoController,
                    _rcExpiryController,
                    () => _pickDocument('RC'),
                    'RC Number',
                    'RC',
                    remoteUrl: vehicle?.rcFileUrl,
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
                    fileError: permitFileError,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: isEdit ? 'Update Vehicle' : 'Save Vehicle',
                    onPressed: _handleSave,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
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
    {String? remoteUrl, String? fileError}
  ) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.document_text, size: 16, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              AppText(label, style: AppTextStyle.subheading, fontSize: 13, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 12),
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
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: AppText(fileError, color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 8),
          AppInputField(
            label: noLabel,
            hint: 'Enter Number',
            controller: noController,
            icon: Iconsax.hashtag,
            validator: (v) => AppValidators.validateEmpty(v, fieldName: noLabel),
          ),
          const SizedBox(height: 8),
          AppInputField(
            label: 'Expiry Date',
            hint: 'DD-MM-YYYY',
            controller: expiryController,
            readOnly: true,
            icon: Iconsax.calendar_1,
            onTap: () => _selectDate(context, type),
            validator: (v) => AppValidators.validateEmpty(v, fieldName: 'Expiry Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        AppText(label, fontSize: 11, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 2),
        AppText(value.isEmpty ? '-' : value, fontSize: 14, color: AppColors.primaryColor, fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.primaryColor.withValues(alpha: 0.2),
    );
  }
}
