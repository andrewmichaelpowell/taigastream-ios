//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell
//
//  Generates the custom SF Symbols used by the Control Center controls:
//  taiga.radio.1-32 (the "radio" symbol with the stream number) and
//  taiga.podcast.1-32 (the "mic" symbol with the podcast number).
//
//  The base glyphs are pulled as vectors from the system symbols, the number
//  is set in SF Pro Rounded, and the glyph is knocked out around the number.
//
//  Usage (macOS):
//    swift Tools/GenerateControlSymbols.swift export "Taiga Stream Widget/Assets.xcassets"
//    swift Tools/GenerateControlSymbols.swift preview preview.png

import AppKit
import SwiftUI
import CoreText

// MARK: PDF -> CGPath
final class Collector {
	var ctm = CGAffineTransform.identity
	var stack: [CGAffineTransform] = []
	var current = CGMutablePath()
	let output = CGMutablePath()
	var streams: [CGPDFContentStreamRef] = []
	var table: CGPDFOperatorTableRef!
	func num(_ s: CGPDFScannerRef) -> CGFloat { var v: CGPDFReal = 0; CGPDFScannerPopNumber(s, &v); return CGFloat(v) }
	func fill(evenOdd: Bool = false) {
		let p = current.copy(using: [ctm])!.normalized(using: evenOdd ? .evenOdd : .winding)
		output.addPath(p); current = CGMutablePath()
	}
	func run(_ stream: CGPDFContentStreamRef) {
		streams.append(stream)
		let sc = CGPDFScannerCreate(stream, table, Unmanaged.passUnretained(self).toOpaque())
		CGPDFScannerScan(sc)
		streams.removeLast()
	}
}
func C(_ i: UnsafeMutableRawPointer?) -> Collector { Unmanaged<Collector>.fromOpaque(i!).takeUnretainedValue() }

