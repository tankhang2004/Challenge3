import SwiftUI

struct StartupView: View {
    @State private var goToHome = false
    @AppStorage("hasSeenStartup") private var hasSeenStartup = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.brandBlue, location: 0),
                    .init(color: Color(red: 0.20, green: 0.55, blue: 0.80), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ZStack {
                Circle()
                    .stroke(Color.brandBlue, lineWidth: 80)
                    .frame(width: 800, height: 800)
                Circle()
                    .stroke(Color.brandBlue, lineWidth: 80)
                    .frame(width: 450, height: 450)
            }
            .padding(.top, 230)
            .offset(y: 20)

            // Logo
            VStack {
                Image("Logo-1")
                    .padding(.bottom, 375)
            }

            // Teks & tombol
            VStack(alignment: .center, spacing: 16) {
                Text("Manage \nYour Contents \nWith Lumio")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.white)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)

                Text("Create, collaborate, and organize \nyour contents in one space.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Button {
                    goToHome = true
                } label: {
                    Text("Get Started")
                        .font(.title2.bold())
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 18)
                        .frame(width: 198, height: 68)
                        .background(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.secondaryOrange, location: 0),
                                    .init(color: Color.brandOrange, location: 1)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 1)
                                .padding(0)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.top, 30)
            }
            .offset(y: 180)
        }
        .fullScreenCover(isPresented: $goToHome) {
            OnboardingView()
        }
    }
}

#Preview {
    StartupView()
}
