//  HomePageScreen.swift
//  Challenge3

import SwiftUI
import SwiftData
// MARK: - Corner Extension
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
// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case newest   = "Newest"
    case oldest   = "Oldest"
    case title    = "Title (A–Z)"
    case postDate = "Post Date"
    
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}

// MARK: - Home Page Screen

struct HomePageScreen: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CreatorProject.createdAt, order: .reverse)
    private var projects: [CreatorProject]

    // MARK: Filter & Sort State
    @State private var sortOption: SortOption = .newest
    @State private var selectedCategory: String? = nil
    @State private var filterHasDeadline: Bool = false
    @State private var filterHasScript: Bool = false
    @State private var filterHasCaption: Bool = false
    @State private var groupByDate: Bool = false
    @State private var searchText: String = ""

    // MARK: Select Mode State
    @State private var isSelecting: Bool = false
    @State private var selectedIDs: Set<PersistentIdentifier> = []
    @State private var showDeleteConfirm: Bool = false

    // MARK: Navigation State
    @State private var goToAddProject: Bool = false
    @State private var newProjectTitle: String = ""
    @State private var showNameModal: Bool = false

    // MARK: Category State
    @AppStorage(kCategoriesStorageKey) private var categoriesRaw: String = kCategoriesDefault
    @State private var showAddCategoryAlert: Bool = false
    @State private var newCategoryName: String = ""

    private var defaultCategories: [String] {
        kCategoriesDefault.split(separator: ",").map(String.init)
    }

    private var userCategories: [String] {
        categoriesRaw.isEmpty ? [] : categoriesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }

    private var categories: [String] {
        defaultCategories + userCategories
    }

    private func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        var updated = userCategories
        updated.append(trimmed)
        categoriesRaw = updated.joined(separator: ",")
    }

    private func removeCategory(_ cat: String) {
        if selectedCategory == cat { selectedCategory = nil }
        var updated = userCategories
        updated.removeAll { $0 == cat }
        categoriesRaw = updated.joined(separator: ",")
    }
    