func symbolPath(_ name: String, pointSize: CGFloat) -> CGPath {
	let url = URL(fileURLWithPath: NSTemporaryDirectory() + "sym-\(name).pdf")
	MainActor.assumeIsolated {
		let r = ImageRenderer(content: Image(systemName: name).font(.system(size: pointSize, weight: .regular)))
		r.render { size, draw in
			var box = CGRect(origin: .zero, size: size)
			let ctx = CGContext(url as CFURL, mediaBox: &box, nil)!
			ctx.beginPDFPage(nil); draw(ctx); ctx.endPDFPage(); ctx.closePDF()
		}
	}
	let page = CGPDFDocument(url as CFURL)!.page(at: 1)!
	let c = Collector()
	let t = CGPDFOperatorTableCreate()!
	c.table = t
	CGPDFOperatorTableSetCallback(t, "q") { _, i in let c = C(i); c.stack.append(c.ctm) }
	CGPDFOperatorTableSetCallback(t, "Q") { _, i in let c = C(i); c.ctm = c.stack.popLast() ?? .identity }
	CGPDFOperatorTableSetCallback(t, "cm") { s, i in
		let c = C(i); let f = c.num(s), e = c.num(s), d = c.num(s), cc = c.num(s), b = c.num(s), a = c.num(s)
		c.ctm = CGAffineTransform(a: a, b: b, c: cc, d: d, tx: e, ty: f).concatenating(c.ctm)
	}
	CGPDFOperatorTableSetCallback(t, "m") { s, i in let c = C(i); let y = c.num(s), x = c.num(s); c.current.move(to: .init(x: x, y: y)) }
	CGPDFOperatorTableSetCallback(t, "l") { s, i in let c = C(i); let y = c.num(s), x = c.num(s); c.current.addLine(to: .init(x: x, y: y)) }
	CGPDFOperatorTableSetCallback(t, "c") { s, i in
		let c = C(i); let y3 = c.num(s), x3 = c.num(s), y2 = c.num(s), x2 = c.num(s), y1 = c.num(s), x1 = c.num(s)
		c.current.addCurve(to: .init(x: x3, y: y3), control1: .init(x: x1, y: y1), control2: .init(x: x2, y: y2))
	}
	CGPDFOperatorTableSetCallback(t, "v") { s, i in
		let c = C(i); let y3 = c.num(s), x3 = c.num(s), y2 = c.num(s), x2 = c.num(s)
		c.current.addCurve(to: .init(x: x3, y: y3), control1: c.current.currentPoint, control2: .init(x: x2, y: y2))
	}
	CGPDFOperatorTableSetCallback(t, "y") { s, i in
		let c = C(i); let y3 = c.num(s), x3 = c.num(s), y1 = c.num(s), x1 = c.num(s)
		c.current.addCurve(to: .init(x: x3, y: y3), control1: .init(x: x1, y: y1), control2: .init(x: x3, y: y3))
	}
	CGPDFOperatorTableSetCallback(t, "h") { _, i in C(i).current.closeSubpath() }
	CGPDFOperatorTableSetCallback(t, "re") { s, i in
		let c = C(i); let h = c.num(s), w = c.num(s), y = c.num(s), x = c.num(s)
		c.current.addRect(.init(x: x, y: y, width: w, height: h))
	}
	for op in ["f", "F"] { CGPDFOperatorTableSetCallback(t, op) { _, i in C(i).fill() } }
	CGPDFOperatorTableSetCallback(t, "f*") { _, i in C(i).fill(evenOdd: true) }
	CGPDFOperatorTableSetCallback(t, "n") { _, i in C(i).current = CGMutablePath() }
	CGPDFOperatorTableSetCallback(t, "Do") { s, i in
		let c = C(i)
		var name: UnsafePointer<CChar>?
		guard CGPDFScannerPopName(s, &name), let name, let parent = c.streams.last,
			let obj = CGPDFContentStreamGetResource(parent, "XObject", name) else { return }
		var stream: CGPDFStreamRef?
		guard CGPDFObjectGetValue(obj, .stream, &stream), let stream,
			let dict = CGPDFStreamGetDictionary(stream) else { return }
		c.stack.append(c.ctm)
		var m: CGPDFArrayRef?
		if CGPDFDictionaryGetArray(dict, "Matrix", &m), let m {
			var v = [CGPDFReal](repeating: 0, count: 6)
			for k in 0..<6 { CGPDFArrayGetNumber(m, k, &v[k]) }
			c.ctm = CGAffineTransform(a: v[0], b: v[1], c: v[2], d: v[3], tx: v[4], ty: v[5]).concatenating(c.ctm)
		}
		var res: CGPDFDictionaryRef?
		CGPDFDictionaryGetDictionary(dict, "Resources", &res)
		c.run(CGPDFContentStreamCreateWithStream(stream, res ?? dict, parent))
		c.ctm = c.stack.popLast()!
	}
	c.run(CGPDFContentStreamCreateWithPage(page))
	return c.output
}

// MARK: digits
func textPath(_ text: String, size: CGFloat) -> CGPath {
	let base = NSFont.systemFont(ofSize: size, weight: .semibold)
	let desc = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
	let font = NSFont(descriptor: desc, size: size)! as CTFont
	let attr = NSAttributedString(string: text, attributes: [.font: font, .kern: -size * 0.02])
	let line = CTLineCreateWithAttributedString(attr)
	let path = CGMutablePath()
	for run in CTLineGetGlyphRuns(line) as! [CTRun] {
		let n = CTRunGetGlyphCount(run)
		var glyphs = [CGGlyph](repeating: 0, count: n); var pos = [CGPoint](repeating: .zero, count: n)
		CTRunGetGlyphs(run, CFRange(), &glyphs); CTRunGetPositions(run, CFRange(), &pos)
		let rf = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont
		for k in 0..<n {
			if let g = CTFontCreatePathForGlyph(rf, glyphs[k], nil) {
				path.addPath(g, transform: .init(translationX: pos[k].x, y: pos[k].y))
			}
		}
	}
	return path
}

// MARK: composition (y-up coordinates, baseline at 0, cap height 70.459)
let capHeight: CGFloat = 70.459
/// A control symbol: the glyph (drawn as the dimmed secondary layer) and the
/// number (the solid primary layer).
struct Composed {
	let glyph: CGPath
	let digits: CGPath
	var all: CGPath {
		let p = CGMutablePath()
		p.addPath(glyph)
		p.addPath(digits)
		return p
	}
}

