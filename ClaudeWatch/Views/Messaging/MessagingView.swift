import SwiftUI

struct MessagingView: View {
    @Bindable var viewModel: MessagingViewModel
    @State private var showingVoiceInput = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Theme.spacingSM) {
                        if viewModel.messages.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .tint(Theme.accent)
                                    Text("Thinking...")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Theme.spacingSM)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.reject)
                                .padding(Theme.spacingSM)
                        }

                        // Quick replies
                        quickRepliesSection
                    }
                    .padding(.horizontal, Theme.spacingXS)
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        withAnimation(.spring(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .navigationTitle("Claude")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingVoiceInput = true
                    } label: {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingVoiceInput) {
                VoiceInputView { text in
                    viewModel.sendMessage(text)
                    showingVoiceInput = false
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 32))
                .foregroundStyle(Theme.accent.opacity(0.5))
            Text("Ask Claude")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Text("Tap a quick reply or use voice")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.spacingXL)
    }

    private var quickRepliesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            if !viewModel.isLoading {
                ForEach(viewModel.quickReplies, id: \.self) { reply in
                    QuickReplyChip(text: reply) {
                        viewModel.sendQuickReply(reply)
                    }
                }
            }
        }
        .padding(.top, Theme.spacingSM)
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 20) }

            Text(message.content)
                .font(.system(size: 13))
                .foregroundStyle(isUser ? .white : Theme.textPrimary)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(isUser ? Theme.accent : Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))

            if !isUser { Spacer(minLength: 20) }
        }
    }
}
