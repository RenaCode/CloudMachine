import SwiftUI

/// System wizualny RenaCode dla CloudMachine.
/// Spójne tokeny kolorów, typografii i glassmorphismu z Dietetyk-AI i Trader-AI.
public enum RenaCodeTheme {
  // MARK: - Kolory Podstawowe (Tokens)

  public static let bgDark = Color(red: 7 / 255, green: 9 / 255, blue: 19 / 255)  // #070913
  public static let bgDarkEnd = Color(red: 13 / 255, green: 17 / 255, blue: 39 / 255)  // #0D1127
  public static let bgCard = Color(red: 18 / 255, green: 22 / 255, blue: 41 / 255).opacity(0.75)  // #121629
  public static let bgCardHover = Color(red: 26 / 255, green: 32 / 255, blue: 58 / 255).opacity(
    0.85)
  public static let bgInset = Color(red: 9 / 255, green: 12 / 255, blue: 24 / 255).opacity(0.65)

  public static let borderGlass = Color.white.opacity(0.08)
  public static let borderGlassStrong = Color.white.opacity(0.14)
  public static let borderGlassGlow = Color(red: 124 / 255, green: 58 / 255, blue: 237 / 255)
    .opacity(0.35)

  // Akcenty kolorystyczne
  public static let colorPrimary = Color(red: 124 / 255, green: 58 / 255, blue: 237 / 255)  // #7C3AED Fiolet AI
  public static let colorPrimaryLight = Color(red: 192 / 255, green: 132 / 255, blue: 252 / 255)  // #C084FC
  public static let colorCyan = Color(red: 6 / 255, green: 182 / 255, blue: 212 / 255)  // #06B6D4 Cyjan aktywności
  public static let colorSuccess = Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255)  // #34D399 Szmaragd
  public static let colorSuccessDark = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)  // #10B981
  public static let colorWarning = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)  // #F59E0B Pomarańcz
  public static let colorDanger = Color(red: 248 / 255, green: 113 / 255, blue: 113 / 255)  // #F87171 Czerwień

  public static let textMain = Color(red: 241 / 255, green: 245 / 255, blue: 249 / 255)  // #F1F5F9
  public static let textMuted = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)  // #94A3B8
  public static let textDim = Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255)  // #64748B

  // MARK: - Gradienty

  public static let aiGradient = LinearGradient(
    colors: [colorPrimary, colorPrimaryLight],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  public static let cyanGradient = LinearGradient(
    colors: [colorCyan, colorSuccess],
    startPoint: .leading,
    endPoint: .trailing
  )

  public static let darkGradient = LinearGradient(
    colors: [bgDark, bgDarkEnd],
    startPoint: .top,
    endPoint: .bottom
  )

  public static let cardGradient = LinearGradient(
    colors: [Color.white.opacity(0.04), Color.white.opacity(0.01)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}

// MARK: - Tło ze świetlistymi kulami (Ambient Orbs Background)

public struct AmbientGlowBackground: View {
  public init() {}

  public var body: some View {
    ZStack {
      RenaCodeTheme.darkGradient
        .ignoresSafeArea()

      // Fioletowa kuleczka z lewej strony
      Circle()
        .fill(RenaCodeTheme.colorPrimary.opacity(0.18))
        .frame(width: 380, height: 380)
        .blur(radius: 90)
        .offset(x: -220, y: -180)

      // Cyjanowa kuleczka z prawej strony
      Circle()
        .fill(RenaCodeTheme.colorCyan.opacity(0.14))
        .frame(width: 340, height: 340)
        .blur(radius: 85)
        .offset(x: 240, y: 160)
    }
    .allowsHitTesting(false)
  }
}

// MARK: - Modyfikator Karty Glassmorphic (GlassCard)

public struct GlassCardModifier: ViewModifier {
  var cornerRadius: CGFloat
  var borderColor: Color
  var padding: CGFloat

  public init(
    cornerRadius: CGFloat = 16,
    borderColor: Color = RenaCodeTheme.borderGlass,
    padding: CGFloat = 18
  ) {
    self.cornerRadius = cornerRadius
    self.borderColor = borderColor
    self.padding = padding
  }

  public func body(content: Content) -> some View {
    content
      .padding(padding)
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(RenaCodeTheme.bgCard)
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(RenaCodeTheme.cardGradient)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(borderColor, lineWidth: 1)
      )
      .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
  }
}

extension View {
  public func glassCard(
    cornerRadius: CGFloat = 16,
    borderColor: Color = RenaCodeTheme.borderGlass,
    padding: CGFloat = 18
  ) -> some View {
    self.modifier(
      GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor, padding: padding))
  }
}

// MARK: - Komponent Karta Statystyk (KPI StatCard)

public struct StatCard: View {
  let title: String
  let value: String
  let subtitle: String
  let systemImage: String
  let iconColor: Color

  public init(
    title: String,
    value: String,
    subtitle: String,
    systemImage: String,
    iconColor: Color = RenaCodeTheme.colorPrimary
  ) {
    self.title = title
    self.value = value
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.iconColor = iconColor
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(iconColor.opacity(0.15))
            .frame(width: 34, height: 34)
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(iconColor)
        }

        Spacer()

        Text(title.uppercased())
          .font(.system(size: 10, weight: .bold, design: .rounded))
          .tracking(0.8)
          .foregroundStyle(RenaCodeTheme.textMuted)
      }

      Text(value)
        .font(.system(size: 20, weight: .bold, design: .monospaced))
        .foregroundStyle(RenaCodeTheme.textMain)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      Text(subtitle)
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .lineLimit(1)
    }
    .glassCard(cornerRadius: 14, padding: 14)
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
      }
      Text(text.uppercased())
        .font(.system(size: 10, weight: .bold))
        .tracking(0.6)
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

// MARK: - Style Przycieków (ButtonStyles)

public struct PrimaryGradientButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

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
            RenaCodeTheme.aiGradient
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
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1.0) : 0.5)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

public struct SecondaryGlassButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 13, weight: .medium))
      .foregroundStyle(isEnabled ? RenaCodeTheme.textMain : RenaCodeTheme.textDim)
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
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(isEnabled ? 1.0 : 0.5)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}
