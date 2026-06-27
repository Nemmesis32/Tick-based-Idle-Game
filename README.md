# 🔬 Reactor Idle – GDScript Remake

Ein tick-basiertes Idle-Strategie-Spiel inspiriert von [Reactor Idle](https://reactoridle.com/), gebaut mit der **Godot Engine 4.7** und **GDScript**.

## 🎮 Spielkonzept

Baue und verwalte einen Reaktorkomplex auf einem 22×15 Grid. Platziere Reaktoren, leite Wärme über Heat Pipes zu Generatoren, versorge sie mit Wasser für zusätzlichen Durchsatz, verkaufe Energie über Offices – und vermeide Überhitzung.

```
Reaktor → Heat Pipe → Generator → Strom → Office → Credits
              ↑            ↑
         Isolation    Circulator
         (+Heat)      (+Water)
                          ↑
                     Water Pipe
                          ↑
                     Water Pump
```

## ⚙️ Aktuelle Mechaniken

### Tick-System
Jeder Tick durchläuft eine feste Reihenfolge:
1. **Produktion** – `process_heat()`, `process_water()`
2. **Transport** – `process_heat_pipes()`, `process_water_pipes()`
3. **Sonderverarbeitung** – `process_heat_sink()`, `process_research()`
4. **Umwandlung** – `process_generators()`
5. **Konsequenzen** – `process_overheat()`
6. **Energie & Credits** – Verkauf, Speicherung

### Wärme-System
- Reaktoren produzieren Wärme pro Tick und verteilen sie gleichmäßig auf valide Nachbarn
- Reaktoren akzeptieren **keine** fremde Wärme – reine Produzenten
- Ohne validen Abnehmer überhitzt ein Reaktor nach 1 Tick
- Heat Pipes puffern Wärme und gleichen sie zwischen Nachbarn aus (fließt immer von voll zu leer)
- Heat Sink vernichtet pro Tick einen Prozentsatz seiner gespeicherten Wärme (`energy_loss`)

### Energie-System
- Generatoren wandeln empfangene Wärme in Strom um (`energy_processing` als Grunddurchsatz)
- **Wasser-Boost**: Bei Überschuss-Wärme wird Wasser verbraucht um die Kapazität additiv zu erhöhen
- Reicht das Wasser nicht aus, staut sich Wärme im Generator bis zur Überhitzung
- Windturbinen produzieren direkt Strom ohne Wärmesystem

### Auto-Seller System
- Offices (`energy_seller` Tag) verkaufen pro Tick automatisch Energie → Credits
- Verkauf passiert **vor** der Speicherung – Überschuss geht in den Tank
- Hat ein Office mehr Sell-Kapazität als Produktion vorhanden ist, wird auch aus dem Speicher verkauft
- `Battery` Gebäude erhöhen `max_storage` dynamisch

### Wasser-System
- Water Pumps produzieren und speichern Wasser
- Water Pipes leiten Wasser weiter (prozentual von `max_water` pro Tick, Basis 50%)
- Wasser-immune Gebäude können kein Wasser aufnehmen

### Forschungs-System
- Research Center produzieren `research_points` pro Tick passiv
- Research Points werden global gesammelt (Grundlage für spätere Gebäude-Freischaltung)

### Booster-System
Drei Booster-Typen beeinflussen direkte Nachbarn pro Tick:
- **Isolation** – boosted Nachbar-Reaktoren: `heat_production * (1 + summe_heat_boost)`
- **Circulator** – boosted Nachbar-Generatoren: erhöht effektives `max_water`
- **Bank** – boosted Nachbar-Offices: `sell_amount * (1 + summe_sell_boost)`

Booster stacken additiv (4 Isolatoren = +20% heat_boost).

### Upgrade-System
Zwei Upgrade-Modi:
- **Multiplikativ** – für Produktion, Max-Werte, Sell-Amount etc.: `wert * (1.0 + multiplier * stufen)`
- **Additiv** – für Transfer-Rates und Booster-Effektivität: `wert + (multiplier * stufen)`

Drei Target-Typen:
- **GLOBAL** – gilt für globale Spielwerte (z.B. Max Storage)
- **BUILDING_TYPE** – gilt für alle Gebäude eines bestimmten Typs
- **TAG** – gilt für alle Gebäude mit einem bestimmten Tag (z.B. alle `energy_seller`)

Besonderheiten:
- Kosten steigen exponentiell: `base_cost * (cost_multiplier ^ current_level)`
- Reaktor Heat-Production Upgrades können per SELL-Button rückgängig gemacht werden (50% Rückerstattung pro Stufe)
- Lifespan-Upgrades verlängern die Lebensdauer von Verbrauchsmaterial

### Tag-System
Gebäudeeigenschaften über Tags statt Typ-Abfragen:

| Tag | Bedeutung |
|---|---|
| `heat_producer` | produziert Wärme, gibt sie an Nachbarn ab |
| `heat_consumer` | kann Wärme aufnehmen und speichern |
| `heat_transfer` | leitet Wärme weiter (Heat Pipe) |
| `heat_sink` | vernichtet Wärme prozentual pro Tick |
| `heat_immune` | nimmt keine Wärme von Reaktoren an |
| `water_producer` | produziert Wasser |
| `water_transfer` | leitet Wasser weiter (Water Pipe) |
| `water_consumer` | verbraucht Wasser als Generator-Boost |
| `water_immune` | nimmt kein Wasser an |
| `energy_producer` | produziert direkt Strom |
| `energy_seller` | verkauft Energie automatisch gegen Credits |
| `research_producer` | produziert Research Points pro Tick |
| `booster` | beeinflusst Nachbargebäude positiv |

### BigNumber-System
Eigene Mantisse/Exponent-Klasse (`BigNumber.gd`) für alle spielrelevanten Werte. Unterstützt alle Grundrechenarten sowie kompakte Anzeige mit internationalen Suffixen (K, M, B, T, Qa, Qi, Sx, …) mit intelligenten Nachkommastellen. Unterstützt korrekt Werte unter 1.0 (z.B. 0.15 Energy/Tick der Wind Turbine).

### Gebäude-Lebensdauer
- **Verbrauchsmaterial** (Reaktoren, Windturbinen): verfallen nach X Ticks, Balken läuft von voll nach leer
- **Infrastruktur** (alles andere): permanent (`lifespan = -1`)
- Lebensdauer durch Upgrades verlängerbar

### Visuelles Feedback
- Füllstand-Balken auf Grid-Zellen (Wasser blau, Hitze rot)
- Lebensdauer-Balken (gelb) läuft von voll nach leer für Verbrauchsmaterial
- Dynamisch berechnete Zellgröße – Grid skaliert mit Fenstergröße

## 🏗️ Vollständige Gebäudeliste

### Reaktoren
| Gebäude | Kosten | Heat/Tick | Lifespan |
|---|---|---|---|
| Solar Cell | 100 | 3 | 100 |
| Coal Burner | 1K | 380 | 400 |
| Gas Burner | 40M | 75K | 800 |
| Nuclear Cell | 500M | 1.2M | 800 |
| Thermonuclear Cell | 20B | 50M | 800 |
| Fusion Cell | 800B | 2.5B | 800 |
| Thorium Cell | Platzhalter | – | – |
| Protactium Cell | Platzhalter | – | – |
| Curium Cell | Platzhalter | – | – |
| Balduranium Cell | Platzhalter | – | – |

### Generatoren
| Gebäude | Kosten | Processing | Wasser-Boost |
|---|---|---|---|
| Wind Turbine | 1 | direkt 0.15/Tick | – |
| Basic Generator | 500 | 3 | – |
| Generator 2 | 2.5M | 9 | +100/Wasser |
| Generator 3 | 10T | 32 | +200/Wasser |
| Generator 4 | 50Qa | 96 | +400/Wasser |
| Generator 5 | 12.5Qa | 288 | +800/Wasser |

### Hitze-Management
| Gebäude | Funktion |
|---|---|
| Heat Pipe | puffert & verteilt Wärme (Basis 30% Transfer/Tick) |
| Heat Sink | vernichtet 5% Wärme/Tick |
| Heat Inlet | Platzhalter (zukünftig: Untergrund-Transfer) |
| Heat Outlet | Platzhalter (zukünftig: Untergrund-Transfer) |

### Wasser-Management
| Gebäude | Produktion | Max Storage |
|---|---|---|
| Water Pump | 25K/Tick | 150K |
| Ground Water Pump | 67.5K/Tick | 250K |
| Water Pipe | – | 150K (Transfer Basis 50%/Tick) |

### Auto-Seller & Booster
| Gebäude | Funktion | Sell/Tick |
|---|---|---|
| Home Office | verkauft Energie | 5 |
| Small Office | verkauft Energie | 100 |
| Medium Office | verkauft Energie | 2.5K |
| Large Office | verkauft Energie | 60K |
| Huge Office | verkauft Energie | 900K |
| Boiler House | verkauft Wärme direkt | 2.5K |
| Isolation | +5% Heat-Boost für Nachbar-Reaktoren | – |
| Circulator | +90% max_water für Nachbar-Generatoren | – |
| Bank | +2.5x sell_amount für Nachbar-Offices | – |
| Battery | +100 max_storage pro Einheit | – |

### Forschung
| Gebäude | Research/Tick |
|---|---|
| Research Center | 1 |
| Advanced Research Center | 8 |
| Super Research Center | 40 |

## 🖥️ UI-Struktur

```
NavTabs (Power Plants | Research | Upgrades | Settings)
HeaderRow
├── StatsBox     – Credits, Energy/Tick, Stored + Balken, Sell Energy
├── OverlayBox   – Tooltips / Warnungen / Events
└── ControlsBox  – Auto-Rebuild, Bonus Ticks, Pause/Fast
MainArea
├── ComponentsPanel
│   ├── CategoryTabs (Reaktoren | Generatoren | Hitze | Wasser | Verkauf | Forschung)
│   ├── BuildingList (dynamisch befüllt, gecacht)
│   └── TooltipBox
└── GridPanel – 22×15 Reaktor-Grid

UpgradePanel (eigene Szene, Overlay über MainArea)
├── BackButton – zurück zu Power Plants
├── CreditsLabel – aktueller Kontostand
└── ScrollContainer
    └── GridContainer (2 Spalten)
        └── [Upgrade-Einträge: Label + SELL? + BUY]
```

## 📁 Projektstruktur

```
scripts/
├── control.gd            # Hauptsteuerung: Grid, Tick-Loop, UI, alle process_*
├── Building.gd           # Instanz eines platzierten Gebäudes
├── BuildingDefinition.gd # Template + Enum + alle Felder
├── Building_database.gd  # Fabrik-Funktionen für alle Gebäudetypen
├── BigNumber.gd          # Mantisse/Exponent-Zahlensystem
├── UpgradeDefinition.gd  # Template + Enums für Upgrades
└── UpgradeDatabase.gd    # Alle Upgrade-Definitionen

scenes/
├── control.tscn          # Hauptszene
└── upgrade_panel.tscn    # Upgrade-Overlay (eigene Szene)
```

### Architektur-Prinzipien
- `BuildingDefinition` – unveränderliches Template (was ein Gebäude *ist*)
- `Building` – veränderliche Instanz (aktueller Zustand: Hitze, Wasser, Alter)
- `BuildingDatabase` – statische Fabrik-Funktionen, große Zahlen via `from_notation(m, e)`
- `UpgradeDefinition` – Template für Upgrades (Ziel, Stat, Multiplikator, Modus)
- `UpgradeDatabase` – alle Upgrade-Definitionen als statische Fabrik-Funktionen
- Gebäudetypen via `enum type`, Verhalten via `tags` – keine Magic Strings
- Upgrades via `enum stat_type` und `enum target_type` – klar getrennte Ziele

## 🚧 Roadmap

### Must-Have (1.0)
- [x] Tick-System
- [x] Grid mit Nachbarschaftssystem (dynamisch skalierend, 22×15)
- [x] Wärmeverteilung & Überhitzung
- [x] Generator: Wärme → Strom (mit Wasser-Boost)
- [x] Wassersystem (Pumps, Pipes, Verbrauch)
- [x] Auto-Seller System (Offices verkaufen Energie → Credits)
- [x] Booster-System (Isolation, Circulator, Bank)
- [x] Heat Sink (Wärme vernichten)
- [x] Forschungspunkte sammeln
- [x] Battery (max_storage erhöhen)
- [x] Tag-System
- [x] BigNumber-System (K/M/B/T/Qa/Qi/Sx…)
- [x] UI-Grundgerüst (Header, Components-Panel, Grid)
- [x] Visuelles Feedback (Füllstand- & Lebensdauer-Balken, Balken läuft runter)
- [x] Vollständige Gebäudeliste
- [x] Upgrade-System (Multiplikativ + Additiv, Global + Type + Tag)
- [x] Upgrade-Panel (eigene Szene, Overlay, zweispaltig)
- [x] Sell-Button für Reaktor Heat-Production Upgrades
- [ ] Forschung (Logik + UI – Gebäude freischalten)
- [ ] Savegames
- [ ] Vollständige Visualisierung (Sprites statt Text)
- [ ] Sound/Musik
- [ ] Einstellungen
- [ ] Offline Progress

### Nice-to-Have (Post-1.0)
- [ ] Upgrade-Kategorien / Gruppierung
- [ ] Upgrades durch Forschung freischalten
- [ ] Bonusticks
- [ ] Prestige-/Reset-System
- [ ] Weitere Spielmodi
- [ ] Ingame-Käufe
- [ ] 2-Feld Reaktoren (Thorium, Protactium)
- [ ] Radial-Reaktoren (Curium, Balduranium)
- [ ] Heat Inlet/Outlet System

## 🎯 Inspiration

Basiert auf dem Spielkonzept von [Reactor Idle by Grest Games](https://reactoridle.com/), mit eigenständigen Mechaniken – insbesondere das Wasser-System als additiver Kapazitäts-Booster, das Booster-System mit Nachbarschafts-Stacking, das BigNumber-System für astronomische Zahlenwerte, sowie ein zweistufiges Upgrade-System mit multiplikativen und additiven Modi.
