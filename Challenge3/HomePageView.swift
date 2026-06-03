import SwiftUI

// MARK: - Models

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let image: String?
}

struct MenuSection: Identifiable {
    let id = UUID()
    let dateLabel: String
    var items: [MenuItem]
}

// MARK: - Sample Data

let sampleSections: [MenuSection] = [
    MenuSection(
        dateLabel: "Monday (May, 25th)",
        items: [
            MenuItem(title: "Vlog A Day in My Life", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Street Food Bali", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Hidden Gems Ubud", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Sunset Seminyak", date: "Monday (May, 25th)", image: nil),
        ]
    ),
    MenuSection(
        dateLabel: "Monday (May, 18th)",
        items: [
            MenuItem(title: "Morning Routine", date: "Monday (May, 18th)", image: nil),
            MenuItem(title: "Cafe Hopping Bali", date: "Monday (May, 18th)", image: nil),
        ]
    )
]

// MARK: - App Colors

extension Color {
    static let brandBlue             = Color("BrandBlue")
    static let brandOrange           = Color("BrandOrange")
    static let secondaryBlue         = Color("SecondaryBlue")
    static let secondaryOrange       = Color("SecondaryOrange")
    static let pageBackground        = Color("PageBackground")
    static let cardSurface           = Color("CardSurface")
    static let musicSectionBackground = Color("MusicSectionBackground")
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case defaultSort = "Default"
    case dateEdited  = "Date Edited"
    case dateCreated = "Date Created"
    case title       = "Title"
}


extension UIWindowScene {
    static var cornerRadius: CGFloat {
           UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .keyWindow?
                .screen
                .value(forKey: "displayCornerRadius") as? CGFloat ?? 44
    }
}
// MARK: - Menu Card

struct MenuCard: View {
    let item: MenuItem
    var isSelecting: Bool = false
    var isSelected: Bool  = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack(alignment: .topLeading) {
                // Thumbnail placeholder
                ZStack {
                    Color.cardSurface
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color(.systemGray4))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)

                // Checkbox saat mode select
                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.brandBlue : Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .padding(8)
                }
            }

            // Label
            ZStack(alignment: .leading) {
                Color.brandBlue
                Text(item.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.label).opacity(0.06), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.brandBlue : Color.clear, lineWidth: 2.5)
        )
    }
}

// MARK: - Profile Screen

struct ProfileScreen: View {
    var body: some View {
        List {
            // Avatar section
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.brandBlue)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Richard")
                            .font(.headline)
                        Text("Content Creator")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Account") {
                Label("Edit Profile", systemImage: "pencil")
                Label("Notifications", systemImage: "bell")
                Label("Privacy", systemImage: "lock")
            }

            Section("App") {
                Label("Help & Support", systemImage: "questionmark.circle")
                Label("About Lumio", systemImage: "info.circle")
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Detail Preview (destination placeholder)

struct MenuDetailView: View {
    let item: MenuItem
    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.brandBlue.opacity(0.25))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundStyle(Color(.systemGray3))
                    )
                    .padding(.horizontal)
                Text(item.title).font(.title2.bold()).padding(.horizontal)
                Text(item.date).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Home Page View

struct HomePageView: View {

    // Data
    @State private var sections: [MenuSection] = sampleSections

    // Filter & Sort
    @State private var sortOption: SortOption = .defaultSort
    @State private var groupByDate = false

    // Select mode
    @State private var isSelecting = false
    @State private var selectedIDs: Set<UUID> = []

    // Search
    @State private var searchText = ""

    // Category filter
    @State private var categories: [String] = ["LinkedIn", "Feeds", "Reels"]
    @State private var selectedCategory: String? = nil
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""

    // Toggle filters
    @State private var filterEdited   = false
    @State private var filterDeadline = false

    // Navigation — add project
    @State private var showNameModal  = false
    @State private var newProjectName = ""
    @State private var goToAddProject = false

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // Sections setelah sort diterapkan
    var sortedSections: [MenuSection] {
        sections.map { section in
            var s = section
            switch sortOption {
            case .defaultSort:  break
            case .dateEdited:   s.items = s.items.sorted { $0.date > $1.date }
            case .dateCreated:  s.items = s.items.sorted { $0.date < $1.date }
            case .title:        s.items = s.items.sorted { $0.title < $1.title }
            }
            return s
        }
    }

