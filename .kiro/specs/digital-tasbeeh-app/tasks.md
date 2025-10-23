# Implementation Plan

- [x] 1. Set up project structure and dependencies





  - Create Flutter project named 'digital_tasbeeh' with proper directory structure: lib/{models,screens,widgets,services,providers,utils,constants}
  - Add dependencies in pubspec.yaml: cupertino_icons ^1.0.6, provider ^6.1.1, sqflite ^2.3.0, shared_preferences ^2.2.2, firebase_core ^2.24.2, firebase_messaging ^14.7.10, firebase_analytics ^10.8.0, fl_chart ^0.66.0, flutter_local_notifications ^16.3.0
  - Create Firebase project with Android app configuration and download google-services.json to android/app/
  - Set up main.dart with CupertinoApp, custom theme data, and provider initialization
  - Create constants/app_colors.dart with iOS-style color palette: primary #007AFF, secondary #5AC8FA, backgrounds, text colors for light/dark modes
  - Create constants/app_text_styles.dart with SF Pro Display font family and iOS typography scale
  - _Requirements: 7.2, 8.1, 9.2_

- [x] 2. Implement core data models and database layer




  - Create Tasbeeh model class with id, name, targetCount, currentCount, roundNumber, timestamps, and isDefault properties
  - Create CountHistory model for tracking individual count events with timestamps
  - Create AppSettings model for user preferences and configuration
  - Implement SQLite database helper with table creation and migration logic
  - Write database repository classes for Tasbeeh CRUD operations and count history management
  - _Requirements: 4.1, 4.2, 6.4, 10.5_

- [x] 3. Create counter business logic and state management





  - Implement CounterProvider using ChangeNotifier for counter state management
  - Add increment, decrement, and reset functionality with validation
  - Implement round completion logic for Tasbeehs with target counts
  - Add progress calculation methods for visual progress ring
  - Create methods for switching between different Tasbeehs
  - _Requirements: 1.1, 1.2, 2.1, 2.3, 2.4_

