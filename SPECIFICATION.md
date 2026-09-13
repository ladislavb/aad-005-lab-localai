# Specification — MacAdminInspector Lab

Implementační kontrakt pro cvičení. Prompt určuje cíl; tento dokument určuje funkční hranice a akceptační podmínky. `AGENTS.md` určuje způsob práce s projektem.

## Společná pravidla

- Cesty v tomto dokumentu jsou relativní k rootu repozitáře. Hodnoty cest uložené v `AITools.json` naopak popisují lokální filesystem uživatele a nejsou relativní k repozitáři. Funkční požadavky neudávají názvy nových Swift souborů; před změnou vždy prozkoumej aktuální strukturu projektu.
- Minimum deployment target je macOS 14.0. Inventarizace je lokální a pouze pro čtení, bez změny konfigurace, vyšších oprávnění, nových závislostí, telemetrie a odesílání dat. Jedinou výjimkou je uživatelem potvrzené jednorázové odeslání podle Cvičení 5.
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

Jediným zdrojem produktových metadat je `MacAdminInspector/Resources/AITools.json`. Kořen obsahuje `cliSearchDirectories` a `tools`; nástroj má `id`, `name`, `category` a volitelně `gui`, `cli` a/nebo `configSearch`. `gui.bundleIdentifiers` obsahuje bundle ID a `cli.executables` názvy souborů. Volitelné `cli.versionArguments` je pole neprázdných řetězců pro zjištění verze; není-li uvedeno, použij přesně `["--version"]`. Argumenty jsou statická katalogová data bez interpolace a nikdy neobsahují uživatelský vstup. Pro CLI je vždy základem `cliSearchDirectories` z kořene; volitelné `cli.searchDirectories` u položky jsou další cesty, které se k němu přidají — nikdy jej nenahrazují. Efektivní seznam je sjednocení obou seznamů bez duplicit.

### Cvičení 3 — Detekce nainstalovaných nástrojů a verzí

- Každý nález je samostatný výskyt. Identitu tvoří `tool.id`, metoda a kanonická skutečná cesta; odstranit lze jen přesný duplicitní nález se stejnou trojicí. Nikdy neslučuj výskyty podle názvu produktu, názvu executable ani toho, že patří do stejné `.app`.
- Pro nalezenou GUI aplikaci vždy vytvoř výskyt s metodou `GUI app` a cestou ke kořeni `.app`. GUI hledej jen přes `NSWorkspace.shared.urlForApplication(withBundleIdentifier:)`.
- Je-li u stejné položky deklarováno `cli.executables`, každý nalezený deklarovaný executable uvnitř GUI aplikace je další výskyt s metodou `App executable` a svou cestou. Pro každý executable z `cli.executables` rekurzivně prohledej celý `.app` bundle od kořene; první nalezený soubor se shodujícím názvem, který je běžný a spustitelný, se přidá jako výsledek. Binární název neodvozuj.
- Každý nalezený CLI executable mimo `.app` je nezávislý výskyt s metodou `CLI executable`, i když má stejný název jako GUI aplikace nebo její embedded executable. CLI hledej pomocí `FileManager.default.isExecutableFile(atPath:)` ve všech efektivních katalogových cestách; cesty s `~/` rozbal spojením `homeDirectoryForCurrentUser.path + "/" + restOfPath`.
- Statická část detekce nepoužívá shell, `which`, XPC, síť ani rekurzivní procházení mimo nalezené `.app`. Nenalezené položky skryj; prázdný výsledek a chybu katalogu zobraz explicitně.
- Pro GUI aplikaci čti z jejího bundle pouze `CFBundleShortVersionString`, `CFBundleVersion` a bundle identifier. Chybějící nebo prázdná hodnota je `Unavailable`; verzi neodvozuj z názvu aplikace, cesty ani názvu souboru.
- Pro CLI nástroj spusť nalezený executable jeho kanonickou absolutní cestou s argumenty z `cli.versionArguments`, popř. přesně `["--version"]`. Nepoužívej shell, PATH, `which`, `/bin/ps` ani jakékoli zjišťování běžících procesů. Prostředí procesu nahraď přesně hodnotami `LANG=C` a `LC_ALL=C`; neděď prostředí aplikace. Zavři stdin.
- CLI kontroly prováděj sekvenčně v deterministickém pořadí výsledků. `Process.run()` pouze proces spouští: mimo `MainActor` od okamžiku spuštění průběžně odčítej stdout i stderr. Z každého streamu uchovej nejvýše 4 KiB, ale po dosažení limitu další data dál odčítej a zahazuj až do skončení procesu.
- Kontrola CLI má timeout 3 sekundy; při timeoutu nebo zrušení proces ukonči a mimo `MainActor` vyčkej na jeho skončení. `terminate()` volej pouze na úspěšně spuštěný, dosud běžící proces. Proces nesmí po skončení scanu zůstat běžet ani získat vstup uživatele. Za verzi považuj pouze jednoznačný token ve tvaru `v?MAJOR.MINOR.PATCH` s případným suffixem. Při selhání, nejednoznačném výstupu nebo chybějícím tokenu zobraz `Unavailable` s konkrétním důvodem; nezobrazuj celý výstup a verzi neodhaduj.
- UI používá stejný layout jako Overview a Network: `ScrollView`, obsah s paddingem 32 a `GroupBox` s `Grid` řádky. Nevkládej vlastní velký nadpis. Každý výskyt zobraz v samostatném `GroupBox` v řádcích `Tool`, `Category`, `Method`, `Path` a `Version`; u GUI aplikace doplň `Build`. Pro CLI je `Build` `Unavailable`. Cesta je označitelná. Počet výskytů nesmí označovat za „unique“ a nesmí naznačovat sloučení.
- První otevření karty spustí právě jeden kompletní scan: statickou detekci, načtení GUI metadat a kontroly CLI verzí. Další kompletní scan spouští uživatel akcí `Refresh` v toolbaru. Stav a jedinou rušitelnou úlohu scanu vlastní view model; pohled přímo nespouští službu ani `Task`.
- Scan se po spuštění ihned přepne do `loading` a další Refresh je po dobu běhu nedostupný. Snímání souborového systému, čtení bundle metadat, běh CLI a parsování výstupu běží mimo `MainActor`; na něj se vrací pouze hotové neměnné hodnotové modely a konečný stav. Při opuštění obrazovky nebo zániku view modelu scan zruš; zrušený či starší scan nesmí přepsat novější výsledek.

