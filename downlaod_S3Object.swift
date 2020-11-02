#!/usr/bin/env swift

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

print(CommandLine.arguments)
let s3Bucket = CommandLine.arguments[1]
let region = CommandLine.arguments[2]
let REPO = CommandLine.arguments[3]
let PR_NUMBER = CommandLine.arguments[4]
let GITHUB_TOKEN = CommandLine.arguments[5]
let issueURL = "https://api.github.com/repos/\(REPO)/issues/\(PR_NUMBER)/comments"


extension String {
    var images: [String] {
        images(for: "", issueNumber: 0)
    }
    func images(for repo: String, issueNumber: Int) -> [String] {
        if let regex = try? NSRegularExpression(pattern: "\\biPhone.*\\b", options: .caseInsensitive) {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
            }
        }
        return []
    }
}

func getObjects(from bucket: String) -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    let pipe = Pipe()
    process.standardOutput = pipe
    process.arguments = ["aws", "s3", "ls", "s3://\(bucket)/\(REPO)/\(PR_NUMBER)/"]
    
    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    } catch {
        print("Error")
        return ""
    }
}
//https://bucket-name.s3.Region.amazonaws.com/key
func getURLs(for images: [String], from s3Bucket: String, in region: String, prefix: String) -> [String] {
    return images.map {
        "https://\(s3Bucket).s3.\(region).amazonaws.com/\(prefix)/\($0)"
    }
}

func getMD(for urls: [String]) -> String {
    var markDown = ""
    for imageURL in urls {
        markDown += """
        _<img alt='Screenshot' height=500 width=300 src='\(imageURL)'>_
        """
    }
    
    if markDown == "" {
        markDown = "Unable to capture screenshots.."
    }
    return markDown
}

func createIssueComment(with body: String) {
    let body = """
    {
    "body": "\(body)"
    }
    """
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [
        "curl", "--request", "POST",
        "--url", issueURL,
        "--header", "Authorization: Bearer \(GITHUB_TOKEN)",
        "--header", "Accept: application/vnd.github.v3+json",
        "--header", "Content-Type: application/json",
        "--data", body
    ]

    print(body)
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print("Error: \(error): \nError while uploading comment.")
    } 
}

func createIssueCommentWithAPI(with markdown: String) {
    let semaphore = DispatchSemaphore (value: 0)
    let body = """
    {
    "body": "\(markdown)"
    }
    """

    let parameters = body//"{\n  \"body\": \"test\"\n}"
    let postData = parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: issueURL)!,timeoutInterval: Double.infinity)
    request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    request.addValue("Bearer \(GITHUB_TOKEN)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print(String(describing: error))
        return
      }
      print(String(data: data, encoding: .utf8)!)
      semaphore.signal()
    }

    task.resume()
    semaphore.wait()
}

let s3Objects = getObjects(from: s3Bucket)
//Get url for all images
let urls = getURLs(for: s3Objects.images, from: s3Bucket, in: region, prefix: "\(REPO)/\(PR_NUMBER)")
let markdown = getMD(for: urls)
createIssueCommentWithAPI(with: markdown)

