import 'package:credit_debit/features/routes_management/views/assign_route_driver_screen.dart';
import 'package:get/get.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/signup_screen.dart';
import '../features/auth/views/otp_screen.dart';
import '../features/auth/views/forgot_password_screen.dart';
import '../features/auth/views/reset_password_screen.dart';
import '../features/corporate/views/assign_driver.dart';
import '../features/intro/views/intro_screen.dart';
import '../features/intro/controllers/intro_controller.dart';
import '../features/inventory/controllers/inventory_stocks_controller.dart';
import '../features/inventory/views/inventory_stocks_screen.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/dashboard/views/dashboard_screen.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/leads/views/lead_list_screen.dart';
import '../features/leads/controllers/lead_controller.dart';
import '../features/leads/views/create_lead_screen.dart';
import '../features/leads/views/lead_details_screen.dart';
import '../features/leads/views/edit_lead_screen.dart';
import '../features/leads/views/lead_notes_screen.dart';
import '../features/leads/views/follow_up_screen.dart';
import '../features/leads/views/follow_up_list_screen.dart';
import '../features/leads/views/quotation_preview_screen.dart';
import '../features/leads/views/pdf_viewer_screen.dart';
import '../features/trips/views/trip_list_screen.dart';
import '../features/trips/views/create_trip_screen.dart';
import '../features/trips/views/trip_details_screen.dart';
import '../features/trips/views/assign_vehicle_screen.dart';
import '../features/trips/views/assign_driver_screen.dart';
import '../features/trips/views/trip_tracking_screen.dart';
import '../features/trips/views/trip_expense_entry_screen.dart';
import '../features/trips/views/trip_expense_list_screen.dart';
import '../features/trips/views/trip_invoice_screen.dart';
import '../features/trips/views/duty_sheet_upload_screen.dart';
import '../features/trips/views/duty_sheet_list_screen.dart';
import '../features/trips/views/trip_status_update_screen.dart';
import '../features/trips/views/trip_summary_screen.dart';
import '../features/trips/controllers/trip_controller.dart';
import '../features/vehicles/views/vehicle_list_screen.dart';
import '../features/vehicles/views/vehicle_form_screen.dart';
import '../features/vehicles/views/vehicle_details_screen.dart';
import '../features/vehicles/views/vehicle_documents_screen.dart';
import '../features/vehicles/views/fuel_entry_screen.dart';
import '../features/vehicles/views/fuel_history_screen.dart';
import '../features/vehicles/views/service_entry_screen.dart';
import '../features/vehicles/views/service_history_screen.dart';
import '../features/vehicles/views/repair_entry_screen.dart';
import '../features/vehicles/views/maintenance_history_screen.dart';
import '../features/vehicles/views/document_upload_screen.dart';
import '../features/vehicles/controllers/vehicle_controller.dart';
import '../features/staff/views/staff_list_screen.dart';
import '../features/staff/views/staff_details_screen.dart';
import '../features/staff/views/staff_form_screen.dart';
import '../features/staff/views/attendance_screen.dart';
import '../features/staff/views/attendance_history_screen.dart';
import '../features/staff/views/duty_hours_screen.dart';
import '../features/staff/views/add_duty_record_screen.dart';
import '../features/staff/views/salary_management_screen.dart';
import '../features/staff/views/salary_payment_entry_screen.dart';
import '../features/staff/views/salary_history_screen.dart';
import '../features/staff/views/advance_payment_entry_screen.dart';
import '../features/staff/views/advance_history_screen.dart';
import '../features/staff/views/staff_documents_screen.dart';
import '../features/staff/views/driver_license_tracker_screen.dart';
import '../features/staff/views/staff_performance_screen.dart';
import '../features/staff/controllers/staff_controller.dart';
import '../features/staff/bindings/attendance_binding.dart';
import '../features/staff/bindings/attendance_history_binding.dart';
import '../features/corporate/views/company_list_screen.dart';
import '../features/corporate/views/create_corporate_contract_screen.dart';
import '../features/corporate/views/contract_details_screen.dart';
import '../features/corporate/views/assign_vehicle_to_contract_screen.dart';
import '../features/corporate/views/corporate_duty_tracking_screen.dart';
import '../features/corporate/views/corporate_invoice_screen.dart';
import '../features/corporate/controllers/corporate_controller.dart';
import '../features/finance/views/cashbook_dashboard_screen.dart';
import '../features/finance/views/cash_in_entry_screen.dart';
import '../features/finance/views/cash_out_entry_screen.dart';
import '../features/finance/views/payment_history_screen.dart';
import '../features/finance/views/payment_details_screen.dart';
import '../features/finance/controllers/finance_controller.dart';
import '../features/finance/bindings/finance_binding.dart';
import '../features/inventory/views/inventory_list_screen.dart';
import '../features/inventory/views/add_inventory_item_screen.dart';
import '../features/inventory/views/inventory_details_screen.dart';
import '../features/inventory/views/stock_in_screen.dart';
import '../features/inventory/views/stock_out_screen.dart';
import '../features/inventory/controllers/inventory_controller.dart';
import '../features/inventory/domain/repositories/inventory_repository.dart';
import '../features/inventory/domain/services/inventory_service.dart';
import '../features/shifts/views/shift_list_screen.dart';
import '../features/shifts/views/create_shift_screen.dart';
import '../features/shifts/views/assign_driver_to_shift_screen.dart';
import '../features/shifts/views/shift_details_screen.dart';
import '../features/shifts/controllers/shift_controller.dart';
import '../features/routes_management/views/route_list_screen.dart';
import '../features/routes_management/views/create_route_screen.dart';
import '../features/routes_management/views/route_details_screen.dart';
import '../features/routes_management/views/assign_route_screen.dart';
import '../features/routes_management/controllers/route_controller.dart';
import '../features/reports/views/reports_dashboard_screen.dart';
import '../features/reports/views/trip_reports_screen.dart';
import '../features/reports/views/financial_reports_screen.dart';
import '../features/reports/views/vehicle_reports_screen.dart';
import '../features/reports/views/staff_reports_screen.dart';
import '../features/reports/views/compliance_reports_screen.dart';
import '../features/reports/views/profit_loss_report_screen.dart';
import '../features/vehicles/views/repair_history_screen.dart';
import '../features/vehicles/views/service_payment_history_screen.dart';
import '../features/reports/controllers/reports_controller.dart';
import '../features/settings/views/profile_screen.dart';
import '../features/settings/views/edit_profile_screen.dart';
import '../features/settings/views/change_password_screen.dart';
import '../features/settings/views/subscription_screen.dart';
import '../features/settings/views/help_screen.dart';
import '../features/templates/views/template_list_screen.dart';
import '../features/templates/views/add_edit_template_screen.dart';
import '../features/templates/views/template_details_screen.dart';
import '../features/templates/views/template_view_screen.dart';
import '../features/templates/controllers/template_controller.dart';
import '../features/templates/controllers/template_view_controller.dart';
import '../features/roles/views/role_list_screen.dart';
import '../features/roles/views/add_edit_role_screen.dart';
import '../features/roles/views/role_details_screen.dart';
import '../features/roles/controllers/role_controller.dart';
import '../features/membership/views/membership_screen.dart';
import '../features/membership/controllers/membership_controller.dart';
import '../features/notifications/views/notifications_screen.dart';
import '../features/notifications/views/notification_details_screen.dart';
import '../features/dashboard/views/search_screen.dart';
import '../features/vehicles/views/document_viewer_screen.dart';
import '../features/vehicles/views/vehicle_type_list_screen.dart';
import '../features/vehicles/views/add_edit_vehicle_type_screen.dart';
import '../features/vehicles/controllers/vehicle_type_controller.dart';
import '../features/reports/views/all_reports_screen.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
  static String getLoginRoute() => AppRoutes.login;
  static String getSignupRoute() => AppRoutes.signup;
  static String getOtpRoute() => AppRoutes.otp;
  static String getIntroRoute() => AppRoutes.intro;
  static String getForgotPasswordRoute() => AppRoutes.forgotPassword;
  static String getResetPasswordRoute() => AppRoutes.resetPassword;
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getLeadListRoute() => AppRoutes.leadList;
  static String getLeadSummaryRoute() => AppRoutes.leadSummary; // Added this line as it was in the instruction's context

  // Trips
  static String getTripListRoute() => AppRoutes.tripList;
  static String getCreateTripRoute() => AppRoutes.createTrip;
  static String getTripDetailsRoute() => AppRoutes.tripDetails;
  static String getAssignVehicleRoute() => AppRoutes.assignVehicle;
  static String getAssignDriverRoute() => AppRoutes.assignDriver;
  static String getTripTrackingRoute() => AppRoutes.tripTracking;
  static String getTripExpenseEntryRoute() => AppRoutes.tripExpenseEntry;
  static String getTripExpenseListRoute() => AppRoutes.tripExpenseList;
  static String getTripInvoiceRoute() => AppRoutes.tripInvoice;
  static String getDutySheetUploadRoute() => AppRoutes.dutySheetUpload;
  static String getDutySheetListRoute() => AppRoutes.dutySheetList;
  static String getTripStatusUpdateRoute() => AppRoutes.tripStatusUpdate;
  static String getTripSummaryRoute() => AppRoutes.tripSummary;

  // Vehicles
  static String getVehicleListRoute() => AppRoutes.vehicleList;
  static String getAddVehicleRoute() => AppRoutes.addVehicle;
  static String getVehicleDetailsRoute() => AppRoutes.vehicleDetails;
  static String getEditVehicleRoute() => AppRoutes.editVehicle;
  static String getVehicleDocumentsRoute() => AppRoutes.vehicleDocuments;
  static String getFuelEntryRoute() => AppRoutes.fuelEntry;
  static String getFuelHistoryRoute() => AppRoutes.fuelHistory;
  static String getServiceEntryRoute() => AppRoutes.serviceEntry;
  static String getServiceHistoryRoute() => AppRoutes.serviceHistory;
  static String getRepairEntryRoute() => AppRoutes.repairEntry;
  static String getMaintenanceHistoryRoute() => AppRoutes.maintenanceHistory;
  static String getDocumentUploadRoute() => AppRoutes.documentUpload;
  static String getServicePaymentHistoryRoute() => AppRoutes.servicePaymentHistory;
  static String getCreateLeadRoute() => AppRoutes.createLead;
  static String getLeadDetailsRoute() => AppRoutes.leadDetails;
  static String getEditLeadRoute() => AppRoutes.editLead;
  static String getLeadNotesRoute() => AppRoutes.leadNotes;
  static String getFollowUpRoute() => AppRoutes.followUp;
  static String getFollowUpListRoute() => AppRoutes.followUpList;
  static String getQuotationPreviewRoute() => AppRoutes.quotationPreview;
  static String getPdfViewerRoute() => AppRoutes.pdfViewer;
  static String getDocumentPreviewRoute() => AppRoutes.documentPreview;

  // Staff
  static String getStaffListRoute() => AppRoutes.staffList;
  static String getAddStaffRoute() => AppRoutes.addStaff;
  static String getStaffDetailsRoute() => AppRoutes.staffDetails;
  static String getEditStaffRoute() => AppRoutes.editStaff;
  static String getAttendanceRoute() => AppRoutes.attendance;
  static String getAttendanceHistoryRoute() => AppRoutes.attendanceHistory;
  static String getDutyHoursRoute() => AppRoutes.dutyHours;
  static String getAddDutyRecordRoute() => AppRoutes.addDutyRecord;
  static String getSalaryManagementRoute() => AppRoutes.salaryManagement;
  static String getSalaryPaymentEntryRoute() => AppRoutes.salaryPaymentEntry;
  static String getSalaryHistoryRoute() => AppRoutes.salaryHistory;
  static String getAdvancePaymentEntryRoute() => AppRoutes.advancePaymentEntry;
  static String getAdvanceHistoryRoute() => AppRoutes.advanceHistory;
  static String getStaffDocumentsRoute() => AppRoutes.staffDocuments;
  static String getDriverLicenseTrackerRoute() => AppRoutes.driverLicenseTracker;
  static String getStaffPerformanceRoute() => AppRoutes.staffPerformance;

  // Corporate
  static String getCompanyListRoute() => AppRoutes.companyList;
  static String getCreateCorporateContractRoute() => AppRoutes.createCorporateContract;
  static String getContractDetailsRoute() => AppRoutes.contractDetails;
  static String getAssignVehicleToContractRoute() => AppRoutes.assignVehicleToContract;
  static String getCorporateDutyTrackingRoute() => AppRoutes.corporateDutyTracking;
  static String getCorporateInvoiceRoute() => AppRoutes.corporateInvoice;
  static String getAssignDriverToContractRoute() => AppRoutes.assignDriverToContract;

  // Finance
  static String getCashbookDashboardRoute() => AppRoutes.cashbookDashboard;
  static String getCashInEntryRoute() => AppRoutes.cashInEntry;
  static String getCashOutEntryRoute() => AppRoutes.cashOutEntry;
  static String getPaymentHistoryRoute() => AppRoutes.paymentHistory;
  static String getPaymentDetailsRoute() => AppRoutes.paymentDetails;

  // Inventory
  static String getInventoryListRoute() => AppRoutes.inventoryList;
  static String getAddInventoryItemRoute() => AppRoutes.addInventoryItem;
  static String getInventoryDetailsRoute() => AppRoutes.inventoryDetails;
  static String getStockInRoute() => AppRoutes.stockIn;
  static String getStockOutRoute() => AppRoutes.stockOut;
  static String getStockHistoryRoute() => AppRoutes.stockHistory;

  // Shifts
  static String getShiftListRoute() => AppRoutes.shiftList;
  static String getCreateShiftRoute() => AppRoutes.createShift;
  static String getAssignDriverToShiftRoute() => AppRoutes.assignDriverToShift;
  static String getShiftDetailsRoute() => AppRoutes.shiftDetails;

  // Routes Management
  static String getRouteListRoute() => AppRoutes.routeList;
  static String getCreateRouteRoute() => AppRoutes.createRoute;
  static String getRouteDetailsRoute() => AppRoutes.routeDetails;
  static String getAssignRouteRoute() => AppRoutes.assignRoute;
  static String getAssignRouteDriver() => AppRoutes.assignRouteDriver;

  // Reports
  static String getReportsDashboardRoute() => AppRoutes.reportsDashboard;
  static String getTripReportsRoute() => AppRoutes.tripReports;
  static String getFinancialReportsRoute() => AppRoutes.financialReports;
  static String getVehicleReportsRoute() => AppRoutes.vehicleReports;
  static String getStaffReportsRoute() => AppRoutes.staffReports;
  static String getComplianceReportsRoute() => AppRoutes.complianceReports;
  static String getProfitLossReportRoute() => AppRoutes.profitLossReport;
  static String getAllReportsRoute() => AppRoutes.allReports;
  static String getRepairHistoryRoute() => AppRoutes.repairHistory;

  // Phase 11 Modules
  static String getTemplateListRoute() => AppRoutes.templateList;
  static String getAddTemplateRoute() => AppRoutes.addTemplate;
  static String getEditTemplateRoute() => AppRoutes.editTemplate;
  static String getTemplateDetailsRoute() => AppRoutes.templateDetails;
  static String getTemplateViewRoute() => AppRoutes.templateView;
  static String getRoleListRoute() => AppRoutes.roleList;
  static String getAddRoleRoute() => AppRoutes.addRole;
  static String getEditRoleRoute() => AppRoutes.editRole;
  static String getRoleDetailsRoute() => AppRoutes.roleDetails;
  static String getMembershipRoute() => AppRoutes.membership;

  // Settings & Profile
  static String getProfileRoute() => AppRoutes.profile;
  static String getEditProfileRoute() => AppRoutes.editProfile;
  static String getChangePasswordRoute() => AppRoutes.changePassword;
  static String getSubscriptionRoute() => AppRoutes.subscription;
  static String getHelpRoute() => AppRoutes.help;
  static String getNotificationsRoute() => AppRoutes.notifications;
  static String getNotificationDetailsRoute() => AppRoutes.notificationDetails;
  static String getSearchRoute() => AppRoutes.search;
  static String getVehicleTypeListRoute() => AppRoutes.vehicleTypeList;
  static String getAddVehicleTypeRoute() => AppRoutes.addVehicleType;
  static String getEditVehicleTypeRoute() => AppRoutes.editVehicleType;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => IntroController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController(), fenix: true);
        Get.lazyPut(() => LeadController(), fenix: true);
        Get.lazyPut(() => TripController(), fenix: true);
        Get.lazyPut(() => VehicleController(), fenix: true);
        Get.lazyPut(() => StaffController(), fenix: true);
        Get.lazyPut(() => RouteController(), fenix: true);
        FinanceBinding().dependencies();
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.leadList,
      page: () => const LeadListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LeadController(), fenix: true);
        Get.lazyPut(() => RouteController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.createLead,
      page: () => const CreateLeadScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.leadDetails,
      page: () => const LeadDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editLead,
      page: () => const EditLeadScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.leadNotes,
      page: () => const LeadNotesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.followUp,
      page: () => const FollowUpScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.followUpList,
      page: () => const FollowUpListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.quotationPreview,
      page: () => const QuotationPreviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pdfViewer,
      page: () => const PdfViewerScreen(),
      transition: Transition.fadeIn,
    ),

    // Trips
    GetPage(
      name: AppRoutes.tripList,
      page: () => const TripListScreen(),
      binding: BindingsBuilder(() {
        Get.put(TripController());
      }),
    ),
    GetPage(
      name: AppRoutes.createTrip,
      page: () => const CreateTripScreen(),
    ),
    GetPage(
      name: AppRoutes.tripDetails,
      page: () => const TripDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.assignVehicle,
      page: () => const AssignVehicleScreen(),
    ),
    GetPage(
      name: AppRoutes.assignDriver,
      page: () => const AssignDriverScreen(),
    ),
    GetPage(
      name: AppRoutes.tripTracking,
      page: () => const TripTrackingScreen(),
    ),
    GetPage(
      name: AppRoutes.tripExpenseEntry,
      page: () => const TripExpenseEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.tripExpenseList,
      page: () => const TripExpenseListScreen(),
    ),
    GetPage(
      name: AppRoutes.tripInvoice,
      page: () => const TripInvoiceScreen(),
    ),
    GetPage(
      name: AppRoutes.dutySheetUpload,
      page: () => const DutySheetUploadScreen(),
    ),
    GetPage(
      name: AppRoutes.dutySheetList,
      page: () => const DutySheetListScreen(),
    ),
    GetPage(
      name: AppRoutes.tripStatusUpdate,
      page: () => const TripStatusUpdateScreen(),
    ),
    GetPage(
      name: AppRoutes.tripSummary,
      page: () => const TripSummaryScreen(),
    ),

    // Vehicles
    GetPage(
      name: AppRoutes.vehicleList,
      page: () => const VehicleListScreen(),
      binding: BindingsBuilder(() {
        Get.put(VehicleController());
      }),
    ),
    GetPage(
      name: AppRoutes.addVehicle,
      page: () => const VehicleFormScreen(),
    ),
    GetPage(
      name: AppRoutes.vehicleDetails,
      page: () => const VehicleDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.editVehicle,
      page: () => const VehicleFormScreen(),
    ),
    GetPage(
      name: AppRoutes.vehicleDocuments,
      page: () => const VehicleDocumentsScreen(),
    ),
    GetPage(
      name: AppRoutes.fuelEntry,
      page: () => const FuelEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.fuelHistory,
      page: () => const FuelHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.serviceEntry,
      page: () => const ServiceEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.serviceHistory,
      page: () => const ServiceHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.repairEntry,
      page: () => const RepairEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.repairHistory,
      page: () => const RepairHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.maintenanceHistory,
      page: () => const MaintenanceHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.documentUpload,
      page: () => const DocumentUploadScreen(),
    ),
    GetPage(
      name: AppRoutes.servicePaymentHistory,
      page: () => const ServicePaymentHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.documentPreview,
      page: () => const DocumentViewerScreen(),
    ),

    GetPage(
      name: AppRoutes.staffList,
      page: () => const StaffListScreen(),
    ),
    GetPage(
      name: AppRoutes.addStaff,
      page: () => const StaffFormScreen(),
    ),
    GetPage(
      name: AppRoutes.staffDetails,
      page: () => const StaffDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.editStaff,
      page: () => const StaffFormScreen(),
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceScreen(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: AppRoutes.attendanceHistory,
      page: () => const AttendanceHistoryScreen(),
      binding: AttendanceHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.dutyHours,
      page: () => const DutyHoursScreen(),
    ),
    GetPage(
      name: AppRoutes.addDutyRecord,
      page: () => const AddDutyRecordScreen(),
    ),
    GetPage(
      name: AppRoutes.salaryManagement,
      page: () => const SalaryManagementScreen(),
    ),
    GetPage(
      name: AppRoutes.salaryPaymentEntry,
      page: () => const SalaryPaymentEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.salaryHistory,
      page: () => const SalaryHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.advancePaymentEntry,
      page: () => const AdvancePaymentEntryScreen(),
    ),
    GetPage(
      name: AppRoutes.advanceHistory,
      page: () => const AdvanceHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.staffDocuments,
      page: () => const StaffDocumentsScreen(),
    ),
    GetPage(
      name: AppRoutes.driverLicenseTracker,
      page: () => const DriverLicenseTrackerScreen(),
    ),
    GetPage(
      name: AppRoutes.staffPerformance,
      page: () => const StaffPerformanceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.companyList,
      page: () => const CompanyListScreen(),
      binding: BindingsBuilder(() {
        Get.put(CorporateController());
      }),
    ),
    GetPage(
      name: AppRoutes.createCorporateContract,
      page: () => const CreateCorporateContractScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.contractDetails,
      page: () => const ContractDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.assignVehicleToContract,
      page: () => const AssignVehicleToContractScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.assignDriverToContract,
      page: () => const AssignDriverToContractScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.corporateDutyTracking,
      page: () => const CorporateDutyTrackingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.corporateInvoice,
      page: () => const CorporateInvoiceScreen(),
      transition: Transition.rightToLeft,
    ),

    // Finance
    GetPage(
      name: AppRoutes.cashbookDashboard,
      page: () => const CashbookDashboardScreen(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: AppRoutes.cashInEntry,
      page: () => const CashInEntryScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.cashOutEntry,
      page: () => const CashOutEntryScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.paymentHistory,
      page: () => const PaymentHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.paymentDetails,
      page: () => const PaymentDetailsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Inventory
    GetPage(
      name: AppRoutes.inventoryList,
      page: () => const InventoryListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl(Get.find()));
        Get.lazyPut(() => AddInventoryItemUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => GetInventoryDataUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => GetInventoryDetailsUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => GetInventoryStocksUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => UpdateInventoryItemUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => DeleteInventoryItemUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => StockInUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => StockOutUseCase(Get.find<InventoryRepository>()));
        Get.put(InventoryController(
          addInventoryItemUseCase: Get.find<AddInventoryItemUseCase>(),
          getInventoryDataUseCase: Get.find<GetInventoryDataUseCase>(),
          getInventoryDetailsUseCase: Get.find<GetInventoryDetailsUseCase>(),
          updateInventoryItemUseCase: Get.find<UpdateInventoryItemUseCase>(),
          deleteInventoryItemUseCase: Get.find<DeleteInventoryItemUseCase>(),
          stockInUseCase: Get.find<StockInUseCase>(),
          stockOutUseCase: Get.find<StockOutUseCase>(),
        ));
      }),
    ),
    GetPage(
      name: AppRoutes.addInventoryItem,
      page: () => const AddInventoryItemScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.inventoryDetails,
      page: () => const InventoryDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.stockIn,
      page: () => const StockInScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.stockOut,
      page: () => const StockOutScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.stockHistory,
      page: () => const InventoryStocksScreen(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl(Get.find()));
        Get.lazyPut(() => GetInventoryStocksUseCase(Get.find<InventoryRepository>()));
        Get.lazyPut(() => InventoryStocksController(
          getInventoryStocksUseCase: Get.find<GetInventoryStocksUseCase>(),
        ));
      }),
    ),

    // Shifts
    GetPage(
      name: AppRoutes.shiftList,
      page: () => const ShiftListScreen(),
      binding: BindingsBuilder(() {
        Get.put(ShiftController());
      }),
    ),
    GetPage(
      name: AppRoutes.createShift,
      page: () => const CreateShiftScreen(),
      binding: BindingsBuilder(() {
        Get.put(ShiftController());
      }),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.assignDriverToShift,
      page: () => const AssignDriverToShiftScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.shiftDetails,
      page: () => const ShiftDetailsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Routes Management
    GetPage(
      name: AppRoutes.routeList,
      page: () => const RouteListScreen(),
      binding: BindingsBuilder(() {
        Get.put(RouteController());
      }),
    ),
    GetPage(
      name: AppRoutes.createRoute,
      page: () => const CreateRouteScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.routeDetails,
      page: () => const RouteDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.assignRoute,
      page: () => const AssignRouteScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.assignRouteDriver,
      page: () => const AssignRouteDriverScreen(),
      transition: Transition.downToUp,
    ),

    // Reports
    GetPage(
      name: AppRoutes.reportsDashboard,
      page: () => const ReportsDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(ReportsController());
      }),
    ),
    GetPage(
      name: AppRoutes.tripReports,
      page: () => const TripReportsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.financialReports,
      page: () => const FinancialReportsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vehicleReports,
      page: () => const VehicleReportsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.staffReports,
      page: () => const StaffReportsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.complianceReports,
      page: () => const ComplianceReportsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profitLossReport,
      page: () => const ProfitLossReportScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ReportsController());
        FinanceBinding().dependencies();
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.allReports,
      page: () => const AllReportsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ReportsController());
      }),
      transition: Transition.rightToLeft,
    ),

    // Settings & Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () =>  EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      transition: Transition.rightToLeft,
    ),

    // Phase 11 Modules - Templates
    GetPage(
      name: AppRoutes.templateList,
      page: () => const TemplateListScreen(),
      binding: BindingsBuilder(() { Get.put(TemplateController()); }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addTemplate,
      page: () => const AddEditTemplateScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.editTemplate,
      page: () => AddEditTemplateScreen(template: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.templateDetails,
      page: () => const TemplateDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.templateView,
      page: () => const TemplateViewScreen(),
      binding: BindingsBuilder(() { Get.put(TemplateViewController()); }),
      transition: Transition.rightToLeft,
    ),

    // Phase 11 Modules - Roles
    GetPage(
      name: AppRoutes.roleList,
      page: () => const RoleListScreen(),
      binding: BindingsBuilder(() { Get.put(RoleController()); }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addRole,
      page: () => const AddEditRoleScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.editRole,
      page: () => AddEditRoleScreen(role: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.roleDetails,
      page: () => const RoleDetailsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Phase 11 Modules - Membership
    GetPage(
      name: AppRoutes.membership,
      page: () => const MembershipScreen(),
      binding: BindingsBuilder(() { Get.put(MembershipController()); }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notificationDetails,
      page: () => const NotificationDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.vehicleTypeList,
      page: () => const VehicleTypeListScreen(),
      binding: BindingsBuilder(() {
        Get.put(VehicleTypeController());
      }),
    ),
    GetPage(
      name: AppRoutes.addVehicleType,
      page: () => const AddEditVehicleTypeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editVehicleType,
      page: () => const AddEditVehicleTypeScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
