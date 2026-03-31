import UserNotifications

enum NotificationService {
    static let approvalCategory = "APPROVAL_REQUEST"
    static let messageCategory = "QUICK_MESSAGE"

    static func registerCategories() {
        let approveAction = UNNotificationAction(
            identifier: "APPROVE",
            title: "Approve",
            options: [.foreground]
        )
        let rejectAction = UNNotificationAction(
            identifier: "REJECT",
            title: "Reject",
            options: [.destructive, .foreground]
        )
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY",
            title: "Reply",
            options: [.foreground],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type a reply..."
        )

        let approvalCategory = UNNotificationCategory(
            identifier: approvalCategory,
            actions: [approveAction, rejectAction, replyAction],
            intentIdentifiers: []
        )

        let messageCategory = UNNotificationCategory(
            identifier: messageCategory,
            actions: [replyAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            approvalCategory,
            messageCategory
        ])
    }

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleLocalApproval(_ request: ApprovalRequest, delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = request.sender
        content.body = request.title
        content.categoryIdentifier = approvalCategory
        content.sound = .default
        content.userInfo = [
            "requestId": request.id.uuidString,
            "title": request.title,
            "body": request.body,
            "sender": request.sender
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let notification = UNNotificationRequest(
            identifier: request.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(notification)
    }
}
