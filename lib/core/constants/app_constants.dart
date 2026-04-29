import '../services/config/env_config.dart';

class AppConstants {
    static String appName = EnvConfig.appName;
    static String baseUrl = "https://beige-stingray-620454.hostingersite.com";
    static String apiToken = EnvConfig.apiToken;
    static const String googleMapsKey = 'AIzaSyAH2m4kQwGljzCxdDdy7JrnKTDKCgFZU_A';
    static const String fontFamily = 'Poppins';
    static const String defaultTag = 'PCB_APP'; // default tag for log checking

    static const bool isHandleInternetScreen = true;
    static const bool isHandleErrorScreen = false;
    static const bool handleError = true; // manages logic-level error flow.
    static const bool showToaster = false; // manages UI-level notifications.

    // API base URLs
    static  String imageUrl = '$baseUrl';

    // API endpoints
    static const String sendOtpUrl = '/api/auth/send-otp';
    static const String resendOtpUrl = '/api/auth/resend-login-otp';
    static const String verifyLoginOtpUrl = '/api/auth/verify-login-otp';
    static const String registerSendOtpUrl = '/api/auth/register/send-otp';
    static const String plansListUrl = '/api/plans/list';
    static const String createSubscriptionUrl = '/api/v1/subscriptions';
    static const String verifyPaymentUrl = '/api/v1/subscriptions/verify-payment';
    static const String currentSubscriptionUrl = '/api/v1/subscriptions/current';
    static const String subscriptionsHistoryUrl = '/api/v1/subscriptions';
    static const String logoutUrl = '/api/v1/auth/logout';
    static const String profileUrl = '/api/v1/auth/me';
    static const String updateProfileUrl = '/api/v1/auth/profile/update';
    static const String userSignupUrl = '/api/user_signup';
    static const String userLoginUrl = '/api/user_login';
    static const String otpVerifyUrl = '/api/otp_verify';
    static const String documentTemplatesEndpoint = '/api/v1/document-templates/';

    // Shared Preferences keys
    static const String theme = 'theme';
    static const String language = 'language';
    static const String token = 'token';
    static const String userData = 'user_data';
    static const String profileData = 'profile_data';
    static const String isLoggedIn = 'is_logged_in';


    static const String createShift = '/api/v1/shifts';
    static const String getShift = '/api/v1/shifts';
    static  String getShiftById(int id) => '/api/v1/shifts/$id';
    
    // Role Endpoints
    static const String rolesUrl = '/api/v1/roles';
    static const String getRolesUrl = '/api/v1/roles';
    static const String createRoleUrl = '/api/v1/roles';
    static String updateRoleUrl(dynamic id) => '/api/v1/roles/$id';
    static String getRoleByIdUrl(dynamic id) => '/api/v1/roles/$id';

    // Route Endpoints
    static const String routesUrl = '/api/v1/routes';
    static const String getRoutesUrl = '/api/v1/routes';
    static const String createRouteUrl = '/api/v1/routes';
    static String searchRoutesUrl(String query) => '/api/v1/routes/search?query=$query';
    static String updateRouteUrl(dynamic id) => '/api/v1/routes/$id';
    static String getRouteByIdUrl(dynamic id) => '/api/v1/routes/$id';

    // Staff Endpoints
    static const String staffUrl = '/api/v1/staff';
    static const String getStaffUrl = '/api/v1/staff';
    static const String createStaffUrl = '/api/v1/staff';
    static String updateStaffUrl(dynamic id) => '/api/v1/staff/$id';
    static String getStaffDetailsUrl(dynamic id) => '/api/v1/staff/$id';

    // Vehicle Endpoints
    static const String vehiclesUrl = '/api/v1/vehicles';
    static const String getVehiclesUrl = '/api/v1/vehicles';
    static String updateVehicleUrl(dynamic id) => '/api/v1/vehicles/$id';
    static String deleteVehicleUrl(dynamic id) => '/api/v1/vehicles/$id';
}