### Cvičení 4 — Lokální revize AI konfigurací

Přidej samostatný panel **AI Configs**. Výsledky označ jako `Local configuration source`; jejich hodnoty jsou neověřený obsah uživatelských konfigurací, nikoli lokálně ověřený bezpečnostní stav. Panel nic nespouští, nemění, nenahrává ani nesdílí přes síť.

#### Katalogová data

- Volitelné `configSearch` nástroje obsahuje `paths`, neprázdné pole katalogově deklarovaných adresářů, `recursive`, `includePatterns`, `excludePatterns` a volitelné `excludeDirectoryPatterns`. Jednotlivé soubory se vyhledávají jako přesný include pattern v některém z těchto adresářů.
- Každá cesta v `paths` začíná přesně `~/` nebo `/`. Aplikace rozbalí pouze úvodní `~/` přes `FileManager.default.homeDirectoryForCurrentUser`; odmítne relativní cesty, proměnné prostředí a segment `..`. Pro cestu `~/` musí být `recursive` vždy `false`.
- `includePatterns` a `excludePatterns` jsou jednoduché globy porovnávané pouze se jménem souboru; podporují jen `*`, nikoli regulární výrazy ani oddělovač cesty. Kandidát musí odpovídat alespoň jednomu include patternu; exclude pattern má vždy přednost. Pro každý nástroj zahrň alespoň `auth.json`, `credentials.json`, `keys.json`, `secrets.yaml`, `.env` a `.env.*` mezi `excludePatterns`.
- `excludeDirectoryPatterns` jsou volitelné jednoduché globy porovnávané pouze se jménem adresáře. Shodný adresář přeskoč před načtením jeho obsahu; pattern `cache` proto vyloučí `cache` i v libovolném vnoření pod deklarovanou cestou.
- Cesty, přípony, výjimky ani názvy souborů neodvozuj ze jména nástroje. Nástroj bez `configSearch` nemá žádné kandidáty.

#### Hledání a náhled

