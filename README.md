# 🔬 Reactor Idle – GDScript Remake

Ein tick-basiertes Idle-Strategie-Spiel inspiriert von [Reactor Idle](https://grestgames.itch.io/reactor-idle), gebaut mit der **Godot Engine** und **GDScript**.

## 🎮 Spielkonzept

Baue und verwalte einen Reaktorkomplex auf einem großen Grid. Platziere Reaktoren, leite Wärme über Heat Pipes zu Generatoren, versorge sie mit Wasser für zusätzlichen Durchsatz – und vermeide Überhitzung.

```
Reaktor → Heat Pipe → Generator → Strom → Credits
                           ↑
                      Water Pipe
                           ↑
                      Water Pump (Boost)
```

## ⚙️ Aktuelle Mechaniken

### Tick-System
Jeder Tick durchläuft eine feste Reihenfolge:
1. **Produktion** – `process_heat()`, `process_water()`
2. **Transport** – `process_heat_pipes()`, `process_water_pipes()`
3. **Umwandlung** – `process_generators()`
4. **Konsequenzen** – `process_overheat()`

### Wärme-System
- Reaktoren produzieren Wärme pro Tick und verteilen sie gleichmäßig auf valide Nachbarn
- Reaktoren akzeptieren **keine** fremde Wärme – reine Produzenten
- Ohne validen Abnehmer überhitzt ein Reaktor nach 1 Tick (`max_heat == heat_production`)
- Heat Pipes puffern Wärme und gleichen sie zwischen Nachbarn aus (fließt immer von voll zu leer)

### Energie-System
- Generatoren wandeln empfangene Wärme in Strom um (`energy_processing` als Grunddurchsatz)
- **Wasser-Boost**: Reicht der Grunddurchsatz nicht aus, wird zusätzliches Wasser verbraucht, um die Kapazität in festen Schritten zu erhöhen (additiv, kein Multiplikator – bleibt balancierbar über Upgrades)
- Reicht das Wasser nicht aus, staut sich überschüssige Wärme im Generator bis zur Überhitzung
- Windturbinen produzieren direkt Strom ohne Wärmesystem

### Wasser-System
- Water Pumps produzieren und speichern Wasser
- Water Pipes leiten Wasser weiter (prozentual von `max_water` pro Tick)
- Wasser-immune Gebäude (z. B. Reaktoren) können kein Wasser aufnehmen

### Tag-System
Gebäudeeigenschaften werden über Tags statt feste Typabfragen gesteuert (`heat_producer`, `heat_consumer`, `heat_immune`, `water_producer`, `water_transfer`, `water_immune`, `energy_producer` u. a.). Neue Gebäude erben automatisch das richtige Verhalten in allen `process_*`-Funktionen, ohne dass bestehender Code geändert werden muss.

### BigNumber-System
Eigene Mantisse/Exponent-Zahlenklasse (`BigNumber.gd`) ersetzt `float`/`int` für alle spielrelevanten Werte (Credits, Kosten, Wärme, Wasser, Energie). Unterstützt Addition, Subtraktion, Multiplikation, Division und Vergleiche, sowie kompakte Anzeige mit internationalen Kurz-Suffixen (K, M, B, T, Qa, Qi, Sx, …).

### Gebäude-Lebensdauer
- **Verbrauchsmaterial** (Reaktoren): verfallen nach X Ticks
- **Infrastruktur** (Pipes, Pumps, Generatoren): permanent (`lifespan = -1`)

### Visuelles Feedback
- Lebensdauer- und Füllstand-Balken direkt auf den Grid-Zellen (Wasser blau, Hitze rot, Lebensdauer gelb)
- Dynamisch berechnete Zellgröße – das Grid skaliert automatisch mit der Fenstergröße

## 🏗️ Gebäude (aktueller Stand)

| Kategorie | Gebäude |
|---|---|
| Reaktoren | Solar Cell, Coal Burner, Gas Burner, Nuclear Cell, Thermonuclear Cell, Fusion Cell |
| Generatoren | Wind Turbine, Basic Generator, Generator 2–4 |
| Hitze | Heat Pipe |
| Wasser | Water Pump, Water Pipe |

## 🖥️ UI-Struktur

```
NavTabs (Power Plants | Research | Upgrades | Settings)
HeaderRow
├── StatsBox     – Credits, Energy/Tick, Stored + Balken, Sell Energy
├── OverlayBox   – Platzhalter für Tooltips/Warnungen/Events
└── ControlsBox  – Auto-Rebuild, Bonus Ticks, Pause/Fast
MainArea
├── ComponentsPanel – Kategorie-Tabs + Gebäudeliste + Tooltip
└── GridPanel       – das Reaktor-Grid
```

## 📁 Projektstruktur

```
scripts/
├── control.gd            # Hauptsteuerung: Grid, Tick-Loop, UI
├── Bulding.gd             # Instanz eines platzierten Gebäudes
├── BuildingDefinition.gd # Definition/Template eines Gebäudetyps
├── Building_database.gd  # Fabrik für alle Gebäudetypen
└── BigNumber.gd           # Mantisse/Exponent-Zahlensystem
```

### Architektur-Prinzipien
- `BuildingDefinition` – unveränderliches Template (was ein Gebäude *ist*)
- `Building` – veränderliche Instanz (aktueller Zustand: Hitze, Wasser, Alter)
- `BuildingDatabase` – statische Fabrik-Funktionen pro Gebäudetyp
- Gebäudetypen über `enum type`, Verhalten über `tags` – keine Magic Strings, keine wiederholten Typ-Abfragen in der Spiellogik

## 🚧 Roadmap

### Must-Have (1.0)
- [x] Tick-System
- [x] Grid mit Nachbarschaftssystem (dynamisch skalierend)
- [x] Wärmeverteilung & Überhitzung
- [x] Generator: Wärme → Strom (mit Wasser-Boost)
- [x] Wassersystem komplett (Pumps, Pipes, Verbrauch)
- [x] Tag-System
- [x] BigNumber-System
- [x] UI-Grundgerüst (Header, Components-Panel, Grid)
- [x] Visuelles Feedback (Füllstand- & Lebensdauer-Balken)
- [ ] Vollständige Gebäudeliste (Heat Sink, Boiler House, Isolation, Circulator, Groundwater Pump, Auto-Seller-Reihe, Research-Gebäude)
- [ ] Forschung (Logik + Gebäude)
- [ ] Upgrades (Logik)
- [ ] Savegames
- [ ] Vollständige Visualisierung (Sprites statt Text-Buttons)
- [ ] Sound/Musik
- [ ] Einstellungen
- [ ] Offline Progress

### Nice-to-Have (Post-1.0)
- [ ] Bonusticks
- [ ] Prestige-/Reset-System
- [ ] Weitere Spielmodi
- [ ] Ingame-Käufe

## 🎯 Inspiration

Basiert auf dem Spielkonzept von [Reactor Idle by Grest Games](https://grestgames.itch.io/reactor-idle), mit eigenständigen Abwandlungen — insbesondere beim Wasser-System, das hier als additiver Kapazitäts-Booster für Generatoren funktioniert statt als reine Kühlung.
