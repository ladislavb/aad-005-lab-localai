# Mac Admin Inspector

Mac Admin Inspector je malý local-first SwiftUI Lab pro **Apple Admin Days**. Účastníci s pomocí AI asistenta rozšiřují inventarizaci macOS o úzce vymezené funkce pouze pro čtení.

## Účel a struktura dokumentace

- [AGENTS.md](AGENTS.md) obsahuje závazná provozní pravidla pro agenta a práci v projektu.
- [SPECIFICATION.md](SPECIFICATION.md) je implementační kontrakt jednotlivých funkcí: zdroje dat, hranice, architektura a akceptační kritéria.
- Tento README je workshopový průvodce. Popisuje cíl cvičení a obsahuje krátké prompty; nemá opakovat implementační detaily ze specifikace.

## Výchozí aplikace

Aplikace cílí na macOS 14+ a obsahuje:

- **Overview** — lokální profil zařízení: hardware, macOS, úložiště, doba běhu, Rosetta a dostupné údaje o baterii.
- **Network** — lokální aktivní rozhraní, adresy, DNS a Wi-Fi údaje, pokud je macOS poskytne.
- specializované Foundation služby; SwiftUI pohledy neprovádějí systémové dotazy ani parsování.

Podrobná pravidla těchto funkcí jsou ve SPECIFICATION.

## Otevření a spuštění

1. Otevři [MacAdminInspector.xcodeproj](MacAdminInspector.xcodeproj) v Xcode 16 nebo novějším.
2. Vyber **My Mac** a spusť aplikaci.

Výchozí inventarizace nevyžaduje administrátorská práva, externí účet ani telemetrii.

## Workshop

Každé cvičení řeš samostatně a před zahájením vytvoř commit jako kontrolní bod. Prompt má popsat cíl; přesnou implementaci vždy určuje odkazovaná sekce v [SPECIFICATION.md](SPECIFICATION.md).

### Cvičení 1 — OpenCode a Exo cluster

Ověř napojení OpenCode na Exo cluster. Nastav OpenCode v Xcode jako agenta a povol jeho MCP integraci.

```text
Ověř, že je OpenCode připojený k Exo clusteru, funguje jako agent v Xcode a má povolenou MCP integraci. Popiš výsledek ověření.
```

### Cvičení 2 — Bezpečnostní inventarizace

Přidej obrazovku pro místní, pouze čtecí inventarizaci MDM, FileVaultu 2, Application Firewallu včetně jeho detailů, Gatekeeperu a SIP.

```text
Nejdřív si přečti AGENTS.md a SPECIFICATION.md v rootu repozitáře, zejména sekci „Bezpečnostní inventarizace“. SPECIFICATION.md je závazná.

Před změnami pomocí Xcode MCP prozkoumej aktuální strukturu projektu a otevři existující modely, služby a pohledy související s kartou Security. Neodvozuj názvy ani cesty souborů ze specifikace; pokud soubor nenajdeš, nejdřív jej vyhledej v projektu. Tento průzkum nepovažuj za chybu.

Implementuj kartu Security pro lokální, pouze čtecí inventarizaci MDM, FileVault 2, Application Firewallu včetně jeho detailů, Gatekeeperu a SIP. Dodrž datový model, pravidla pro Unavailable a UI smlouvu ze SPECIFICATION.md. Před dokončením porovnej výsledný kód s každým bodem sekce „Bezpečnostní inventarizace“. Neměň konfiguraci Macu, nevyžaduj vyšší oprávnění, nepoužívej síť a po změně sestav schéma MacAdminInspector v Xcode.
```

### Cvičení 3 — Detekce nainstalovaných AI nástrojů

Najdi všechny výskyty GUI aplikací a CLI executables podle katalogu `Resources/AITools.json`.

```text
Nejdřív si přečti AGENTS.md, SPECIFICATION.md a celý katalog Resources/AITools.json. Před změnami prozkoumej aktuální strukturu projektu; názvy budoucích souborů neodvozuj ze specifikace. Implementuj pouze cvičení „Detekce nainstalovaných nástrojů“ ze sekce „AI nástroje“ v SPECIFICATION.md. Po změně sestav schéma MacAdminInspector v Xcode.
```

### Cvičení 4 — Detekce spuštěných AI nástrojů

Doplň ručně spuštěný přehled běžících katalogových nástrojů a jejich parent procesů.

```text
Nejdřív si přečti AGENTS.md, SPECIFICATION.md a celý katalog Resources/AITools.json. Před změnami prozkoumej aktuální strukturu projektu. Implementuj pouze cvičení „Detekce spuštěných nástrojů“ ze sekce „AI nástroje“ v SPECIFICATION.md. Navazuj na hotové cvičení 3; neměň jeho pravidla statické detekce. Po změně sestav schéma MacAdminInspector v Xcode.
```

### Cvičení 5 — Procesy s MCP metadaty

Zobraz procesy, jejichž metadata obsahují `mcp`, spolu s parent procesem.

```text
Nejdřív si přečti AGENTS.md a SPECIFICATION.md. Před změnami prozkoumej aktuální strukturu projektu. Implementuj pouze cvičení „Procesy s MCP metadaty“ ze sekce „AI nástroje“ v SPECIFICATION.md. Navazuj na hotové cvičení 4 a znovu nepřebírej procesní snapshot. Neprezentuj výsledek jako potvrzené MCP spojení. Po změně sestav schéma MacAdminInspector v Xcode.
```

## Dokončení cvičení

Po dokončení uveď změněné soubory, výsledek sestavení, ručně ověřenou cestu a systémová omezení. Podrobné akceptační podmínky jsou ve specifikaci.

## Soukromí a bezpečnost

Inventarizační data zůstávají na Macu. Nové funkce nesmějí data nahrávat, měnit konfiguraci zařízení ani zpřístupňovat přihlašovací údaje. Externí zdroj je možný jen po výslovném schválení a musí být v UI pojmenován.

## Licence

MIT — viz [LICENSE](LICENSE).
