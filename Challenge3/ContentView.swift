//
//  ContentView.swift
//  Challenge3
//
//  Created by Johnny Khang on 26/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var goToHome: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 89/255, green: 193/255, blue: 253/255),
                        Color(red: 63/255, green: 169/255, blue: 247/255)
                    ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                
                ZStack {
                    Circle()
                        .stroke(Color(red: 89/255, green: 193/255, blue: 253/255), lineWidth: 90)
                        .frame(width: 700, height: 700)
                    Circle()
                        .stroke(Color(red: 89/255, green: 193/255, blue: 253/255), lineWidth: 90)
                        .frame(width: 375, height: 375)
                }
                .padding(.top, 141)
                .offset(y: 20)
                
                VStack {
                    Image("Logo-1")
                        .padding(.bottom, 375)
                }
                
                VStack (alignment: .center, spacing: 16){
                    Text("Manage \nYour Contents \nWith Lumio")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                    Text("Create, collaborate, and organize \nyour contents in one space.")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    
                    Button{
                        goToHome = true
                    } label: {
                     Text("Get Started")
                         .font(.system(size: 28, weight: .bold))
                         .foregroundStyle(Color.white)
                         .padding(.vertical, 18)
                         .frame(width: 198, height: 68)
                         .background(LinearGradient(colors: [Color(red: 251/255, green: 154/255, blue: 108/255), Color(red: 230/255, green: 119/255, blue: 64/255)], startPoint: .top, endPoint: .bottom))
                         .clipShape(Capsule())
                         .overlay(
                             Capsule()
                                 .stroke(Color.white, lineWidth: 2)
                                 .padding(-5)
                         )
                 }
                 .padding(.horizontal, 32)
                 .padding(.top, 30)
                 .navigationDestination(isPresented: $goToHome) {
                     HomePageView()
                    }
                           
                }
                .offset(y: 130)
                
            }
        }
    }
}

#Preview {
    ContentView()
}
