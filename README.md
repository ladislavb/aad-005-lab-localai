# Mac Admin Inspector

Mac Admin Inspector je záměrně malý, lokální výchozí projekt pro inventarizaci macOS určený pro praktický workshop **Apple Admin Days**. Účastníci pomocí AI asistenta pro programování rozšiřují profil zařízení ve SwiftUI o úzce zaměřené funkce inventarizace pouze pro čtení.

## Co projekt obsahuje

- Aplikaci ve SwiftUI pro macOS 14 a novější s obrazovkami Overview a Network.
- Lokální profil zařízení pouze pro čtení: název Macu, identifikátor modelu, architekturu, paměť, úložiště, sériové číslo, verzi a sestavení macOS, dobu běhu, Rosettu 2 a dostupný stav baterie.
- Síťovou inventarizaci pouze pro čtení: aktivní rozhraní, IP adresy, DNS připojení i systému a Wi-Fi SSID, pokud jej macOS zpřístupní.
- Specializované služby Foundation; pohledy neobsahují logiku pro práci se souborovým systémem ani systémové dotazy.

Výchozí projekt záměrně **nesbírá** data o zabezpečení, AI nástrojích, MCP ani reportingu. Soubor `Resources/AITools.json` je součástí projektu jako datový katalog pro cvičení AI Tools.

## Otevření a spuštění

1. Otevři [MacAdminInspector.xcodeproj](MacAdminInspector.xcodeproj) v Xcode 16 nebo novějším.
2. Vyber **My Mac** a spusť aplikaci.

Nejsou vyžadována oprávnění správce, přístup k síti, telemetrie ani externí účet.

## Workshop

### Cíl

S pomocí AI asistenta pro programování rozšiř malý profil zařízení ve SwiftUI na užitečný nástroj pro lokální inventarizaci Macu. Výchozí projekt obsahuje přehled zařízení pouze pro čtení; každá další schopnost níže je samostatné cvičení.

### Výchozí stav

Spusť aplikaci a prozkoumej obrazovky **Overview** a **Network**. Zobrazují základní hardware zařízení, macOS, dobu běhu, Rosettu 2 na Apple Siliconu, stav baterie na přenosných Macích a aktivní síťovou konfiguraci.

### Cvičení 1 — OpenCode a Exo cluster

Ověř napojení OpenCode na Exo cluster. Nastav OpenCode v Xcode jako agenta a povol jeho MCP integraci.

### Cvičení 2 — Lokální repozitář a bezpečnostní inventarizace

Naklonuj repozitář na disk a přidej do aplikace lokální bezpečnostní informace pouze pro čtení:

- správa prostřednictvím MDM,
- stav FileVaultu 2,
- firewall,
- Gatekeeper,
- XProtect.

Každý zdroj dat implementuj jako samostatnou službu Foundation a v rozhraní uveď, co bylo zjištěno a z jakého zdroje.

#### Prompt pro lokální AI model

> Projdi existující projekt a implementuj obrazovku bezpečnostní inventarizace pro MDM správu, FileVault 2, firewall, Gatekeeper a XProtect. Každou kontrolu implementuj jako samostatnou službu Foundation, která je pouze pro čtení. Používej jen hodnoty, které macOS vrátí explicitně; pokud hodnota není k dispozici, zobraz „Nedostupné“ a nic neodvozuj. Nevynucuj zvýšená oprávnění, neměň konfiguraci Macu a nenačítej data přes síť. Před změnami stručně popiš zdroje dat a případné požadavky na oprávnění, poté projekt sestav v Xcode.

### Cvičení 3 — Detekce AI nástrojů

Přidej detekci AI nástrojů s využitím katalogu `Resources/AITools.json`. Rozliš zdroj detekce — například GUI aplikaci, příkazový nástroj CLI nebo spuštěný proces.

#### Prompt pro lokální AI model

> Jsi lokální model **mlx-community/Qwen3.5-122B-A10B-8bit**. Implementuj od nuly funkci **AI nástroje** v projektu MacAdminInspector. Předpokládej čistý výchozí stav bez předchozí implementace této funkce; nehledej ani neopravuj dřívější chyby. Než začneš měnit kód, přečti projekt, `AGENTS.md` a celý `Resources/AITools.json`, pak navrhni krátký plán a implementuj jej pouze přes Xcode.