- [x] 4. Build the main counter component UI with stunning iOS aesthetics




  - Create CircularCounter widget with precise 380dp diameter, responsive scaling for small (320dp), medium (380dp), large (420dp) screens
  - Implement GestureDetector with full counter area tap detection, double-tap protection (100ms minimum delay), and haptic feedback integration
  - Build CustomPainter for animated progress ring: 14dp stroke width, rounded caps, smooth 300ms ease-out transitions, #007AFF color with gradient support
  - Create layered visual hierarchy: outer background track (gray #C8C8C8/dark #3A3A3C), animated progress arc, inner white circle (352dp) with subtle shadow (blur 20, spread -5)
  - Add 100 radial tick marks (12dp length, 1.5dp width) positioned at 166dp radius with 60% opacity for premium iOS feel
  - Implement 33 progress dots (6dp diameter) evenly distributed on progress ring, appearing only on completed progress with fade-in animation
  - Create progress handle (20dp circular knob) at arc end with white color and shadow (blur 4, offset y:2)
  - Build current count display with SF Pro Display font, 120pt size, -2 letter spacing, #007AFF color, center alignment, scale-pulse animation on increment
  - Add conditional target count display (format "/ {target}") with 48pt size, gray color, positioned below current count
  - Implement round number display (format "Round {number}") with 42pt size, #007AFF color, scale-bounce animation on round completion
  - Create unlimited mode with infinite scroll progress ring and continuous rotation animation
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.4, 10.1, 10.2_

- [x] 5. Implement stunning action bar with premium iOS-style controls





  - Create ActionBar widget with perfect pill shape (430x80dp, 40dp border radius), positioned 60dp from top center
  - Apply frosted glass background effect: semi-transparent (#C8C8C8 light, #3A3A3C dark) with 90% opacity and blur backdrop filter
  - Add subtle shadow: color #00000015, blur radius 10dp, offset y:2dp for floating appearance
  - Build five premium interactive buttons with 60dp circular touch targets, 24dp spacing between buttons:
    * Sound Toggle: Volume up icon (32dp, 2.5dp stroke), active #007AFF, inactive #8E8E93, scale-bounce animation
    * Vibration Toggle: Phone vibrate icon (28dp, 2.5dp stroke), active #007AFF, inactive #8E8E93, scale-bounce animation  
    * Undo: Horizontal minus line (32dp, 3dp stroke), #007AFF color, scale-press animation
    * Reset: Circular refresh arrow (36dp, 2.5dp stroke), clockwise rotation, #007AFF color, 360° rotate animation
    * Rate App: Star outline (36dp, 2.5dp stroke), #007AFF color, no fill, scale-bounce animation
  - Implement button state management with Provider pattern, visual active/inactive states with smooth color transitions
  - Add premium haptic feedback (light impact) for all button interactions with 50ms delay
  - Create smooth button animations: scale to 1.15x on tap with spring physics (tension 300, friction 10)
  - Connect buttons to counter logic, settings provider, and app store rating functionality
  - Ensure buttons maintain iOS-style spacing and alignment with pixel-perfect positioning
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 1.3_

- [x] 6. Create stunning home screen layout with premium iOS navigation






  - Build HomeScreen widget with perfect vertical layout: SafeArea, Column with MainAxisAlignment.center, 20dp horizontal padding, 40dp vertical padding
  - Position ActionBar at top with 60dp margin from safe area, ensuring perfect center alignment
  - Place CircularCounter component 100dp below action bar with precise center positioning
  - Add Tasbeeh name display 40dp below counter: SF Pro Display medium 500 weight, 24pt size, 0.5 letter spacing, center aligned, max width 300dp with ellipsis truncation
  - Apply dynamic text color: black 80% opacity (light mode), white 80% opacity (dark mode)
  - Create floating navigation bar with premium iOS aesthetics:
    * Pill-shaped container (280x70dp, 35dp border radius) positioned 30dp from bottom center
    * Frosted glass background: white/dark (#FFFFFF/#1C1C1E) with 95% opacity and backdrop blur effect
    * Subtle border: 0.5dp width with 10% opacity (#00000010 light, #FFFFFF10 dark)
    * Premium shadow: #00000020 color, 20dp blur radius, 8dp y-offset for floating effect
  - Build three navigation buttons with perfect spacing (50dp between centers):
    * Home: House icon (28dp), active #007AFF, inactive #8E8E93, currently active state
    * Manage: Plus circle icon (32dp), active #007AFF, inactive #8E8E93
    * Stats: Bar chart icon (28dp), active #007AFF, inactive #8E8E93
  - Implement smooth navigation with CupertinoPageRoute transitions, fade-color animations (200ms duration)
  - Add navigation state management with Provider to maintain active button highlighting
  - Ensure pixel-perfect alignment and spacing matching iOS design guidelines
  - Create responsive layout that adapts to different screen sizes while maintaining proportions
  - _Requirements: 5.1, 5.2, 7.2, 10.4_

- [ ] 7. Implement stunning Tasbeeh management with premium iOS interface
  - Create ManageTasbeehScreen with elegant iOS-style layout:
    * CupertinoNavigationBar with large title "Manage Tasbeehs" and iOS-style back button
    * Grouped list view with rounded corners, proper spacing (16dp margins), and subtle shadows
    * Section headers with iOS-style typography and proper spacing
  - Build beautiful Tasbeeh list items with premium design:
    * Card-style containers with rounded corners (12dp radius) and subtle elevation
    * Leading icon with Islamic calligraphy or geometric patterns
    * Primary text: Tasbeeh name with SF Pro Display medium weight, 18pt size
    * Secondary text: Target count or "Unlimited" with gray color, 14pt size
    * Trailing elements: current count badge and selection checkmark
    * Active state highlighting with iOS-style blue accent and smooth transitions
  - Create stunning forms for Tasbeeh creation/editing:
    * Modal presentation with iOS-style slide-up animation
    * CupertinoTextField with proper styling, placeholders, and validation
    * Segmented control for count limit options (Unlimited, 33, 99, Custom)
    * Custom number picker with iOS-style wheel selector for target counts
    * Form validation with real-time feedback and error states
    * Save/Cancel buttons with proper iOS styling and haptic feedback
  - Implement smooth selection logic with visual feedback:
    * Animated checkmarks with scale and fade transitions
    * Selected item highlighting with iOS-style blue background
    * Smooth list reordering with drag handles and animations
  - Add comprehensive default Tasbeehs with beautiful presentation:
    * "Sallallahu Alayhi Wasallam" (unlimited) - marked as default with special icon
    * "SubhanAllah" (33 count) with Arabic text and translation
    * "Allahu Akbar" (33 count) with proper typography
    * "Alhamdulillah" (33 count) with elegant styling
    * "La ilaha illa Allah" (100 count) with premium presentation
  - Create elegant delete functionality:
    * iOS-style swipe-to-delete with red action button
    * Confirmation dialog with CupertinoAlertDialog styling
    * Smooth removal animation with fade and scale effects
    * Protection for default Tasbeehs with appropriate user feedback
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.3_

- [ ] 8. Build statistics and analytics system
  - Create StatsProvider for managing statistics data and calculations
  - Implement real-time count aggregation across all Tasbeehs
  - Build time-based data grouping (daily, weekly, monthly, yearly)
  - Calculate percentage distributions for pie chart visualization
  - Create StatsScreen with total counts display and chart containers
  - _Requirements: 6.1, 6.4, 6.5_

- [ ] 9. Implement stunning data visualization with premium iOS-style charts
  - Integrate fl_chart package with custom styling for iOS aesthetic
  - Create beautiful bar chart component with premium design:
    * Segmented control for time periods (Week/Month/Year) with iOS-style selection animation
    * Gradient bar fills with iOS-style colors (#007AFF to #5AC8FA)
    * Smooth bar animations with staggered entrance effects (100ms delays between bars)
    * Interactive tooltips with rounded corners, shadows, and fade animations
    * Grid lines with subtle gray color and proper spacing
    * Axis labels with SF Pro Display font and appropriate sizing
    * Touch interactions with haptic feedback and highlight animations
  - Build elegant pie chart with premium visual design:
    * Smooth gradient segments with iOS-style color palette
    * Interactive segment selection with scale and glow effects
    * Animated percentage labels with fade-in transitions
    * Center hole with total count display and elegant typography
    * Legend with colored indicators and proper text alignment
    * Touch gestures for segment highlighting with haptic feedback
  - Implement sophisticated chart data preparation:
    * Time-based aggregation with proper date formatting
    * Percentage calculations with decimal precision and rounding
    * Data smoothing for better visual representation
    * Empty state handling with elegant placeholder graphics
    * Real-time data updates with smooth transition animations
  - Add premium interactive features:
    * Zoom and pan gestures for detailed data exploration
    * Crosshair indicators with precise value display
    * Smooth scrolling between time periods with momentum
    * Loading animations with iOS-style activity indicators
    * Error states with retry functionality and user-friendly messages
  - Create responsive chart layouts:
    * Adaptive sizing for different screen dimensions
    * Proper spacing and margins following iOS design guidelines
    * Landscape orientation support with optimized layouts
    * Accessibility support with VoiceOver descriptions for chart data
  - _Requirements: 6.2, 6.3_

- [ ] 10. Add audio and haptic feedback systems
  - Implement audio service for counting sounds with volume control
  - Create haptic feedback service with different intensity levels (light, medium, heavy)
  - Add sound effects for counter taps, round completion, and button interactions
  - Integrate feedback systems with user preference settings
  - Implement feedback for round completion with celebration effects
  - _Requirements: 1.3, 1.4, 3.1, 3.2_

- [ ] 11. Implement premium theme system and comprehensive accessibility
  - Create ThemeProvider with automatic system preference detection using MediaQuery.platformBrightnessOf
  - Build comprehensive CupertinoThemeData with iOS-style color schemes:
    * Light mode: primary #007AFF, background #F2F2F7, surface #FFFFFF, text primary #000000, text secondary #8E8E93
    * Dark mode: primary #007AFF, background #000000, surface #1C1C1E, text primary #FFFFFF, text secondary #98989D
  - Implement smooth theme transitions with AnimatedTheme widget and 300ms duration curves
  - Create typography system with SF Pro Display font family (fallback: Roboto):
    * Light weight 300 for large numbers, Regular 400 for body text, Medium 500 for labels, Semibold 600 for headers
    * Proper letter spacing: -2 for large counters, 0 for body, 0.5 for labels
  - Add comprehensive semantic labels for screen readers:
    * Counter: "Current count {number}, tap to increment"
    * Action buttons: "Sound toggle, currently {on/off}", "Vibration toggle", "Undo last count", "Reset counter", "Rate this app"
    * Navigation: "Home screen", "Manage Tasbeehs", "Statistics"
  - Implement VoiceOver/TalkBack support with proper focus management and announcements
  - Ensure all interactive elements meet 48dp minimum touch target requirement with proper padding
  - Create high contrast mode compatibility with increased color contrast ratios (4.5:1 minimum)
  - Build responsive design system with breakpoints: small (<360dp), medium (360-480dp), large (>480dp)
  - Implement dynamic scaling for counter diameter, font sizes, and spacing based on screen size
  - Add color-blind friendly design with shape and text indicators alongside color coding
  - Create accessibility testing utilities and validation methods
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 10.4_

- [ ] 12. Integrate Firebase services
  - Set up Firebase Cloud Messaging for push notifications
  - Implement notification scheduling and delivery system
  - Add Firebase Analytics tracking for user behavior and app performance
  - Create crash reporting and error logging functionality
  - Implement privacy controls and opt-out options for analytics
  - _Requirements: 8.1, 8.2, 8.3, 9.1, 9.2, 9.5_

- [ ] 13. Add settings and preferences management
  - Create SettingsProvider for managing user preferences
  - Implement settings persistence using SharedPreferences
  - Build settings screen for notification configuration and theme selection
  - Add preference validation and default value handling
  - Create settings import/export functionality for backup
  - _Requirements: 8.4, 8.5, 3.1, 3.2, 7.1_

- [ ] 14. Implement app initialization and lifecycle management
  - Create app initialization sequence with database setup and default data loading
  - Implement proper app lifecycle handling for background/foreground transitions
  - Add state restoration after app termination or crashes
  - Create splash screen with app branding and loading indicators
  - Implement automatic default Tasbeeh selection on app launch
  - _Requirements: 4.1, 5.5, 10.5_

- [ ] 15. Add premium animations and stunning visual polish for iOS-level quality
  - Implement buttery-smooth counter increment animations:
    * Scale-pulse effect: scale from 1.0 to 1.1 and back with 150ms ease-out curve
    * Number change animation with fade transition for seamless count updates
    * Haptic feedback synchronization with visual animation timing
  - Create mesmerizing progress ring animations:
    * Smooth arc progression with 300ms ease-out curve and spring physics
    * Progress dots fade-in animation (200ms) when segments complete
    * Progress handle smooth movement along arc path with momentum
    * Infinite scroll mode with continuous rotation for unlimited Tasbeehs
  - Build premium button press animations:
    * Scale-bounce: scale to 1.15x with spring physics (tension 300, friction 10)
    * Scale-press: scale to 0.9x with 100ms ease-in-out for immediate feedback
    * Color transitions: 200ms fade between active/inactive states
    * Rotation animation for reset button: smooth 360° clockwise rotation in 400ms
  - Implement celebration animations for round completion:
    * Counter scale-bounce with increased magnitude (1.2x scale)
    * Progress ring completion flash with color pulse effect
    * Round number appearance with scale-bounce and fade-in
    * Confetti-like particle effects around counter (optional premium touch)
    * Success haptic pattern with medium impact feedback
  - Create elegant screen transition animations:
    * CupertinoPageRoute with iOS-style slide transitions
    * Navigation bar button state changes with smooth color fades
    * Loading states with iOS-style activity indicators
    * Splash screen with app logo fade-in and scale animation
  - Add micro-interactions for premium feel:
    * Button hover states with subtle scale changes (1.05x)
    * Touch ripple effects with iOS-style feedback
    * Smooth keyboard appearance/dismissal animations
    * Pull-to-refresh animations with iOS-style indicators
  - Implement performance-optimized animations:
    * Use Transform widgets for GPU-accelerated animations
    * Proper animation controller disposal to prevent memory leaks
    * 60fps maintenance with frame rate monitoring
    * Reduced motion support for accessibility preferences
  - _Requirements: 7.2, 10.2, 10.3_

- [ ] 16. Write comprehensive unit tests
  - Create unit tests for counter logic including increment, decrement, reset, and round completion
  - Write tests for data models validation and business rules
  - Add tests for statistics calculations and data aggregation
  - Test state management providers and their state changes
  - Create tests for utility functions and helper methods
  - _Requirements: All requirements validation_

- [ ] 17. Implement widget and integration tests
  - Write widget tests for counter component interactions and visual updates
  - Create tests for action bar button functionality and state changes
  - Add integration tests for database operations and data persistence
  - Test Firebase integration including FCM and analytics
  - Create tests for settings management and theme switching
  - _Requirements: All requirements validation_

- [ ] 18. Add performance monitoring and optimization
  - Implement frame rate monitoring during animations and interactions
  - Add memory usage tracking and leak detection
  - Create performance benchmarks for app startup and screen transitions
  - Implement battery usage optimization for background processes
  - Add automated performance regression testing
  - _Requirements: 10.1, 10.2, 10.3, 10.5_