    // Sections setelah filter search diterapkan
    var displayedSections: [MenuSection] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return sortedSections }
        return sortedSections.compactMap { section in
            let filtered = section.items.filter { $0.title.lowercased().contains(query) }
            return filtered.isEmpty ? nil : MenuSection(dateLabel: section.dateLabel, items: filtered)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.pageBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hello, Richard")
                                    .font(.largeTitle.bold())
                                Text("Have a nice day !")
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isSelecting {
                                Button("Done") {
                                    withAnimation {
                                        isSelecting = false
                                        selectedIDs.removeAll()
                                    }
                                }
                                .font(.headline)
                                .foregroundStyle(Color.brandBlue)
                            } else {
                                // Hanya tombol profile di kanan atas
                                NavigationLink(destination: ProfileScreen()) {
                                    Circle()
                                        .fill(Color.brandBlue)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.subheadline.bold())
                                                .foregroundStyle(.white)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                        // MARK: Filter bar (di bawah Have a nice day)
                        if !isSelecting {
                            filterBar
                                .padding(.bottom, 20)
                        }

                        // MARK: Konten project
                        ForEach(displayedSections) { section in
                            if !section.items.isEmpty {

                                // Tampilkan label tanggal hanya jika Group By Date aktif
                                if groupByDate {
                                    Text(section.dateLabel)
                                        .font(.title3.bold())
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 12)
                                }

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(section.items) { item in
                                        if isSelecting {
                                            MenuCard(
                                                item: item,
                                                isSelecting: true,
                                                isSelected: selectedIDs.contains(item.id)
                                            )
                                            .onTapGesture { toggleSelection(item.id) }
                                        } else {
                                            NavigationLink(destination: DetailProjectScreen()) {
                                                MenuCard(item: item)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            }
                        }

                        Spacer().frame(height: 100)
                    }
                }

                // MARK: Search bar + FAB
                if !isSelecting {
                    HStack(spacing: 12) {

                        // Search bar
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)

                            TextField("Search projects...", text: $searchText)
                                .font(.subheadline)

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color(.systemGray3))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.cardSurface)
                        .clipShape(Capsule())
                        .shadow(color: Color(.label).opacity(0.08), radius: 4, x: 0, y: 2)

                        // FAB
                        Button {
                            newProjectName = ""
                            showNameModal  = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .glassEffect(.regular.tint(Color.brandOrange.opacity(0.8)), in: .circle)
                        }
                        .accessibilityLabel("Add new project")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }

