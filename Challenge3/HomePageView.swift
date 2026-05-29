//
//  HomePageView.swift
//  Challenge3
//
//  Created by Alexander Yofilio S on 26/05/26.
//

import SwiftUI

// MARK: - Model

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let image: String?
}

struct MenuSection: Identifiable {
    let id = UUID()
    let dateLabel: String
    let items: [MenuItem]
}

// MARK: - Sample Data

let sampleSections: [MenuSection] = [
    MenuSection(
        dateLabel: "Monday (May, 25th)",
        items: [
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
        ]
    ),
    MenuSection(
        dateLabel: "Monday (May, 25th)",
        items: [
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
            MenuItem(title: "Menu Lebaran Idul Adha", date: "Monday (May, 25th)", image: nil),
        ]
    )
]

// MARK: - Colors

extension Color {
    static let brandBlue   = Color(red: 89/255,  green: 193/255, blue: 253/255)
    static let brandOrange = Color(red: 253/255, green: 144/255, blue: 89/255)
    static let pageBg      = Color(red: 246/255, green: 249/255, blue: 254/255)
}

// MARK: - Menu Card

struct MenuCard: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder area
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

            // Label
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

// MARK: - Detail View (destination)

struct MenuDetailView: View {
    let item: MenuItem

    var body: some View {
        ZStack {
            Color.pageBg.ignoresSafeArea()
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.brandBlue.opacity(0.25))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(Color(.systemGray3))
                    )
                    .padding(.horizontal)

                Text(item.title)
                    .font(.title2.bold())
                    .padding(.horizontal)

                Text(item.date)
                    .foregroundColor(.secondary)

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
    @State private var selectedFilter: String = "Newest"
    @State private var goToAddProject: Bool = false
    let filters = ["Newest", "By Type"]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottomTrailing) {
                Color.pageBg.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hello, Richard")
                                    .font(.largeTitle.bold())
                                Text("Have a nice day !")
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer()
                            // Profile circle
                            Circle()
                                .fill(Color.brandBlue)
                                .frame(width: 48, height: 48)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        // MARK: Filter Pills
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter)
                                        .font(.system(size: 13, weight: .semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 7)
                                        .background(
                                            selectedFilter == filter
                                            ? Color.brandOrange
                                            : Color.clear
                                        )
                                        .foregroundColor(
                                            selectedFilter == filter ? .white : Color.brandBlue
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    selectedFilter == filter
                                                    ? Color.brandOrange
                                                    : Color.brandBlue,
                                                    lineWidth: 1.5
                                                )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // MARK: Sections
                        ForEach(sampleSections) { section in
                            Text(section.dateLabel)
                                .font(.title3.bold())
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(section.items) { item in
                                    NavigationLink(destination: DetailProjectScreen()) {
                                        MenuCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                        
                        Spacer().frame(height: 80)
                    }
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
                .navigationDestination(isPresented: $goToAddProject) {  AddProjectScreen()}
            }
        }
    }
}


// MARK: - Preview

#Preview {
    HomePageView()
}
