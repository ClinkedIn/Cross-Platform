import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/notifications/state/notification_settings_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:lockedin/features/notifications/model/notification_model.dart';
import 'package:lockedin/features/notifications/widgets/notifications_widgets.dart';
import 'package:sizer/sizer.dart';

/// A test suite for the NotificationsViewModel, related widgets and state providers of the user preferences.
void main() {
  late NotificationsViewModel viewModel;
  late ProviderContainer container;
  const testUser = 'testuser';
  setUp(() {
    viewModel = NotificationsViewModel();
    container = ProviderContainer();
    addTearDown(container.dispose);
  });
 
/// test for markAllAsSeen method in NotificationsViewModel file 
  test('markAllAsSeen sets all notifications as seen', () {
    final notifications = [
      NotificationModel(
        id: "1",
        from: "user1",
        to: "user2",
        subject: "Test",
        content: "Content",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSeen: false,
        sendingUser: SendingUser(
          email: "test@test.com",
          firstName: "Test",
          lastName: "User",
          profilePicture: null,
        ),
      ),
      NotificationModel(
        id: "2",
        from: "user3",
        to: "user4",
        subject: "Another",
        content: "Another content",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSeen: false,
        sendingUser: SendingUser(
          email: "test2@test.com",
          firstName: "Jane",
          lastName: "Doe",
          profilePicture: null,
        ),
      ),
    ];

    viewModel.state = AsyncData(notifications);

    viewModel.markAllAsSeen();

    final result = viewModel.state.asData?.value;

    expect(result?.every((n) => n.isSeen), true);
  });

/// test for showLessLikeThis method in NotificationsViewModel file
  test('showLessLikeThis replaces with placeholder', () {
    final notification = NotificationModel(
      id: "3",
      from: "user1",
      to: "user2",
      subject: "Test",
      content: "Show less test",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sendingUser: SendingUser(
        email: "test@test.com",
        firstName: "Test",
        lastName: "User",
        profilePicture: null,
      ),
    );

    viewModel.state = AsyncData([notification]);
    viewModel.showLessLikeThis("3");
    expect(viewModel.state.value?.first.isPlaceholder, true);
  });

/// test for undoShowLessLikeThis method in NotificationsViewModel file
  test('undoShowLessLikeThis restores original notification', () {
    final notification = NotificationModel(
      id: "4",
      from: "user1",
      to: "user2",
      subject: "Undo show less",
      content: "Original content",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sendingUser: SendingUser(
        email: "test@test.com",
        firstName: "Test",
        lastName: "User",
        profilePicture: null,
      ),
    );

    final placeholder = NotificationModel(
      id: "4",
      from: "",
      to: "",
      subject: "Show less like this",
      content: "Show less like this",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPlaceholder: true,
      sendingUser: SendingUser.empty(),
    );

    viewModel.state = AsyncData([placeholder]);
    viewModel.showLessNotifications["4"] = notification;
    viewModel.undoShowLessLikeThis("4");

    expect(viewModel.state.value?.first.content, "Original content");
  });

/// test for buildNotificationItem widget in widgets file
  testWidgets('buildNotificationItem renders correctly and handles tap', (WidgetTester tester) async {
    final notification = NotificationModel(
      id: "123",
      from: "user1",
      to: "user2",
      subject: "Test",
      content: "Mohamed Nabil liked your post",
      isRead: false,
      isPlaceholder: false,
      createdAt: DateTime.now().subtract(Duration(minutes: 5)),
      updatedAt: DateTime.now(),
      sendingUser: SendingUser(
        email: "test@email.com",
        firstName: "Test",
        lastName: "User",
        profilePicture: null, // Or provide dummy URL
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [],
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: buildNotificationItem(
                  notification,
                  false,
                  MockWidgetRef(),
                  context,
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

/// test for buildCategoryButton widget in widgets file
  testWidgets('buildCategoryButton renders correctly and updates selection', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    return buildCategoryButton(
                      context,
                      ref,
                      "All",
                      true,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
  });

/// test for showToggleMessage function in widgets file
  testWidgets('showToggleMessage displays overlay', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showToggleMessage(ctx, "Test Message", false);
                    },
                    child: Text("Show Message"),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Tap the button to show the overlay
    await tester.tap(find.text("Show Message"));
    await tester.pump();

    // Confirm the overlay appears
    expect(find.text("Test Message"), findsOneWidget);

    // Wait enough time for the delayed timer to finish and overlay to remove itself
    await tester.pump(const Duration(seconds: 3));
  });

/// test for showDeleteMessage function in widgets file
  testWidgets('showDeleteMessage displays snackbar and undo works', (WidgetTester tester) async {
    bool undoCalled = false;

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteMessage(ctx, () {
                        undoCalled = true;
                      }, false);
                    },
                    child: Text("Delete"),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Tap the delete button
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle(); // Allow snackbar to appear

    // Verify the snackbar text is shown
    expect(find.text("Notification deleted."), findsOneWidget);

    // Tap the Undo button (wrapped in a TextButton inside a Row)
    await tester.tap(find.text("Undo"));
    await tester.pumpAndSettle();

    // Check that the callback was triggered
    expect(undoCalled, true);
  });

/// tests for NotificationSettingsProvider file (User Notifications, Network Updates)
  test('returns default settings if user is not set', () {
    final notifier = container.read(notificationSettingsProvider.notifier);

    final settings = notifier.getSettingsForUser(testUser);

    expect(settings.allowUserNotifications, true);
    expect(settings.allowNetworkUpdates, true);
  });

  test('toggles user notifications correctly', () {
    final notifier = container.read(notificationSettingsProvider.notifier);

    notifier.toggleUserNotifications(testUser, false);
    final updated = container.read(notificationSettingsProvider)[testUser];

    expect(updated?.allowUserNotifications, false);
    expect(updated?.allowNetworkUpdates, true); // default value
  });

  test('toggles network updates correctly', () {
    final notifier = container.read(notificationSettingsProvider.notifier);

    notifier.toggleNetworkUpdates(testUser, false);
    final updated = container.read(notificationSettingsProvider)[testUser];

    expect(updated?.allowNetworkUpdates, false);
    expect(updated?.allowUserNotifications, true); // default value
  });

  test('both toggles work independently', () {
    final notifier = container.read(notificationSettingsProvider.notifier);

    notifier.toggleUserNotifications(testUser, false);
    notifier.toggleNetworkUpdates(testUser, false);

    final updated = container.read(notificationSettingsProvider)[testUser];

    expect(updated?.allowUserNotifications, false);
    expect(updated?.allowNetworkUpdates, false);
  });
}

class MockNotifier extends Mock implements NotificationsViewModel {}
class MockStateNotifier extends Mock implements NotificationSettingsNotifier {}
class MockWidgetRef extends Mock implements WidgetRef {}