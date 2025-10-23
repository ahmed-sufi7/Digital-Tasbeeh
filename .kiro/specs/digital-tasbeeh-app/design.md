# Design Document

## Overview

The Digital Tasbeeh Mobile App is architected as a Flutter-based Android application using the Cupertino design system to provide an iOS-style aesthetic. The app follows a clean architecture pattern with clear separation between presentation, business logic, and data layers. The design emphasizes simplicity, performance, and spiritual focus while providing comprehensive dhikr counting and tracking capabilities.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Home Screen    │  Manage Screen   │   Stats Screen         │
│  - Counter UI   │  - Tasbeeh List  │   - Charts & Graphs    │
│  - Action Bar   │  - CRUD Forms    │   - Progress Tracking  │
│  - Navigation   │  - Selection     │   - Data Visualization │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Counter Logic  │  Tasbeeh Mgmt   │   Stats Engine         │
│  - Increment    │  - CRUD Ops     │   - Aggregation        │
│  - Progress     │  - Validation   │   - Time-based Views   │
│  - Round Mgmt   │  - Defaults     │   - Chart Data Prep    │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  Local Storage  │  Firebase       │   Preferences          │
│  - SQLite DB    │  - FCM          │   - Settings           │
│  - Tasbeeh Data │  - Analytics    │   - Theme              │
│  - Count History│  - Crash Report │   - Notifications      │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Framework**: Flutter 3.x with Dart
- **UI Design**: Cupertino widgets for iOS-style aesthetics
- **State Management**: Provider pattern with ChangeNotifier
- **Local Database**: SQLite with sqflite package
- **Preferences**: SharedPreferences for app settings
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Analytics**: Firebase Analytics
- **Charts**: fl_chart package for statistics visualization
- **Animations**: Flutter's built-in animation framework

## Components and Interfaces

### Core Components

#### 1. Counter Component
The central UI element responsible for dhikr counting with visual feedback.

**Key Features:**
- Circular design with 380dp diameter (responsive scaling)
- Tap-to-increment functionality with full-area touch detection
- Animated progress ring with smooth 300ms transitions
- Multi-layered visual hierarchy (background track, progress arc, inner circle)
- Dynamic text sizing based on count magnitude
- Haptic and audio feedback integration