func compose(symbol: String, number: Int, digitSize: CGFloat = 60, overhang: CGFloat = 0.6, drop: CGFloat = 0.2, gap: CGFloat = 6, glyphScale: CGFloat = 1.0, topLift: CGFloat = 0) -> Composed {
	let glyph = symbolPath(symbol, pointSize: 100).normalized()
	let gb = glyph.boundingBoxOfPath
	let gScale = glyphScale
	let g = glyph.copy(using: [CGAffineTransform(translationX: -gb.minX, y: -gb.minY).concatenating(.init(scaleX: gScale, y: gScale))])!
	let gbox0 = g.boundingBoxOfPath
	let g2 = g.copy(using: [CGAffineTransform(translationX: 0, y: capHeight - gbox0.height + (gbox0.height - capHeight) * 0.5 + topLift)])!
	let gbox = g2.boundingBoxOfPath

	let digits = textPath("\(number)", size: digitSize).normalized()
	let db = digits.boundingBoxOfPath
	let dx = gbox.maxX - overhang - db.minX
	let dy = -capHeight * drop
	let d2 = digits.copy(using: [CGAffineTransform(translationX: dx, y: dy)])!
	let halo = d2.copy(strokingWithWidth: gap * 2, lineCap: .round, lineJoin: .round, miterLimit: 4)
	let knockout = halo.union(d2)
	let originals = g2.componentsSeparated().map(\.boundingBoxOfPath)
	let out = CGMutablePath()
	for piece in g2.subtracting(knockout).componentsSeparated() {
		let b = piece.boundingBoxOfPath
		let untouched = originals.contains {
			abs($0.minX - b.minX) < 0.5 && abs($0.minY - b.minY) < 0.5
				&& abs($0.width - b.width) < 0.5 && abs($0.height - b.height) < 0.5
		}
		if untouched || b.width * b.height >= 90 { out.addPath(piece) }
	}
	return Composed(glyph: out, digits: d2)
}

func render(_ symbols: [Composed], file: String) {
	let cell: CGFloat = 220
	let W = Int(cell) * symbols.count, H = Int(cell)
	let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
	let ctx = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
	ctx.setFillColor(.white); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
	// Same scale for every cell so relative sizes are visible.
	let maxSide = symbols.map { max($0.all.boundingBoxOfPath.width, $0.all.boundingBoxOfPath.height) }.max() ?? 1
	for (i, sym) in symbols.enumerated() {
		let b = sym.all.boundingBoxOfPath
		let s = (cell * 0.8) / maxSide
		ctx.saveGState()
		ctx.translateBy(x: CGFloat(i) * cell + cell / 2, y: cell / 2)
		ctx.scaleBy(x: s, y: s)
		ctx.translateBy(x: -b.midX, y: -b.midY)
		ctx.addPath(sym.glyph); ctx.setFillColor(CGColor(gray: 0, alpha: 0.4)); ctx.fillPath()
		ctx.addPath(sym.digits); ctx.setFillColor(.black); ctx.fillPath()
		ctx.restoreGState()
	}
	try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: file))
}

let args = CommandLine.arguments
struct Style { let tuck: CGFloat; let drop: CGFloat; let size: CGFloat; let scale: CGFloat }
let styles: [String: Style] = [
	"radio": Style(tuck: 30, drop: 0.22, size: 64, scale: 0.85),
	"mic": Style(tuck: 10, drop: 0.22, size: 64, scale: 0.85),
]
func make(_ sym: String, _ n: Int, glyphScale: CGFloat? = nil) -> Composed {
	let s = styles[sym]!
	return compose(symbol: sym, number: n, digitSize: s.size, overhang: s.tuck, drop: s.drop, glyphScale: glyphScale ?? s.scale)
}

// MARK: Control symbol layout
//
// Every control symbol uses the same layout so the number is the same size
// and in the same place in all 64 controls: the glyph is fitted into a fixed
// box at the top left, the number sits below and to the right of it with a
// slight overlap, and every symbol gets the same canvas width (Control Center
// scales symbols to a fixed width) with its content centered in it.

let glyphBox: CGFloat = 60
let numberSize: CGFloat = 64
let overlapX: CGFloat = 14
let overlapY: CGFloat = 12
let knockoutGap: CGFloat = 6

