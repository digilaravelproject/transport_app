# Implementation Plan: Improved Splash Screen

## Overview

This implementation plan converts the splash screen from using a background image to a modern gradient-based design that adapts to the app's theme. The implementation focuses on creating a clean, animated splash screen with theme-aware gradient backgrounds, smooth logo animations, and a responsive loading indicator.

## Tasks

- [x] 1. Create gradient color helper functions
  - Implement `_getGradientColors()` function that returns appropriate colors based on theme mode
  - Define light mode gradient colors: primary blue (#1E3A6F), light blue (#E3F2FD), white
  - Define dark mode gradient colors: dark card (#1E1E1E), dark background (#121212), deeper black (#0A0A0A)
  - Ensure function returns exactly 3 colors for any theme mode
  - _Requirements: 1.1, 1.2, 8.2_

- [ ]* 1.1 Write property test for gradient color selection
  - **Property 5: Gradient Color Count** - Verify gradient always contains exactly 3 colors
  - **Property 1: Theme Consistency** - Verify dark mode colors have luminance < 0.3 and light mode has at least one color with luminance > 0.5
  - **Validates: Requirements 1.1, 1.2, 8.4, 8.5**

- [ ] 2. Implement gradient background widget
  - [x] 2.1 Create `_buildGradientBackground()` function
    - Build Container widget with BoxDecoration
    - Apply LinearGradient with topLeft to bottomRight alignment
    - Use colors from `_getGradientColors()` based on isDarkMode parameter
    - _Requirements: 1.1, 1.2, 1.4, 4.2_

  - [ ]* 2.2 Write unit tests for gradient background
    - Test gradient contains correct colors for light mode
    - Test gradient contains correct colors for dark mode
    - Test gradient alignment is topLeft to bottomRight
    - _Requirements: 1.1, 1.2, 1.4_

- [ ] 3. Implement animated logo widget
  - [ ] 3.1 Create `_buildAnimatedLogo()` function
    - Use TweenAnimationBuilder for fade-in effect (0.0 to 1.0 over 800ms)
    - Apply Transform.scale animation (0.8 to 1.0 over 600ms)
    - Set logo width to 180 pixels
    - Use Curves.easeInOut for smooth animation
    - Load logo from ImageConstants.logo
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ]* 3.2 Write property test for animation timing
    - **Property 2: Animation Timing** - Verify fade-in and scale durations are > 0 and < 2000ms
    - **Validates: Requirements 7.4, 7.5**

  - [ ]* 3.3 Write unit tests for animated logo
    - Test logo width is 180 pixels
    - Test animation durations are correct (800ms fade, 600ms scale)
    - Test animation curve is easeInOut
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 4. Implement loading indicator widget
  - [ ] 4.1 Create `_buildLoadingIndicator()` function
    - Wrap CircularProgressIndicator in Visibility widget
    - Set visibility based on isLoading parameter
    - Use white color in dark mode, primary color in light mode
    - Apply AlwaysStoppedAnimation for color
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.6_

  - [ ]* 4.2 Write property test for loading indicator visibility
    - **Property 4: Loading Indicator Visibility** - Verify indicator visibility matches isLoading state
    - **Validates: Requirements 3.1, 3.2**

  - [ ]* 4.3 Write unit tests for loading indicator
    - Test indicator is visible when isLoading is true
    - Test indicator is hidden when isLoading is false
    - Test indicator color is white in dark mode
    - Test indicator color is primary color in light mode
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 5. Checkpoint - Ensure all component functions are working
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement main SplashScreen widget
  - [ ] 6.1 Update SplashScreen class structure
    - Ensure SplashScreen extends StatelessWidget
    - Add const constructor with Key parameter
    - _Requirements: 4.1_

  - [ ] 6.2 Implement build method with theme integration
    - Use Get.find to retrieve ThemeController and SplashController
    - Wrap with GetBuilder<ThemeController> for theme reactivity
    - Build Scaffold as root widget
    - _Requirements: 4.1, 6.1, 6.4_

  - [ ] 6.3 Compose widget tree with layout structure
    - Set Scaffold body to gradient background container
    - Add Center widget for content positioning
    - Add Column with MainAxisAlignment.center
    - Add animated logo as first child
    - Add SizedBox with 30px height for spacing
    - Add loading indicator wrapped in Obx for reactivity
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 3.5, 2.5_

  - [ ]* 6.4 Write property test for widget tree structure
    - **Property 3: Widget Tree Validity** - Verify widget tree contains Scaffold, Container, and Center in correct hierarchy
    - **Validates: Requirements 4.1, 4.2, 4.3**

  - [ ]* 6.5 Write unit tests for SplashScreen widget
    - Test widget tree structure is correct
    - Test spacing between logo and loading indicator is 30px
    - Test content is centered
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 7. Implement error handling
  - [ ] 7.1 Add error handling for missing logo asset
    - Wrap Image.asset in try-catch or use errorBuilder
    - Display placeholder text (app name) if logo fails to load
    - Log error message when asset is not found
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ] 7.2 Add error handling for missing ThemeController
    - Wrap Get.find<ThemeController>() in try-catch
    - Use light mode as default if controller not found
    - Log warning message when controller is missing
    - _Requirements: 6.2, 6.3_

  - [ ] 7.3 Add fallback colors for invalid color constants
    - Add validation in `_getGradientColors()` to check for null colors
    - Use Material Design defaults (Colors.blue, Colors.white) as fallback
    - _Requirements: 8.3_

  - [ ]* 7.4 Write unit tests for error handling
    - Test missing logo asset shows placeholder
    - Test missing ThemeController uses light mode default
    - Test invalid colors use fallback values
    - _Requirements: 5.1, 5.2, 5.3, 6.2, 6.3, 8.3_

- [ ] 8. Optimize performance
  - [ ] 8.1 Add const constructors where applicable
    - Mark SizedBox with const
    - Mark Duration objects with const
    - Mark Color objects with const
    - _Requirements: 7.2_

  - [ ] 8.2 Verify animation performance
    - Ensure animations use Flutter's optimized framework
    - Confirm no unnecessary rebuilds during animations
    - _Requirements: 7.1, 7.3_

- [ ] 9. Final checkpoint - Integration testing
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The implementation uses existing GetX controllers (ThemeController, SplashController)
- No new dependencies are required for this feature
- All animations use Flutter's built-in animation framework for optimal performance
- Error handling ensures graceful degradation if assets or controllers are missing