> Přesná implementace:
> 1. Dekóduj `AITools.json` do modelů `Catalog`, `Tool`, `GUI` a `CLI`. Všechny vlastnosti zůstávají volitelné, protože katalog dovoluje nástroj pouze s GUI nebo pouze s CLI.
> 2. Vytvoř jednu službu Foundation, například `AIToolDetectionService`. Služba vrací pro každý nástroj jeden výsledek s názvem, kategorií a jednou či více explicitními metodami detekce.
> 3. GUI aplikaci detekuj výhradně podle `gui.bundleIdentifiers` z katalogu přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`. Výsledek označ jako „Nainstalovaná GUI aplikace“ a vrať nalezenou URL aplikace.
> 4. CLI nástroj detekuj bez spouštění shellu: pro každý název z `cli.executables` ověř `FileManager.default.isExecutableFile(atPath:)` v `cli.searchDirectories`, a pokud chybí, v kořenovém `cliSearchDirectories`. Cesty začínající `~/` rozbal pomocí `FileManager.default.homeDirectoryForCurrentUser`. Nevolej `which`, `--version`, `Process`, ani žádný shell.
> 5. Neukazuj „spuštěný proces“, protože katalog pro něj neobsahuje žádná metadata. Pokud se později přidají, navrhni rozšíření katalogu místo heuristického odhadování podle názvu procesu.
> 6. Nástroj bez shody nezobrazuj jako detekovaný. Po dokončení skenu ukaž přehledný prázdný stav s počtem zkontrolovaných položek a informací, že nebyla nalezena žádná katalogová shoda.

> Architektura a UI:
> - Služba nesmí být ve SwiftUI pohledu. View model vlastní stav `idle/loading/loaded/error`, výsledky a jedinou úlohu skenu.
> - Sken spouštěj jednou při prvním otevření obrazovky; při opětovném otevření použij uložené výsledky. Nepovol souběžný duplicitní sken.
> - I/O sken proveď mimo MainActor pomocí Swift concurrency; změny stavu UI publikuj zpět na MainActor. Sken je omezený na položky katalogu a deklarované cesty — žádné rekurzivní procházení disku, síť, XPC ani čekání na proces.
> - Indikátor načítání zobraz jen po dobu této jediné úlohy a vždy jej ukonči přes `defer` i při chybě nebo zrušení. Pohled nesmí obsahovat cyklické aktualizace stavu.
> - Na macOS 14 používej pouze dostupná API. Neměň konfiguraci Macu, nevyžaduj oprávnění správce a nepřidávej závislosti.

> Akceptační kritéria:
> - Při nainstalovaném ChatGPT je v seznamu detekován ChatGPT (a případně Codex, protože oba používají katalogový bundle identifier `com.openai.chat`); CLI nástroje se objeví pouze tehdy, je-li jejich deklarovatelný soubor skutečně spustitelný v deklarované cestě.
> - Otevření obrazovky „AI nástroje“ zůstane okamžitě responzivní, indikátor skončí po konečném lokálním skenu a následná otevření znovu neskenují.
> - Výsledek vždy odpovídá konkrétní položce a cestě/identifikátoru katalogu; žádné odhady a žádné falešné negativní stavy „Nedostupné“.
> - Sestav schéma MacAdminInspector v Xcode a ručně ověř obrazovku. Na závěr uveď přidané soubory, výsledek sestavení a skutečně detekované položky.

### Prompty k vyzkoušení

> Ověř, že je OpenCode připojený k Exo clusteru, funguje jako agent v Xcode a má povolenou MCP integraci. Popiš výsledek ověření.

> Přidej bezpečnostní inventarizaci pro MDM, FileVault 2, firewall, Gatekeeper a XProtect jako služby pouze pro čtení. Před implementací vysvětli, které kontroly vyžadují zvýšená oprávnění.

> Přidej detekci AI nástrojů s katalogem `Resources/AITools.json`. U každé detekce uveď zdroj a vyhni se interpolaci shellových příkazů.

### Kritéria dokončení

- OpenCode je ověřeně připojený k Exo clusteru, nastavený jako agent v Xcode a má povolené MCP.
- Aplikace se sestaví pro **My Mac**.
- Bezpečnostní i AI inventarizace zůstávají lokální a pouze pro čtení.
- Text viditelný uživateli uvádí, co a jak bylo detekováno.
- Každý nový zdroj inventarizace má vlastní úzce zaměřenou službu Foundation.

### Body pro návrat

Před každým cvičením vytvoř commit s kontrolním bodem. Pokud se experiment nepovede, vrať se k poslednímu kontrolnímu bodu místo snahy zachraňovat nesouvisející změny.

## Soukromí a bezpečnost

Data inventarizace zůstávají na Macu. Nové funkce mají být lokální a pouze pro čtení, nesmějí data nahrávat ani měnit konfiguraci zařízení a nesmějí zpřístupňovat přihlašovací údaje z konfiguračních souborů.

## Licence

MIT — viz [LICENSE](LICENSE).
