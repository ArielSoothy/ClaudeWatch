import SwiftUI

struct StatusBadge: View {
    let status: ApprovalRequest.Status

    private var color: Color {
        switch status {
        case .pending: Theme.accent
        case .approved: Theme.approve
        case .rejected: Theme.reject
        }
    }

    private var icon: String {
        switch status {
        case .pending: "clock.fill"
        case .approved: "checkmark.circle.fill"
        case .rejected: "xmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(status.rawValue.capitalized)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}
