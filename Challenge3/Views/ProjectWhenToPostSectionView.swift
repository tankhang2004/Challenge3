//  WhenToPostSectionView.swift
//  Challenge3

import SwiftUI

struct ProjectWhenToPostSectionView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date?
    @Binding var postHour: Int
    @Binding var postMinute: Int
    @Binding var isAM: Bool?
    @Binding var showTimePicker: Bool
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale.current
        return cal
    }()

    private var weekdays: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1

        return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
    }


    private var strokeColor: Color {
        if selectedDate != nil {
            return Color.brandBlue
        } else {
            return Color.white
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to Post")
                .font(.headline)

            // MARK: Calendar Card
            VStack(spacing: 10) {
                // Month navigation
                HStack {
                    Button {
                        displayedMonth = Calendar.current.date(
                            byAdding: .month, value: -1, to: displayedMonth
                        ) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.brandBlue)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    Spacer()

                    Button {
                        displayedMonth = Calendar.current.date(
                            byAdding: .month, value: 1, to: displayedMonth
                        ) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.brandBlue)
                    }
                    .buttonStyle(.plain)
                }

                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                                    Text(day)
                                        .textCase(.uppercase)
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity)
                    }
                }

                // Day grid
                let days = calendarDays(for: displayedMonth)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                    spacing: 2
                ) {
                    ForEach(days.indices, id: \.self) { i in
                        if let day = days[i] {
                            let isSelected = Calendar.current.isDate(
                                day, inSameDayAs: selectedDate ?? .distantPast
                            )
                            let isToday = Calendar.current.isDateInToday(day)

                            Button {
                                selectedDate = day
                            } label: {
                                ZStack {
                                    if isSelected {
                                        Circle()
                                            .fill(Color.brandBlue)
                                            .frame(width: 34, height: 34)
                                    } else if isToday {
                                        Circle()
                                            .stroke(Color.brandBlue, lineWidth: 1.5)
                                            .frame(width: 34, height: 34)
                                    }
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .font(.system(size: 14))
                                        .foregroundColor(
                                            isSelected ? .white : isToday ? Color.brandBlue : .primary
                                        )
                                }
                                .frame(height: 36)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear.frame(height: 36)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.cardSurface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(strokeColor, lineWidth: 1.5)
            )

            // MARK: Time Row
            HStack {
                Text("Time")
                    .font(.system(size: 15, weight: .semibold))

                Spacer()

                Button {
                    withAnimation { showTimePicker.toggle() }
                } label: {
                    Text(formattedTime)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.cardSurface)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(strokeColor, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)

                AMPMToggle(isAM: $isAM)
            }
            .padding(16)
            .background(Color.cardSurface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(strokeColor, lineWidth: 1.5)
            )

            // MARK: Time Picker
            if showTimePicker {
                HStack(spacing: 0) {
                    Picker("Hour", selection: $postHour) {
                        ForEach(1...12, id: \.self) { h in
                            Text(String(format: "%02d", h)).tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Text(":")
                        .font(.title2.bold())

                    Picker("Minute", selection: $postMinute) {
                        ForEach([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 140)
                .background(Color.cardSurface)
                .cornerRadius(14)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        String(format: "%02d:%02d", postHour, postMinute)
    }

    private func calendarDays(for monthStart: Date) -> [Date?] {
        let calendar = Calendar.current
        guard
            let range = calendar.range(of: .day, in: .month, for: monthStart),
            let firstOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: monthStart)
            )
        else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        let padding: [Date?] = Array(repeating: nil, count: weekdayOfFirst)
        let days: [Date?] = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
        return padding + days
    }
}

public struct AMPMToggle: View {
    @Binding var isAM: Bool?

    public var body: some View {
        HStack(spacing: 0) {
            periodButton("AM", active: isAM == true) { isAM = true }
            periodButton("PM", active: isAM == false) { isAM = false }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardSurface)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
        .cornerRadius(14)
    }

    private func periodButton(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(active ? .primary : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(active ? Color.brandBlue : Color.clear)
                .cornerRadius(active ? 14 : 0)
        }
        .buttonStyle(.plain)
    }
}
