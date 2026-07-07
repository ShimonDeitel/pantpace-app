import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var draft = BreathReading()
    @State private var editing: BreathReading?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            row(entry)
                                .listRowBackground(Theme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    draft = entry
                                    editing = entry
                                    showingAdd = true
                                }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Pantpace")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            draft = BreathReading()
                            editing = nil
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .tint(Theme.accent)
            .sheet(isPresented: $showingAdd) {
                addSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: Theme.glyph)
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("No entries yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func row(_ entry: BreathReading) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.petName.isEmpty ? "Untitled" : entry.petName)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.textPrimary)
            Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("Pet Name", text: $draft.petName)
                    .accessibilityIdentifier("field_petName")
                TextField("Breaths Per Minute", value: $draft.breathCount, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("field_breathCount")
                DatePicker("Time Taken", selection: $draft.takenAt)
                    .accessibilityIdentifier("field_takenAt")
                TextField("Notes", text: $draft.notes)
                    .accessibilityIdentifier("field_notes")
            }
            .navigationTitle(editing == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAdd = false
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let editing {
                            var updated = draft
                            updated = BreathReading(id: editing.id, createdAt: editing.createdAt, petName: draft.petName, breathCount: draft.breathCount, takenAt: draft.takenAt, notes: draft.notes)
                            store.update(updated)
                        } else {
                            store.add(draft)
                        }
                        showingAdd = false
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(PurchaseManager())
}
