//
//  SubtitleConverter.swift
//  TXT to SRT Converter
//
//  Handles conversion of TXT subtitle files to SRT format
//

import Foundation

class SubtitleConverter {
    
    struct Subtitle {
        let startTime: String
        let endTime: String
        let text: String
    }
    
    /// Convert a TXT file to SRT format
    func convertFile(inputURL: URL) throws -> URL {
        // Read the input file
        let content = try String(contentsOf: inputURL, encoding: .utf8)
        
        // Parse subtitles
        let subtitles = try parseSubtitles(from: content)
        
        guard !subtitles.isEmpty else {
            throw ConversionError.noSubtitlesFound
        }
        
        // Generate SRT content
        let srtContent = generateSRT(from: subtitles)
        
        // Create output URL (same location, .srt extension)
        let outputURL = inputURL.deletingPathExtension().appendingPathExtension("srt")
        
        // Write the SRT file
        try srtContent.write(to: outputURL, atomically: true, encoding: .utf8)
        
        return outputURL
    }
    
    /// Parse subtitle content (supports both TXT and SRT formats)
    private func parseSubtitles(from content: String) throws -> [Subtitle] {
        var subtitles: [Subtitle] = []
        
        // Normalize line endings (handle both \r\n and \n)
        let normalizedContent = content.replacingOccurrences(of: "\r\n", with: "\n")
        
        // Split by double newlines to get blocks
        let blocks = normalizedContent.components(separatedBy: "\n\n")
        
        for block in blocks {
            let lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
            
            guard lines.count >= 2 else { continue }
            
            // Try to find timecode line (skip subtitle numbers)
            var timecodeLine: String?
            var textStartIndex = 1
            
            // Check if first line is a number (SRT format)
            if let _ = Int(lines[0].trimmingCharacters(in: .whitespaces)) {
                // Skip the number, timecode is on second line
                if lines.count >= 3 {
                    timecodeLine = lines[1]
                    textStartIndex = 2
                }
            } else {
                // First line should be timecode
                timecodeLine = lines[0]
                textStartIndex = 1
            }
            
            guard let timecode = timecodeLine else { continue }
            
            // Try TXT format: HH:MM:SS:FF - HH:MM:SS:FF
            let txtPattern = #"(\d{2}:\d{2}:\d{2}:\d{2})\s*-\s*(\d{2}:\d{2}:\d{2}:\d{2})"#
            
            // Try SRT format: HH:MM:SS,mmm --> HH:MM:SS,mmm
            let srtPattern = #"(\d{2}:\d{2}:\d{2}[,\.]\d{3})\s*--?>\s*(\d{2}:\d{2}:\d{2}[,\.]\d{3})"#
            
            var startTime: String?
            var endTime: String?
            
            // Try TXT format first
            if let regex = try? NSRegularExpression(pattern: txtPattern),
               let match = regex.firstMatch(in: timecode, range: NSRange(timecode.startIndex..., in: timecode)),
               let startRange = Range(match.range(at: 1), in: timecode),
               let endRange = Range(match.range(at: 2), in: timecode) {
                startTime = String(timecode[startRange])
                endTime = String(timecode[endRange])
            }
            // Try SRT format
            else if let regex = try? NSRegularExpression(pattern: srtPattern),
                    let match = regex.firstMatch(in: timecode, range: NSRange(timecode.startIndex..., in: timecode)),
                    let startRange = Range(match.range(at: 1), in: timecode),
                    let endRange = Range(match.range(at: 2), in: timecode) {
                // Already in SRT format, just normalize (replace . with ,)
                startTime = String(timecode[startRange]).replacingOccurrences(of: ".", with: ",")
                endTime = String(timecode[endRange]).replacingOccurrences(of: ".", with: ",")
            }
            
            guard let start = startTime, let end = endTime else {
                continue
            }
            
            // Rest of lines are subtitle text
            guard textStartIndex < lines.count else { continue }
            let text = lines[textStartIndex...].joined(separator: "\n")
            
            subtitles.append(Subtitle(startTime: start, endTime: end, text: text))
        }
        
        return subtitles
    }
    
    /// Convert timecode from HH:MM:SS:FF to HH:MM:SS,mmm (or pass through if already converted)
    private func convertTimecode(_ timecode: String) -> String {
        // Check if already in SRT format (contains comma or has 3 digits at end)
        if timecode.contains(",") || timecode.contains(".") {
            // Already in SRT format, just normalize
            return timecode.replacingOccurrences(of: ".", with: ",")
        }
        
        let parts = timecode.components(separatedBy: ":")
        
        guard parts.count == 4,
              let hours = parts[0] as String?,
              let minutes = parts[1] as String?,
              let seconds = parts[2] as String?,
              let frames = Int(parts[3]) else {
            return timecode
        }
        
        // Convert frames to milliseconds (assuming 25 fps)
        let milliseconds = Int(Double(frames) * (1000.0 / 25.0))
        
        return String(format: "%@:%@:%@,%03d", hours, minutes, seconds, milliseconds)
    }
    
    /// Generate SRT format content
    private func generateSRT(from subtitles: [Subtitle]) -> String {
        var lines: [String] = []
        
        for (index, subtitle) in subtitles.enumerated() {
            // Subtitle number (1-indexed)
            lines.append(String(index + 1))
            
            // Timecode line
            let startSRT = convertTimecode(subtitle.startTime)
            let endSRT = convertTimecode(subtitle.endTime)
            lines.append("\(startSRT) --> \(endSRT)")
            
            // Subtitle text
            lines.append(subtitle.text)
            
            // Blank line separator
            lines.append("")
        }
        
        return lines.joined(separator: "\n")
    }
    
    enum ConversionError: Error, LocalizedError {
        case noSubtitlesFound
        case invalidFormat
        
        var errorDescription: String? {
            switch self {
            case .noSubtitlesFound:
                return "Aucun sous-titre trouvé dans le fichier"
            case .invalidFormat:
                return "Format de fichier invalide"
            }
        }
    }
}
