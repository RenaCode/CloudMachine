import SwiftUI

/// The RenaCode visual system for CloudMachine.
/// Color, typography and glassmorphism tokens consistent with Dietetyk-AI and Trader-AI.
public enum RenaCodeTheme {
  // MARK: - Base Colors (Tokens)

  public static let bgDark = Color(red: 7 / 255, green: 9 / 255, blue: 19 / 255)  // #070913
  public static let bgDarkEnd = Color(red: 13 / 255, green: 17 / 255, blue: 39 / 255)  // #0D1127
  // #121629
  public static let bgCard = Color(red: 18 / 255, green: 22 / 255, blue: 41 / 255).opacity(0.75)
  // #121629, for Reduce Transparency
  public static let bgCardSolid = Color(red: 18 / 255, green: 22 / 255, blue: 41 / 255)
  public static let bgInset = Color(red: 9 / 255, green: 12 / 255, blue: 24 / 255).opacity(0.65)
  // #0F1324 sidebar
  public static let bgSidebar = Color(red: 15 / 255, green: 19 / 255, blue: 36 / 255)

  public static let borderGlass = Color.white.opacity(0.08)
  public static let borderGlassStrong = Color.white.opacity(0.14)

  // Color accents
  // #7C3AED AI violet
  public static let colorPrimary = Color(red: 124 / 255, green: 58 / 255, blue: 237 / 255)
  // #C084FC
  public static let colorPrimaryLight = Color(red: 192 / 255, green: 132 / 255, blue: 252 / 255)
  // #6366F1 indigo, the middle of the window frame
  public static let colorIndigo = Color(red: 99 / 255, green: 102 / 255, blue: 241 / 255)
  // #06B6D4 Activity cyan
  public static let colorCyan = Color(red: 6 / 255, green: 182 / 255, blue: 212 / 255)
  // #34D399 Emerald
  public static let colorSuccess = Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255)
  // #F59E0B Orange
  public static let colorWarning = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)
  // #F87171 Red
  public static let colorDanger = Color(red: 248 / 255, green: 113 / 255, blue: 113 / 255)

  // Pill fills: dark enough for white text to keep a 4.5:1 contrast.
  // #047857
  public static let fillSuccess = Color(red: 4 / 255, green: 120 / 255, blue: 87 / 255)
  // #B45309
  public static let fillWarning = Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)
  // #B91C1C
  public static let fillDanger = Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255)
  // #6D28D9
  public static let fillPrimary = Color(red: 109 / 255, green: 40 / 255, blue: 217 / 255)
  // #475569
  public static let fillNeutral = Color(red: 71 / 255, green: 85 / 255, blue: 105 / 255)

  public static let textMain = Color(red: 241 / 255, green: 245 / 255, blue: 249 / 255)  // #F1F5F9
  public static let textMuted = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)  // #94A3B8

  // MARK: - Gradients

  public static let aiGradient = LinearGradient(
    colors: [colorPrimary, colorPrimaryLight],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  /// Violet into cyan: the window frame, progress bars and the active state.
  public static let frameGradient = LinearGradient(
    colors: [colorPrimary, colorIndigo, colorCyan],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  public static let progressGradient = LinearGradient(
    colors: [colorCyan, colorIndigo, colorPrimary],
    startPoint: .leading,
    endPoint: .trailing
  )

  public static let darkGradient = LinearGradient(
    colors: [bgDark, bgDarkEnd],
    startPoint: .top,
    endPoint: .bottom
  )

  public static let cardGradient = LinearGradient(
    colors: [Color.white.opacity(0.05), Color.white.opacity(0.01)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}

// MARK: - Status Tone

/// What a card or a badge says about the state, and therefore its color.
///
/// Green is reserved for a state that is really good. `.brand` is a card
/// that reports a quantity rather than a verdict (the buffer size, a running
/// backup), so it is neither green nor alarming.
public enum StatusTone: Equatable {
  case success
  case warning
  case danger
  case neutral
  case brand
  /// Activity that is expected, such as a queue draining.
  case info

  public var color: Color {
    switch self {
    case .success: return RenaCodeTheme.colorSuccess
    case .warning: return RenaCodeTheme.colorWarning
    case .danger: return RenaCodeTheme.colorDanger
    case .neutral: return RenaCodeTheme.textMuted
    case .brand: return RenaCodeTheme.colorPrimaryLight
    case .info: return RenaCodeTheme.colorCyan
    }
  }

  /// Solid fill for a pill with white text.
  public var fill: Color {
    switch self {
    case .success: return RenaCodeTheme.fillSuccess
    case .warning: return RenaCodeTheme.fillWarning
    case .danger: return RenaCodeTheme.fillDanger
    case .neutral: return RenaCodeTheme.fillNeutral
    case .brand: return RenaCodeTheme.fillPrimary
    // #0E7490
    case .info: return Color(red: 14 / 255, green: 116 / 255, blue: 144 / 255)
    }
  }

  var border: LinearGradient {
    switch self {
    case .brand:
      return LinearGradient(
        colors: [
          RenaCodeTheme.colorCyan.opacity(0.75), RenaCodeTheme.colorPrimary.opacity(0.75),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    case .neutral:
      return LinearGradient(
        colors: [RenaCodeTheme.borderGlassStrong, RenaCodeTheme.borderGlass],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    case .success, .warning, .danger, .info:
      return LinearGradient(
        colors: [color.opacity(0.8), color.opacity(0.45)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    }
  }

  /// The wash behind a status card; the green cards of the mockup.
  var tint: Color {
    switch self {
    case .success, .warning, .danger, .info: return color.opacity(0.12)
    case .brand: return RenaCodeTheme.colorPrimary.opacity(0.08)
    case .neutral: return Color.clear
    }
  }

  /// The worse of two tones: a card made of several facts shows its worst one.
  public func worst(_ other: StatusTone) -> StatusTone {
    rank >= other.rank ? self : other
  }

  private var rank: Int {
    switch self {
    case .neutral: return 0
    case .brand: return 1
    case .info: return 2
    case .success: return 2
    case .warning: return 3
    case .danger: return 4
    }
  }
}

// MARK: - Ambient Orbs Background

public struct AmbientGlowBackground: View {
  public init() {}

  public var body: some View {
    ZStack {
      RenaCodeTheme.darkGradient
        .ignoresSafeArea()

      // Violet glow at the top left
      Circle()
        .fill(RenaCodeTheme.colorPrimary.opacity(0.20))
        .frame(width: 420, height: 420)
        .blur(radius: 110)
        .offset(x: -260, y: -260)

      // Cyan glow at the top right
      Circle()
        .fill(RenaCodeTheme.colorCyan.opacity(0.14))
        .frame(width: 380, height: 380)
        .blur(radius: 110)
        .offset(x: 300, y: -200)
    }
    .allowsHitTesting(false)
  }
}

// MARK: - Window Frame

/// The violet-to-cyan frame around the whole window, with a soft inner glow.
public struct GradientWindowFrame: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  var cornerRadius: CGFloat
  var lineWidth: CGFloat

  public init(cornerRadius: CGFloat = 16, lineWidth: CGFloat = 1.5) {
    self.cornerRadius = cornerRadius
    self.lineWidth = lineWidth
  }

  public var body: some View {
    ZStack {
      if !reduceTransparency {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(RenaCodeTheme.frameGradient, lineWidth: 6)
          .blur(radius: 8)
          .opacity(0.55)
      }
      RoundedRectangle(cornerRadius: cornerRadius)
        .strokeBorder(RenaCodeTheme.frameGradient, lineWidth: lineWidth)
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}

// MARK: - Tone Card

/// A glass card with a gradient border; the tone says whether its content is
/// good, waiting or broken.
public struct ToneCardModifier: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  var tone: StatusTone
  var cornerRadius: CGFloat
  var padding: CGFloat

  public func body(content: Content) -> some View {
    content
      .padding(padding)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(reduceTransparency ? RenaCodeTheme.bgCardSolid : RenaCodeTheme.bgCard)
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(tone.tint)
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(RenaCodeTheme.cardGradient)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .strokeBorder(tone.border, lineWidth: tone == .neutral ? 1 : 1.5)
      )
      .shadow(
        color: tone == .neutral ? Color.black.opacity(0.35) : tone.color.opacity(0.18),
        radius: 16, x: 0, y: 6)
  }
}

extension View {
  public func toneCard(
    _ tone: StatusTone = .neutral, cornerRadius: CGFloat = 16, padding: CGFloat = 18
  ) -> some View {
    modifier(ToneCardModifier(tone: tone, cornerRadius: cornerRadius, padding: padding))
  }
}

// MARK: - Icon Tile

/// The rounded square with a symbol that opens a card heading.
public struct IconTile: View {
  let systemImage: String
  let gradient: LinearGradient
  var size: CGFloat

  public init(systemImage: String, gradient: LinearGradient, size: CGFloat = 32) {
    self.systemImage = systemImage
    self.gradient = gradient
    self.size = size
  }

  public var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: size * 0.28)
        .fill(gradient)
      Image(systemName: systemImage)
        .font(.system(size: size * 0.48, weight: .semibold))
        .foregroundStyle(.white)
    }
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

// MARK: - Status Pill

/// A solid pill with white text, as in the mockup ("Healthy", "Attached").
public struct StatusPill: View {
  let text: String
  let tone: StatusTone
  var icon: String?

  public init(_ text: String, tone: StatusTone, icon: String? = nil) {
    self.text = text
    self.tone = tone
    self.icon = icon
  }

  public var body: some View {
    HStack(spacing: 4) {
      if let icon {
        Image(systemName: icon)
          .font(.system(size: 10, weight: .bold))
          .accessibilityHidden(true)
      }
      Text(text)
        .font(.system(size: 12, weight: .semibold))
        .lineLimit(1)
    }
    // A verdict is never truncated; the text next to it gives way instead.
    .fixedSize()
    .padding(.horizontal, 9)
    .padding(.vertical, 3)
    .foregroundStyle(.white)
    .background(RoundedRectangle(cornerRadius: 6).fill(tone.fill))
  }
}

// MARK: - Status Dot

/// A colored dot; while `live`, a ring pulses around it (not with Reduce Motion).
public struct StatusDot: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var pulsing = false
  let tone: StatusTone
  var live: Bool
  var size: CGFloat

  public init(_ tone: StatusTone, live: Bool = false, size: CGFloat = 8) {
    self.tone = tone
    self.live = live
    self.size = size
  }

  public var body: some View {
    Circle()
      .fill(tone.color)
      .frame(width: size, height: size)
      .shadow(color: tone.color.opacity(0.7), radius: 4)
      .background(
        Circle()
          .stroke(tone.color.opacity(pulsing ? 0 : 0.6), lineWidth: 1.5)
          .scaleEffect(pulsing ? 2.4 : 1)
          .opacity(live && !reduceMotion ? 1 : 0)
      )
      .task(id: live && !reduceMotion) {
        pulsing = false
        guard live, !reduceMotion else { return }
        withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
          pulsing = true
        }
      }
      .accessibilityHidden(true)
  }
}

// MARK: - Progress Bar

public struct GradientProgressBar: View {
  let fraction: Double
  var height: CGFloat

  public init(fraction: Double, height: CGFloat = 8) {
    self.fraction = fraction
    self.height = height
  }

  public var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.white.opacity(0.10))
        Capsule()
          .fill(RenaCodeTheme.progressGradient)
          .frame(width: max(0, min(geo.size.width * CGFloat(fraction), geo.size.width)))
          .shadow(color: RenaCodeTheme.colorIndigo.opacity(0.6), radius: 5)
      }
    }
    .frame(height: height)
  }
}

