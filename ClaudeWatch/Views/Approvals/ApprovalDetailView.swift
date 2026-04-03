import SwiftUI

struct ApprovalDetailView: View {
    let request: ApprovalRequest
    @ObservedObject var viewModel: ApprovalsViewModel
    @Environment(\.dismiss) private var dismiss

    private let quickResponses = [
        "LGTM, ship it",
        "Needs more tests",
        "Wait for QA",
        "Let's discuss tomorrow",
        "Approved with changes"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingMD) {
                // Header
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    HStack(spacing: 6) {
                        StatusBadge(status: request.status)
                        if request.isPermission {
                            HStack(spacing: 3) {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 10))
                                Text("Permission")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(Theme.accent)
                        }
                    }
                    Text(request.title)
                        .font(.system(size: 16, weight: .semibold))
                    if let tool = request.tool {
                        Text(tool)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                    }
                    Text(request.sender)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                // Tool input (for permission requests)
                if let toolInput = request.toolInput {
                    Text(toolInput)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(Theme.spacingSM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                }

                // Body
                Text(request.body)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(Theme.spacingMD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))

                if request.status == .pending {
                    // Action buttons
                    ActionButton(
                        title: "Approve",
                        icon: "checkmark",
                        color: Theme.approve
                    ) {
                        viewModel.approve(request)
                        dismiss()
                    }

                    ActionButton(
                        title: "Reject",
                        icon: "xmark",
                        color: Theme.reject
                    ) {
                        viewModel.reject(request)
                        dismiss()
                    }

                    // Quick responses
                    Divider()
                        .background(Theme.surfaceLight)

                    Text("Reply & Approve")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)

                    ForEach(quickResponses, id: \.self) { reply in
                        QuickReplyChip(text: reply) {
                            viewModel.approve(request, reply: reply)
                            dismiss()
                        }
                    }
                } else if let reply = request.selectedReply {
                    VStack(alignment: .leading, spacing: Theme.spacingXS) {
                        Text("Reply")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                        Text(reply)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .padding(.horizontal, Theme.spacingSM)
        }
    }
}