func makeControlSymbol(_ sym: String, _ n: Int) -> Composed {
	// Glyph: fit inside the box, hugging its bottom-right corner (toward
	// the number).
	let raw = symbolPath(sym, pointSize: 100).normalized()
	let rb = raw.boundingBoxOfPath
	let scale = min(glyphBox / rb.width, glyphBox / rb.height)
	let glyph = raw.copy(using: [
		CGAffineTransform(translationX: -rb.minX, y: -rb.minY)
			.concatenating(.init(scaleX: scale, y: scale))
			.concatenating(.init(
				translationX: glyphBox - rb.width * scale,
				y: 0
			))
	])!

	// Number: its top-left corner overlaps the glyph box's bottom-right.
	let rawDigits = textPath("\(n)", size: numberSize).normalized()
	let db = rawDigits.boundingBoxOfPath
	let digits = rawDigits.copy(using: [
		CGAffineTransform(
			translationX: glyphBox - overlapX - db.minX,
			y: overlapY - db.maxY
		)
	])!

	// Knock the glyph out around the number, dropping slivers left over.
	let halo = digits.copy(
		strokingWithWidth: knockoutGap * 2,
		lineCap: .round,
		lineJoin: .round,
		miterLimit: 4
	)
	let knockout = halo.union(digits)
	let originals = glyph.componentsSeparated().map(\.boundingBoxOfPath)
	let cut = CGMutablePath()
	for piece in glyph.subtracting(knockout).componentsSeparated() {
		let b = piece.boundingBoxOfPath
		let untouched = originals.contains {
			abs($0.minX - b.minX) < 0.5 && abs($0.minY - b.minY) < 0.5
				&& abs($0.width - b.width) < 0.5
				&& abs($0.height - b.height) < 0.5
		}
		if untouched || b.width * b.height >= 60 { cut.addPath(piece) }
	}

	// Center the combined image vertically on the cap height.
	let combined = Composed(glyph: cut, digits: digits)
	let cb = combined.all.boundingBoxOfPath
	let shift = CGAffineTransform(
		translationX: -cb.minX,
		y: capHeight / 2 - cb.midY
	)
	return Composed(
		glyph: combined.glyph.copy(using: [shift])!,
		digits: combined.digits.copy(using: [shift])!
	)
}

/// The shared canvas width: the widest of all control symbols, plus a
/// little padding.
let controlCanvasWidth: CGFloat = {
	var widest: CGFloat = 0
	for sym in ["radio", "mic"] {
		for n in 1...32 {
			widest = max(widest, makeControlSymbol(sym, n).all.boundingBoxOfPath.width)
		}
	}
	return widest + 2
}()
if args.count > 2 && args[1] == "preview" {
	var ps: [Composed] = []
	for (sym, n) in [("radio", 1), ("radio", 8), ("radio", 12), ("radio", 32), ("mic", 4), ("mic", 18), ("mic", 30)] { ps.append(makeControlSymbol(sym, n)) }
	render(ps, file: args[2])
}

// MARK: SVG export
func svgPathData(_ path: CGPath, originX: CGFloat, baseline: CGFloat) -> String {
	func f(_ v: CGFloat) -> String { String(format: "%.3f", v) }
	func p(_ pt: CGPoint) -> String { "\(f(originX + pt.x)) \(f(baseline - pt.y))" }
	var d = ""
	path.applyWithBlock { el in
		let e = el.pointee
		switch e.type {
		case .moveToPoint: d += "M\(p(e.points[0]))"
		case .addLineToPoint: d += "L\(p(e.points[0]))"
		case .addQuadCurveToPoint: d += "Q\(p(e.points[0])) \(p(e.points[1]))"
		case .addCurveToPoint: d += "C\(p(e.points[0])) \(p(e.points[1])) \(p(e.points[2]))"
		case .closeSubpath: d += "Z"
		@unknown default: break
		}
	}
	return d
}

