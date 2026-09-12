# MacAdminInspector — pravidla pro agenty

MacAdminInspector je malá SwiftUI lab aplikace pro macOS 14+. Zachovej její omezený rozsah, local-first chování a jednoduchou architekturu.

## Závazná hranice nástrojů

Xcode MCP je jediný autoritativní nástroj pro práci s tímto projektem.

- Přes Xcode MCP prohlížej soubory, upravuj Swift a zdroje, přidávej či odebírej soubory, měň nastavení targetu, spravuj schémata, sestavuj, testuj, spouštěj a debuguj.
- Pro tento projekt je zakázáno používat nástroje `edit`, `write`, `bash` pro jakékoli soubory v repozitáři kromě již existujících `.md` souborů. Týká se to i `.swift`, `.json`, `.plist`, `.entitlements`, `.xcodeproj`, `.xcworkspace`, schémat a build nastavení.
- Pro tento projekt nevolej `xcodebuild`, `swift`, `swiftc`, `grep`, `find`, `cat`, `ls` ani jiné příkazové nástroje pro sestavení, debug nebo prohlížení projektu.
- `project.pbxproj` nikdy neměň ručně; členství souborů a build fáze spravuje Xcode MCP.
- Není-li Xcode MCP dostupné nebo nezvládne potřebnou operaci, zastav se a oznam blokaci. Nepoužívej přímou či příkazovou náhradu.

## Povinný postup

1. Před změnou přes Xcode MCP prohlédni související soubory a konfiguraci targetu.
2. Proveď nejmenší změnu, která splní požadavek. Neupravuj nesouvisející uživatelskou práci.
3. Po každé významné změně sestav schéma `MacAdminInspector` přes Xcode MCP; pokud existují relevantní testy, spusť je.
4. Před dokončením vyřeš chyby a varování vzniklé změnou.
5. U změny UI či běhového chování aplikaci podle možností spusť nebo debuguj a ověř dotčenou cestu.
6. Uveď, co se změnilo, jak bylo ověřeno a které omezení případně zůstává.

## Produktová pravidla

- Minimum deployment target zůstává macOS 14.0; používej jen odpovídající SwiftUI/AppKit API.
- Inventarizace zařízení je ve výchozím stavu lokální a pouze pro čtení. Bez výslovného požadavku a schválení uživatele nenahrávej data, neměň konfiguraci, nevyžaduj vyšší oprávnění ani nespouštěj privilegované příkazy.
- Externě načtená data vždy označ jako externí zdroj a nikdy je nevydávej za lokálně ověřený stav.
- Upřednostni údaje explicitně vrácené macOS. Neodvozuj typ sítě, produkt, vlastnictví, bezpečnostní stav ani jinou klasifikaci z názvů, adres, cest nebo heuristik.
- Každý zdroj inventarizace má úzce zaměřenou Foundation službu. View vykreslují modely a vyvolávají akce; neobsahují filesystem, procesní ani parsovací logiku.
- Katalog AI nástrojů udržuj jako data: produktová metadata přidávej a upravuj v `Resources/AITools.json`, nikoli přímo ve Swiftu.
- Funkční a implementační požadavky jednotlivých cvičení jsou v `SPECIFICATION.md`; nezdvojuj je zde.

## Stabilita existujícího UI

- Neměň navigační strukturu, názvy existujících sekcí, hlavní titulky, ikony, velikost okna, toolbar ani globální vizuální styl, pokud to prompt výslovně nepožaduje.
- Nová nebo upravená funkce smí změnit pouze obsah své dotčené sekce a jen v rozsahu nutném pro cvičení.
- Před změnou UI si přečti související existující pohledy a převezmi z nich layout, spacing, `GroupBox`, `Grid`, typografii a stavové obrazovky.
- Neprováděj redesign ani nepřejmenovávej sekce. Nelze-li požadavek splnit bez změny sdíleného UI, zastav se a popiš konkrétní nutnou změnu.

## Hygiena změn

- Zachovej uživatelské soubory a necommitnuté změny. Nikdy nerestartuj, nezahazuj ani nepřepisuj nesouvisející práci.
- Bez výslovného schválení uživatele nepřidávej závislosti, capabilities, síťový přístup, privacy permissions, telemetrii ani chování na pozadí.
- Řetězce i datové modely udržuj přesné: pokud zdroj hodnotu neposkytne, zobraz `Unavailable`, nikoli odhad.
