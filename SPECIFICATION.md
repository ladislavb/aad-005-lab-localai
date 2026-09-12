# Specification — MacAdminInspector Lab

Implementační kontrakt pro cvičení. Prompt určuje cíl; tento dokument určuje funkční hranice a akceptační podmínky. `AGENTS.md` určuje způsob práce s projektem.

## Společná pravidla

- Cesty v tomto dokumentu jsou relativní k rootu repozitáře. Funkční požadavky neudávají názvy nových Swift souborů; před změnou vždy prozkoumej aktuální strukturu projektu.
- Minimum deployment target je macOS 14.0. Inventarizace je lokální a pouze pro čtení, bez změny konfigurace, vyšších oprávnění, nových závislostí, telemetrie a odesílání dat.
- Zobrazuj jen hodnoty explicitně vrácené macOS nebo katalogem. Používej zdokumentované veřejné API nebo stabilní systémový nástroj; nevymýšlej interní klíče, cesty ani formáty.
- Služby Foundation zjišťují data; SwiftUI pohledy vykreslují modely a vyvolávají akce.

## Overview a Network

- `DeviceInformationService` vrací hardware, úložiště, macOS, dobu běhu, Rosettu a dostupné údaje o baterii.
- `NetworkInformationService` vrací aktivní rozhraní, jejich explicitní IP adresy, DNS a Wi-Fi údaje z CoreWLAN. SSID/BSSID mohou vyžadovat Location access až po akci uživatele.
- Public IP je samostatná, uživatelem spuštěná externí akce se zdrojem v UI.

## Cvičení 1 — OpenCode a Exo cluster

- Sdílená konfigurace OpenCode je `opencode.jsonc` v rootu repozitáře. Obsahuje pouze commitovatelná nastavení projektu, například výchozí model, agenty a MCP servery.
- Přihlašovací údaje, tokeny a API klíče do repozitáře nepatří; konfigurace na ně odkazuje přes prostředí nebo existující přihlášení uživatele.
- Ověř, že Xcode spouští OpenCode z pracovního adresáře projektu a že agent vidí projektovou konfiguraci i požadované MCP nástroje. Cvičení nemění zdrojový kód aplikace.

## Cvičení 2 — Bezpečnostní inventarizace

Karta **Security** obsahuje lokální, pouze čtecí výsledky pro MDM, FileVault 2, Application Firewall, Gatekeeper a SIP.

- Každá kontrola má vlastní Foundation službu. `SecuritySnapshot` obsahuje všech pět položek; `SecurityView` vždy vykreslí pět pojmenovaných GroupBoxů se stavem, zdrojem a případným důvodem nedostupnosti.
- Selhání zdroje, chybějící oprávnění nebo nejednoznačný výstup znamenají `Unavailable`, nikoli `nil`. Text parsuj po pojmenovaných polích, po oříznutí mezer a bez rozlišení velikosti písmen.
- Jednoznačné hodnoty `true`, `yes`, `on`, `enabled`, `active` a `enrolled` jsou pozitivní; `false`, `no`, `off`, `disabled`, `inactive` a `not enrolled` negativní. Neodvozuj stav z obecného slova kdekoli ve výstupu. Při `Unavailable` ukaž až 1 000 znaků neupraveného výstupu jako důvod, bez další interpretace.
- MDM znamená zápis zařízení do MDM, ne seznam konfiguračních profilů. Zdrojem je `/usr/bin/profiles status -type=enrollment`; vyhodnoť pouze pole `MDM enrollment`. `profiles -L` nepoužívej.
- Application Firewall zobrazuje globální stav, `Block all incoming connections` a `Stealth mode`. Hodnoty zjišťuj samostatně; nezobrazuj seznam aplikací ani pravidel.
- Služba používající `Process` pracuje s ověřenou absolutní cestou, ne s PATH. Před dokončením porovnej výsledek aplikace s výstupem stejného příkazu spuštěného se stejnou cestou.

## AI nástroje

### Katalog

Jediným zdrojem produktových metadat je `MacAdminInspector/Resources/AITools.json`. Kořen obsahuje `cliSearchDirectories` a `tools`; nástroj má `id`, `name`, `category` a volitelně `gui` a/nebo `cli`. `gui.bundleIdentifiers` obsahuje bundle ID, `cli.executables` názvy souborů a `cli.searchDirectories` může přepsat kořenové cesty.

### Cvičení 3 — Detekce nainstalovaných nástrojů

- Detekuj všechny unikátní výskyty každé katalogové položky. Výskyt obsahuje název, kategorii, metodu a skutečnou cestu; výskyty neslučuj podle produktu.
- GUI hledej jen přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`. CLI hledej pomocí `FileManager.default.isExecutableFile(atPath:)` v katalogových cestách; `~/` rozbal přes `homeDirectoryForCurrentUser`.
- U nalezené GUI aplikace s CLI nejdřív ověř `<URL aplikace>/Contents/MacOS/<název z cli.executables>`; potom můžeš rekurzivně procházet jen tento `.app` bundle. Binární název neodvozuj.
- Statická detekce nepoužívá shell, `which`, `Process`, `--version`, XPC, síť ani rekurzivní procházení mimo nalezené `.app`. Nenalezené položky skryj; prázdný výsledek a chybu katalogu zobraz explicitně.
- UI používá stejný layout jako Overview a Network: `ScrollView`, obsah s paddingem 32 a `GroupBox` s `Grid` řádky. Nevkládej vlastní velký nadpis. Každý výskyt zobraz v řádcích `Tool`, `Method` a `Path`; cesta je označitelná.
- První otevření karty spustí statický scan právě jednou. Další scan spouští uživatel akcí `Refresh` v toolbaru. Stav a scan vlastní view model; pohled přímo nespouští službu ani `Task`.

### Cvičení 4 — Detekce spuštěných nástrojů

- Běžící GUI aplikace zjišťuj přes `NSWorkspace.runningApplications` a porovnávej jejich bundle ID s katalogem.
- Jeden ručně obnovený procesní snapshot poskytuje PID, PPID, executable a argumenty pro cvičení 4 i 5. Pro CLI procesy použij ověřenou absolutní cestu `/bin/ps`; parent proces vyhledej ve stejném snapshotu.
- Katalogový CLI nástroj je běžící jen při jednoznačné shodě s deklarovaným executable; runtime cesta je samostatný výskyt a může odhalit umístění mimo katalogové cesty. Ukaž PID, PPID, executable, parent proces a cestu, je-li zdroj poskytne.
- Sken se spouští výhradně akcí uživatele; neprováděj polling ani sledování na pozadí. Neúplný nebo nedostupný procesní snapshot ukaž jako omezení, ne jako negativní stav.

### Cvičení 5 — Procesy s MCP metadaty

- Použij sdílený procesní snapshot z cvičení 4. Jedna akce `Refresh` vytvoří nejvýše jeden nový snapshot pro oba přehledy.
- Nález vznikne při doslovné shodě `mcp` bez rozlišení velikosti písmen v executable nebo argumentech procesu. Ukaž PID, PPID, executable a parent proces, ale nezobrazuj celé argumenty.
- Výsledek označ jako `Process metadata contains mcp`. Nepotvrzuje aktivní MCP spojení, konkrétní server ani vlastnictví procesu.

### Společný stav a výsledek

- Každý přehled vlastní stav `idle/loading/loaded/error`, výsledky, počet zkontrolovaných položek a jedinou úlohu svého scanu. I/O běží mimo MainActor.
- Při selhání nebo nejednoznačném výsledku zobraz `Unavailable` a zdroj; nesupluj jej odhadem.
