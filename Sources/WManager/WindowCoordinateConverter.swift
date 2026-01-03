import CoreGraphics

enum WindowCoordinateConverter {
    static func axFrame(fromCocoa frame: CGRect, in screenFrame: CGRect) -> CGRect {
        let flippedY = screenFrame.maxY - frame.maxY
        return CGRect(x: frame.minX, y: flippedY, width: frame.width, height: frame.height)
    }
}
