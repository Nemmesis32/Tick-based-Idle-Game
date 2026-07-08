# 🔬 Reactor Idle – GDScript Remake

**Alpha `v0.70`** – Multi-Map-Update ("Giga Refactoring")

Ein tick-basiertes Idle-Strategie-Spiel inspiriert von [Reactor Idle](https://reactoridle.com/), gebaut mit der **Godot Engine 4.7** und **GDScript**.

## 🎮 Spielkonzept

Baue und verwalte einen Reaktorkomplex auf einem 24×13 Grid – und mittlerweile auf **mehreren gleichzeitig laufenden Inseln**. Platziere Reaktoren, leite Wärme über Heat Pipes zu Generatoren, versorge sie mit Wasser für zusätzlichen Durchsatz, verkaufe Energie über Offices – und vermeide Überhitzung. Erforsche neue Gebäude über den Forschungsbaum und schalte mächtigere Reaktoren und Infrastruktur frei.

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
- Drei Stufen: Research Center (1 RP/Tick), Advanced (8 RP/Tick), Super (40 RP/Tick)
- Research Points fließen in einen globalen Pool
- Der Forschungsbaum schaltet neue Gebäude frei – das ist die **einzige** Funktion der Forschung
- Zwei Ausnahmen: Manager (Auto-Rebuild) und Chromatic Boost (Ticks/Sekunde) sind keine Gebäude

#### Forschungsbaum-Struktur
```
Research Center (100 Credits – Einstieg)
├── Home Office
├── Wind Turbine Manager
├── Chromatic Boost 1/5 → 2/5 → 3/5 → 4/5 → 5/5
└── Solar Cell
    ├── Generator 1 (kostenlos)
    ├── Isolation
    ├── Solar Cell Manager
    └── Coal Burner
        ├── Heat Exchanger
        ├── Small Office
        ├── Coal Burner Manager
        └── Gas Burner
            ├── Heat Sink → Boiler House
            ├── Advanced Research Center
            ├── Gas Burner Manager
            └── Nuclear Cell
                ├── Water Pump
                ├── Water Pipe
                ├── Generator 2
                ├── Medium Office
                ├── Nuclear Cell Manager
                └── Thermonuclear Cell
                    ├── Thermonuclear Cell Manager
                    └── Fusion Cell
                        ├── Generator 3
                        ├── Groundwater Pump
                        ├── Large Office
                        ├── Bank
                        ├── Fusion Cell Manager
                        └── Thorium Cell
                            ├── Generator 4
                            ├── Heat Inlet
                            ├── Heat Outlet
                            ├── Huge Office
                            ├── Thorium Cell Manager
                            └── Protactium Cell
                                ├── Generator 5
                                ├── Circulator
                                ├── Super Research Center
                                ├── Protactium Cell Manager
                                └── Curium Cell
                                    ├── Curium Cell Manager
                                    └── Balduranium Cell
                                        └── Balduranium Cell Manager
```

#### Forschungs-Logik
- Forschungspunkte sind **Verbrauchsmaterial** – einmal ausgegeben weg
- Nodes erscheinen im Grid sobald ihre Voraussetzung erforscht wurde (Zustand: gesperrt → sichtbar → kaufbar)
- `research_center_bought` ist die Sonder-Node: kostet 100 Credits statt RP, schaltet den ganzen Baum auf
- Wind Turbine (Gebäude) ist ohne Forschung verfügbar – das einzige Startgebäude

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

### Multi-Map-System (neu in v0.70)
Das Spiel unterstützt mehrere Inseln ("Maps"), die **gleichzeitig und unabhängig voneinander** ticken:
- Ein globaler Tick durchläuft alle freigeschalteten Maps nacheinander (`MapManager.tick_all()`) – auch wenn du gerade eine andere Insel anschaust, läuft die im Hintergrund weiter
- **Global geteilt**: Credits, Research Points, Forschungsstand, Tick-Takt, Pause/Fast-Forward
- **Pro Map getrennt**: Grid, Terrain, Gebäude, Upgrades, gespeicherte Energie
- **Map-Übersicht** (erreichbar über den "Power Plants"-Tab) zeigt alle Maps als Kacheln mit Live-Energie- und Forschungsproduktion pro Tick
- **Freischaltung**: neue Maps kosten Credits (aktuell 100.000.000 für die zweite Insel), Lock-Status bleibt über Speichern/Laden erhalten
- Gesperrte Maps ticken nicht mit – sie verbrauchen keine Rechenzeit und produzieren nichts, bis sie freigeschaltet sind
- Navigation: "Power Plants" führt immer zur Übersicht; "Zurück" aus Research/Upgrades kehrt zur vorherigen Ansicht zurück (Übersicht oder die zuletzt geöffnete Map)

### Terrain-System
Insel-Layouts werden als lesbare ASCII-Grids definiert (`MapTerrainDatabase.gd`), eine Zeile Text pro Grid-Zeile:

| Zeichen | Tile-Typ | Bedeutung |
|---|---|---|
| `W` | Water | nicht bebaubar |
| `G` | Grass | normal bebaubar |
| `S` | Shore | bebaubar wie Grass, **einzige** Fläche für Water Pump |
| `M` | Mountain | nie bebaubar (aktuell Grass-Sprite als Platzhalter, bis ein eigenes Mountain-Sprite existiert) |

Jede Map bekommt beim Anlegen eine `terrain_id`, über die ihr Layout aus der Datenbank geladen wird – neue Insel-Formen anzulegen heißt einfach, ein neues ASCII-Layout zu ergänzen.

### BigNumber-System
Eigene Mantisse/Exponent-Klasse (`BigNumber.gd`) für alle spielrelevanten Werte. Unterstützt alle Grundrechenarten sowie kompakte Anzeige mit internationalen Suffixen (K, M, B, T, Qa, Qi, Sx, …) mit intelligenten Nachkommastellen. Unterstützt korrekt Werte unter 1.0 (z.B. 0.15 Energy/Tick der Wind Turbine).

### Gebäude-Lebensdauer
- **Verbrauchsmaterial** (Reaktoren, Windturbinen): verfallen nach X Ticks, Balken läuft von voll nach leer
- **Infrastruktur** (alles andere): permanent (`lifespan = -1`)
- Lebensdauer durch Upgrades verlängerbar

### Savegame-System
- Automatisches Speichern alle **60 Sekunden** + beim Schließen des Spiels
- Speicherort: `user://savegame.json` (Windows: `AppData/Roaming/Godot/app_userdata/PROJEKTNAME/`)
- Gespeicherte Daten: Credits, Research Points, Forschungsstand, **pro Map**: Grid-Zustand (Gebäudetyp, Alter, Wärme, Wasser), Upgrades, Lock-Status
- Versioniert (`version: 2`, seit v0.70 Multi-Map-Format) – ältere Alpha-Saves sind **nicht** kompatibel
- Erweiterbar auf mehrere Slots (5 Savegame-Slots geplant)

### Visuelles Feedback
- Füllstand-Balken auf Grid-Zellen (Wasser blau, Hitze rot)
- Lebensdauer-Balken (gelb) läuft von voll nach leer für Verbrauchsmaterial
- Dynamisch berechnete Zellgröße – Grid skaliert mit Fenstergröße

## 🏗️ Vollständige Gebäudeliste

### Reaktoren
| Gebäude | Kosten | Heat/Tick | Lifespan | Freischaltung |
|---|---|---|---|---|
| Solar Cell | 100 | 3 | 100 | solar_cell |
| Coal Burner | 1K | 380 | 400 | coal_burner |
| Gas Burner | 40M | 75K | 800 | gas_burner |
| Nuclear Cell | 500M | 1.2M | 800 | nuclear_cell |
| Thermonuclear Cell | 20B | 50M | 800 | thermonuclear_cell |
| Fusion Cell | 800B | 2.5B | 800 | fusion_cell |
| Thorium Cell | Platzhalter | – | – | thorium_cell |
| Protactium Cell | Platzhalter | – | – | protactium_cell |
| Curium Cell | Platzhalter | – | – | curium_cell |
| Balduranium Cell | Platzhalter | – | – | balduranium_cell |

### Generatoren
| Gebäude | Kosten | Processing | Wasser-Boost | Freischaltung |
|---|---|---|---|---|
| Wind Turbine | 1 | direkt 0.15/Tick | – | – (Startgebäude) |
| Basic Generator | 500 | 3 | – | generator_1 |
| Generator 2 | 2.5M | 9 | +100/Wasser | generator_2 |
| Generator 3 | 10T | 32 | +200/Wasser | generator_3 |
| Generator 4 | 50Qa | 96 | +400/Wasser | generator_4 |
| Generator 5 | 12.5Qa | 288 | +800/Wasser | generator_5 |

### Hitze-Management
| Gebäude | Funktion | Freischaltung |
|---|---|---|
| Heat Pipe | puffert & verteilt Wärme (30% Transfer/Tick) | heat_exchanger |
| Heat Sink | vernichtet 5% Wärme/Tick | heat_sink |
| Heat Inlet | Untergrund-Transfer (geplant) | heat_inlet |
| Heat Outlet | Untergrund-Transfer (geplant) | heat_outlet |
| Boiler House | verkauft Wärme direkt | boiler_house |

### Wasser-Management
| Gebäude | Produktion | Max Storage | Freischaltung |
|---|---|---|---|
| Water Pump | 25K/Tick | 150K | water_pump (nur auf Shore) |
| Ground Water Pump | 67.5K/Tick | 250K | groundwater_pump |
| Water Pipe | – | 150K (50%/Tick) | water_pipe |

### Auto-Seller & Booster
| Gebäude | Funktion | Sell/Tick | Freischaltung |
|---|---|---|---|
| Home Office | verkauft Energie | 5 | home_office |
| Small Office | verkauft Energie | 100 | small_office |
| Medium Office | verkauft Energie | 2.5K | medium_office |
| Large Office | verkauft Energie | 60K | large_office |
| Huge Office | verkauft Energie | 900K | huge_office |
| Isolation | +5% Heat-Boost Nachbar-Reaktoren | – | isolation |
| Circulator | +90% max_water Nachbar-Generatoren | – | circulator |
| Bank | +2.5x sell_amount Nachbar-Offices | – | bank |
| Battery | +100 max_storage pro Einheit | – | batteries |

### Forschung
| Gebäude | Research/Tick | Freischaltung |
|---|---|---|
| Research Center | 1 | research_center_bought |
| Advanced Research Center | 8 | advanced_research_center |
| Super Research Center | 40 | super_research_center |

## 🖥️ UI-Struktur

```
NavTabs (Power Plants | Research | Upgrades | Settings)
HeaderRow
├── StatsBox     – Credits, Energy/Tick, Stored + Balken, Sell Energy
├── OverlayBox   – Tooltips / Warnungen / Events
└── ControlsBox  – Auto-Rebuild, Bonus Ticks, Pause/Fast

MapOverviewPanel (Vollbild-Overlay, "Power Plants" führt immer hierher)
└── Kachel pro Map: Name, Energie/Tick, Forschung/Tick, "Öffnen"-Button
    (gesperrte Maps: 🔒-Hinweis, Kosten, "Freischalten"-Button)

MainArea (sichtbar nach Klick auf eine Map-Kachel)
├── ComponentsPanel
│   ├── CategoryTabs (Reaktoren | Generatoren | Hitze | Wasser | Verkauf | Forschung)
│   ├── BuildingList (dynamisch befüllt, gecacht, gefiltert nach Forschungsstand)
│   └── TooltipBox
└── GridPanel – 24×13 Reaktor-Grid der aktuell aktiven Map

UpgradePanel (eigene Szene, Overlay über MainArea)
├── BackButton – zurück zur vorherigen Ansicht (Übersicht oder aktive Map)
├── CreditsLabel – aktueller Kontostand
└── ScrollContainer
    └── GridContainer (2 Spalten)
        └── [Upgrade-Einträge: Label + SELL? + BUY]

ResearchPanel (eigene Szene, Overlay über MainArea)
├── BackButton – zurück zur vorherigen Ansicht (Übersicht oder aktive Map)
├── RPLabel – aktuelle Forschungspunkte
└── ScrollContainer
    └── GridContainer (2 Spalten)
        └── [Research-Einträge: Name + Kosten + Erforschen/Gesperrt/Erforscht]
```

## 📁 Projektstruktur

```
scripts/
├── control.gd              # View/Controller: zeigt aktive Map + Map-Übersicht, Input-Handling
├── GameState.gd            # Autoload: global geteilter Zustand (Credits, Research, Tick-Takt)
├── MapManager.gd           # Autoload: hält alle MapState-Instanzen, tickt alle unlockten Maps
├── MapState.gd             # Pro-Map-Zustand + alle process_*-Funktionen (RefCounted, kein Autoload)
├── MapTerrainDatabase.gd   # ASCII-Insel-Layouts pro terrain_id
├── Building.gd             # Instanz eines platzierten Gebäudes
├── BuildingDefinition.gd   # Template + Enum + alle Felder (inkl. required_research, requires_shore)
├── Building_database.gd    # Fabrik-Funktionen für alle Gebäudetypen
├── BigNumber.gd            # Mantisse/Exponent-Zahlensystem
├── UpgradeDefinition.gd    # Template + Enums für Upgrades
├── UpgradeDatabase.gd      # Alle Upgrade-Definitionen
├── ResearchDefinition.gd   # Template für Forschungs-Nodes
├── ResearchDatabase.gd     # Alle 50 Forschungs-Nodes mit Abhängigkeiten
└── SaveManager.gd          # Autoload: Speichern/Laden via JSON, Multi-Map-Format

scenes/
├── control.tscn            # Hauptszene
├── upgrade_panel.tscn      # Upgrade-Overlay (eigene Szene)
└── research_panel.tscn     # Forschungsbaum-Overlay (eigene Szene)
```

### Architektur-Prinzipien
- `BuildingDefinition` – unveränderliches Template (was ein Gebäude *ist*)
- `Building` – veränderliche Instanz (aktueller Zustand: Hitze, Wasser, Alter)
- `BuildingDatabase` – statische Fabrik-Funktionen, große Zahlen via `from_notation(m, e)`
- `UpgradeDefinition` – Template für Upgrades (Ziel, Stat, Multiplikator, Modus)
- `UpgradeDatabase` – alle Upgrade-Definitionen als statische Fabrik-Funktionen
- `ResearchDefinition` – Template für Forschungs-Nodes (ID, Kosten, Voraussetzungen)
- `ResearchDatabase` – alle 50 Forschungs-Nodes als statische Fabrik-Funktionen
- `SaveManager` – Autoload-Singleton, speichert/lädt JSON, versioniert
- Gebäudetypen via `enum type`, Verhalten via `tags` – keine Magic Strings
- Upgrades via `enum stat_type` und `enum target_type` – klar getrennte Ziele
- Forschung via `required_research: String` auf `BuildingDefinition` – ein Feld, klare Abhängigkeit
- `GameState` – Autoload, global geteilter Zustand (Credits, Research, Tick-Takt, Bonus-Ticks)
- `MapManager` – Autoload, hält alle `MapState`-Instanzen, tickt alle unlockten Maps pro Tick durch
- `MapState` – `RefCounted`-Klasse (kein Autoload), pro-Map-Zustand + gesamte Tick-Verarbeitung; wird über `MapManager.add_map()` instanziiert
- `MapTerrainDatabase` – statische Fabrik-Funktionen für ASCII-Insel-Layouts, referenziert über `terrain_id`
- `control.gd` ist seit v0.70 reine View/Controller-Schicht – zeigt die aktive Map bzw. Map-Übersicht an und delegiert Logik an `GameState`/`MapManager`/`MapState`

## 🚧 Roadmap

### Must-Have (Alpha)
- [x] Tick-System
- [x] Grid mit Nachbarschaftssystem (dynamisch skalierend, 24×13, jetzt pro Map)
- [x] Wärmeverteilung & Überhitzung
- [x] Generator: Wärme → Strom (mit Wasser-Boost)
- [x] Wassersystem (Pumps, Pipes, Verbrauch)
- [x] Auto-Seller System (Offices verkaufen Energie → Credits)
- [x] Booster-System (Isolation, Circulator, Bank)
- [x] Heat Sink (Wärme vernichten)
- [x] Battery (max_storage erhöhen)
- [x] Tag-System
- [x] BigNumber-System (K/M/B/T/Qa/Qi/Sx…)
- [x] UI-Grundgerüst (Header, Components-Panel, Grid)
- [x] Visuelles Feedback (Füllstand- & Lebensdauer-Balken)
- [x] Vollständige Gebäudeliste
- [x] Upgrade-System (Multiplikativ + Additiv, Global + Type + Tag)
- [x] Upgrade-Panel (eigene Szene, Overlay, zweispaltig)
- [x] Sell-Button für Reaktor Heat-Production Upgrades
- [x] Forschungsbaum (50 Nodes, Abhängigkeiten, Credits/RP-Logik)
- [x] Gebäude durch Forschung freischalten (Gebäudeliste gefiltert)
- [x] Savegames (JSON, Autosave 60s + beim Schließen, versioniert)
- [ ] Upgrades filtern nach Forschungsstand
- [x] Ghost-Gebäude wenn Reaktoren auslaufen
- [ ] Vollständige Visualisierung (Sprites statt Text bei Gebäuden)
- [ ] Sound/Musik
- [ ] Einstellungen
- [x] Offline Progress (Bonus-Ticks, 12h-Cap)

### Multi-Map-System (v0.70)
- [x] Mehrere Maps laufen gleichzeitig & unabhängig (globaler Tick durchläuft alle unlockten Maps)
- [x] Map-Übersicht mit Live-Stats (Energie/Forschung pro Tick)
- [x] Map-Unlock-Mechanik gegen Credits, Lock-Status speicherbar
- [x] Terrain-Typen Shore (Water-Pump-exklusiv) & Mountain (unbebaubar)
- [ ] Unterschiedliche Grid-Größen pro Map tatsächlich genutzt (technisch bereits unterstützt)
- [ ] Research-Voraussetzung für Map-Unlock (aktuell nur Credits-Kosten)
- [ ] Eigenes Mountain-Sprite (aktuell Grass als Platzhalter)

### Nice-to-Have (Beta / Post-1.0)
- [ ] Mehrere Savegame-Slots (5 geplant)
- [x] Mehrere Maps (unabhängig tickend) – unterschiedliche Grid-**Größen** pro Map noch offen
- [x] Gesperrte Felder auf dem Grid (Mountain-Tile)
- [x] Bodenabhängigkeiten für Gebäude (Water Pump nur auf Shore)
- [ ] Upgrade-Kategorien / Gruppierung
- [ ] Upgrades durch Forschung freischalten
- [x] Bonusticks
- [ ] Prestige-/Reset-System
- [ ] Weitere Spielmodi
- [ ] 2-Feld Reaktoren (Thorium, Protactium)
- [ ] Radial-Reaktoren (Curium, Balduranium)
- [ ] Heat Inlet/Outlet System (Untergrund-Wärmetransfer)
- [ ] Ingame-Käufe

## 🎯 Inspiration

Basiert auf dem Spielkonzept von [Reactor Idle by Grest Games](https://reactoridle.com/), mit eigenständigen Mechaniken – insbesondere das Wasser-System als additiver Kapazitäts-Booster, das Booster-System mit Nachbarschafts-Stacking, das BigNumber-System für astronomische Zahlenwerte, sowie ein zweistufiges Upgrade-System mit multiplikativen und additiven Modi.
