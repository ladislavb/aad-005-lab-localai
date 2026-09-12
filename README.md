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

Každé cvičení řeš samostatně a před zahájením vytvoř commit jako kontrolní bod. Prompt určuje cíl; přesné funkční požadavky jsou v [SPECIFICATION.md](SPECIFICATION.md). Všechny uvedené cesty jsou relativní k rootu repozitáře.

### Cvičení 1 — OpenCode a Exo cluster

Nastav OpenCode jako agenta v Xcode a ověř jeho napojení na Exo cluster a MCP.

```text
Pracuj od rootu repozitáře. Přečti `AGENTS.md` a sekci „Cvičení 1 — OpenCode a Exo cluster“ v `SPECIFICATION.md`.

Nakonfiguruj a ověř OpenCode jako agenta v Xcode podle specifikace. Sdílenou konfiguraci ukládej pouze do `opencode.jsonc` v rootu repozitáře; do repozitáře neukládej přihlašovací údaje, tokeny ani API klíče.

Neměň zdrojový kód aplikace. Uveď použitý model, stav připojení k Exo a stav MCP nástrojů nebo konkrétní omezení, které ověření zabránilo.
```

### Cvičení 2 — Bezpečnostní inventarizace

Přidej kartu Security pro MDM, FileVault 2, Application Firewall, Gatekeeper a SIP.

```text
Pracuj od rootu repozitáře. Přečti `AGENTS.md` a sekci „Cvičení 2 — Bezpečnostní inventarizace“ v `SPECIFICATION.md`.

Před změnami prozkoumej aktuální strukturu projektu; názvy budoucích souborů neodvozuj ze specifikace. Zachovej beze změny existující navigaci a globální vzhled aplikace; uprav pouze obsah karty Security podle jejího datového, zdrojového a UI kontraktu.

Před dokončením ověř každý zdroj podle specifikace, sestav schéma MacAdminInspector v Xcode a uveď změněné soubory, výsledek sestavení a omezení systému.
```

### Cvičení 3 — Detekce nainstalovaných AI nástrojů a verzí

Najdi všechny výskyty GUI aplikací a CLI executables podle katalogu a doplň jejich verze.

```text
Pracuj od rootu repozitáře. Přečti `AGENTS.md`, sekci „Cvičení 3 — Detekce nainstalovaných nástrojů a verzí“ v `SPECIFICATION.md` a celý katalog `MacAdminInspector/Resources/AITools.json`.

Před změnami prozkoumej aktuální strukturu projektu; názvy budoucích souborů neodvozuj ze specifikace. Zachovej beze změny existující navigaci a globální vzhled aplikace; uprav pouze obsah karty AI Tools. Implementuj statickou detekci a ověření verzí včetně UI kontraktu.

Ověř nalezené cesty a verze, sestav schéma MacAdminInspector v Xcode a uveď změněné soubory, výsledek sestavení a omezení systému.
```

### Cvičení 4 — Lokální revize AI konfigurací

Přidej panel AI Configs pro nalezení a bezpečný náhled lokálních konfigurací katalogových AI nástrojů.

```text
Pracuj od rootu repozitáře. Přečti `AGENTS.md`, sekci „Cvičení 4 — Lokální revize AI konfigurací“ v `SPECIFICATION.md` a celý katalog `MacAdminInspector/Resources/AITools.json`.

Před změnami prozkoumej aktuální strukturu projektu. Zachovej existující navigaci a globální vzhled; přidej pouze panel AI Configs a jeho obsah podle specifikace. Konfigurační cesty a pravidla hledání přidávej výhradně jako data do `AITools.json`, nikoli do Swiftu.

Funkce je lokální a pouze pro čtení: nic nespouští, nemění ani neodesílá. Ověř nalezené cesty, redakci náhledů a stavy nedostupnosti, sestav schéma MacAdminInspector v Xcode a uveď změněné soubory, výsledek sestavení a omezení systému.
```

## Dokončení cvičení

Po dokončení uveď změněné soubory, výsledek sestavení, ručně ověřenou cestu a systémová omezení. Podrobné akceptační podmínky jsou ve specifikaci.

## Soukromí a bezpečnost

Inventarizační data zůstávají na Macu. Nové funkce nesmějí data nahrávat, měnit konfiguraci zařízení ani zpřístupňovat přihlašovací údaje. Externí zdroj je možný jen po výslovném schválení a musí být v UI pojmenován.

## Licence

MIT — viz [LICENSE](LICENSE).
