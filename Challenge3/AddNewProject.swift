//
//  AddNewProject.swift
//  Challenge3
//
//  Created by Khaerul Alfian on 29/05/26.
//

import SwiftUI

struct AddNewProjectView: View {
    
    @State private var projectName = ""
    
    var body: some View {
        ZStack {
            
            // Background blur
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text("Project's Name")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Subtitle
                Text("Input your project's name")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                // TextField
                TextField("Project's Name", text: $projectName)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(30)
                
                // Buttons
                HStack(spacing: 16) {
                    
                    Button(action: {
                        print("Cancel")
                    }) {
                        Text("Cancel")
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                    
                    Button(action: {
                        print("Next")
                    }) {
                        Text("Next")
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(35)
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    AddNewProjectView()
}
