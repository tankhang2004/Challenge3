//  HomePageView.swift
//  Challenge3

import SwiftUI
import SwiftData

// MARK: - Home Page View

struct HomePageView: View {
    @Query(sort: \CreatorProject.createdAt, order: .reverse)
    private var projects: [CreatorProject]

    @State private var selectedFilter: String = "Newest"
    @State private var goToAddProject: Bool = false

    let filters = ["Newest", "By Type"]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Computed: grouped sections

    /// Groups projects into sections keyed by their display date label.
    /// - "Newest": sorted by createdAt descending, grouped by calendar day
    /// - "By Type": could later group by a type/tag field; for now same grouping
    private var sections: [MenuSection] {
        let grouped = Dictionary(grouping: projects) { project -> String in
            Self.sectionLabel(for: project.postDate ?? project.createdAt)
        }

        // Sort section keys so most-recent date appears first
        let sortedKeys = grouped.keys.sorted { lhs, rhs in
            // Parse back to Date for reliable sort
            let lhsDate = Self.date(fromLabel: lhs) ?? .distantPast
            let rhsDate = Self.date(fromLabel: rhs) ?? .distantPast
            return lhsDate > rhsDate
        }

        return sortedKeys.map { label in
            MenuSection(
                dateLabel: label,
                items: (grouped[label] ?? []).map { project in
                    MenuItem(
                        title: project.title,
                        date: label,
                        image: nil,            // swap for real asset/thumbnail later
                        project: project
                    )
                }
            )
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.pageBg.ignoresSafeArea()

                if projects.isEmpty {
                    emptyState
                } else {
                    scrollContent
                }

                // MARK: FAB
                Button {
                    goToAddProject = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.brandOrange)
                        .clipShape(Circle())
                        .shadow(color: Color.brandOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 28)

            }
            .navigationDestination(isPresented: $goToAddProject) {
                AddProjectScreen()
            }
        }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                filterPills
                sectionList
                Spacer().frame(height: 80)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, Richard")
                    .font(.largeTitle.bold())
                Text("Have a nice day !")
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Circle()
                .fill(Color.brandBlue)
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Filter pills

    private var filterPills: some View {
        HStack(spacing: 8) {
            ForEach(filters, id: \.self) { filter in
                Button { selectedFilter = filter } label: {
                    Text(filter)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(selectedFilter == filter ? Color.brandOrange : Color.clear)
                        .foregroundColor(selectedFilter == filter ? .white : Color.brandBlue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    selectedFilter == filter ? Color.brandOrange : Color.brandBlue,
                                    lineWidth: 1.5
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Sections list

    private var sectionList: some View {
        ForEach(sections) { section in
            Text(section.dateLabel)
                .font(.title3.bold())
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(section.items) { item in
                    NavigationLink(destination: DetailProjectScreen(project: item.project)) {
                        MenuCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            headerView
            filterPills
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(Color.brandBlue.opacity(0.4))
            Text("No projects yet")
                .font(.title3.bold())
            Text("Tap + to create your first project")
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
        }
    }

    // MARK: - Date helpers

    private static let sectionFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE (MMM, d"   // e.g. "Monday (May, 25"
        return f
    }()

    private static let parseFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE (MMM, d"
        return f
    }()

    /// e.g. "Monday (May, 25th)"
    private static func sectionLabel(for date: Date) -> String {
        let base = sectionFormatter.string(from: date)   // "Monday (May, 25"
        let day  = Calendar.current.component(.day, from: date)
        return base + ordinalSuffix(day) + ")"           // "Monday (May, 25th)"
    }

    private static func date(fromLabel label: String) -> Date? {
        // Strip the ordinal suffix before parsing
        let stripped = label
            .replacingOccurrences(of: "st)", with: ")")
            .replacingOccurrences(of: "nd)", with: ")")
            .replacingOccurrences(of: "rd)", with: ")")
            .replacingOccurrences(of: "th)", with: ")")
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

// MARK: - Model (updated to carry the SwiftData object)

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let image: String?
    let project: CreatorProject     // ← real backing data
}

struct MenuSection: Identifiable {
    let id = UUID()
    let dateLabel: String
    let items: [MenuItem]
}

// MARK: - Colors (unchanged)

extension Color {
    static let brandBlue   = Color(red: 89/255,  green: 193/255, blue: 253/255)
    static let brandOrange = Color(red: 253/255, green: 144/255, blue: 89/255)
    static let pageBg      = Color(red: 246/255, green: 249/255, blue: 254/255)
}

// MARK: - Menu Card (unchanged)

struct MenuCard: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color.white
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(.systemGray4))
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
    }
}

// MARK: - Preview

#Preview {
    HomePageView()
        .modelContainer(for: CreatorProject.self, inMemory: true)
}
