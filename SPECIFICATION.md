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

Jediným zdrojem produktových metadat je `MacAdminInspector/Resources/AITools.json`. Kořen obsahuje `cliSearchDirectories` a `tools`; nástroj má `id`, `name`, `category` a volitelně `gui` a/nebo `cli`. `gui.bundleIdentifiers` obsahuje bundle ID a `cli.executables` názvy souborů. Pro CLI je vždy základem `cliSearchDirectories` z kořene; volitelné `cli.searchDirectories` u položky jsou další cesty, které se k němu přidají — nikdy jej nenahrazují. Efektivní seznam je sjednocení obou seznamů bez duplicit.

### Cvičení 3 — Detekce nainstalovaných nástrojů

- Každý nález je samostatný výskyt. Identitu tvoří `tool.id`, metoda a kanonická skutečná cesta; odstranit lze jen přesný duplicitní nález se stejnou trojicí. Nikdy neslučuj výskyty podle názvu produktu, názvu executable ani toho, že patří do stejné `.app`.
- Pro nalezenou GUI aplikaci vždy vytvoř výskyt s metodou `GUI app` a cestou ke kořeni `.app`. GUI hledej jen přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`.
- Je-li u stejné položky deklarováno `cli.executables`, každý nalezený deklarovaný executable uvnitř GUI aplikace je další výskyt s metodou `App executable` a svou cestou. Pro každý executable z `cli.executables` rekurzivně prohledej celý `.app` bundle od kořene; první nalezený soubor se shodujícím názvem, který je běžný a spustitelný, se přidá jako výsledek. Binární název neodvozuj.
- Každý nalezený CLI executable mimo `.app` je nezávislý výskyt s metodou `CLI executable`, i když má stejný název jako GUI aplikace nebo její embedded executable. CLI hledej pomocí `FileManager.default.isExecutableFile(atPath:)` ve všech efektivních katalogových cestách; `~/` rozbal přes `homeDirectoryForCurrentUser`.
- Statická detekce nepoužívá shell, `which`, `Process`, `--version`, XPC, síť ani rekurzivní procházení mimo nalezené `.app`. Nenalezené položky skryj; prázdný výsledek a chybu katalogu zobraz explicitně.
- UI používá stejný layout jako Overview a Network: `ScrollView`, obsah s paddingem 32 a `GroupBox` s `Grid` řádky. Nevkládej vlastní velký nadpis. Každý výskyt zobraz v samostatném `GroupBox` v řádcích `Tool`, `Category`, `Method` a `Path`; cesta je označitelná. Počet výskytů nesmí označovat za „unique“ a nesmí naznačovat sloučení.
- První otevření karty spustí statický scan právě jednou. Další scan spouští uživatel akcí `Refresh` v toolbaru. Stav a scan vlastní view model; pohled přímo nespouští službu ani `Task`.

### Cvičení 4 — Verze a podpis nainstalovaných nástrojů

Rozšiř existující kartu **AI Tools** o uživatelem spouštěný přehled **Version & Signature**. Vstupem jsou výhradně jednotlivé nálezy z přehledu **Installed** ve cvičení 3. Zachovej Installed přehled, navigaci i vizuální styl aplikace; nevytvářej další filesystem scan, procesní snapshot, polling ani sledování na pozadí.

- Pro GUI aplikaci čti z jejího bundle pouze `CFBundleShortVersionString`, `CFBundleVersion` a bundle identifier. Chybějící nebo prázdná hodnota je `Unavailable`; verzi neodvozuj z názvu aplikace, cesty ani názvu souboru.
- Pro CLI nástroj zjišťuj verzi jen po výslovné akci uživatele Refresh. Je povoleno spustit výhradně nalezený executable jeho kanonickou absolutní cestou s jediným argumentem `--version`. Nepoužívej shell, PATH, `which`, `/bin/ps` ani jakékoli zjišťování běžících procesů.
- CLI kontrole nastav `LANG=C` a `LC_ALL=C`, zavři stdin a odděleně zachyť stdout a stderr, každý nejvýše do 4 KiB. Kontrola má timeout 3 sekundy; při timeoutu nebo zrušení proces ukonči a vyčkej na jeho skončení. Proces nesmí po skončení scanu zůstat běžet ani získat vstup uživatele.
- Za verzi CLI považuj pouze jednoznačný token ve tvaru `v?MAJOR.MINOR.PATCH` s případným suffixem. Když výstup takový token neobsahuje, obsahuje různé tokeny nebo kontrola selže, zobraz `Unavailable` s konkrétním důvodem. Nezobrazuj celý výstup a verzi neodhaduj.
- Podpis ověřuj výhradně přes Security framework pomocí `SecStaticCodeCreateWithPath`, `SecStaticCodeCheckValidity` a signing information. Nikdy nespouštěj `codesign`. Stav podpisu je `Valid`, `Invalid`, `Unsigned` nebo `Unavailable`; Team ID zobraz jen pokud jej framework explicitně vrátí.
- Každý nález zobraz v samostatném `GroupBox` ve stejném layoutu jako cvičení 3. Řádky jsou `Tool`, `Category`, `Method`, `Path`, `Version`, `Build`, `Signature` a `Team ID`. Pro CLI jsou `Build` a Team ID `Unavailable`, pokud je zdroj neposkytne.

Přehled Version & Signature má vlastní stav `idle/loading/loaded/error`, výsledky, počet zkontrolovaných nálezů a právě jednu rušitelnou scan úlohu. Jeho stav nesmí ovlivnit Installed přehled.

- Scan spusť pouze akcí uživatele Refresh; nepoužívej automatický scan. Po spuštění ihned přejdi do `loading` a zakaž další Refresh.
- `Refresh` nesmí blokovat `MainActor`. Čtení bundle metadat, ověřování podpisů, běh CLI i parsování výstupu musí probíhat mimo hlavní aktor; na něj se vrací pouze hotové neměnné hodnotové modely a konečný stav.
- Pravidelně kontroluj zrušení. Při opuštění obrazovky nebo zániku view modelu scan zruš. Zrušený či starší scan nesmí přepsat stav ani výsledek novějšího scanu.

UI zachovej ve stylu ostatních sekcí: `ScrollView`, padding 32, `GroupBox` a `Grid`. Pohled pouze vykresluje model a volá akce view modelu; přímo nevytváří `Task` ani nevolá službu. Zobraz explicitní počáteční, načítací, prázdný, výsledkový a chybový stav.

Před dokončením obnov diagnostiku změněných Swift souborů, sestav schéma `MacAdminInspector` a aplikaci spusť. Ověř, že Installed přehled zůstal funkční, kontrola verzí i podpisů neblokuje UI, nelze ji spustit souběžně a zrušený scan nepublikuje výsledek.

### Cvičení 5 — Konfigurace a bezpečnostní analýza EXO clusteru

- Cílem je získat kompletní konfiguraci běžících AI toolů a provést jejich bezpečnostní analýzu na EXO clusteru.
- Pro každý běžící AI tool (z cvičení 4) získej:
  - **Konfiguraci**: Hledej konfigurační soubory v `~/.opencode/`, `~/.config/opencode/`, `/etc/` a v pracovním adresáři procesu. Podporované formáty: `opencode.json`, `opencode.jsonc`, `opencode.yaml`, `opencode.yml`.
  - **MCP servery**: Z katalogu běžících procesů extrahuj argumenty obsahující `mcp`, `server`, `transport` nebo `connection`. Ty označ jako potenciální MCP konfiguraci.
  - **Bezpečnostní metadata**: Získej digitální podpis (codesign -dv), certifikát (codesign -dv --verbose=4), a zkontroluj zda je binary signován validním vývojářským certifikátem.
- **EXO cluster analýza**:
  - Porovnej konfiguraci běžících AI toolů s lokální `opencode.jsonc` v rootu projektu.
  - Identifikuj rozdíly v modelových nastaveních, MCP server konfiguracích a bezpečnostních politikách.
  - Zkontroluj zda běžící tool používá stejný EXO cluster endpoint jako lokální konfigurace.
  - Vyhodnoť zda jsou API klíče a tokeny referencovány přes environment variablu nebo hardcodované.
- Výstup: Pro každý běžící tool ukaž sekci s konfigurací (cesta k souboru, obsah v preformátovaném textu), MCP servery (seznam detekovaných serverů a jejich transport), bezpečnostní stav (signován/nesignován, certifikát), a EXO cluster konzistenci (shoda s lokální konfigurací, rozdíly).
- Sken se spouští akcí uživatele. I/O operace čtou soubory a procesní metadata pouze pro čtení.

### Společný stav a výsledek

- Každý přehled vlastní stav `idle/loading/loaded/error`, výsledky, počet zkontrolovaných položek a jedinou úlohu svého scanu. I/O běží mimo MainActor.
- Akce vyvolaná z pohledu předá řízení view modelu; pohled přímo nevytváří `Task`, nečeká synchronně na službu ani nemění výsledky scanu.
- Při selhání nebo nejednoznačném výsledku zobraz `Unavailable` a zdroj; nesupluj jej odhadem.
