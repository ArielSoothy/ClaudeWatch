import SwiftUI

struct MessagingView: View {
    @ObservedObject var viewModel: MessagingViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingSM) {
                    if viewModel.messages.isEmpty {
                        VStack(spacing: Theme.spacingMD) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.accent.opacity(0.5))
                            Text("Ask Claude")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Theme.spacingXL)
                    } else {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.role == .user { Spacer(minLength: 20) }
                                Text(message.content)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Theme.spacingMD)
                                    .padding(.vertical, Theme.spacingSM)
                                    .background(message.role == .user ? Theme.accent : Theme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
                                if message.role != .user { Spacer(minLength: 20) }
                            }
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Theme.accent)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.reject)
                    }

                    // Quick replies
                    if !viewModel.isLoading {
                        ForEach(viewModel.quickReplies, id: \.self) { reply in
                            QuickReplyChip(text: reply) {
                                viewModel.sendQuickReply(reply)
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.spacingXS)
            }
            .navigationTitle("Claude")
        }
    }
}