- Při prvním otevření panelu proveď právě jeden lokální scan; `Refresh` jej provede znovu. Rekurze je povolená pouze pod existujícími katalogovými adresáři, s maximální hloubkou 2, nejvýše 100 kandidáty celkem a nejvýše 64 KiB na soubor.
- Zpracuj pouze běžný soubor odpovídající alespoň jednomu `includePatterns`. Neprocházej symlinky; po kanonizaci musí každý soubor zůstat uvnitř kanonické deklarované cesty. Chybějící, nečitelný, příliš velký nebo binární soubor zobraz jako `Unavailable` s důvodem.
- Výsledkový seznam obsahuje `Tool`, `Category`, `Path`, `Format`, `Size` a stav náhledu. Cesta je označitelná; každý výsledek zobrazuje samostatný `GroupBox` ve stejném layoutu jako ostatní inventarizační karty.
- Obsah načti až po výslovné akci uživatele nad konkrétním souborem nebo při výslovné akci `Prepare audit snapshot` podle Cvičení 5. JSON a JSONC zobraz jako strukturovaný redigovaný náhled do limitu velikosti; JSONC nejprve převeď na JSON lexerem, který respektuje řetězce, řádkové i blokové komentáře a koncové čárky. YAML a TOML zobraz jako redigovaný textový náhled; nepřidávej závislost jen kvůli jejich parsování.
- Ve strukturovaném JSON/JSONC náhledu hodnotu klíče, jehož název po normalizaci obsahuje `token`, `key`, `secret`, `password`, `authorization` nebo `credential`, vždy nahraď textem `REDACTED`. Při neplatném JSON nebo JSONC zobraz `Unavailable` s důvodem.
- V textovém YAML/TOML náhledu rediguj hodnotu každé položky klíč–hodnota se stejným citlivým názvem klíče, a to pro zápis s `:` i `=`; hodnota i případný navazující odsazený blok se nahradí textem `REDACTED`. Nerozpoznané nebo nejednoznačné zápisy raději nezobrazuj jako nezkontrolovaný obsah.
- Blokované soubory z `excludePatterns` nikdy nečti ani nezobrazuj. Redakce je ochranná vrstva, ne důkaz absence tajných údajů; proto nikdy nezobrazuj neupravený obsah a náhled označ jako `Redacted local configuration`.

#### Stav a ověření

- Panel vlastní stav `idle/loading/loaded/error`, výsledky, počet zkontrolovaných cest a jedinou rušitelnou úlohu scanu. Snímání adresářů, čtení souborů, parsování a redakce běží mimo `MainActor`; pohled pouze vykresluje model a volá akce view modelu.
- Během `loading` zakaž další Refresh. Při opuštění panelu nebo zániku view modelu scan zruš; zrušený či starší scan nesmí přepsat novější výsledek.
- Před dokončením ověř prázdný výsledek, blokovaný soubor, redigovaný klíč, nečitelný nebo neplatný soubor a ruční otevření náhledu. Sestav schéma `MacAdminInspector` a aplikaci spusť.

## Cvičení 5 — Security Audit přes OpenAI-compatible endpoint

Přidej nastavení endpointu a samostatný panel **Security Audit**. Cvičení výslovně povoluje jediný typ síťové operace: uživatelem potvrzený `POST` redigovaného auditního snapshotu na nakonfigurovaný OpenAI-compatible endpoint. Nenahrávej data automaticky, na pozadí ani pro telemetrii.

### Nastavení endpointu

- Použij existující mechanismus nastavení aplikace. Pokud jej projekt nemá, přidej jen minimální nastavení nutné pro Security Audit, bez změny stávajících sekcí a globálního vzhledu.
- Nastavení obsahuje `Endpoint URL`, `Model` a volitelný `API key`. Endpoint URL je úplná URL OpenAI API rootu končící `/v1`; povol pouze schéma `https` nebo `http`. `http` zřetelně označ jako nešifrované připojení. Neprováděj přesměrování a po uložení zobraz normalizovanou cílovou URL.
- `Endpoint URL` a `Model` lze uložit do běžného lokálního nastavení aplikace. API klíč nikdy neukládej do `UserDefaults`, do snapshotu, do logů ani do UI po opuštění editačního pole; ulož jej výhradně do Keychainu. Prázdný klíč znamená, že se hlavička `Authorization` neodešle. Uživatel jej může odstranit.
- Nastavení nesmí provádět testovací request ani jinou síťovou operaci. Podporuj OpenAI i Exo pouze jako obecné OpenAI-compatible servery; nepřidávej provider-specifická pravidla, katalogy modelů ani autentizaci.

### Příprava a kontrola snapshotu

