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

func drawUkraineScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleRed)
    rounded(CGRect(x: x + 338, y: y + 96, width: 72, height: 112),
            radius: 4, ink)
    for row in 0..<4 {
        for column in 0..<3 {
            rectangle(CGRect(x: x + 348 + CGFloat(column) * 19,
                             y: y + 108 + CGFloat(row) * 22,
                             width: 9, height: 10), color(0xf3c974))
        }
    }
    polygon([
        (x + 377, y + 194), (x + 394, y + 208), (x + 409, y + 193),
        (x + 397, y + 181), (x + 383, y + 183)
    ], coral)
    polygon([
        (x + 346, y + 96), (x + 360, y + 86), (x + 378, y + 96),
        (x + 365, y + 108)
    ], muted)
    polygon([
        (x + 331, y + 83), (x + 352, y + 83), (x + 342, y + 98)
    ], gold)
    line(x + 333, y + 78, x + 350, y + 78, ink, width: 3)
    circle(CGRect(x: x + 338, y: y + 73, width: 7, height: 7), coral)
}

func drawSudanScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleGold)
    rounded(CGRect(x: x + 326, y: y + 94, width: 92, height: 95),
            radius: 5, teal)
    rectangle(CGRect(x: x + 338, y: y + 176, width: 65, height: 20), ink)
    text("UN", x: x + 353, y: y + 179, size: 14, fill: white, weight: .bold)
    for row in 0..<2 {
        for column in 0..<4 {
            rectangle(CGRect(x: x + 337 + CGFloat(column) * 19,
                             y: y + 111 + CGFloat(row) * 24,
                             width: 10, height: 11), color(0xeaf0e8))
        }
    }
    line(x + 382, y + 141, x + 398, y + 151, coral, width: 4)
    line(x + 398, y + 151, x + 388, y + 159, coral, width: 4)
    circle(CGRect(x: x + 367, y: y + 205, width: 14, height: 14), ink)
    line(x + 374, y + 211, x + 350, y + 225, ink, width: 3)
    line(x + 374, y + 211, x + 397, y + 225, ink, width: 3)
    line(x + 353, y + 223, x + 346, y + 223, coral, width: 3)
    line(x + 397, y + 223, x + 404, y + 223, coral, width: 3)
}

func drawMarketScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleBlue)
    line(x + 326, y + 101, x + 326, y + 193, muted, width: 2)
    line(x + 326, y + 101, x + 421, y + 101, muted, width: 2)
    for offset in [0, 1, 2] {
        let level = y + 121 + CGFloat(offset) * 25
        line(x + 329, level, x + 417, level, color(0xc9d8de), width: 1)
    }
    let points: [(CGFloat, CGFloat)] = [
        (x + 334, y + 178), (x + 350, y + 163), (x + 367, y + 170),
        (x + 383, y + 133), (x + 399, y + 119), (x + 413, y + 145)
    ]
    for index in 0..<(points.count - 1) {
        line(points[index].0, points[index].1, points[index + 1].0,
             points[index + 1].1, index < 3 ? coral : teal, width: 4)
    }
    circle(CGRect(x: x + 408, y: y + 140, width: 10, height: 10), teal)
}

func drawScienceScene(x: CGFloat, y: CGFloat) {
    circle(CGRect(x: x + 306, y: y + 84, width: 126, height: 126), paleTeal)
    polygon([
        (x + 315, y + 117), (x + 340, y + 117), (x + 357, y + 101),
        (x + 379, y + 101), (x + 399, y + 119), (x + 424, y + 119),
        (x + 424, y + 88), (x + 315, y + 88)
    ], color(0x4d95aa))
    polygon([
        (x + 316, y + 88), (x + 342, y + 88), (x + 357, y + 66),
        (x + 381, y + 66), (x + 401, y + 88), (x + 424, y + 88),
        (x + 424, y + 84), (x + 316, y + 84)
    ], ink)
    line(x + 320, y + 133, x + 421, y + 133, white, width: 2)
    line(x + 320, y + 147, x + 412, y + 147, color(0x91c5cb), width: 2)
    rounded(CGRect(x: x + 337, y: y + 157, width: 43, height: 17),
            radius: 8, ink)
    circle(CGRect(x: x + 350, y: y + 163, width: 6, height: 6), gold)
    line(x + 379, y + 165, x + 393, y + 165, ink, width: 3)
    polygon([
        (x + 337, y + 157), (x + 321, y + 183), (x + 354, y + 174)
    ], color(0xf0b84c, alpha: 0.55))
}

func drawCard(x: CGFloat, y: CGFloat, label: String, first: String,
              second: String, detail1: String, detail2: String? = nil,
              accent: NSColor, scene: Int) {
    cardBase(x: x, y: y, accent: accent)
    cardHeading(label, first, second, detail1, detail2, x: x, y: y, accent: accent)
    switch scene {
    case 0:
        drawUkraineScene(x: x, y: y)
    case 1:
        drawSudanScene(x: x, y: y)
    case 2:
        drawMarketScene(x: x, y: y)
    default:
        drawScienceScene(x: x, y: y)
    }
}

rectangle(CGRect(x: 0, y: 0, width: width, height: height), paper)
rectangle(CGRect(x: 0, y: 1012, width: width, height: 12), coral)
text("GLOBAL DESK   /   MONDAY, 23 NOVEMBER 2026",
     x: 48, y: 970, size: 17, fill: muted, weight: .bold)
text("THE WORLD", x: 48, y: 874, size: 76, fill: ink, weight: .heavy)
text("IN FOUR FRONTS", x: 51, y: 817, size: 43, fill: coral, weight: .bold)
text("Four signals from a fast-moving day.", x: 53, y: 779,
     size: 20, fill: muted)
drawGlobe(cx: 850, cy: 857, radius: 76)
line(42, 751, 982, 751, ink, width: 2)

drawCard(x: 40, y: 423, label: "EUROPE  /  UKRAINE",
         first: "RUSSIAN STRIKE", second: "KILLS AT LEAST 11",
         detail1: "Dymer block collapses;",
         detail2: "rescuers search the rubble.",
         accent: coral, scene: 0)
drawCard(x: 528, y: 423, label: "AFRICA  /  KHARTOUM",
         first: "DRONE HITS", second: "RESIDENTIAL AREA",
         detail1: "UN building damaged;",
         detail2: "casualties and attacker unreported.",
         accent: teal, scene: 1)
drawCard(x: 40, y: 96, label: "ASIA  /  MARKETS",
         first: "AI SELL-OFF", second: "WEIGHS ON SHARES",
         detail1: "Asian shares lower;",
         detail2: "US futures rebound.",
         accent: blue, scene: 2)
drawCard(x: 528, y: 96, label: "PACIFIC  /  SCIENCE",
         first: "MARIANA TRENCH", second: "DEEP-SEA FIND",
         detail1: "Pyroclastic rocks found",
         detail2: "6,148 metres below sea.",
         accent: teal, scene: 3)

rounded(CGRect(x: 40, y: 44, width: 944, height: 38), radius: 12, paleGold)
text("ALSO MONDAY: CROWDSTRIKE TO BUY ZSCALER IN A $44B ALL-STOCK DEAL",
     x: 55, y: 55, size: 17, fill: ink, weight: .bold)
text("SOURCES: AP  /  THE GUARDIAN  /  BERNAMA-DPA  /  PHYS.ORG",
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
