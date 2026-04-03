import SwiftUI

struct ApprovalsListView: View {
    @ObservedObject var viewModel: ApprovalsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.requests.isEmpty {
                    emptyState
                } else {
                    List {
                        if !viewModel.pendingRequests.isEmpty {
                            Section {
                                ForEach(viewModel.pendingRequests) { request in
                                    NavigationLink(value: request.id) {
                                        ApprovalRow(request: request)
                                    }
                                }
                            } header: {
                                Text("Pending (\(viewModel.pendingRequests.count))")
                            }
                        }

                        if !viewModel.completedRequests.isEmpty {
                            Section {
                                ForEach(viewModel.completedRequests) { request in
                                    ApprovalRow(request: request)
                                }
                            } header: {
                                HStack {
                                    Text("Done")
                                    Spacer()
                                    if !viewModel.completedRequests.isEmpty {
                                        Button("Clear") {
                                            viewModel.clearCompleted()
                                        }
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.accent)
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: UUID.self) { id in
                        if let request = viewModel.requests.first(where: { $0.id == id }) {
                            ApprovalDetailView(request: request, viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("Approvals")
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(Theme.approve.opacity(0.5))
            Text("All clear")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Text("No pending approvals")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Row

private struct ApprovalRow: View {
    let request: ApprovalRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if request.isPermission {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.accent)
                }
                Text(request.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                Spacer()
                StatusBadge(status: request.status)
            }
            HStack(spacing: 4) {
                if let tool = request.tool {
                    Text(tool)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }
                Text(request.sender)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }
}