- Otevření panelu Security Audit samo nic nenačítá, nespouští ani neodesílá. Výslovná akce `Prepare audit snapshot` lokálně znovu načte zdroje Overview, Network, Security, AI Tools a AI Configs a vytvoří z nich nový úplný snapshot. Public IP zahrň pouze tehdy, pokud ji už uživatel dříve výslovně načetl. Tato akce je jediná, která smí načíst redigovaný obsah všech nalezených konfigurací pro účely auditu.
- `AuditSnapshotBuilder` získává data přímo z injektovaných služeb nebo samostatného koordinačního objektu. Nesmí číst výchozí, zobrazený ani případně zastaralý stav jiných ViewModelů. Před serializací musí `await` dokončení každého zdroje; až poté vytvoří snapshot a nastaví `generatedAt` na aktuální čas vytvoření snapshotu.
- Snapshot zahrnuje všechna data takto získaná včetně položek `Unavailable` a jejich stručných důvodů, ale ne neupravené výstupy systémových příkazů ani interní diagnostiku.
- Každá nedostupná skalární hodnota se v JSON serializuje jako `null`, nikdy jako `0`, `false`, prázdný řetězec, prázdné pole ani text `Unavailable`. Kořenový objekt `unavailableReasons` mapuje plnou cestu pole, například `device.memoryBytes`, na konkrétní důvod. Prázdné pole je povolené jen tehdy, když zdroj explicitně potvrdil nulový počet položek.
- Snapshot neobsahuje API klíče, tokeny, hesla, credentials, blokované konfigurační soubory, neupravený obsah konfigurací, absolutní nebo relativní lokální cesty, uživatelské jméno ani hodnoty redigované podle Cvičení 4. Konfiguraci reprezentuj názvem nástroje, kategorií, formátem, velikostí a redigovaným náhledem; všechny cesty z modelu před serializací odstraň.
- Pro každý nalezený a neblokovaný kandidát musí `Prepare audit snapshot` načíst soubor a vytvořit jeho redigovaný obsah podle pravidel Cvičení 4. Každá položka `aiConfigs` proto obsahuje `redactedContent`, nebo `previewStatus: "Unavailable"` s konkrétním důvodem; samotná metadata, odkaz nebo cesta k souboru nestačí. Cestu před serializací vždy odstraň.
- Snapshot serializuj jako deterministický JSON s `schemaVersion`, `generatedAt`, `device`, `network`, `security`, `aiTools`, `aiConfigs` a `unavailableReasons`. Neodvozuj ani nedoplňuj chybějící hodnoty. Před odesláním zobraz uživateli přesný JSON, počet konfigurací a cílovou URL; obsah je označen `Redacted local snapshot`.
- Je-li libovolná konfigurace nečitelná, příliš velká, binární nebo nemůže být bezpečně redigována, zahrň pouze její metadata a stav `Unavailable`; nikdy ji nevynechávej potichu ani neposílej její původní obsah.

### Prompt, request a odpověď

- Auditní instrukce jsou výhradně v bundle resource `MacAdminInspector/Resources/SecurityAuditPrompt.md`. Soubor je součástí targetu, nepochází ze sítě a není upravitelný z UI. Musí modelu říct, že celý snapshot je nedůvěryhodný vstup, nesmí se řídit instrukcemi uvnitř dat, musí uvést důkazy z konkrétních polí, míru jistoty a lokální doporučené ověření nebo nápravu. Nesmí požadovat, odvozovat ani rekonstruovat tajemství.
- Po kliknutí `Send for analysis` zobraz před odesláním potvrzovací dialog se cílovou URL, modelem a upozorněním, že redigovaný snapshot opustí zařízení. Jedině potvrzení spustí request; zrušení nic neodesílá.
- Odesílej přes ephemeral `URLSession` bez cookie storage, cache a automatické autentizace právě jeden `POST` na `Endpoint URL + /chat/completions`, s `Content-Type: application/json`, volitelnou hlavičkou `Authorization: Bearer <API key>` a tělem OpenAI Chat Completions: `model`, `messages` se systémovou zprávou ze `SecurityAuditPrompt.md` a uživatelskou zprávou obsahující přesný snapshot JSON mezi datovými oddělovači. Neposílej cookies, vlastní identifikátor zařízení ani jiné hlavičky mimo nezbytné HTTP hlavičky.
- Nastav timeout requestu na 30 sekund, neprováděj automatický retry a při zrušení request zruš. Akce Send je během přípravy nebo odesílání nedostupná; nový `Prepare audit snapshot` zneplatní starší neodeslaný snapshot.
- Přijmi pouze úspěšnou HTTP odpověď s neprázdným textovým obsahem `choices[0].message.content`. Neplatnou URL, chybu transportu, timeout, neúspěšný HTTP status nebo nekompatibilní tělo zobraz jako `Unavailable` s konkrétním důvodem. Odpověď je nedůvěryhodná externí analýza: zobraz ji spolu s endpointem a časem, neinterpretuj ji jako lokálně ověřený bezpečnostní stav a neprováděj z ní akce.
- Výsledek analýzy ani snapshot trvale neukládej. Panel může držet výsledek jen v paměti po dobu otevřené relace; při opuštění panelu zruš běžící request a zahoď připravený snapshot i odpověď.