//    private var categories: [String] {
//        categoriesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty }
//    }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Computed: processed projects

    private var processedProjects: [CreatorProject] {
        var result = projects

        // 1. Search
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(query)
                || $0.outline.lowercased().contains(query)
            }
        }

        // 2. Deadline filter
        if filterHasDeadline {
            result = result.filter { $0.postDate != nil }
        }

        // 3. Has Script filter
        if filterHasScript {
            result = result.filter { !$0.scripts.isEmpty }
        }

        // 4. Has Caption filter
        if filterHasCaption {
            result = result.filter { !$0.captions.isEmpty }
        }

        // 5. Category filter — project bisa punya banyak kategori (comma-separated)
        if let category = selectedCategory {
            result = result.filter { project in
                project.category
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                    .contains(category.lowercased())
            }
        }

        // 6. Sort
        result.sort { lhs, rhs in
            switch sortOption {
            case .newest:
                return lhs.createdAt > rhs.createdAt
            case .oldest:
                return lhs.createdAt < rhs.createdAt
            case .title:
                return lhs.title.lowercased() < rhs.title.lowercased()
            case .postDate:
                let l = lhs.postDate ?? .distantFuture
                let r = rhs.postDate ?? .distantFuture
                return l < r
            }
        }

        return result
    }

    private var processedSections: [MenuSection] {
        guard groupByDate else {
            return [MenuSection(
                dateLabel: "",
                items: processedProjects.map { MenuItem(project: $0) }
            )]
        }

        let grouped = Dictionary(grouping: processedProjects) { project -> String in
            Self.sectionLabel(for: project.postDate ?? project.createdAt)
        }

        return grouped.keys
            .sorted {
                let l = Self.date(fromLabel: $0) ?? .distantPast
                let r = Self.date(fromLabel: $1) ?? .distantPast
                return l > r
            }
            .map { label in
                MenuSection(
                    dateLabel: label,
                    items: (grouped[label] ?? []).map { MenuItem(project: $0) }
                )
            }
    }

    private var hasActiveFilter: Bool {
        filterHasDeadline || filterHasScript || filterHasCaption
            || selectedCategory != nil || sortOption != .newest
            || groupByDate || !searchText.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.pageBackground.ignoresSafeArea()

                if processedProjects.isEmpty {
                    emptyState
                } else {
                    scrollContent
                }

                if isSelecting {
                    selectModeBar
                } else {
                    searchAndFABBar
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $goToAddProject) {
                AddProjectScreen(initialTitle: newProjectTitle)
            }
            .sheet(isPresented: $showNameModal, onDismiss: {
                if !newProjectTitle.isEmpty {
                    goToAddProject = true
                }
            }) {
                AddNewProjectNameSheet { name in
                    newProjectTitle = name
                    showNameModal = false
                }
                .presentationDetents([.fraction(0.42)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(UIWindowScene.cornerRadius)
                .presentationBackground(.regularMaterial)
            }
            .alert("New Category", isPresented: $showAddCategoryAlert) {
                TextField("e.g. Finance, Health…", text: $newCategoryName)
                Button("Add") {
                    let name = newCategoryName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty && !categories.contains(name) {
                        categoriesRaw = categoriesRaw + "," + name
                    }
                    newCategoryName = ""
                }
                Button("Cancel", role: .cancel) { newCategoryName = "" }
            } message: {
                Text("Enter a name for the new category.")
            }
            .confirmationDialog(
                "Delete \(selectedIDs.count) project\(selectedIDs.count == 1 ? "" : "s")?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteSelected() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                filterBar
                sectionList
                Spacer().frame(height: 100)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello")
                    .font(.largeTitle.bold())
                Text("Have a nice day!")
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                sortMenu
                categoryMenu

                filterPill(
                    text: NSLocalizedString("Has Deadline", comment: ""),
                    isActive: filterHasDeadline
                ) {
                    withAnimation { filterHasDeadline.toggle() }
                }

                filterPill(
                    text: NSLocalizedString("Has Script", comment: ""),
                    isActive: filterHasScript
                ) {
                    withAnimation { filterHasScript.toggle() }
                }

                filterPill(
                    text: NSLocalizedString("Has Caption", comment: ""),
                    isActive: filterHasCaption
                ) {
                    withAnimation { filterHasCaption.toggle() }
                }

                if hasActiveFilter {
                    Button {
                        withAnimation { clearAllFilters() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 1)
                    }
                    .accessibilityLabel("Clear all filters")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .padding(.bottom, 16)
    }

    private var sortMenu: some View {
        let isActive = sortOption != .newest || groupByDate
        return Menu {
            Picker("Sort By", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.localized).tag(option)
                }
            }
            Divider()
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
                Label("Select Items", systemImage: "checkmark.circle")
            }
        } label: {
            pillView(
                icon: "line.3.horizontal.decrease",
//                text: sortOption != .newest ? sortOption.rawValue : "Sort",
                text: sortOption != .newest ? sortOption.localized : NSLocalizedString("Sort", comment: ""),
                isActive: isActive
            )
        }
    }

    private var categoryMenu: some View {
        Menu {
            Button { selectedCategory = nil } label: {
                Label("All", systemImage: selectedCategory == nil ? "checkmark" : "")
            }
            Divider()
            ForEach(categories, id: \.self) { cat in
                Button {
                    selectedCategory = selectedCategory == cat ? nil : cat
                } label: {
                    Label(cat, systemImage: selectedCategory == cat ? "checkmark" : "")
                }
                // Only show delete for user-added categories, not defaults
                if !defaultCategories.contains(cat) {
                    Button(role: .destructive) {
                        removeCategory(cat)
                    } label: {
                        Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                    }
                }
            }
            Divider()
            Button { showAddCategoryAlert = true } label: {
                Label("Add Category…", systemImage: "plus")
            }
        } label: {
            pillView(
                icon: "tag",
                text: selectedCategory ?? NSLocalizedString("Category", comment: ""),
                isActive: selectedCategory != nil
            )
        }
    }

    private func filterPill(
        text: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            pillView(icon: nil, text: text, isActive: isActive)
        }
    }

    private func pillView(icon: String?, text: String, isActive: Bool) -> some View {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.bold())
                }
                Text(text)
                    .font(.footnote.bold())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
