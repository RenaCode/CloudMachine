// Generuje ikone aplikacji CloudMachine (klepsydra na tle chmury) jako .iconset
// z plikow PNG w roznych rozdzielczosciach, gotowe do spakowania przez
// `iconutil -c icns`. Uruchamiane raz przy zmianie wygladu ikony:
//   swift Resources/icon-gen/generate_icon.swift Resources/AppIcon.iconset
import AppKit

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

/// Rysuje symbol SF (obraz-szablon: czarny ksztalt na przezroczystym tle)
/// wypelniony podanym kolorem, uzywajac go jako maski clipowania - to jedyny
/// niezawodny sposob na "przekolorowanie" NSImage template poza kontekstem
/// NSButton/NSImageView, gdzie automatyczne tintowanie by zadzialalo samo.
func drawTintedSymbol(name: String, pointSize: CGFloat, weight: NSFont.Weight, in rect: NSRect, color: NSColor) {
    guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return }
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    guard let configured = symbol.withSymbolConfiguration(config) else { return }
    guard let cgImage = configured.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

    guard let context = NSGraphicsContext.current?.cgContext else { return }
    context.saveGState()
    context.clip(to: rect, mask: cgImage)
    color.setFill()
    context.fill(rect)
    context.restoreGState()
}

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    defer { image.unlockFocus() }

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    // Tlo: zaokraglony kwadrat z gradientem niebieskim (klimat "dysk w chmurze").
    let cornerRadius = size * 0.225
    let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    let gradient = NSGradient(colorsAndLocations:
        (NSColor(calibratedRed: 0.45, green: 0.74, blue: 0.99, alpha: 1.0), 0.0),
        (NSColor(calibratedRed: 0.10, green: 0.40, blue: 0.85, alpha: 1.0), 1.0)
    )
    gradient?.draw(in: backgroundPath, angle: -90)

    // Cien pod chmura, zeby nie "kleila sie" wizualnie do tla.
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.20)
    shadow.shadowBlurRadius = size * 0.035
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.015)
    shadow.set()

    // Chmura biala - symbolizuje Google Drive / backup w chmurze.
    let cloudSize = size * 0.80
    let cloudRect = NSRect(x: (size - cloudSize) / 2, y: size * 0.17, width: cloudSize, height: cloudSize)
    drawTintedSymbol(name: "cloud.fill", pointSize: cloudSize, weight: .regular, in: cloudRect, color: .white)
    NSGraphicsContext.restoreGraphicsState()

    // Klepsydra bursztynowa na srodku chmury - symbolizuje historie / Time Machine.
    let hourglassSize = size * 0.34
    let hourglassRect = NSRect(x: (size - hourglassSize) / 2, y: size * 0.34, width: hourglassSize, height: hourglassSize)
    let amber = NSColor(calibratedRed: 0.80, green: 0.52, blue: 0.06, alpha: 1.0)
    drawTintedSymbol(name: "hourglass", pointSize: hourglassSize, weight: .semibold, in: hourglassRect, color: amber)

    return image
}

func savePNG(_ image: NSImage, to path: String, size: CGFloat) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .sourceOver, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    guard let data = rep.representation(using: .png, properties: [:]) else { return }
    try? data.write(to: URL(fileURLWithPath: path))
}

let targets: [(String, CGFloat)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)
]

for (name, size) in targets {
    let img = drawIcon(size: size)
    savePNG(img, to: outputDir + "/" + name, size: size)
    print("wrote \(name)")
}
