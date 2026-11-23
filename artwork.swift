import AppKit
import Darwin
import Foundation

let width = 1024
let height = 1024
let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!
let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
graphics.imageInterpolation = .high
graphics.cgContext.setShouldAntialias(true)

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

let paper = color(0xf3efe5)
let white = color(0xfffdf7)
let ink = color(0x172b3a)
let muted = color(0x52636c)
let coral = color(0xd85843)
let teal = color(0x16877f)
let gold = color(0xf0b84c)
let blue = color(0x3479a5)
let paleRed = color(0xf6dfd6)
let paleTeal = color(0xdcece6)
let paleBlue = color(0xddeaf0)
let paleGold = color(0xf4e8c9)

func rectangle(_ rect: CGRect, _ fill: NSColor) {
    fill.setFill()
    NSBezierPath(rect: rect).fill()
}

func rounded(_ rect: CGRect, radius: CGFloat, _ fill: NSColor) {
    fill.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func circle(_ rect: CGRect, _ fill: NSColor) {
    fill.setFill()
    NSBezierPath(ovalIn: rect).fill()
}

func strokeCircle(_ rect: CGRect, _ stroke: NSColor, width: CGFloat) {
    stroke.setStroke()
    let path = NSBezierPath(ovalIn: rect)
    path.lineWidth = width
    path.stroke()
}

func line(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat,
          _ stroke: NSColor, width: CGFloat = 2) {
    stroke.setStroke()
    let path = NSBezierPath()
    path.lineWidth = width
    path.lineCapStyle = .round
    path.move(to: NSPoint(x: x1, y: y1))
    path.line(to: NSPoint(x: x2, y: y2))
    path.stroke()
}

func polygon(_ points: [(CGFloat, CGFloat)], _ fill: NSColor) {
    guard let first = points.first else { return }
    let path = NSBezierPath()
    path.move(to: NSPoint(x: first.0, y: first.1))
    for point in points.dropFirst() {
        path.line(to: NSPoint(x: point.0, y: point.1))
    }
    path.close()
    fill.setFill()
    path.fill()
}

func text(_ value: String, x: CGFloat, y: CGFloat, size: CGFloat,
          fill: NSColor, weight: NSFont.Weight = .regular) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: fill
    ]
    (value as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: attributes)
}

func drawGlobe(cx: CGFloat, cy: CGFloat, radius: CGFloat) {
    let globe = CGRect(x: cx - radius, y: cy - radius,
                       width: radius * 2, height: radius * 2)
    circle(globe, ink)
    strokeCircle(globe.insetBy(dx: 1, dy: 1), color(0x314858), width: 2)

    let grid = color(0x718691, alpha: 0.65)
    for fraction in [-0.5, 0.0, 0.5] {
        let oval = CGRect(x: cx - radius * CGFloat(abs(fraction) == 0 ? 1 : 0.72),
                          y: cy - radius,
                          width: radius * 2 * CGFloat(abs(fraction) == 0 ? 1 : 0.72),
                          height: radius * 2)
        grid.setStroke()
        let path = NSBezierPath(ovalIn: oval)
        path.lineWidth = 1.2
        path.stroke()
    }
    for factor in [-0.42, 0.0, 0.42] {
        let oval = CGRect(x: cx - radius, y: cy - radius * (0.25 + factor * 0.15),
                          width: radius * 2, height: radius * 0.5)
        grid.setStroke()
        let path = NSBezierPath(ovalIn: oval)
        path.lineWidth = 1
        path.stroke()
    }
    polygon([
        (cx - 52, cy + 24), (cx - 30, cy + 49), (cx - 6, cy + 40),
        (cx + 4, cy + 18), (cx - 17, cy + 4), (cx - 38, cy + 8)
    ], teal)
    polygon([
        (cx + 14, cy + 35), (cx + 40, cy + 44), (cx + 60, cy + 25),
        (cx + 46, cy + 9), (cx + 25, cy + 13)
    ], gold)
    polygon([
        (cx + 4, cy - 5), (cx + 25, cy - 12), (cx + 20, cy - 39),
        (cx + 4, cy - 55), (cx - 4, cy - 30)
    ], coral)
}

func cardBase(x: CGFloat, y: CGFloat, accent: NSColor) {
    rounded(CGRect(x: x + 3, y: y - 5, width: 456, height: 300),
            radius: 22, color(0x122432, alpha: 0.08))
    rounded(CGRect(x: x, y: y, width: 456, height: 300), radius: 22, white)
    rounded(CGRect(x: x, y: y, width: 9, height: 300), radius: 4, accent)
}

