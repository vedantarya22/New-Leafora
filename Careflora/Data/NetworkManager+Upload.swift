import Foundation

// MARK: - Cloudinary Upload
extension NetworkManager {

    func uploadImageToCloudinary(_ imageData: Data?, completion: @escaping (String?) -> Void) {
        guard let imageData = imageData else {
            completion(nil)
            return
        }

        let urlString = baseURL + "/upload"
        guard let url = URL(string: urlString) else {
            print(" Invalid upload URL: \(urlString)")
            completion(nil)
            return
        }

        let base64String = "data:image/jpeg;base64," + imageData.base64EncodedString()

        let request = makeRequest(url: url, method: "POST", body: [
            "image": base64String
        ])

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(" Upload error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let imageUrl = json["url"] as? String
            else {
                print(" Failed to parse upload response")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            DispatchQueue.main.async { completion(imageUrl) }
        }.resume()
    }
}
