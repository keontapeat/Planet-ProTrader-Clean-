import Foundation

// Test VPS connection from Swift
func testVPSConnection() async {
    print("🧪 Testing VPS connection from Swift...")
    
    guard let url = URL(string: "http://172.234.201.231:8080/health") else {
        print("❌ Invalid URL")
        return
    }
    
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        let httpResponse = response as? HTTPURLResponse
        
        print("✅ Response status: \(httpResponse?.statusCode ?? -1)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("✅ Response data: \(responseString)")
        }
        
        if httpResponse?.statusCode == 200 {
            print("🎉 VPS CONNECTION SUCCESS!")
        } else {
            print("❌ VPS connection failed")
        }
        
    } catch {
        print("❌ Connection error: \(error.localizedDescription)")
    }
}

// Run the test
Task {
    await testVPSConnection()
}

// Keep the script running
RunLoop.main.run()