**Visual Elements:**
- Outer background ring (14dp stroke, gray color)
- Animated progress ring (14dp stroke, blue #007AFF)
- Progress dots (33 evenly distributed, 6dp diameter)
- Progress handle (20dp circular knob at arc end)
- Inner white/dark circle (352dp diameter with shadow)
- Tick marks (100 radial lines, 12dp length)

#### 2. Action Bar Component
Horizontal control bar with five interactive buttons.

**Buttons:**
- Sound Toggle: Volume icon, toggles audio feedback
- Vibration Toggle: Phone icon, toggles haptic feedback  
- Undo: Minus icon, decrements count by one
- Reset: Circular arrow icon, resets count to zero
- Rate App: Star icon, opens app store rating

**Design Specifications:**
- Pill-shaped container (430x80dp, 40dp border radius)
- Semi-transparent background with blur effect
- 24dp spacing between buttons, 60dp touch targets
- Scale animations on tap with haptic feedback

#### 3. Navigation Bar Component
Floating bottom navigation with three main sections.

**Structure:**
- Pill-shaped container (280x70dp, 35dp border radius)
- Frosted glass background with border
- Three buttons: Home, Manage (+), Stats
- Active state indication with color changes
- Smooth fade transitions between states

#### 4. Statistics Engine
Comprehensive analytics system for tracking dhikr progress.

**Data Aggregation:**
- Real-time count accumulation across all Tasbeehs
- Time-based grouping (daily, weekly, monthly, yearly)
- Percentage distribution calculations
- Historical trend analysis

**Visualization Components:**
- Bar charts for temporal progress (Week/Month/Year tabs)
- Pie charts for Tasbeeh distribution with percentages
- Total count displays with real-time updates
- Progress indicators and achievement tracking

### Data Models

#### Tasbeeh Model
```dart
class Tasbeeh {
  final String id;
  final String name;
  final int? targetCount;  // null for unlimited
  final int currentCount;
  final int roundNumber;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isDefault;
}
```

#### Count History Model
```dart
class CountHistory {
  final String id;
  final String tasbeehId;
  final int count;
  final DateTime timestamp;
  final int roundNumber;
}
```

#### App Settings Model
```dart
class AppSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final List<NotificationSchedule> reminderSchedules;
}
```

### State Management Architecture

#### Counter State
- Current active Tasbeeh
- Real-time count value
- Progress percentage calculation
- Round completion status
- Animation states

#### Settings State
- Audio/haptic preferences
- Theme selection
- Notification configuration
- User preferences persistence

#### Statistics State
- Aggregated count data
- Chart data preparation
- Time range filtering
- Real-time updates

## Data Models

### Database Schema

#### Tasbeehs Table
```sql
CREATE TABLE tasbeehs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_count INTEGER,
  current_count INTEGER DEFAULT 0,
  round_number INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_used_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_default BOOLEAN DEFAULT FALSE
);
```

#### Count History Table
```sql
CREATE TABLE count_history (
  id TEXT PRIMARY KEY,
  tasbeeh_id TEXT NOT NULL,
  count INTEGER NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  round_number INTEGER DEFAULT 1,
  FOREIGN KEY (tasbeeh_id) REFERENCES tasbeehs (id)
);
```

#### Settings Table
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Data Flow

1. **Counter Increment Flow:**
   - User taps counter → Increment business logic → Update local state
   - Save to database → Update statistics → Trigger UI animations
   - Check round completion → Handle progress ring updates

2. **Statistics Update Flow:**
   - Count increment → Insert history record → Aggregate calculations
   - Update chart data → Refresh UI components → Persist changes

3. **Tasbeeh Management Flow:**
   - CRUD operations → Validation logic → Database updates
   - State synchronization → UI refresh → Settings persistence

## Error Handling

### Error Categories and Strategies

#### 1. Database Errors
- **Connection failures**: Retry mechanism with exponential backoff
- **Constraint violations**: User-friendly validation messages
- **Corruption issues**: Database repair and backup restoration
- **Migration errors**: Rollback to previous schema version

#### 2. Network Errors (Firebase)
- **FCM delivery failures**: Queue notifications for retry
- **Analytics upload issues**: Local caching with batch upload
- **Connection timeouts**: Graceful degradation to offline mode
- **Authentication errors**: Re-authentication flow

#### 3. UI/Animation Errors
- **Performance issues**: Frame rate monitoring and optimization
- **Memory leaks**: Proper disposal of animation controllers
- **State inconsistencies**: State validation and recovery
- **Touch responsiveness**: Debouncing and gesture conflict resolution

#### 4. Data Validation Errors
- **Invalid count values**: Range validation and sanitization
- **Malformed Tasbeeh data**: Schema validation and defaults
- **Settings corruption**: Reset to factory defaults with user confirmation
- **Import/export errors**: Data integrity checks and user feedback

### Error Recovery Mechanisms

1. **Graceful Degradation**: Core counting functionality remains available even when secondary features fail
2. **Data Backup**: Automatic local backups before critical operations
3. **User Feedback**: Clear error messages with actionable recovery steps
4. **Logging**: Comprehensive error logging for debugging and analytics
5. **Crash Recovery**: State restoration after unexpected app termination

## Testing Strategy

### Unit Testing
- **Counter Logic**: Increment, decrement, reset, round completion
- **Data Models**: Validation, serialization, business rules
- **Utilities**: Date formatting, calculations, validators
- **State Management**: Provider state changes and notifications

### Widget Testing
- **Counter Component**: Tap interactions, visual updates, animations
- **Action Bar**: Button functionality, state changes, feedback
- **Navigation**: Screen transitions, state persistence
- **Forms**: Input validation, submission, error handling

### Integration Testing
- **Database Operations**: CRUD operations, migrations, transactions
- **Firebase Integration**: FCM delivery, analytics tracking
- **Settings Persistence**: Theme changes, preference updates
- **Statistics Calculation**: Data aggregation, chart generation

### Performance Testing
- **Animation Smoothness**: 60fps maintenance during interactions
- **Memory Usage**: Leak detection and optimization
- **Battery Impact**: Background processing efficiency
- **Startup Time**: App launch performance under 2 seconds

### Accessibility Testing
- **Screen Reader**: VoiceOver/TalkBack compatibility
- **High Contrast**: Visual accessibility in different modes
- **Touch Targets**: Minimum 48dp interactive areas
- **Color Blindness**: Color-independent information conveyance

### Device Testing Matrix
- **Screen Sizes**: Small (< 360dp), Medium (360-480dp), Large (> 480dp)
- **Android Versions**: API 21+ compatibility
- **Performance Tiers**: Low-end, mid-range, high-end devices
- **Orientations**: Portrait and landscape support

### Automated Testing Pipeline
1. **Pre-commit Hooks**: Linting, formatting, basic unit tests
2. **CI/CD Integration**: Full test suite on pull requests
3. **Performance Monitoring**: Automated performance regression detection
4. **Accessibility Audits**: Automated accessibility compliance checks
5. **Device Farm Testing**: Multi-device compatibility validation

### Test Data Management
- **Mock Data**: Realistic test datasets for various scenarios
- **Test Isolation**: Independent test environments
- **Data Cleanup**: Automated test data cleanup procedures
- **Edge Cases**: Boundary value testing and error conditions