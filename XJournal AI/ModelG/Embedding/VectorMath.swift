import Foundation

enum VectorMath {
    static func cosine(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0, na: Float = 0, nb: Float = 0
        for i in a.indices { dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i] }
        let denom = na.squareRoot() * nb.squareRoot()
        return denom == 0 ? 0 : dot / denom
    }
}
