# Specification — MacAdminInspector Lab

Implementační reference pro cvičení. Prompt má stručně říct, co se má přidat, a odkázat na příslušnou sekci zde.

## Společná pravidla

- Minimum deployment target je macOS 14.0.
- Inventarizace je lokální a pouze pro čtení: bez změny konfigurace, administrátorských práv, nových závislostí, telemetrie a odesílání dat.
- Zobrazuj jen hodnoty explicitně vrácené macOS nebo deklarované katalogem. Jinak použij `Unavailable`.
- Služby Foundation zjišťují data; SwiftUI pohledy je pouze vykreslují.

## Overview a Network

- `DeviceInformationService` vrací lokální profil: hardware, úložiště, macOS, dobu běhu, Rosettu a baterii. Baterii nezobrazuj, pokud ji Mac neposkytne.
- `NetworkInformationService` vrací jen aktivní rozhraní, jejich explicitní IP adresy, DNS a Wi-Fi údaje vrácené CoreWLAN.
- SSID/BSSID mohou vyžadovat Location access; žádost se nabídne až po akci uživatele.
- Public IP je oddělená, výslovně uživatelem spuštěná externí akce se zdrojem v UI.

## Bezpečnostní inventarizace

### Účel

Přidej kartu **Security** s lokálními, pouze čtecími výsledky pro MDM, FileVault 2, firewall, Gatekeeper a XProtect.

### Smlouva

- Každá kontrola má samostatnou Foundation službu; služba vybere přiměřený lokální zdroj pouze pro čtení a UI vždy uvede jeho název.
- `SecuritySnapshot` vždy obsahuje všech pět položek. Každá položka obsahuje zobrazovaný stav, zdroj a případně důvod nedostupnosti.
- `SecurityView` vždy vykreslí pět pojmenovaných GroupBoxů. Nezobrazuje společný prázdný stav.
- Neúspěšný zdroj, neznámý výstup nebo nedostatek oprávnění znamená `Unavailable`, nikoli `nil`.
- Textový výstup normalizuj oříznutím mezer a bez rozlišení velikosti písmen. Jednoznačné hodnoty `true`, `yes`, `on`, `enabled`, `active` nebo `enrolled` mapuj na pozitivní stav; `false`, `no`, `off`, `disabled`, `inactive` nebo `not enrolled` na negativní stav.
- Nejednoznačný text nemapuj; ukaž `Unavailable` se stručným důvodem. XProtect zobrazuje jen explicitně nalezenou verzi či datum definic se zdrojem `XProtect definitions`; tyto údaje nepotvrzují aktivní ochranu, aktuálnost definic ani nepřítomnost malwaru.
- Pohledy nespouštějí procesy. Kontroly nesmí měnit konfiguraci, vyžadovat vyšší oprávnění ani používat síť.


## AI nástroje

### Katalog

Jediným zdrojem metadat je `MacAdminInspector/Resources/AITools.json`; produktová metadata se nesmí přidávat do Swift kódu.

- Kořen obsahuje `cliSearchDirectories` a `tools`.
- Položka nástroje má `id`, `name`, `category` a volitelný blok `gui` a/nebo `cli`.
- `gui.bundleIdentifiers` obsahuje bundle ID; `cli.executables` názvy souborů a případné `cli.searchDirectories` přepisují kořenové cesty.

### Detekce

- Modely jsou v `Models/AIToolCatalog.swift`, logika v jediné `AIToolDetectionService`.
- GUI hledej jen přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`.
- CLI hledej přes `FileManager.default.isExecutableFile(atPath:)` v deklarovaných cestách; `~/` rozbal přes `homeDirectoryForCurrentUser`.
- Pokud katalogová položka obsahuje `gui` i `cli` a GUI aplikace byla nalezena, nejprve ověř `<URL aplikace>/Contents/MacOS/<název z cli.executables>` a potom můžeš rekurzivně procházet jen tento `.app` bundle. Binární název neodvozuj.
- Nepoužívej shell, `which`, `Process`, `--version`, rekurzivní procházení mimo nalezené `.app`, XPC ani síť.

### Stav a hotovo

- `AIToolDetectionViewModel` vlastní stav `idle/loading/loaded/error`, výsledky, skutečný počet zkontrolovaných katalogových položek a jedinou úlohu skenu.
- I/O běží mimo MainActor; změny UI se vrací na MainActor. Sken se při dalším otevření neduplikuje.
- Seznam používá stejný view model, který sken spustil. Nenalezené nástroje se nezobrazují.
- Výsledek vždy uvádí název, kategorii, metodu a nalezenou cestu.

## Ověření cvičení

Po dokončení uveď změněné soubory, výsledek buildu, ručně ověřenou cestu a omezení, která systém explicitně vrátil. Před samostatným cvičením vytvoř commit jako kontrolní bod.
