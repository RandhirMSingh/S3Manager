#!/usr/bin/env swift

import Foundation

print(CommandLine.arguments)

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

let PR_NUMBER = 22
let GITHUB_TOKEN = CommandLine.arguments[5]
let REPO = "RandhirMSingh/HackathonSampleApp"
let issueURL = "https://api.github.com/repos/\(REPO)/issues/\(PR_NUMBER)/comments"

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
func getURLs(for images: [String], from s3Bucket: String, in region: String) -> [String] {
    return images.map {
        "https://\(s3Bucket).s3.\(region).amazonaws.com/\($0)"
    }
}

func getMD(for urls: [String]) -> String {
    var markDown = ""
    for imageURL in urls {
        markDown += """
        <img alt='Screenshot' height=500 width=300 src='\(imageURL)'>
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
    } catch {
        print("Error: \(error): \nError while uploading comment.")
    }
    
}

let s3Bucket = "randhir-hackathon-screenshots-ap-south-1"
let region = "ap-south-1"
let s3Objects = getObjects(from: s3Bucket)
//Get url for all images
let urls = getURLs(for: s3Objects.images, from: s3Bucket, in: region)
let markdown = getMD(for: urls)
createIssueComment(with: markdown)

