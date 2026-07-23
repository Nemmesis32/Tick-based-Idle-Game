# 🔬 Reactor Idle – GDScript Remake

**Alpha `v0.70`** – Multi-Map-Update ("Giga Refactoring")

Ein tick-basiertes Idle-Strategie-Spiel inspiriert von [Reactor Idle](https://reactoridle.com/), gebaut mit der **Godot Engine 4.7** und **GDScript**.

## 🎮 Spielkonzept

Baue und verwalte einen Reaktorkomplex auf mehreren gleichzeitig laufenden Inseln ("Maps"). Platziere Reaktoren, leite Wärme über Heat Pipes zu Generatoren, versorge sie mit Wasser für zusätzlichen Durchsatz, verkaufe Energie über Offices – und vermeide Überhitzung. Erforsche neue Gebäude über den globalen Forschungsbaum und schalte mächtigere Reaktoren und Infrastruktur frei.

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
`MapManager.tick_all()` ruft `run_tick()` auf jeder **freigeschalteten** Map auf – auch auf Inseln, die gerade nicht sichtbar sind. Innerhalb einer Map läuft eine fest verdrahtete Reihenfolge:

1. `process_heat()` – Reaktoren verteilen Wärme gleichmäßig auf valide Nachbarn
2. `process_heat_pipes()` – lokaler, paarweiser Ausgleich zwischen Heat-Pipes/Nachbarn (Jacobi-Style: ein Snapshot pro Tick, danach werden alle Deltas gemeinsam angewendet)
3. `process_water_network()` – Flood-Fill aller zusammenhängenden Wasser-Pools, Produktion/Verteilung/Verbrauch
4. `process_heat_sink()` – Sinks bauen Hitze passiv ab (`energy_loss`-Anteil)
5. `process_boiler_house()` – Bulk-Extraktion von Hitze aus Nachbar-Sink/-Generator gegen Credits
6. `process_research()` → `GameState.add_research_points(...)`
7. `process_generators()` – Hitze (+ Wasser-Boost) wird zu `generated` Energie
8. `process_overheat()` – Gebäude über `max_heat` werden zerstört (läuft **nach** den Generatoren, d.h. ein Gebäude gibt seine Hitze noch ab, bevor es explodiert)
9. Storage/Verkauf: `total_production` wird zuerst gepoolt an alle Offices verkauft, Rest füllt den Storage, danach ggf. weiterer Verkauf aus dem Storage
10. `_process_building_lifespans()` – Alterung, Ghost-Zustand, Auto-Rebuild

### Wärme-System
- Reaktoren produzieren Wärme pro Tick und verteilen sie gleichmäßig auf valide Nachbarn (kein `heat_producer`, kein `heat_immune`, `max_heat > 0`); ohne validen Nachbarn bleibt die Wärme im Reaktor selbst
- Reaktoren akzeptieren **keine** fremde Wärme – reine Produzenten, auch beim Pipe-Ausgleich ausgeschlossen
- Heat Pipes gleichen sich paarweise mit Nachbarn aus, **nicht** über ein globales Netzwerk-Modell (das ist bewusst anders gelöst als beim Wasser-System). Die eigentliche Anti-Oszillations-Maßnahme ist eine Grad-Normierung: eine Kachel verliert pro Tick nie mehr als `rate * 0.5` ihrer eigenen Hitze, egal wie viele Nachbarn sie hat
- Heat Sink vernichtet pro Tick einen Prozentsatz seiner gespeicherten Wärme (`energy_loss`), unabhängig vom Grid
- Boiler House extrahiert Wärme aus Nachbar-Sink/-Generator in festen Batches (Bulk-Extraktion) gegen Credits, statt kontinuierlich zu fließen

### Energie-System
- Generatoren wandeln empfangene Wärme in Strom um (`energy_processing` als Grunddurchsatz), zusätzlich per Wasser-Boost (siehe unten)
- Reicht Kapazität und Wasser nicht aus, staut sich Wärme im Generator bis zur Überhitzung
- Gebäude mit `energy_production > 0` (z.B. Wind Turbine) produzieren direkt Strom, ganz ohne Wärme-Umweg

### Auto-Seller System
- Offices (`energy_seller` Tag) verkaufen pro Tick gepoolt Energie → Credits, nicht einzeln pro Office
- Verkauf aus frischer Produktion hat Vorrang: erst wird `min(total_production, sell_capacity)` verkauft, der Rest füllt den Storage; ist danach noch Kapazität übrig, wird zusätzlich aus dem Storage verkauft
- Der tatsächlich verkaufte Betrag wird pro Office fürs UI proportional zu seiner Kapazität zurückverteilt (vereinfachende Annahme, kein "wer hat wirklich verkauft")
- `Battery`-Gebäude erhöhen `max_storage` additiv, upgrade-modifiziert
- Boiler House ist eine **zweite, komplett unabhängige** Einnahmequelle (Wärme direkt gegen Credits), läuft nicht über dieses Storage/Verkauf-Pooling

### Wasser-System
Grundlegend anders gelöst als das Heat-System – hier gibt es ein **Netzwerk-Pool-Modell**:
- `process_water_network()` macht pro Tick einen Flood-Fill über alle zusammenhängenden `water_producer`/`water_transfer`-Zellen; jeder zusammenhängende Klumpen wird als **eine gemeinsame Einheit** behandelt (Bestand + Kapazität werden gepoolt)
- Pumpen produzieren in den Pool, Verbraucher am Netzwerkrand (z.B. Generatoren) bekommen das Wasser **fair verteilt** (proportional, iterativ – wer voll ist, fällt raus, Rest wird neu verteilt)
- Sonderfall Rückfluss: fällt die Produktion im Pool auf null (z.B. Pumpe zerstört), dürfen angrenzende, prozentual vollere Verbraucher als "Spender" einspringen und sich mit dem Netzwerk auf denselben Füllstand einpendeln
- Verbrauch durch Generatoren läuft in ganzzahligen Zyklen (`needed_water`/`available_cycles`), nie teilweise
- Wasser-immune Gebäude nehmen kein Wasser an
- Pump-Attribution fürs UI (`pump_water_stats`) deckt aktuell nur Pumpen *innerhalb* des Pools ab – Wasser aus dem Rückfluss-Sonderfall taucht dort noch nicht separat auf (offene Baustelle)

### Forschungs-System
- Research ist **global**, nicht pro Map – eine einzige, geteilte Liste (`GameState.research`) über alle Inseln hinweg
- ~50 Forschungs-Knoten, in Abhängigkeitsreihenfolge, thematisch nach Vorgänger-Zelle gruppiert (z.B. "Von Nuclear Cell")
- Research Points fließen in einen globalen Pool, sind Verbrauchsmaterial
- Der Forschungsbaum schaltet primär neue Gebäude frei (`required_research` auf `BuildingDefinition`), außerdem Auto-Rebuild-Manager pro Gebäudetyp (`manager_research_id`) sowie Sichtbarkeit von Upgrades (`required_research` auf `UpgradeDefinition`)
- Sonderfall: Kauf eines der fünf `chromatic_1..5`-Knoten erhöht `ticks_per_second` um 1 – der einzige Ort, an dem Research direkt die Tick-Geschwindigkeit beeinflusst
- `research_center_bought` kostet als einzige Node Credits statt Research Points und schaltet den Baum frei
- Einige Knoten sind aktuell im Code auskommentiert bzw. pausiert ("totes" Content), u.a. **Wind Turbine Manager** und **Generator 1** – im Spiel aktuell nicht erreichbar, auch wenn sie konzeptionell im Baum stehen
- Wind Turbine (Gebäude) ist ohne Forschung von Anfang an verfügbar – das einzige Startgebäude

#### Forschungsbaum-Struktur (Konzept, teils pausiert – s.o.)
```
Research Center (100 Credits – Einstieg)
├── Home Office
├── Wind Turbine Manager [pausiert/auskommentiert]
├── Chromatic Boost 1/5 → 2/5 → 3/5 → 4/5 → 5/5
└── Solar Cell
    ├── Generator 1 [pausiert/auskommentiert]
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

### Booster-System
Drei Booster-Typen beeinflussen direkte Nachbarn pro Tick:
- **Isolation** – boosted Nachbar-Reaktoren: `heat_production * (1 + summe_heat_boost)`
- **Circulator** – boosted Nachbar-Generatoren: erhöht effektives `max_water`
- **Bank** – boosted Nachbar-Offices: `sell_amount * (1 + summe_sell_boost)`

Booster stacken additiv (4 Isolatoren = +20% heat_boost).

### Upgrade-System
Upgrades sind **pro Map separat** (jede Map hat ihre eigene Kopie der Upgrade-Liste), im Gegensatz zu Research, das global ist.

Zwei Upgrade-Modi:
- **Multiplikativ** – für Produktion, Max-Werte, Sell-Amount etc.: `total *= pow(1.0 + multiplier, level)`, stackt exponentiell
- **Additiv** – für Transfer-Rates und andere 0.0–1.0-Anteile (z.B. `heat_transfer_rate`, `water_transfer_rate`): `total += multiplier * level`, stackt linear (ein multiplikativer Bonus wäre hier sinnlos, weil die Rate bei 1.0 gedeckelt ist)

Drei Target-Typen:
- **GLOBAL** – gilt immer, unabhängig vom Gebäudetyp
- **BUILDING_TYPE** – gilt nur für exakt einen Gebäudetyp
- **TAG** – gilt für alle Gebäude mit einem bestimmten Tag (z.B. alle `energy_seller`, ohne jeden Office-Tier einzeln aufzuzählen)

16 `stat_type`-Werte insgesamt, u.a. `HEAT_PRODUCTION`, `MAX_HEAT`, `MAX_WATER`, `WATER_PRODUCTION`, `ENERGY_PROCESSING`, `ENERGY_PRODUCTION`, `SELL_AMOUNT`, `HEAT_BOOST`, `WATER_BOOST`, `SELL_AMOUNT_BOOST`, `ADDITIONAL_STORAGE`, `HEAT_TRANSFER_RATE`, `WATER_TRANSFER_RATE`, `LIFESPAN`, `RESEARCH_PRODUCTION`, `HEAT_SELL_AMOUNT`.

Besonderheiten:
- Kosten steigen exponentiell: `base_cost * (cost_multiplier ^ current_level)`, Standard-Multiplikator 2.1
- **Jedes** Upgrade (nicht nur Heat-Production) kann per SELL-Button rückgängig gemacht werden – 50% Rückerstattung des Preises der letzten Stufe
- Kein gecachter "effektiver Stat" – jede tick-relevante Stelle berechnet Multiplikator/Additiv live bei jeder Tick-Berechnung neu (konsistent, aber CPU-Kosten pro Tick, weil jedes Gebäude gegen die komplette Upgrade-Liste geprüft wird)

### Tag-System
Statt harter Typ-Abfragen läuft die Spiellogik über Tags (Strings auf `BuildingDefinition`):

| Tag | Bedeutung |
|---|---|
| `heat_producer` | produziert Wärme, gibt sie an Nachbarn ab, nimmt selbst nie welche an |
| `heat_consumer` | kann Wärme aufnehmen und speichern |
| `heat_transfer` | leitet Wärme weiter (Heat Pipe) |
| `heat_sink` | vernichtet Wärme prozentual pro Tick |
| `heat_seller` | verkauft Wärme direkt gegen Credits (Boiler House), eigene Extraktionslogik statt passivem Ausgleich |
| `heat_immune` | nimmt keine Wärme von Reaktoren an, komplett ausgeschlossen vom Heat-Netzwerk |
| `water_producer` | produziert Wasser |
| `water_transfer` | leitet Wasser weiter (Water Pipe), Teil des Flood-Fill-Pools |
| `water_consumer` | in der Tag-Liste vorhanden, wird aktuell aber nicht aktiv abgefragt (Verbraucher werden implizit über "hat `max_water`, ist nicht Producer/Transfer" erkannt) |
| `water_immune` | nimmt kein Wasser an |
| `energy_producer` | produziert direkt Strom, ohne Wärme-Umweg |
| `energy_seller` | verkauft Energie automatisch gegen Credits (gepoolt, siehe oben) |
| `research_producer` | produziert Research Points pro Tick |
| `generator` | wandelt Wärme (+ Wasser-Boost) in Energie um |
| `booster` | beeinflusst Nachbargebäude positiv (Isolation, Circulator, Bank) |
| `heat_booster` | Sonderfall-Markierung für Isolation-artige Booster |
| `water_element` | Sonderfall-Markierung im Wasser-Kontext |

### Multi-Map-System
Das Spiel unterstützt mehrere Inseln ("Maps"), die **gleichzeitig und unabhängig** ticken:
- Ein globaler Tick durchläuft alle freigeschalteten Maps nacheinander (`MapManager.tick_all()`) – auch im Hintergrund, wenn du gerade eine andere Insel anschaust
- **Global geteilt** (`GameState`): Credits, Research Points + Research-Liste, Tick-Takt, Pause/Bonus-Ticks, Auto-Rebuild-Flag
- **Pro Map getrennt** (`MapState`): Grid (Gebäude, Terrain, Hindernisse), Upgrades, Storage (`stored_energy`, `max_storage`), Pump-/Office-Stats fürs UI
- Gesperrte Maps ticken nicht mit – sie verbrauchen keine Rechenzeit und produzieren nichts, bis sie freigeschaltet sind
- Insel-Definitionen sind aktuell direkt in `control.gd._ready()` verdrahtet (keine eigene "Island-Database")

**Aktuelle Inseln:**

| id | Name | Größe | terrain_id | Freischaltung |
|---|---|---|---|---|
| main | Start Insel | 24×13 | main | von Anfang an frei |
| second | Größere Insel | 24×13 | second | `unlock_cost = 1.000.000` Credits |
| third | Coast | 32×18 | third | `unlock_cost = 100.000.000` Credits |

### Terrain-System
Insel-Layouts werden als lesbare ASCII-Grids definiert (`MapTerrainDatabase.gd`), eine Zeile Text pro Grid-Zeile. Terrain und Hindernisse sind **zwei getrennte, parallele Arrays** pro Map (`grid_terrain`, `grid_obstacle`) – Berge sind also kein eigener Terrain-Typ, sondern ein zusätzliches Overlay:

| Zeichen | Ebene | Bedeutung |
|---|---|---|
| `W` | Terrain | Water – nicht bebaubar |
| `G` | Terrain | Grass – normal bebaubar |
| `S` | Terrain | Shore – bebaubar wie Grass, **einzige** Fläche für Water Pump |
| `M` | Obstacle-Overlay | Mountain – nie bebaubar, unabhängig vom darunterliegenden Terrain (aktuell Grass-Sprite als Platzhalter, bis ein eigenes Mountain-Sprite existiert) |

Jede Map bekommt beim Anlegen eine `terrain_id`, über die ihr Layout aus der Datenbank geladen wird. Aktuell hat nur die Hauptinsel ein aktives Hindernis (ein einzelnes `M`), die anderen beiden Inseln haben leere Hindernis-Layouts.

### BigNumber-System
Eigene Mantisse/Exponent-Klasse (`BigNumber.gd`) für alle spielrelevanten Werte. Unterstützt alle Grundrechenarten sowie kompakte Anzeige mit internationalen Suffixen (K, M, B, T, Qa, Qi, Sx, …) mit intelligenten Nachkommastellen. Unterstützt korrekt Werte unter 1.0 (z.B. 0.15 Energy/Tick der Wind Turbine).

### Gebäude-Lebensdauer & Auto-Rebuild
- **Verbrauchsmaterial** (Reaktoren, Windturbinen): `lifespan != -1`, altert pro Tick
- **Infrastruktur** (alles andere): permanent (`lifespan = -1`), übersprungen
- Erreicht ein Gebäude sein Lebensende, wird es zunächst zum **Ghost** (bleibt stehen, produziert aber nichts mehr, wird in Heat-/Water-Prozessen explizit übersprungen)
- Ist es bereits Ghost, `auto_rebuild_enabled` aktiv, ein `manager_research_id` gesetzt und diese Research erforscht, und genug Credits vorhanden → wird automatisch neu gekauft (Alter zurückgesetzt, kein Ghost mehr)
- Lebensdauer durch Upgrades verlängerbar (`LIFESPAN`-Stat)
- Manuelles Entfernen erstattet Kosten zurück, **außer** bei Reaktoren (`heat_producer`-Tag)

### Savegame-System
- Automatisches Speichern alle **60 Sekunden** + beim Schließen des Spiels
- Speicherort: `user://savegame.json` (Windows: `AppData/Roaming/Godot/app_userdata/PROJEKTNAME/`)
- Gespeicherte Daten: Credits, Research Points, gekaufte Research-IDs, Tick-Takt, Bonus-Ticks; **pro Map**: Grid-Zustand (Gebäudetyp, Alter, Ghost-Status, Hitze, Wasser), Upgrade-Level, Storage, Unlock-Status
- Definitionen selbst werden nie gespeichert, sondern beim Laden frisch aus den jeweiligen Datenbanken aufgelöst
- Versioniert (`version: 2`, seit v0.70 Multi-Map-Format) – aktuell aber ohne echte Migrationslogik, das Feld wird beim Laden nicht ausgewertet
- **Offline Progress**: Beim Laden wird die vergangene Zeit **nicht** sofort durchsimuliert, sondern in `bonus_ticks` umgerechnet (`elapsed_seconds * ticks_per_second`, gedeckelt auf 12h), die der Spieler danach manuell per Fast-Forward-Button abspielen kann (30 Ticks/Sekunde)
- Bekannter Randfall: `terrain_id` wird beim Speichern nicht geschrieben (nur beim Laden mit Fallback `"main"` gelesen) – funktioniert aktuell nur, weil Map-`id` und `terrain_id` 1:1 zusammenhängen

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
| Basic Generator | 500 | 3 | – | generator_1 *(Research-Node aktuell pausiert – siehe Forschungs-System)* |
| Generator 2 | 2.5M | 9 | +100/Wasser | generator_2 |
| Generator 3 | 10T | 32 | +200/Wasser | generator_3 |
| Generator 4 | 50Qa | 96 | +400/Wasser | generator_4 |
| Generator 5 | 12.5Qa | 288 | +800/Wasser | generator_5 |

### Hitze-Management
| Gebäude | Funktion | Freischaltung |
|---|---|---|
| Heat Pipe | puffert & gleicht Wärme paarweise mit Nachbarn aus (grad-normiert) | heat_exchanger |
| Heat Sink | vernichtet 5% Wärme/Tick | heat_sink |
| Heat Inlet | Untergrund-Transfer (geplant) | heat_inlet |
| Heat Outlet | Untergrund-Transfer (geplant) | heat_outlet |
| Boiler House | verkauft Wärme in Bulk-Batches direkt gegen Credits | boiler_house |

### Wasser-Management
| Gebäude | Produktion | Max Storage | Freischaltung |
|---|---|---|---|
| Water Pump | 25K/Tick | 150K | water_pump (nur auf Shore) |
| Ground Water Pump | 67.5K/Tick | 250K | groundwater_pump |
| Water Pipe | – | 150K | water_pipe (Teil des Netzwerk-Pools, siehe Wasser-System) |

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
└── GridPanel – Reaktor-Grid der aktuell aktiven Map (Größe abhängig von der Insel)

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
├── control.gd              # View/Controller: zeigt aktive Map + Map-Übersicht, Input-Handling (~1070 Zeilen, weiterer Split geplant)
├── GameState.gd            # Autoload: global geteilter Zustand (Credits, Research, Tick-Takt)
├── MapManager.gd            # Autoload: hält alle MapState-Instanzen, tickt alle unlockten Maps
├── MapState.gd              # Pro-Map-Zustand + alle process_*-Funktionen (RefCounted, kein Autoload)
├── MapTerrainDatabase.gd    # ASCII-Insel-Layouts pro terrain_id (Terrain + Obstacle getrennt)
├── Building.gd              # Instanz eines platzierten Gebäudes
├── BuildingDefinition.gd    # Template + Enum + alle Felder (inkl. required_research, requires_shore, manager_research_id)
├── Building_database.gd     # Fabrik-Funktionen für alle Gebäudetypen
├── BigNumber.gd             # Mantisse/Exponent-Zahlensystem
├── UpgradeDefinition.gd     # Template + Enums für Upgrades
├── UpgradeDatabase.gd       # Alle Upgrade-Definitionen
├── ResearchDefinition.gd    # Template für Forschungs-Nodes
├── ResearchDatabase.gd      # ~50 Forschungs-Nodes mit Abhängigkeiten (inkl. pausierter/auskommentierter Nodes)
└── SaveManager.gd           # Autoload: Speichern/Laden via JSON, Multi-Map-Format

scenes/
├── control.tscn             # Hauptszene
├── upgrade_panel.tscn       # Upgrade-Overlay (eigene Szene)
└── research_panel.tscn      # Forschungsbaum-Overlay (eigene Szene)
```

### Architektur-Prinzipien
- `BuildingDefinition` – unveränderliches Template (was ein Gebäude *ist*), eine Instanz pro Typ
- `Building` – veränderliche Laufzeit-Instanz (aktueller Zustand: Hitze, Wasser, Alter, Ghost-Status)
- `BuildingDatabase` – statische Fabrik-Funktionen, große Zahlen via `from_notation(m, e)`
- `UpgradeDefinition` / `UpgradeDatabase` – Template + alle Upgrade-Definitionen als statische Fabrik-Funktionen; pro Map eine eigene Kopie
- `ResearchDefinition` / `ResearchDatabase` – Template + alle Forschungs-Nodes; **global**, eine einzige geteilte Instanz über alle Maps
- `SaveManager` – Autoload-Singleton, speichert/lädt JSON, versioniert (Migrationslogik noch nicht implementiert)
- Gebäudetypen via `enum type`, Verhalten via Tags – keine Magic Strings, aber auch keine zentrale Tag-Konstanten-Liste (Tippfehler würden still durchrutschen)
- Upgrades via `enum stat_type` und `enum target_type` – klar getrennte Ziele, live berechnet (kein Caching)
- Forschung via `required_research: String` auf `BuildingDefinition`/`UpgradeDefinition` – ein Feld, klare Abhängigkeit, aber Abhängigkeitsprüfung (`requires`) liegt in der UI-Schicht (`control.gd`/`research_panel.gd`), nicht zentral in `GameState`
- `GameState` – Autoload, global geteilter Zustand (Credits, Research Points + Research-Liste, Tick-Takt, Bonus-Ticks, Auto-Rebuild-Flag)
- `MapManager` – Autoload, hält alle `MapState`-Instanzen, tickt alle unlockten Maps pro Tick durch
- `MapState` – `RefCounted`-Klasse (kein Autoload), pro-Map-Zustand + gesamte Tick-Verarbeitung; wird über `MapManager.add_map()` instanziiert
- `MapTerrainDatabase` – statische Fabrik-Funktionen für ASCII-Insel-Layouts (Terrain + Obstacle-Overlay getrennt), referenziert über `terrain_id`
- `control.gd` ist seit v0.70 reine View/Controller-Schicht – zeigt die aktive Map bzw. Map-Übersicht an und delegiert Logik an `GameState`/`MapManager`/`MapState`

## 🚧 Roadmap

### Must-Have (Alpha)
- [x] Tick-System
- [x] Grid mit Nachbarschaftssystem (dynamisch skalierend, jetzt pro Map, unterschiedliche Größen bereits genutzt: 24×13 und 32×18)
- [x] Wärmeverteilung & Überhitzung
- [x] Generator: Wärme → Strom (mit Wasser-Boost)
- [x] Wassersystem (Netzwerk-Pool-Modell: Pumps, Pipes, Verbrauch)
- [x] Auto-Seller System (gepoolter Verkauf über alle Offices)
- [x] Booster-System (Isolation, Circulator, Bank)
- [x] Heat Sink (Wärme vernichten)
- [x] Battery (max_storage erhöhen)
- [x] Tag-System
- [x] BigNumber-System (K/M/B/T/Qa/Qi/Sx…)
- [x] UI-Grundgerüst (Header, Components-Panel, Grid)
- [x] Visuelles Feedback (Füllstand- & Lebensdauer-Balken)
- [x] Vollständige Gebäudeliste
- [x] Upgrade-System (Multiplikativ + Additiv, Global + Type + Tag, Sell-Button für alle Upgrades)
- [x] Upgrade-Panel (eigene Szene, Overlay, zweispaltig)
- [x] Forschungsbaum (~50 Nodes, Abhängigkeiten, Credits/RP-Logik, global über alle Maps)
- [x] Gebäude durch Forschung freischalten (Gebäudeliste gefiltert)
- [x] Savegames (JSON, Autosave 60s + beim Schließen, versioniert)
- [ ] Upgrades filtern nach Forschungsstand (Feld existiert, Filter-Logik unklar/unvollständig)
- [x] Ghost-Gebäude wenn Reaktoren auslaufen
- [ ] Vollständige Visualisierung (Sprites statt Text bei Gebäuden)
- [ ] Sound/Musik
- [ ] Einstellungen
- [x] Offline Progress (Bonus-Ticks, 12h-Cap, manuelles Fast-Forward-Abspielen)

### Multi-Map-System (v0.70)
- [x] Mehrere Maps laufen gleichzeitig & unabhängig (globaler Tick durchläuft alle unlockten Maps)
- [x] Map-Übersicht mit Live-Stats (Energie/Forschung pro Tick)
- [x] Map-Unlock-Mechanik gegen Credits (1M für Insel 2, 100M für Insel 3), Lock-Status speicherbar
- [x] Terrain-Typen Shore (Water-Pump-exklusiv) & Mountain (unbebaubar, separates Obstacle-Overlay)
- [x] Unterschiedliche Grid-Größen pro Map tatsächlich genutzt (dritte Insel "Coast" ist 32×18)
- [ ] Research-Voraussetzung für Map-Unlock (aktuell nur Credits-Kosten)
- [ ] Eigenes Mountain-Sprite (aktuell Grass als Platzhalter)
- [ ] Zentrale Island-Database (aktuell hart in `control.gd._ready()` verdrahtet)

### Nice-to-Have (Beta / Post-1.0)
- [ ] Mehrere Savegame-Slots (5 geplant)
- [x] Gesperrte Felder auf dem Grid (Mountain-Tile)
- [x] Bodenabhängigkeiten für Gebäude (Water Pump nur auf Shore)
- [ ] Upgrade-Kategorien / Gruppierung
- [ ] Upgrades durch Forschung freischalten (Anzeige-Filter vorhanden, kein Freischalt-Gate)
- [x] Bonusticks
- [ ] Prestige-/Reset-System
- [ ] Weitere Spielmodi
- [ ] 2-Feld Reaktoren (Thorium, Protactium)
- [ ] Radial-Reaktoren (Curium, Balduranium)
- [ ] Heat Inlet/Outlet System (Untergrund-Wärmetransfer)
- [ ] Fast-Forward-/Debug-Modus (geplant, noch nicht im Code – `debug_heat_pipes`-Flag existiert nur als reines Print-Logging ohne UI)
- [ ] Save-Versions-Migration (Feld `version` existiert, wird aber noch nicht ausgewertet)
- [ ] Ingame-Käufe

## 🎯 Inspiration

Basiert auf dem Spielkonzept von [Reactor Idle by Grest Games](https://reactoridle.com/), mit eigenständigen Mechaniken – insbesondere das Wasser-System als Netzwerk-Pool-Modell, das Booster-System mit Nachbarschafts-Stacking, das BigNumber-System für astronomische Zahlenwerte, sowie ein zweistufiges Upgrade-System mit multiplikativen und additiven Modi.