### Stav a ověření

- Panel vlastní stavy `idle/preparing/ready/sending/received/error` a jedinou rušitelnou úlohu. Příprava, serializace, Keychain a síť běží mimo `MainActor`; na něj se vrací jen hotové hodnotové modely a stav. Pohled pouze volá akce ViewModelu.
- V `ready` jsou dostupné přesný náhled a `Send for analysis`; v `sending` jsou `Prepare audit snapshot` i Send nedostupné. Při chybě zachovej pouze bezpečný, již zobrazený snapshot pro opakované uživatelské odeslání, nikdy klíč ani neupravená data.
- Unit testy ověří serializaci, deterministické pořadí, vyloučení cest a tajemství, Keychain hranici, request bez klíče i s klíčem, úspěšnou odpověď, HTTP chybu, timeout a zrušení. Použij injektovatelný `URLSession`/transport nebo ekvivalentní stub; test nesmí volat reálnou síť. UI test ověří, že se před potvrzením request neodešle, a že dialog ukazuje endpoint, model a upozornění.
- Před dokončením ověř lokální přípravu úplného snapshotu, redakci konfigurace, zrušené potvrzení, úspěšnou i neúspěšnou odpověď a spuštění aplikace. Sestav schéma `MacAdminInspector`.

### Společný stav a výsledek

- Každý přehled vlastní stav `idle/loading/loaded/error`, výsledky, počet zkontrolovaných položek a jedinou úlohu svého scanu. I/O běží mimo MainActor.
- Akce vyvolaná z pohledu předá řízení view modelu; pohled přímo nevytváří `Task`, nečeká synchronně na službu ani nemění výsledky scanu.
- Při selhání nebo nejednoznačném výsledku zobraz `Unavailable` a zdroj; nesupluj jej odhadem.

## Testování a ověření

- Unit testy pro služby: parsování výstupů, error handling, edge cases (prázdný výstup, timeout, neplatná data).
- UI testy: navigace mezi kartami, refresh akce, zobrazení stavů (idle, loading, loaded, error, prázdný výsledek).
- Ověř, že scan běží mimo MainActor a výsledky se vrací na MainActor.
- Testuj cancellation: scan se musí zastavit při opuštění panelu nebo zrušení Tasku.

## UI kontrakt

- Layout: `ScrollView` s paddingem 32, GroupBox s Grid řádky, řádky mají `foregroundStyle(.secondary)` pro label a `textSelection(.enabled)` pro hodnotu.
- Stavové obrazovky:
  - `idle`: Cvičení 3 a 4 spustí svůj scan automaticky při `onAppear`; Cvičení 5 čeká na akci `Prepare audit snapshot`. `onAppear` smí pouze zavolat idempotentní akci view modelu; pohled nesmí vytvářet úlohu ani přímo spouštět službu.
  - `loading`: Indeterminate `ProgressView` se zprávou "Scanning..." nebo "Loading...".
  - `loaded`: Výsledky nebo "No X found." pro prázdný výsledek.
  - `error`: Zpráva "Error loading X" a detail chyby v `font(.caption)` s `foregroundStyle(.secondary)`.
- Toolbar: Refresh button s ikonou `arrow.clockwise`, zakázán během `loading`.
- Accessibility: Všechny GroupBox řádky mají meaningful labels pro VoiceOver.

## Performance limity

- CLI timeout: 3 sekundy na jeden nástroj.
- Souborové hledání: max hloubka 2, max 100 kandidátů, max 64 KiB na soubor.
- Stream buffering: max 4 KiB na stdout/stderr pro CLI výstupy.
- Scan cancellation: starší scan nesmí přepsat novější výsledek.

## Build a lint

- Deployment target: macOS 14.0.
- SwiftLint: pokud je v projektu již nakonfigurován a dostupný přes povolený nástroj, spusť jej před dokončením a oprav jeho varování.
- Formátování: 4-space indentation, max 120 znaků na řádek, žádné trailing whitespace.
- Build musí být bez chyb a varování.
