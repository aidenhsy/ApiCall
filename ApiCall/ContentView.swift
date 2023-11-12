//
//  ContentView.swift
//  ApiCall
//
//  Created by Aiden Yang on 2023/11/12.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack {
            AsyncImage(
                url: URL(string: user?.image ?? ""),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
            )
            .frame(width: 120, height: 120)

            Text(user?.firstName ?? "username")
                .bold()
                .font(.title)
            Text(user?.email ?? "user@email.com")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch RestError.invalidURL {
                print("Invalid URL")
            } catch RestError.invalidResponse {
                print("invalid response")
            } catch RestError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected errro")
            }
        }
    }

    func getUser() async throws -> GitHubUser {
        let endpoint = "https://dummyjson.com/users/5"

        guard let url = URL(string: endpoint) else { throw RestError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RestError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw RestError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let firstName: String
    let image: String
    let email: String
}

enum RestError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
