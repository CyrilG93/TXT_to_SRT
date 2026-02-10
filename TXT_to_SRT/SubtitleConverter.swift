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
    /// Uses line-by-line parsing with timecode detection to avoid losing
    /// multi-line subtitles that contain blank lines between text lines.
    private func parseSubtitles(from content: String) throws -> [Subtitle] {
        var subtitles: [Subtitle] = []
        
        // Normalize line endings (handle \r\n, standalone \r, and \n)
        let normalizedContent = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        
        let allLines = normalizedContent.components(separatedBy: "\n")
        
        // Regex patterns for timecode detection
        let txtPattern = #"(\d{2}:\d{2}:\d{2}:\d{2})\s*-\s*(\d{2}:\d{2}:\d{2}:\d{2})"#
        let srtPattern = #"(\d{2}:\d{2}:\d{2}[,\.]\d{3})\s*--?>\s*(\d{2}:\d{2}:\d{2}[,\.]\d{3})"#
        
        let txtRegex = try? NSRegularExpression(pattern: txtPattern)
        let srtRegex = try? NSRegularExpression(pattern: srtPattern)
        
        /// Try to extract start/end times from a line
        func srtConvertExtractTimecodes(from line: String) -> (start: String, end: String)? {
            let range = NSRange(line.startIndex..., in: line)
            
            // Try TXT format first
            if let regex = txtRegex,
               let match = regex.firstMatch(in: line, range: range),
               let startRange = Range(match.range(at: 1), in: line),
               let endRange = Range(match.range(at: 2), in: line) {
                return (String(line[startRange]), String(line[endRange]))
            }
            
            // Try SRT format
            if let regex = srtRegex,
               let match = regex.firstMatch(in: line, range: range),
               let startRange = Range(match.range(at: 1), in: line),
               let endRange = Range(match.range(at: 2), in: line) {
                let start = String(line[startRange]).replacingOccurrences(of: ".", with: ",")
                let end = String(line[endRange]).replacingOccurrences(of: ".", with: ",")
                return (start, end)
            }
            
            return nil
        }
        
        // State for current subtitle being built
        var currentStart: String?
        var currentEnd: String?
        var currentTextLines: [String] = []
        
        /// Flush the current subtitle into the results array
        func srtConvertFlushCurrent() {
            guard let start = currentStart, let end = currentEnd else { return }
            
            // Trim leading/trailing empty lines from text, preserve internal ones
            var trimmedLines = currentTextLines
            while trimmedLines.first?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                trimmedLines.removeFirst()
            }
            while trimmedLines.last?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                trimmedLines.removeLast()
            }
            
            guard !trimmedLines.isEmpty else { return }
            
            let text = trimmedLines.joined(separator: "\n")
            subtitles.append(Subtitle(startTime: start, endTime: end, text: text))
            
            currentStart = nil
            currentEnd = nil
            currentTextLines = []
        }
        
        var i = 0
        while i < allLines.count {
            let line = allLines[i]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Check if this line is a timecode
            if let timecodes = srtConvertExtractTimecodes(from: line) {
                // Flush previous subtitle
                srtConvertFlushCurrent()
                currentStart = timecodes.start
                currentEnd = timecodes.end
                i += 1
                continue
            }
            
            // Check if this line is a subtitle number followed by a timecode on the next line
            if Int(trimmedLine) != nil, i + 1 < allLines.count {
                if let timecodes = srtConvertExtractTimecodes(from: allLines[i + 1]) {
                    // Flush previous subtitle
                    srtConvertFlushCurrent()
                    currentStart = timecodes.start
                    currentEnd = timecodes.end
                    i += 2  // Skip both the number and the timecode line
                    continue
                }
            }
            
            // This is a text line (or empty line between text lines)
            if currentStart != nil {
                currentTextLines.append(line)
            }
            
            i += 1
        }
        
        // Flush the last subtitle
        srtConvertFlushCurrent()
        
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