func cardHeading(_ label: String, _ first: String, _ second: String,
                 _ detail1: String, _ detail2: String? = nil,
                 x: CGFloat, y: CGFloat, accent: NSColor) {
    text(label, x: x + 24, y: y + 264, size: 16, fill: accent, weight: .bold)
    text(first, x: x + 24, y: y + 207, size: 27, fill: ink, weight: .bold)
    text(second, x: x + 24, y: y + 172, size: 27, fill: ink, weight: .bold)
    text(detail1, x: x + 24, y: y + 113, size: 15, fill: muted)
    if let detail2 {
        text(detail2, x: x + 24, y: y + 91, size: 15, fill: muted)
    }
}

func drawBelgiumScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleBlue)
    polygon([
        (x + 329, y + 145), (x + 412, y + 145), (x + 405, y + 168),
        (x + 336, y + 168)
    ], ink)
    rectangle(CGRect(x: x + 338, y: y + 111, width: 68, height: 27), white)
    polygon([
        (x + 332, y + 138), (x + 372, y + 159), (x + 412, y + 138)
    ], teal)
    for column in 0..<4 {
        rectangle(CGRect(x: x + 347 + CGFloat(column) * 15,
                         y: y + 116, width: 8, height: 15), paleBlue)
    }
    line(x + 322, y + 98, x + 418, y + 98, muted, width: 3)
    line(x + 337, y + 91, x + 337, y + 98, coral, width: 3)
    line(x + 357, y + 91, x + 357, y + 98, coral, width: 3)
    line(x + 378, y + 91, x + 378, y + 98, coral, width: 3)
    line(x + 400, y + 91, x + 400, y + 98, coral, width: 3)
    polygon([
        (x + 331, y + 178), (x + 361, y + 178), (x + 372, y + 164),
        (x + 380, y + 164), (x + 376, y + 178), (x + 405, y + 178),
        (x + 411, y + 183), (x + 376, y + 184), (x + 384, y + 196),
        (x + 377, y + 196), (x + 362, y + 184), (x + 334, y + 184)
    ], gold)
}

func drawZambiaScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleGold)
    polygon([
        (x + 324, y + 166), (x + 369, y + 190), (x + 414, y + 166)
    ], ink)
    rectangle(CGRect(x: x + 330, y: y + 102, width: 78, height: 7), ink)
    rectangle(CGRect(x: x + 335, y: y + 109, width: 68, height: 7), teal)
    for column in 0..<4 {
        let columnX = x + 340 + CGFloat(column) * 16
        rounded(CGRect(x: columnX, y: y + 117, width: 7, height: 44),
                radius: 3, white)
    }
    rectangle(CGRect(x: x + 329, y: y + 161, width: 80, height: 7), ink)
    line(x + 368, y + 172, x + 368, y + 195, coral, width: 3)
    line(x + 347, y + 187, x + 390, y + 187, ink, width: 3)
    line(x + 350, y + 187, x + 344, y + 199, ink, width: 2)
    line(x + 384, y + 187, x + 390, y + 199, ink, width: 2)
    line(x + 336, y + 200, x + 352, y + 200, coral, width: 3)
    line(x + 382, y + 200, x + 398, y + 200, coral, width: 3)
}

func drawHealthScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleRed)
    rounded(CGRect(x: x + 321, y: y + 118, width: 61, height: 51),
            radius: 6, ink)
    rounded(CGRect(x: x + 326, y: y + 123, width: 51, height: 40),
            radius: 3, white)
    circle(CGRect(x: x + 339, y: y + 129, width: 25, height: 28), paleRed)
    line(x + 351, y + 169, x + 351, y + 179, ink, width: 4)
    line(x + 337, y + 180, x + 366, y + 180, ink, width: 4)
    line(x + 390, y + 115, x + 390, y + 180, teal, width: 5)
    line(x + 390, y + 115, x + 408, y + 115, teal, width: 5)
    line(x + 408, y + 115, x + 408, y + 138, teal, width: 5)
    rounded(CGRect(x: x + 385, y: y + 139, width: 34, height: 28),
            radius: 6, coral)
    text("AI", x: x + 392, y: y + 147, size: 16, fill: white, weight: .bold)
    circle(CGRect(x: x + 387, y: y + 185, width: 7, height: 7), gold)
    circle(CGRect(x: x + 400, y: y + 177, width: 7, height: 7), gold)
    circle(CGRect(x: x + 412, y: y + 187, width: 7, height: 7), gold)
    line(x + 390, y + 188, x + 403, y + 180, muted, width: 1)
    line(x + 403, y + 180, x + 415, y + 190, muted, width: 1)
}

func drawMarianaScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleTeal)
    rectangle(CGRect(x: x + 314, y: y + 112, width: 110, height: 70),
              color(0x4d95aa))
    polygon([
        (x + 314, y + 116), (x + 336, y + 116), (x + 354, y + 138),
        (x + 370, y + 104), (x + 383, y + 96), (x + 394, y + 116),
        (x + 424, y + 116), (x + 424, y + 91), (x + 314, y + 91)
    ], ink)
    line(x + 316, y + 124, x + 344, y + 124, color(0x91c5cb), width: 2)
    line(x + 385, y + 124, x + 420, y + 124, color(0x91c5cb), width: 2)
    line(x + 316, y + 137, x + 344, y + 137, color(0x91c5cb), width: 2)
    line(x + 385, y + 137, x + 420, y + 137, color(0x91c5cb), width: 2)
    rounded(CGRect(x: x + 323, y: y + 158, width: 42, height: 17),
            radius: 8, gold)
    circle(CGRect(x: x + 337, y: y + 163, width: 7, height: 7), ink)
    text("ROV", x: x + 326, y: y + 163, size: 8, fill: ink, weight: .bold)
    line(x + 365, y + 166, x + 385, y + 166, gold, width: 3)
    polygon([
        (x + 337, y + 158), (x + 362, y + 186), (x + 376, y + 166)
    ], color(0xf0b84c, alpha: 0.35))
    for offset in [0, 1, 2] {
        circle(CGRect(x: x + 388 + CGFloat(offset) * 11,
                      y: y + 92 + CGFloat(offset % 2) * 5,
                      width: 8, height: 8), coral)
    }
}

func drawCard(x: CGFloat, y: CGFloat, label: String, first: String,
              second: String, detail1: String, detail2: String? = nil,
              accent: NSColor, scene: Int) {
    cardBase(x: x, y: y, accent: accent)
    cardHeading(label, first, second, detail1, detail2, x: x, y: y, accent: accent)
    switch scene {
    case 0:
        drawBelgiumScene(x: x, y: y)
    case 1:
        drawZambiaScene(x: x, y: y)
    case 2:
        drawHealthScene(x: x, y: y)
    default:
        drawMarianaScene(x: x, y: y)
    }
}

rectangle(CGRect(x: 0, y: 0, width: width, height: height), paper)
rectangle(CGRect(x: 0, y: 1012, width: width, height: 12), coral)
text("GLOBAL DESK   /   MONDAY, 23 NOVEMBER 2026",
     x: 48, y: 970, size: 17, fill: muted, weight: .bold)
text("THE WORLD", x: 48, y: 874, size: 76, fill: ink, weight: .heavy)
text("IN FOUR REPORTS", x: 51, y: 817, size: 43, fill: coral, weight: .bold)
text("A Monday dispatch from transport, law, health and science.",
     x: 53, y: 779,
     size: 20, fill: muted)
drawGlobe(cx: 850, cy: 857, radius: 76)
line(42, 751, 982, 751, ink, width: 2)

drawCard(x: 40, y: 423, label: "EUROPE  /  BELGIUM",
         first: "STRIKE GROUNDS", second: "BELGIAN FLIGHTS",
         detail1: "Air traffic halted;",
         detail2: "trains also disrupted.",
         accent: coral, scene: 0)
drawCard(x: 528, y: 423, label: "AFRICA  /  ZAMBIA",
         first: "COURT READS", second: "TREASON CHARGE",
         detail1: "Mundubile denies guilt;",
         detail2: "trial expected next year.",
         accent: teal, scene: 1)
drawCard(x: 40, y: 96, label: "UK  /  HEALTH",
         first: "NHS BEGINS AI", second: "SCREENING TRIAL",
         detail1: "Nearly 700,000 women;",
         detail2: "tests assisted readings.",
         accent: blue, scene: 2)
drawCard(x: 528, y: 96, label: "PACIFIC  /  SCIENCE",
         first: "MARIANA TRENCH", second: "DEEP-SEA FIND",
         detail1: "Deepest known pyroclastic",
         detail2: "rocks: 6,148 metres.",
         accent: teal, scene: 3)

rounded(CGRect(x: 40, y: 44, width: 944, height: 38), radius: 12, paleGold)
text("MONDAY'S NEWS: STRIKES, COURTS, HEALTHCARE AND DEEP-SEA SCIENCE",
     x: 55, y: 55, size: 17, fill: ink, weight: .bold)
text("SOURCES: AL JAZEERA  /  REUTERS  /  NHS ENGLAND  /  PHYS.ORG",
     x: 42, y: 18, size: 12, fill: muted, weight: .medium)

NSGraphicsContext.restoreGraphicsState()
guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Could not encode the illustration as PNG.\n", stderr)
    exit(1)
}
let output = CommandLine.arguments.dropFirst().first ?? "entry.png"
do {
    try png.write(to: URL(fileURLWithPath: output))
} catch {
    fputs("Could not write \(output): \(error)\n", stderr)
    exit(1)
}