// MARK: - Pill Badge RenaCode

public struct RenaCodePillBadge: View {
  let text: String
  let icon: String?
  let color: Color

  public init(text: String, icon: String? = nil, color: Color = RenaCodeTheme.colorPrimary) {
    self.text = text
    self.icon = icon
    self.color = color
  }

  public var body: some View {
    HStack(spacing: 5) {
      if let icon = icon {
        Image(systemName: icon)
          .font(.system(size: 10, weight: .bold))
          .accessibilityHidden(true)
      }
      Text(text)
        .font(.system(size: 11, weight: .semibold))
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 4)
    .background(color.opacity(0.12))
    .foregroundStyle(color)
    .clipShape(Capsule())
    .overlay(
      Capsule()
        .stroke(color.opacity(0.35), lineWidth: 1)
    )
  }
}

// MARK: - Button Styles

public struct PrimaryGradientButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .semibold))
      .foregroundStyle(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        ZStack {
          if isEnabled {
            RenaCodeTheme.frameGradient
          } else {
            Color.gray.opacity(0.3)
          }
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .shadow(
        color: isEnabled ? RenaCodeTheme.colorPrimary.opacity(0.4) : Color.clear, radius: 10, x: 0,
        y: 4
      )
      .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1.0)
      .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1.0) : 0.5)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

public struct SecondaryGlassButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .medium))
      .foregroundStyle(isEnabled ? RenaCodeTheme.textMain : RenaCodeTheme.textMuted)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.06))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(RenaCodeTheme.borderGlassStrong, lineWidth: 1)
      )
      .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1.0)
      .opacity(isEnabled ? 1.0 : 0.5)
      .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

/// A square icon button for the top-right corner of the window.
public struct IconGlassButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .medium))
      .foregroundStyle(isEnabled ? RenaCodeTheme.textMain : RenaCodeTheme.textMuted)
      .frame(width: 32, height: 28)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white.opacity(configuration.isPressed ? 0.14 : 0.07))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(RenaCodeTheme.borderGlassStrong, lineWidth: 1)
      )
      .opacity(isEnabled ? 1.0 : 0.5)
  }
}
