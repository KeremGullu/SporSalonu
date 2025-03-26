import SwiftUI
import Foundation
struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["Merhaba! Size nasıl yardımcı olabilirim?"]

    var body: some View {
        VStack {
            List(messages, id: \.self) { message in
                Text(message)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                TextField("Mesajınızı yazın...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
    }

    func sendMessage() {
        guard !userInput.isEmpty else { return }
        messages.append("🧑: \(userInput)")
        getBotResponse(for: userInput)
        userInput = ""
    }

    func getBotResponse(for input: String) {
        let response = simpleAIResponse(for: input)
        messages.append("🤖: \(response)")
    }

    func simpleAIResponse(for message: String) -> String {
        let lowercasedMessage = message.lowercased()

        if lowercasedMessage.contains("merhaba") {
            return "Merhaba! Size nasıl yardımcı olabilirim?"
        } else if lowercasedMessage.contains("nasılsın") {
            return "Ben bir AI'yım, ama iyi olduğumu söyleyebilirim! 😊"
        } else if lowercasedMessage.contains("hava nasıl") {
            return "Hava durumunu şu an kontrol edemiyorum ama tahminimce güzel bir gün!"
        } else {
            return "Üzgünüm, bu konuda pek bilgim yok. Başka bir şey sorabilirsiniz. 🤖"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



class ChatGPTService {
    let apiKey = "" // OpenAI API anahtarınızı buraya ekleyin

    func sendMessageToGPT(_ message: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": message]],
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("API hatası: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: String],
               let responseText = message["content"] {
                DispatchQueue.main.async {
                    completion(responseText)
                }
            } else {
                completion("Yanıt çözümlenemedi.")
            }
        }

        task.resume()
    }
}
