import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenStartup") private var hasSeenStartup = false
    @State private var page = 0
    @State private var goToHome = false

    private let pages: [(image: String, title: String, subtitle: String)] = [
        (
            "onboarding_1",
            "Your Projects, All in One Place",
            "See all your content ideas organized, sorted, and ready to execute."
        ),
        (
            "onboarding_2",
            "Build Every Detail of Your Content",
            "Set a title, pick a category, write your outline, and attach references — all in one project."
        ),
        (
            "onboarding_3",
            "Save Inspiration on the Go",
            "Spot great content on social media? Share it straight to Lumio in one tap."
        ),
        (
            "onboarding_4",
            "Attach References Instantly",
            "Save any link or image to an existing project — or create a brand new one right away."
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.brandBlue, Color(red: 0.18, green: 0.52, blue: 0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            TabView(selection: $page) {
                ForEach(0..<pages.count, id: \.self) { i in
                    OnboardingImagePage(
                        imageName: pages[i].image,
                        title: pages[i].title,
                        subtitle: pages[i].subtitle
                    )
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 0) {
                if page > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { page -= 1 }
                    } label: {
                        navCircle("arrow.left")
                    }
                } else {
                    Spacer().frame(width: 52)
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.white : Color.white.opacity(0.35))
                            .frame(width: i == page ? 10 : 7, height: i == page ? 10 : 7)
                            .animation(.spring(duration: 0.3), value: page)
                    }
                }

                Spacer()

                Button {
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) { page += 1 }
                    } else {
                        hasSeenStartup = true
                        goToHome = true
                    }
                } label: {
                    navCircle("arrow.right")
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
        }
        .fullScreenCover(isPresented: $goToHome) {
            HomePageScreen()
        }
    }

    private func navCircle(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color.brandOrange)
            .frame(width: 52, height: 52)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

struct OnboardingImagePage: View {
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer().frame(height: geo.safeAreaInsets.top + 32)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.65)
                    .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)

                Spacer().frame(height: 28)

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer().frame(height: 10)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                Spacer().frame(height: 116)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    OnboardingView()
}
