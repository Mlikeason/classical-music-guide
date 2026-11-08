import AppKit

// Original vector artwork. Opaque 1024px source, no third-party images or fonts.
let size = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                        bytesPerRow: size * 4, space: colorSpace,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
context.setFillColor(CGColor(red: 0.39, green: 0.16, blue: 0.13, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: size, height: size))
context.setStrokeColor(CGColor(red: 0.91, green: 0.75, blue: 0.54, alpha: 0.32))
context.setLineWidth(3)
for index in 0..<5 {
    let y = CGFloat(310 + index * 86)
    context.move(to: CGPoint(x: 136, y: y))
    context.addLine(to: CGPoint(x: 888, y: y))
    context.strokePath()
}
context.setFillColor(CGColor(red: 0.98, green: 0.94, blue: 0.84, alpha: 1))
context.setStrokeColor(CGColor(red: 0.98, green: 0.94, blue: 0.84, alpha: 1))
context.setLineWidth(18)
context.setLineCap(.round)
for (x,y) in [(CGFloat(320),CGFloat(340)),(CGFloat(626),CGFloat(426))] {
    context.saveGState()
    context.translateBy(x: x, y: y)
    context.rotate(by: 0.3)
    context.fillEllipse(in: CGRect(x: -70, y: -46, width: 140, height: 92))
    context.restoreGState()
    context.move(to: CGPoint(x: x+58, y:y+12))
    context.addLine(to: CGPoint(x: x+58, y: y+306))
    context.strokePath()
}
let beam = CGMutablePath()
beam.move(to: CGPoint(x: 369, y: 642))
beam.addLine(to: CGPoint(x: 693, y: 733))
beam.addLine(to: CGPoint(x: 693, y: 677))
beam.addLine(to: CGPoint(x: 369, y: 586))
beam.closeSubpath()
context.addPath(beam); context.fillPath()
let image = context.makeImage()!
let bitmap = NSBitmapImageRep(cgImage: image)
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
