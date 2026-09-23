import CloudMachineCore
import SwiftUI

/// Główny interfejs aplikacji CloudMachine, utrzymany w nowoczesnym systemie
/// wizualnym RenaCode (spójnym z Dietetyk-AI oraz Trader-AI).
struct DashboardView: View {
  @EnvironmentObject private var controller: CloudMachineController
  @State private var clientID = ""
  @State private var clientSecret = ""
  @State private var credentialsMessage: String?
  @State private var credentialsExpanded = false

  var body: some View {
    ZStack {
      // Świetliste tło RenaCode
      AmbientGlowBackground()

      VStack(spacing: 0) {
        // Górna belka / Nagłówek z logo i zakładkami
        topHeaderBar

        // Główna zawartość
        dashboardContent
      }
    }
    .task { controller.startAutoRefresh() }
  }

  // MARK: - Górna Belka Nawigacyjna

  private var topHeaderBar: some View {
    VStack(spacing: 12) {
      HStack(spacing: 16) {
        // Logo ikona z fioletowym i cyjanowym poświatem
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(RenaCodeTheme.aiGradient)
            .frame(width: 42, height: 42)
            .shadow(color: RenaCodeTheme.colorPrimary.opacity(0.45), radius: 12, x: 0, y: 4)

          Image(systemName: "icloud.and.arrow.up.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
        }

        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 8) {
            Text("CloudMachine")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(RenaCodeTheme.textMain)

            RenaCodePillBadge(
              text: "Time Machine",
              icon: "cloud.fill",
              color: RenaCodeTheme.colorPrimary
            )

            RenaCodePillBadge(
              text: controller.status.healthy ? "Sprawny" : "Uwaga",
              color: controller.status.healthy
                ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
            )
          }

          Text("Lokalny bufor SSD & kopia zapasowa na Google Drive")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(RenaCodeTheme.textMuted)
        }

        Spacer()

        // Informacja o odświeżeniu i wskaźnik pracy
        HStack(spacing: 12) {
          if let at = controller.status.lastRefresh {
            HStack(spacing: 5) {
              Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 11))
              Text("Odświeżono \(at.formatted(date: .omitted, time: .standard))")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .foregroundStyle(RenaCodeTheme.textDim)
          }

          if controller.status.isBusy {
            HStack(spacing: 6) {
              ProgressView().controlSize(.small)
              Text(controller.status.busyLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(RenaCodeTheme.colorCyan)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RenaCodeTheme.colorCyan.opacity(0.12))
            .clipShape(Capsule())
          }
        }
      }

    }
    .padding(.horizontal, 22)
    .padding(.top, 18)
    .padding(.bottom, 14)
    .background(
      RenaCodeTheme.bgDark.opacity(0.85)
    )
    .overlay(
      Rectangle()
        .fill(RenaCodeTheme.borderGlass)
        .frame(height: 1),
      alignment: .bottom
    )
  }

  // MARK: - Zawartość Panelu Głównego (Dashboard Content)

  private var dashboardContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {

        // Baner ewentualnego błędu
        if let error = controller.status.errorMessage {
          errorBanner(error)
        }

        // Siatka kart statystyk KPI (Top Row)
        kpiSummaryGrid

        // Czy kopia dolatuje na Dysk - i dlaczego nie, jesli nie
        uploadStateCard

        // Karta aktywnego postępu backupu (jeśli trwa)
        if let progress = controller.status.backupProgress {
          progressCard(progress)
        }

        // Karta kroków konfiguracji ("Do zrobienia")
        if !setupSteps.isEmpty {
          setupCard
        }

        // Szczegóły bufora i wysyłki
        bufferCard

        // Poświadczenia Google OAuth
        credentialsCard

        // Dolny pasek akcji
        actionsToolbar
      }
      .padding(22)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: - Baner Błędu

  private func errorBanner(_ message: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 18))
        .foregroundStyle(RenaCodeTheme.colorDanger)

      Text(message)
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(RenaCodeTheme.textMain)
        .textSelection(.enabled)

      Spacer()
    }
    .padding(14)
    .background(RenaCodeTheme.colorDanger.opacity(0.12))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(RenaCodeTheme.colorDanger.opacity(0.35), lineWidth: 1)
    )
  }

  // MARK: - Siatka Kart Statystyk (KPI Summary Grid)

  private var kpiSummaryGrid: some View {
    LazyVGrid(
      columns: [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
      ], spacing: 14
    ) {
      StatCard(
        title: "Stan Systemu",
        value: controller.status.healthy ? "Sprawny" : "Wymaga akcji",
        subtitle: controller.status.headline,
        systemImage: controller.status.healthy
          ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
        iconColor: controller.status.healthy
          ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
      )

      StatCard(
        title: "Rozmiar Bufora",
        value: "\(controller.status.buffer.sizeGB) GB",
        // Brak pomiaru ma wygladac inaczej niz liczba - patrz
        // `BufferGuardService.freeGB()`. Samo wstawienie opcjonalnej wartosci
        // do tekstu dalo "Wolne na dysku: Optional(427) GB" i kompilator
        // zglaszal to TYLKO jako ostrzezenie, wiec zaden test by tego nie zlapal.
        subtitle:
          "Wolne na dysku: \(controller.status.buffer.freeDiskGB.map { "\($0) GB" } ?? "nie zmierzono")",
        systemImage: "internaldrive.fill",
        iconColor: RenaCodeTheme.colorCyan
      )

      StatCard(
        title: "Kolejka Wysyłki",
        // Bez odczytu kolejki ta karta nie ma prawa powiedziec "Brak
        // zaleglosci" - zera sa wtedy brakiem pomiaru, nie wynikiem.
        value: !controller.status.buffer.queueKnown
          ? "—"
          : (controller.status.buffer.draining
            ? "\(controller.status.buffer.uploadsQueued) w kolejce" : "Brak zaległości"),
        subtitle: !controller.status.buffer.queueKnown
          ? "rclone nie odpowiedział"
          : (controller.status.buffer.draining
            ? "\(controller.status.buffer.uploadsInProgress) transferów w toku"
            : "Wszystko w chmurze"),
        systemImage: "icloud.and.arrow.up.fill",
        iconColor: !controller.status.buffer.queueKnown
          ? RenaCodeTheme.colorWarning
          : (controller.status.buffer.draining
            ? RenaCodeTheme.colorWarning : RenaCodeTheme.colorSuccess)
      )

      StatCard(
        title: "Time Machine",
        value: controller.status.buffer.imageAttached ? "Podpięty" : "Niepodpięty",
        subtitle: controller.status.buffer.mounted
          ? "Google Drive zamontowany" : "Drive rozłączony",
        systemImage: "clock.arrow.circlepath",
        iconColor: controller.status.buffer.imageAttached
          ? RenaCodeTheme.colorPrimaryLight : RenaCodeTheme.textDim
      )
    }
  }

  // MARK: - Postęp Backupu

  private func progressCard(_ progress: BackupProgressInfo) -> some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          ZStack {
            Circle()
              .fill(RenaCodeTheme.colorCyan.opacity(0.2))
              .frame(width: 28, height: 28)
            Image(systemName: "arrow.triangle.2.circlepath")
              .font(.system(size: 13, weight: .bold))
              .foregroundStyle(RenaCodeTheme.colorCyan)
          }

          Text("Kopia Zapasowa w Toku")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)
        }

        Spacer()

        if let percent = progress.percent {
          Text(String(format: "%.1f%%", percent * 100))
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundStyle(RenaCodeTheme.colorCyan)
        }
      }

      if let percent = progress.percent {
        GeometryReader { geo in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
              .fill(RenaCodeTheme.bgInset)
              .frame(height: 10)

            RoundedRectangle(cornerRadius: 6)
              .fill(RenaCodeTheme.cyanGradient)
              .frame(
                width: max(0, min(geo.size.width * CGFloat(percent), geo.size.width)), height: 10
              )
              .shadow(color: RenaCodeTheme.colorCyan.opacity(0.5), radius: 6, x: 0, y: 0)
          }
        }
        .frame(height: 10)
      }

      HStack(spacing: 24) {
        if let done = progress.filesDone, let total = progress.filesTotal, total > 0 {
          VStack(alignment: .leading, spacing: 2) {
            Text("Przetworzone pliki")
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text("\(done) / \(total)")
              .font(.system(size: 13, weight: .semibold, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMain)
          }
        }

        if let rate = progress.transferRateMBs {
          VStack(alignment: .leading, spacing: 2) {
            Text("Prędkość zapisu")
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text(String(format: "%.1f MB/s", rate))
              .font(.system(size: 13, weight: .semibold, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.colorSuccess)
          }
        }

        if let phase = progress.phase {
          VStack(alignment: .leading, spacing: 2) {
            Text("Faza operacji")
              .font(.system(size: 11))
              .foregroundStyle(RenaCodeTheme.textMuted)
            Text(phase)
              .font(.system(size: 13, weight: .medium))
              .foregroundStyle(RenaCodeTheme.textMain)
          }
        }
      }
    }
    .glassCard(borderColor: RenaCodeTheme.colorCyan.opacity(0.35))
  }

  // MARK: - Kroki Konfiguracji ("Do Zrobienia")

  private var setupSteps: [(String, String?)] {
    var steps: [(String, String?)] = []
    if case .missing(let what, let how) = controller.status.dependencyState {
      for (miss, remedy) in zip(what, how) { steps.append(("Brakuje: \(miss)", remedy)) }
    }
    if !controller.status.remoteConfigured {
      steps.append(("Google Drive niepołączony", controller.connectDriveCommand))
    }
    if case .notRegistered = controller.status.timeMachineState,
      controller.status.buffer.imageAttached
    {
      steps.append(
        ("Time Machine nie wskazuje na CloudMachine", controller.setDestinationCommand))
    }
    return steps
  }

  private var setupCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        Image(systemName: "wrench.and.screwdriver.fill")
          .font(.system(size: 15))
          .foregroundStyle(RenaCodeTheme.colorWarning)
        Text("Wymagane Kroki Konfiguracji")
          .font(.system(size: 15, weight: .bold, design: .rounded))
          .foregroundStyle(RenaCodeTheme.textMain)
      }

      VStack(alignment: .leading, spacing: 12) {
        ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
          VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
              Text("\(index + 1)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(RenaCodeTheme.colorWarning)
                .clipShape(Circle())

              Text(step.0)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(RenaCodeTheme.textMain)
            }

            if let command = step.1 {
              HStack {
                Text(command)
                  .font(.system(size: 12, design: .monospaced))
                  .foregroundStyle(RenaCodeTheme.textMain)
                  .textSelection(.enabled)
                Spacer()
                Button(action: {
                  NSPasteboard.general.clearContents()
                  NSPasteboard.general.setString(command, forType: .string)
                }) {
                  HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                      .font(.system(size: 11))
                    Text("Kopiuj")
                      .font(.system(size: 11, weight: .medium))
                  }
                }
                .buttonStyle(SecondaryGlassButtonStyle())
              }
              .padding(10)
              .background(RenaCodeTheme.bgInset)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
              )
            }
          }
        }
      }
    }
    .glassCard(borderColor: RenaCodeTheme.colorWarning.opacity(0.35))
  }

  // MARK: - Szczegóły Bufora i Wysyłki

  private var bufferCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        HStack(spacing: 8) {
          Image(systemName: "server.rack")
            .font(.system(size: 15))
            .foregroundStyle(RenaCodeTheme.colorCyan)
          Text("Bufor Lokalny & Stan Wysyłki")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)
        }

        Spacer()
      }

      VStack(spacing: 10) {
        row(
          "Montowanie Google Drive (FUSE-T)",
          controller.status.buffer.mounted ? "Zamontowany" : "Nieaktywny",
          ok: controller.status.buffer.mounted
        )

        Divider().background(RenaCodeTheme.borderGlass)

        row(
          "Obraz dysku backupu (.sparsebundle)",
          controller.status.buffer.imageAttached ? "Podpięty do systemu" : "Odłączony",
          ok: controller.status.buffer.imageAttached
        )

        Divider().background(RenaCodeTheme.borderGlass)

        row(
          "Zalokowany bufor na dysku SSD",
          "\(controller.status.buffer.sizeGB) GB",
          ok: true
        )

        Divider().background(RenaCodeTheme.borderGlass)

        // Brak pomiaru MUSI wygladac inaczej niz "0 GB" - patrz
        // `BufferGuardService.freeGB()`. Nieudany statfs to awaria dozorcy
        // bufora, a nie informacja o pustym dysku.
        row(
          "Wolne miejsce na lokalnym wolumenie",
          controller.status.buffer.freeDiskGB.map { "\($0) GB" } ?? "nie zmierzono",
          ok: (controller.status.buffer.freeDiskGB ?? 0) > 80
        )

        Divider().background(RenaCodeTheme.borderGlass)

        // Jedyny wiersz, ktory odpowiada na pytanie "czy kopia POWSTALA".
        // Wszystkie pozostale opisuja stan urzadzen i moga byc zielone, gdy
        // Time Machine od dwoch dni nie dokonczyl backupu.
        row(
          "Ostatnia ukończona kopia",
          controller.status.backupCycle.ageText(),
          ok: controller.status.backupCycle.isFresh()
        )

        Divider().background(RenaCodeTheme.borderGlass)

        row(
          "Kolejka synchronizacji z chmurą",
          !controller.status.buffer.queueKnown
            ? "nie odczytano"
            : (controller.status.buffer.draining
              ? "\(controller.status.buffer.uploadsInProgress) w toku, \(controller.status.buffer.uploadsQueued) w kolejce"
              : "Wszystko wysłane"),
          ok: controller.status.buffer.queueKnown && controller.status.buffer.erroredFiles == 0
        )

        if controller.status.buffer.erroredFiles > 0 {
          Divider().background(RenaCodeTheme.borderGlass)
          row(
            "Błędy wysyłki plików",
            "\(controller.status.buffer.erroredFiles) plików",
            ok: false
          )
        }

        if controller.status.buffer.driveFull {
          Divider().background(RenaCodeTheme.borderGlass)
          row("Miejsce na Google Drive", "Brak miejsca", ok: false)
        }

        if controller.status.buffer.dailyQuotaExhausted {
          Divider().background(RenaCodeTheme.borderGlass)
          row(
            "Limit Google Drive",
            "Dobowe 750 GB wyczerpane",
            ok: false
          )
        }
      }
    }
    .glassCard()
  }

  // MARK: - Poświadczenia Google OAuth

  /// Poswiadczenia sa zwiniete domyslnie. Wpisuje sie je RAZ, przy zakladaniu
  /// wlasnego klienta OAuth, a potem juz nigdy - trzymanie dwoch pol na haslo
  /// na wierzchu panelu, ktory ma odpowiadac na pytanie o stan kopii, tylko
  /// odciaga uwage. Znaczek przy naglowku mowi, czy jest co rozwijac.
  private var credentialsCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      Button {
        withAnimation(.easeInOut(duration: 0.18)) { credentialsExpanded.toggle() }
      } label: {
        HStack(spacing: 8) {
          Image(systemName: "key.fill")
            .font(.system(size: 15))
            .foregroundStyle(RenaCodeTheme.colorPrimaryLight)

          Text("Poświadczenia Google Drive (OAuth 2.0)")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(RenaCodeTheme.textMain)

          Spacer()

          RenaCodePillBadge(
            text: controller.credentials.isComplete ? "Keychain OK" : "Brak własnych kluczy",
            icon: controller.credentials.isComplete ? "checkmark.seal.fill" : "lock.open.fill",
            color: controller.credentials.isComplete
              ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorWarning
          )

          Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(RenaCodeTheme.textMuted)
            .rotationEffect(.degrees(credentialsExpanded ? 90 : 0))
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if credentialsExpanded {

        Text(controller.credentials.summary)
          .font(.system(size: 12))
          .foregroundStyle(RenaCodeTheme.textMuted)
          .fixedSize(horizontal: false, vertical: true)

        VStack(spacing: 10) {
          HStack {
            Text("client_id:")
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMuted)
              .frame(width: 100, alignment: .leading)

            SecureField("Wklej client_id...", text: $clientID)
              .textFieldStyle(.plain)
              .padding(8)
              .background(RenaCodeTheme.bgInset)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
              )
          }

          HStack {
            Text("client_secret:")
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(RenaCodeTheme.textMuted)
              .frame(width: 100, alignment: .leading)

            SecureField("Wklej client_secret...", text: $clientSecret)
              .textFieldStyle(.plain)
              .padding(8)
              .background(RenaCodeTheme.bgInset)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(RenaCodeTheme.borderGlass, lineWidth: 1)
              )
          }
        }

        HStack {
          Button("Zapisz bezpiecznie w Keychainie") {
            let id = clientID
            let secret = clientSecret
            Task {
              credentialsMessage = await controller.saveCredentials(
                clientID: id, clientSecret: secret)
              clientID = ""
              clientSecret = ""
            }
          }
          .buttonStyle(PrimaryGradientButtonStyle())
          .disabled(
            clientID.trimmingCharacters(in: .whitespaces).isEmpty
              || clientSecret.trimmingCharacters(in: .whitespaces).isEmpty)

          Spacer()
        }

        if let message = credentialsMessage {
          Text(message)
            .font(.system(size: 12))
            .foregroundStyle(RenaCodeTheme.colorCyan)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .glassCard()
  }

  // MARK: - Dolny Pasek Akcji

  private var actionsToolbar: some View {
    HStack(spacing: 12) {
      if controller.status.backupProgress == nil {
        Button(action: { Task { await controller.startBackup() } }) {
          HStack(spacing: 6) {
            Image(systemName: "play.fill")
            Text("Zrób backup teraz")
          }
        }
        .buttonStyle(PrimaryGradientButtonStyle())
        .disabled(!controller.status.healthy || controller.status.isBusy)
      } else {
        Button(action: { Task { await controller.stopBackup() } }) {
          HStack(spacing: 6) {
            Image(systemName: "stop.fill")
            Text("Wstrzymaj backup")
          }
        }
        .buttonStyle(SecondaryGlassButtonStyle())
      }

      Button(action: { Task { await controller.verifyImage() } }) {
        HStack(spacing: 6) {
          Image(systemName: "checkmark.shield")
          Text("Sprawdź spójność obrazu")
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())
      .disabled(controller.status.buffer.imageAttached || controller.status.isBusy)

      Button(action: { Task { await controller.refreshAll() } }) {
        HStack(spacing: 6) {
          Image(systemName: "arrow.clockwise")
          Text("Odśwież")
        }
      }
      .buttonStyle(SecondaryGlassButtonStyle())

      Spacer()
    }
  }

  // MARK: - Stan Wysylki na Google Drive

  /// Odpowiada na jedyne pytanie, ktore uzytkownik naprawde zadaje: czy moja
  /// kopia jest bezpieczna. Jedno zdanie, pod nim wyjasnienie po ludzku.
  ///
  /// Kolor rozroznia TRZY rzeczy, nie dwie. Zielony - jest dobrze. Bursztynowy -
  /// nie jest nominalnie, ale nic nie rob, minie samo (limit dobowy Google).
  /// Czerwony - trzeba zareagowac. Bez srodkowego stanu wyczerpany limit
  /// musialby udawac albo awarie, albo porzadek, a nie jest ani jednym, ani drugim.
  ///
  /// Teksty nie ida przez `.localized` celowo: wiekszosc wariantow wstawia
  /// liczbe do zdania, wiec i tak nie trafilaby w slownik tlumaczen.
  private var uploadStateCard: some View {
    let state = controller.status.buffer.uploadState
    let accent = uploadAccent(state)

    return VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        ZStack {
          Circle()
            .fill(accent.opacity(0.15))
            .frame(width: 40, height: 40)

          Image(systemName: uploadIcon(state))
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(accent)
        }

        VStack(alignment: .leading, spacing: 3) {
          Text(uploadBadge(state))
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(accent)

          Text(state.headline)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(RenaCodeTheme.textMain)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)
      }

      Text(state.explanation)
        .font(.system(size: 13))
        .foregroundStyle(RenaCodeTheme.textMuted)
        .fixedSize(horizontal: false, vertical: true)
        .textSelection(.enabled)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .glassCard(borderColor: accent.opacity(0.35))
  }

  private func uploadAccent(_ state: UploadState) -> Color {
    if state.needsAttention { return RenaCodeTheme.colorDanger }
    if !state.isNominal { return RenaCodeTheme.colorWarning }
    return RenaCodeTheme.colorSuccess
  }

  /// Etykieta idzie prosto z `UploadState`. Skladanie jej tutaj z dwoch bool-i
  /// ograniczalo interfejs do trzech wariantow, a stanow jest wiecej.
  private func uploadBadge(_ state: UploadState) -> String { state.badge }

  private func uploadIcon(_ state: UploadState) -> String {
    switch state {
    case .mountDown: return "icloud.slash.fill"
    case .driveFull: return "externaldrive.badge.xmark"
    case .failedFiles: return "exclamationmark.triangle.fill"
    case .bufferFull: return "tray.full.fill"
    case .dailyQuotaExhausted: return "hourglass"
    case .flowing: return "arrow.up.circle.fill"
    case .upToDate: return "checkmark.icloud.fill"
    case .queueUnknown: return "questionmark.circle.fill"
    }
  }

  // MARK: - Pomocniczy Wiersz Tabela

  private func row(_ label: String, _ value: String, ok: Bool) -> some View {
    HStack {
      HStack(spacing: 8) {
        Circle()
          .fill(ok ? RenaCodeTheme.colorSuccess : RenaCodeTheme.colorDanger)
          .frame(width: 7, height: 7)

        Text(label)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(RenaCodeTheme.textMuted)
      }

      Spacer()

      Text(value)
        .font(.system(size: 13, weight: .semibold, design: .monospaced))
        .foregroundStyle(ok ? RenaCodeTheme.textMain : RenaCodeTheme.colorDanger)
    }
  }
}