//            .glassEffect((isActive ? .regular.tint(Color.brandOrange.opacity(0.8)) : .regular), in: .capsule)
            .modify {
                if #available(iOS 26.0, *) {
                    $0.glassEffect(isActive ? .regular.tint(Color.brandOrange.opacity(0.8)) : .regular, in: .capsule)
                } else {
                    $0.background(isActive ? Color.brandOrange : Color.primary.opacity(0.1)).clipShape(.capsule)
                }
            }
            .foregroundStyle(isActive ? Color.white : Color.primary)
            .clipShape(.capsule)
            .shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 1)
        }

    // MARK: - Section List

    private var sectionList: some View {
        ForEach(processedSections) { section in
            if !section.items.isEmpty {
                if groupByDate && !section.dateLabel.isEmpty {
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
                                isSelected: selectedIDs.contains(
                                    item.project.persistentModelID
                                )
                            )
                            .onTapGesture {
                                toggleSelection(item.project.persistentModelID)
                            }
                        } else {
                            NavigationLink(
                                destination: DetailProjectScreen(project: item.project)
                            ) {
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
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            headerView
            filterBar
            Spacer()
            Image(systemName: hasActiveFilter ? "magnifyingglass" : "tray")
                .font(.system(size: 48))
                .foregroundColor(Color.brandBlue.opacity(0.4))
            Text(hasActiveFilter ? "No matching projects" : "No projects yet")
                .font(.title3.bold())
            Text(
                hasActiveFilter
                    ? "Try adjusting your filters"
                    : "Tap + to create your first project"
            )
            .foregroundColor(.secondary)
            .font(.subheadline)
            if hasActiveFilter {
                Button("Clear Filters") {
                    withAnimation { clearAllFilters() }
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color.brandBlue)
            }
            Spacer()
        }
    }


    // MARK: - Search + FAB Bar

        private var searchAndFABBar: some View {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    TextField("Search projects...", text: $searchText)
                        .font(.subheadline)

                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(.systemGray3))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                Button {
                    newProjectTitle = ""
                    showNameModal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
//                        .glassEffect(.regular.tint(Color.brandOrange.opacity(0.8)), in: .circle)
                        .modify {
                            if #available(iOS 26.0, *) {
                                $0.glassEffect(.regular.tint(Color.brandOrange.opacity(0.8)), in: .circle)
                            } else {
                                $0.background(Color.brandOrange).clipShape(.circle)
                            }
                        }
                }
                .accessibilityLabel("Add new project")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }

    // MARK: - Select Mode Bar

    private var selectModeBar: some View {
        HStack {
            Text(selectedIDs.isEmpty
                 ? "Select items"
                 : "\(selectedIDs.count) selected"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                showDeleteConfirm = true
            } label: {
                Text("Delete")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(
                        selectedIDs.isEmpty ? Color.red.opacity(0.35) : Color.red
                    )
                    .clipShape(Capsule())
            }
            .disabled(selectedIDs.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }

    // MARK: - Actions

    private func toggleSelection(_ id: PersistentIdentifier) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func deleteSelected() {
        let toDelete = projects.filter { selectedIDs.contains($0.persistentModelID) }
        for project in toDelete {
            modelContext.delete(project)
        }
        try? modelContext.save()
        selectedIDs.removeAll()
        isSelecting = false
    }

    private func clearAllFilters() {
        filterHasDeadline = false
        filterHasScript   = false
        filterHasCaption  = false
        selectedCategory  = nil
        sortOption        = .newest
        groupByDate       = false
        searchText        = ""
    }

    // MARK: - Date Helpers

    private static let sectionFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE (MMM, d"
        return f
    }()

    private static let parseFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE (MMM, d"
        return f
    }()

    static func sectionLabel(for date: Date) -> String {
        let base = sectionFormatter.string(from: date)
        let day  = Calendar.current.component(.day, from: date)
        return base + ordinalSuffix(day) + ")"
    }

    private static func date(fromLabel label: String) -> Date? {
        let stripped = label
            .replacingOccurrences(of: "st)", with: "")
            .replacingOccurrences(of: "nd)", with: "")
            .replacingOccurrences(of: "rd)", with: "")
            .replacingOccurrences(of: "th)", with: "")
            .replacingOccurrences(of: ")", with: "")
        return parseFormatter.date(from: stripped)
    }

    private static func ordinalSuffix(_ day: Int) -> String {
        switch day {
        case 11, 12, 13: return "th"
        default:
            switch day % 10 {
            case 1:  return "st"
            case 2:  return "nd"
            case 3:  return "rd"
            default: return "th"
            }
        }
    }
}

// MARK: - Models

struct MenuItem: Identifiable {
    let id = UUID()
    let project: CreatorProject

    var title: String { project.title }
    var dateLabel: String {
        HomePageScreen.sectionLabel(for: project.postDate ?? project.createdAt)
    }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let dateLabel: String
    let items: [MenuItem]
}

// MARK: - Menu Card

struct MenuCard: View {
    let item: MenuItem
    var isSelecting: Bool = false
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                ZStack {
                    Color.primary.opacity(0.08)
                    if let filename = item.project.thumbnailFilename,
                       let image =
                            SharedContentManager.shared
                                .loadImage(filename: filename)
                    {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                    }
                    else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)


                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.brandBlue : Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .padding(8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)

            ZStack(alignment: .leading) {
                Color.brandBlue
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.brandBlue : Color.clear, lineWidth: 2.5)
        )
    }
}

// MARK: - Add New Project Name Sheet

struct AddNewProjectNameSheet: View {
    @State private var projectName: String = ""
    @FocusState private var isNameFocused: Bool
    let onConfirm: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("New Project")
                .font(.title2.bold())

            Text("Give your project a name to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("e.g. Day in My Life Vlog", text: $projectName)
                .font(.system(size: 16))
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isNameFocused)
                .onChange(of: projectName) { _, v in
                    if v.count > 80 { projectName = String(v.prefix(80)) }
                }

            if #available(iOS 26.0, *) {
                Button {
                    let name = projectName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    onConfirm(name)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)


                }
                .buttonStyle(.glassProminent)
                .tint(Color.brandBlue)
                .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
            } else {
                Button {
                    let name = projectName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    onConfirm(name)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            projectName.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.brandBlue.opacity(0.4)
                            : Color.brandBlue
                        )
                        .clipShape(RoundedRectangle(cornerRadius: UIWindowScene.cornerRadius))
                }
                .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .onAppear {
            // Delay kecil agar sheet sudah selesai animasi sebelum keyboard muncul
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomePageScreen()
        .modelContainer(for: [CreatorProject.self, ReferenceItem.self], inMemory: true)
}
