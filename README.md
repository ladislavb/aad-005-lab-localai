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

Přidej obrazovku pro místní, pouze čtecí inventarizaci MDM, FileVaultu 2, firewallu, Gatekeeperu a XProtectu.

```text
Implementuj bezpečnostní inventarizaci pro MDM, FileVault 2, firewall, Gatekeeper a XProtect podle sekce „Bezpečnostní inventarizace“ v SPECIFICATION.md.
```

### Cvičení 3 — Detekce AI nástrojů

Přidej nebo rozšiř detekci nainstalovaných AI nástrojů podle katalogu `Resources/AITools.json`.

```text
Implementuj detekci AI nástrojů podle sekce „AI nástroje“ v SPECIFICATION.md. Před změnou si přečti AGENTS.md, SPECIFICATION.md a celý katalog Resources/AITools.json.
```

## Dokončení cvičení

Po dokončení uveď změněné soubory, výsledek sestavení, ručně ověřenou cestu a systémová omezení. Podrobné akceptační podmínky jsou ve specifikaci.

## Soukromí a bezpečnost

Inventarizační data zůstávají na Macu. Nové funkce nesmějí data nahrávat, měnit konfiguraci zařízení ani zpřístupňovat přihlašovací údaje. Externí zdroj je možný jen po výslovném schválení a musí být v UI pojmenován.

## Licence

MIT — viz [LICENSE](LICENSE).
