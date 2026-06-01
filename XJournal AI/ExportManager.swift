import Foundation
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// MARK: - Export Manager (Phase 5: Export Functionality)

class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - PDF Export
    
    func exportToPDF(item: Item) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "The Final Journal AI",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: item.title.isEmpty ? "Untitled Note" : item.title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0 // US Letter width in points
        let pageHeight = 11 * 72.0  // US Letter height in points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.label
            ]
            let titleText = item.title.isEmpty ? "Untitled Note" : item.title
            let titleSize = titleText.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: 72, y: 72, width: pageWidth - 144, height: titleSize.height)
            titleText.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            let dateText = dateFormatter.string(from: item.timestamp)
            let dateFont = UIFont.systemFont(ofSize: 12)
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: dateFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
            let dateSize = dateText.size(withAttributes: dateAttributes)
            let dateRect = CGRect(x: 72, y: titleRect.maxY + 16, width: pageWidth - 144, height: dateSize.height)
            dateText.draw(in: dateRect, withAttributes: dateAttributes)
            
            // Body text
            let bodyFont = UIFont.systemFont(ofSize: 14)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.label
            ]
            let bodyText = item.body.isEmpty ? "(Empty note)" : item.body
            let bodyRect = CGRect(x: 72, y: dateRect.maxY + 32, width: pageWidth - 144, height: pageHeight - dateRect.maxY - 144)
            
            // Draw text with word wrapping
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            var bodyAttributesWithStyle = bodyAttributes
            bodyAttributesWithStyle[.paragraphStyle] = paragraphStyle
            
            bodyText.draw(in: bodyRect, withAttributes: bodyAttributesWithStyle)
            
            // Metadata if available
            var metadataY = bodyRect.maxY + 32
            if let bpm = item.bpm {
                let metadataText = "BPM: \(bpm)"
                let metadataSize = metadataText.size(withAttributes: dateAttributes)
                let metadataRect = CGRect(x: 72, y: metadataY, width: pageWidth - 144, height: metadataSize.height)
                metadataText.draw(in: metadataRect, withAttributes: dateAttributes)
                metadataY += metadataSize.height + 8
            }
            
            if let key = item.key {
                let metadataText = "Key: \(key)"
                let metadataSize = metadataText.size(withAttributes: dateAttributes)
                let metadataRect = CGRect(x: 72, y: metadataY, width: pageWidth - 144, height: metadataSize.height)
                metadataText.draw(in: metadataRect, withAttributes: dateAttributes)
            }
        }
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.title.isEmpty ? "note" : item.title)_\(Date().timeIntervalSince1970).pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("❌ Failed to save PDF: \(error)")
            return nil
        }
    }
    
    func exportMultipleToPDF(items: [Item]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "The Final Journal AI",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "Journal Export"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            for (index, item) in items.enumerated() {
                if index > 0 {
                    context.beginPage()
                } else {
                    context.beginPage()
                }
                
                // Title
                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.label
                ]
                let titleText = item.title.isEmpty ? "Untitled Note" : item.title
                let titleSize = titleText.size(withAttributes: titleAttributes)
                let titleRect = CGRect(x: 72, y: 72, width: pageWidth - 144, height: titleSize.height)
                titleText.draw(in: titleRect, withAttributes: titleAttributes)
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
                dateFormatter.amSymbol = "AM"
                dateFormatter.pmSymbol = "PM"
                let dateText = dateFormatter.string(from: item.timestamp)
                let dateFont = UIFont.systemFont(ofSize: 12)
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: dateFont,
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let dateSize = dateText.size(withAttributes: dateAttributes)
                let dateRect = CGRect(x: 72, y: titleRect.maxY + 16, width: pageWidth - 144, height: dateSize.height)
                dateText.draw(in: dateRect, withAttributes: dateAttributes)
                
                // Body text
                let bodyFont = UIFont.systemFont(ofSize: 14)
                let bodyAttributes: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: UIColor.label
                ]
                let bodyText = item.body.isEmpty ? "(Empty note)" : item.body
                let bodyRect = CGRect(x: 72, y: dateRect.maxY + 32, width: pageWidth - 144, height: pageHeight - dateRect.maxY - 144)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                var bodyAttributesWithStyle = bodyAttributes
                bodyAttributesWithStyle[.paragraphStyle] = paragraphStyle
                
                bodyText.draw(in: bodyRect, withAttributes: bodyAttributesWithStyle)
            }
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("journal_export_\(Date().timeIntervalSince1970).pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("❌ Failed to save PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Word Export (RTF format)
    
    func exportToWord(item: Item) -> URL? {
        let rtfContent = generateRTF(item: item)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.title.isEmpty ? "note" : item.title)_\(Date().timeIntervalSince1970).rtf")
        
        do {
            try rtfContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("❌ Failed to save Word document: \(error)")
            return nil
        }
    }
    
    func exportMultipleToWord(items: [Item]) -> URL? {
        var rtfContent = "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24 "
        
        for (index, item) in items.enumerated() {
            if index > 0 {
                rtfContent += "\\page "
            }
            
            // Title
            let title = item.title.isEmpty ? "Untitled Note" : escapeRTF(item.title)
            rtfContent += "{\\b \(title)}\\par "
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            let dateText = escapeRTF(dateFormatter.string(from: item.timestamp))
            rtfContent += "{\\i \(dateText)}\\par\\par "
            
            // Body
            let body = item.body.isEmpty ? "(Empty note)" : escapeRTF(item.body)
            rtfContent += "\(body)\\par\\par "
            
            // Metadata
            if let bpm = item.bpm {
                rtfContent += "BPM: \(bpm)\\par "
            }
            if let key = item.key {
                rtfContent += "Key: \(escapeRTF(key))\\par "
            }
        }
        
        rtfContent += "}"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("journal_export_\(Date().timeIntervalSince1970).rtf")
        
        do {
            try rtfContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("❌ Failed to save Word document: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateRTF(item: Item) -> String {
        var rtf = "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24 "
        
        // Title
        let title = item.title.isEmpty ? "Untitled Note" : escapeRTF(item.title)
        rtf += "{\\b \(title)}\\par "
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let dateText = escapeRTF(dateFormatter.string(from: item.timestamp))
        rtf += "{\\i \(dateText)}\\par\\par "
        
        // Body
        let body = item.body.isEmpty ? "(Empty note)" : escapeRTF(item.body)
        rtf += "\(body)\\par\\par "
        
        // Metadata
        if let bpm = item.bpm {
            rtf += "BPM: \(bpm)\\par "
        }
        if let key = item.key {
            rtf += "Key: \(escapeRTF(key))\\par "
        }
        
        rtf += "}"
        return rtf
    }
    
    private func escapeRTF(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
    }
}