/// Writes a symbol in the SF Symbols 7 template format. The same outline is
/// used for the Ultralight, Regular and Black small masters, so every weight
/// draws the same glyph; the path is tagged as the monochrome/hierarchical
/// primary layer so the system can render it in any symbol rendering mode
/// (Control Center draws controls with layered rendering, and an untagged
/// legacy template draws nothing there).
func symbolSVG(_ symbol: Composed) -> String {
	let b = symbol.all.boundingBoxOfPath
	let guide = "style=\"fill:none;stroke:#27AAE1;opacity:1;stroke-width:0.5;\""
	let margin = "style=\"fill:none;stroke:#00AEEF;stroke-width:0.5;opacity:1.0;\""
	// The number is the solid primary layer; the glyph is the secondary
	// layer, which hierarchical rendering draws more transparent (like the
	// circle in the system's numbered circle symbols).
	let numberLayer =
		"monochrome-0 multicolor-0:tintColor hierarchical-0:primary SFSymbolsPreview007AFF"
	let glyphLayer =
		"monochrome-1 multicolor-1:tintColor hierarchical-1:secondary SFSymbolsPreview007AFF"
	let masters: [(name: String, x: CGFloat)] = [
		("Ultralight-S", 560), ("Regular-S", 1450), ("Black-S", 2340),
	]
	var margins = ""
	var glyphs = ""
	for master in masters {
		let left = master.x, right = master.x + controlCanvasWidth
		margins += """
			  <line id="left-margin-\(master.name)" \(margin) x1="\(left)" x2="\(left)" y1="600.785" y2="720.121"/>
			  <line id="right-margin-\(master.name)" \(margin) x1="\(right)" x2="\(right)" y1="600.785" y2="720.121"/>

			"""
		glyphs += """
			  <g id="\(master.name)">
			   <path class="\(glyphLayer)" d="\(svgPathData(symbol.glyph, originX: master.x + (controlCanvasWidth - b.width) / 2 - b.minX, baseline: 696))"/>
			   <path class="\(numberLayer)" d="\(svgPathData(symbol.digits, originX: master.x + (controlCanvasWidth - b.width) / 2 - b.minX, baseline: 696))"/>
			  </g>

			"""
	}
	return """
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
	<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="3300" height="2200">
	 <!--glyph: "", point size: 100.0, font version: "", template writer version: "138.0.0"-->
	 <style>.monochrome-0 {-sfsymbols-motion-group:0}
	.monochrome-1 {-sfsymbols-motion-group:1}
	.multicolor-0:tintColor {-sfsymbols-motion-group:0}
	.multicolor-1:tintColor {-sfsymbols-motion-group:1}
	.hierarchical-0:primary {-sfsymbols-motion-group:0}
	.hierarchical-1:secondary {-sfsymbols-motion-group:1}
	.SFSymbolsPreview007AFF {fill:#007AFF;opacity:1.0}
	</style>
	 <g id="Notes">
	  <rect height="2200" id="artboard" style="fill:white;opacity:1" width="3300" x="0" y="0"/>
	  <text id="template-version" style="stroke:none;fill:black;font-family:sans-serif;font-size:13;" transform="matrix(1 0 0 1 263 1933)">Template v.7.0</text>
	 </g>
	 <g id="Guides">
	  <line id="Baseline-S" \(guide) x1="263" x2="3036" y1="696" y2="696"/>
	  <line id="Capline-S" \(guide) x1="263" x2="3036" y1="625.541" y2="625.541"/>
	  <line id="Baseline-M" \(guide) x1="263" x2="3036" y1="1126" y2="1126"/>
	  <line id="Capline-M" \(guide) x1="263" x2="3036" y1="1055.54" y2="1055.54"/>
	  <line id="Baseline-L" \(guide) x1="263" x2="3036" y1="1556" y2="1556"/>
	  <line id="Capline-L" \(guide) x1="263" x2="3036" y1="1485.54" y2="1485.54"/>
	\(margins) </g>
	 <g id="Symbols">
	\(glyphs) </g>
	</svg>
	"""
}

if args.count > 2 && args[1] == "export" {
	let outDir = URL(fileURLWithPath: args[2])
	let fm = FileManager.default
	for (sym, prefix) in [("radio", "taiga.radio"), ("mic", "taiga.podcast")] {
		for n in 1...32 {
			let name = "\(prefix).\(n)"
			let dir = outDir.appendingPathComponent("\(name).symbolset")
			try? fm.removeItem(at: dir)
			try! fm.createDirectory(at: dir, withIntermediateDirectories: true)
			try! symbolSVG(makeControlSymbol(sym, n)).write(to: dir.appendingPathComponent("\(name).svg"), atomically: true, encoding: .utf8)
			let contents = """
			{
			  "info" : {
			    "author" : "xcode",
			    "version" : 1
			  },
			  "symbols" : [
			    {
			      "filename" : "\(name).svg",
			      "idiom" : "universal"
			    }
			  ]
			}
			"""
			try! contents.write(to: dir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
		}
	}
}
