import SwiftUI

struct VoiceInputView: View {
    let onSubmit: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent)

            Text("Tap below to speak or type")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            // On watchOS, tapping TextField opens system dictation/scribble UI
            TextField("Message...", text: $inputText)
                .font(.system(size: 14))

            Button {
                guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSubmit(inputText.trimmingCharacters(in: .whitespacesAndNewlines))
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 16))
                    Text("Send")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.buttonMinHeight)
                .foregroundStyle(.white)
                .background(inputText.isEmpty ? Theme.surfaceLight : Theme.approve)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(Theme.spacingSM)
    }
}
