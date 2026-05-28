//
//  ContentView.swift
//  Challenge3
//
//  Created by Johnny Khang on 26/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 89/255, green: 193/255, blue: 253/255),
                    Color(red: 63/255, green: 169/255, blue: 247/255)
                ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color.white .opacity(0.1))
                    .frame(width: 700, height: 700)
                Circle()
                    .fill(Color.white .opacity(0.1))
                    .frame(width: 380, height: 380)
                Circle()
                    .fill(Color.white .opacity(0.1))
                    .frame(width: 260, height: 260)
                
            }
            .offset(y:60)
            
            
            VStack (alignment: .leading, spacing: 16){
                Text("Manage \nYour Contents \nWith Lumio")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .lineSpacing(4)
                Text("Create, collaborate, and organize \nyour contens in one space.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .offset(y:60)
        }
    }
}

#Preview {
    ContentView()
}