                // MARK: Bottom bar saat mode select
                if isSelecting {
                    HStack {
                        Text(selectedIDs.isEmpty ? "Select items" : "\(selectedIDs.count) selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            withAnimation { deleteSelected() }
                        } label: {
                            Text("Delete")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 10)
                                .background(selectedIDs.isEmpty ? Color.red.opacity(0.35) : Color.red)
                                .clipShape(Capsule())
                        }
                        .disabled(selectedIDs.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("New Category", isPresented: $showAddCategoryAlert) {
                TextField("e.g. TikTok, YouTube Shorts…", text: $newCategoryName)
                Button("Add") {
                    let name = newCategoryName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty && !categories.contains(name) {
                        categories.append(name)
                    }
                    newCategoryName = ""
                }
                Button("Cancel", role: .cancel) { newCategoryName = "" }
            } message: {
                Text("Enter a content type for your projects.")
            }
            .navigationDestination(isPresented: $goToAddProject) {
                AddProjectScreen(projectName: newProjectName)
            }
            .sheet(isPresented: $showNameModal, onDismiss: {
                if !newProjectName.isEmpty {
                    goToAddProject = true
                }
            }) {
                AddNewProjectView { name in
                    newProjectName = name
                }
                .presentationDetents([.fraction(0.42)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(UIWindowScene.cornerRadius)
                .presentationBackground(Color(.systemBackground).opacity(0.45))
            }
        }
    }

    // MARK: Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                sortPill
                categoryPill

                // Edited — mutual exclusive dengan Deadline
                Button {
                    withAnimation {
                        filterEdited   = !filterEdited
                        filterDeadline = false
                    }
                } label: {
                    pillLabel(icon: nil, text: "Edited", isActive: filterEdited, showChevron: false)
                }

                // Deadline — mutual exclusive dengan Edited
                Button {
                    withAnimation {
                        filterDeadline = !filterDeadline
                        filterEdited   = false
                    }
                } label: {
                    pillLabel(icon: nil, text: "Deadline", isActive: filterDeadline, showChevron: false)
                }

                // Clear all — icon circle, muncul hanya jika ada filter aktif
                if hasActiveFilter {
                    Button {
                        withAnimation { clearAllFilters() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.primary)
                            .frame(width: 42, height: 42)
                            .glassEffect(.regular, in: .circle)
                            .clipShape(Circle())
                            .shadow(color: Color(.label).opacity(0.07), radius: 3, x: 0, y: 1)
                    }
                    .accessibilityLabel("Clear all filters")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    private var hasActiveFilter: Bool {
        filterEdited || filterDeadline || selectedCategory != nil
            || sortOption != .defaultSort || groupByDate
    }

    private func clearAllFilters() {
        filterEdited    = false
        filterDeadline  = false
        selectedCategory = nil
        sortOption      = .defaultSort
        groupByDate     = false
    }

    // Pill: Sort / Group / Select — tampil sebagai icon circle
    private var sortPill: some View {
        let isActive = sortOption != .defaultSort || groupByDate
        return Menu {
            Menu {
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("Sort By", systemImage: "arrow.up.arrow.down")
            }

            Button {
                withAnimation { groupByDate.toggle() }
            } label: {
                Label(
                    groupByDate ? "Group By Date: On" : "Group By Date: Off",
                    systemImage: groupByDate ? "checkmark.circle.fill" : "calendar"
                )
            }

            Divider()

            Button {
                withAnimation { isSelecting = true }
            } label: {
                Label("Select", systemImage: "checkmark.circle")
            }
        } label: {
            Button {
                withAnimation { isSelecting = true }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.footnote.bold())
                    .foregroundStyle(isActive ? Color.white : Color.primary)
                    .frame(width: 42, height: 42)
                    .glassEffect(isActive ? .regular.tint(Color("BrandOrange").opacity(0.8)) : .regular, in: .circle)
                    .clipShape(Circle())
                    .shadow(color: Color(.label).opacity(0.07), radius: 3, x: 0, y: 1)
            }
        }
    }

    // Pill: Category dropdown
    private var categoryPill: some View {
        Menu {
            Button {
                selectedCategory = nil
            } label: {
                if selectedCategory == nil {
                    Label("All", systemImage: "checkmark")
                } else {
                    Text("All")
                }
            }

            Divider()

            ForEach(categories, id: \.self) { cat in
                Button {
                    selectedCategory = selectedCategory == cat ? nil : cat
                } label: {
                    if selectedCategory == cat {
                        Label(cat, systemImage: "checkmark")
                    } else {
                        Text(cat)
                    }
                }
            }

            Divider()

            Button {
                showAddCategoryAlert = true
            } label: {
                Label("Add Category…", systemImage: "plus")
            }
        } label: {
            pillLabel(
                icon: nil,
                text: selectedCategory ?? "Category",
                isActive: selectedCategory != nil
            )
        }
    }

    // Shared pill appearance
    @ViewBuilder
    private func pillLabel(icon: String?, text: String, isActive: Bool, showChevron: Bool = true) -> some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption.bold())
            }
            Text(text)
                .font(.footnote.bold())
            if showChevron {
                Image(systemName: "chevron.down")
                    .font(.caption2.bold())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .glassEffect((isActive ? .regular.tint(Color("BrandOrange").opacity(0.8)) : .regular), in: .capsule)
        .foregroundStyle(isActive ? Color.white : Color.primary)
        .clipShape(Capsule())
        .shadow(color: Color(.label).opacity(0.07), radius: 3, x: 0, y: 1)
    }

    // MARK: Helpers

    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func deleteSelected() {
        for i in sections.indices {
            sections[i].items.removeAll { selectedIDs.contains($0.id) }
        }
        selectedIDs.removeAll()
        isSelecting = false
    }
}

// MARK: - Preview

#Preview {
    HomePageView()
}
