import Cocoa

final class OverlayView: NSView {
    var slots: [Slot: CGRect] = [:] {
        didSet { needsDisplay = true }
    }

    var selection: Set<Slot> = [] {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        Settings.overlayBackgroundColor.setFill()
        dirtyRect.fill()

        for slot in Slot.allCases {
            guard let rect = slots[slot] else { continue }

            if selection.contains(slot) {
                Settings.overlayHighlightColor.setFill()
                rect.fill()
            }

            let outline = NSBezierPath(rect: rect.insetBy(dx: 0.5, dy: 0.5))
            outline.lineWidth = Settings.overlayLineWidth
            Settings.overlayLineColor.setStroke()
            outline.stroke()

            drawLabel(slot.label, in: rect)
        }
    }

    private func drawLabel(_ text: String, in rect: CGRect) {
        let font = NSFont.systemFont(ofSize: Settings.overlayLabelFontSize, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: Settings.overlayLabelColor
        ]
        let size = text.size(withAttributes: attributes)
        let point = CGPoint(
            x: rect.midX - (size.width / 2),
            y: rect.midY - (size.height / 2)
        )
        text.draw(at: point, withAttributes: attributes)
    }
}
