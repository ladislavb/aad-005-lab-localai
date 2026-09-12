# Specification — MacAdminInspector Lab

Implementační kontrakt pro cvičení. Prompt stručně popíše cíl a odkáže na příslušnou sekci zde.

## Společná pravidla

- Minimum deployment target je macOS 14.0. Inventarizace je lokální a pouze pro čtení, bez změny konfigurace, vyšších oprávnění, nových závislostí, telemetrie a odesílání dat.
- Zobrazuj jen hodnoty explicitně vrácené macOS nebo katalogem. Používej zdokumentované veřejné API nebo stabilní systémový nástroj; nevymýšlej interní klíče, cesty ani formáty.
- Služby Foundation zjišťují data; SwiftUI pohledy je pouze vykreslují.

## Overview a Network

- `DeviceInformationService` vrací hardware, úložiště, macOS, dobu běhu, Rosettu a dostupné údaje o baterii.
- `NetworkInformationService` vrací aktivní rozhraní, jejich explicitní IP adresy, DNS a Wi-Fi údaje z CoreWLAN. SSID/BSSID mohou vyžadovat Location access až po akci uživatele.
- Public IP je samostatná, uživatelem spuštěná externí akce se zdrojem v UI.

## Bezpečnostní inventarizace

Karta **Security** obsahuje lokální, pouze čtecí výsledky pro MDM, FileVault 2, Application Firewall, Gatekeeper a SIP.

- Každá kontrola má vlastní Foundation službu. `SecuritySnapshot` obsahuje všech pět položek; `SecurityView` vždy vykreslí pět pojmenovaných GroupBoxů se stavem, zdrojem a případným důvodem nedostupnosti.
- Selhání zdroje, chybějící oprávnění nebo nejednoznačný výstup znamenají `Unavailable`, nikoli `nil`.
- Text parsuj po pojmenovaných polích, po oříznutí mezer a bez rozlišení velikosti písmen. Jednoznačné hodnoty `true`, `yes`, `on`, `enabled`, `active` a `enrolled` jsou pozitivní; `false`, `no`, `off`, `disabled`, `inactive` a `not enrolled` negativní. Neodvozuj stav z obecného slova kdekoli ve výstupu. Při `Unavailable` ukaž až 1 000 znaků neupraveného výstupu jako důvod, bez další interpretace.
- MDM znamená zápis zařízení do MDM, ne seznam konfiguračních profilů. Zdrojem je `/usr/bin/profiles status -type=enrollment`; vyhodnoť pouze pole `MDM enrollment`. `profiles -L` nepoužívej.
- Application Firewall zobrazuje globální stav, `Block all incoming connections` a `Stealth mode`. Hodnoty zjišťuj samostatně; nezobrazuj seznam aplikací ani pravidel.
- Služba používající `Process` pracuje s ověřenou absolutní cestou, ne s PATH. Před dokončením porovnej výsledek aplikace s výstupem stejného příkazu spuštěného se stejnou cestou.

## AI nástroje

### Katalog

Jediným zdrojem produktových metadat je `MacAdminInspector/Resources/AITools.json`. Kořen obsahuje `cliSearchDirectories` a `tools`; nástroj má `id`, `name`, `category` a volitelně `gui` a/nebo `cli`. `gui.bundleIdentifiers` obsahuje bundle ID, `cli.executables` názvy souborů a `cli.searchDirectories` může přepsat kořenové cesty.

### Detekce

- Modely jsou v `Models/AIToolCatalog.swift`, logika v jediné `AIToolDetectionService`.
- GUI hledej jen přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`. CLI hledej pomocí `FileManager.default.isExecutableFile(atPath:)` v katalogových cestách; `~/` rozbal přes `homeDirectoryForCurrentUser`.
- U nalezené GUI aplikace s CLI nejdřív ověř `<URL aplikace>/Contents/MacOS/<název z cli.executables>`; potom můžeš rekurzivně procházet jen tento `.app` bundle. Binární název neodvozuj.
- Nepoužívej shell, `which`, `Process`, `--version`, XPC, síť ani rekurzivní procházení mimo nalezené `.app`.

### Stav a výsledek

- `AIToolDetectionViewModel` vlastní stav `idle/loading/loaded/error`, výsledky, skutečný počet zkontrolovaných položek a jedinou úlohu skenu. I/O běží mimo MainActor a sken se při dalším otevření neduplikuje.
- Seznam používá tentýž view model a skrývá nenalezené nástroje. Nález vždy uvádí název, kategorii, metodu a cestu.
