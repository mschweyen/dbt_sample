# DBT_SAMPLE – Aufgabenstellung
Dieses Beispielprojekt enthält eine kleine Übung zur Datenmodellierung und -aufbereitung mittels **dbt**. Sie dient dazu, Ihnen eine Idee des Aufgabenbereiches zu vermitteln, und ermöglicht uns zu sehen, wie Sie mit einer solchen Aufgabenstellung umgehen. Es gibt viele Lösungsmöglichkeiten – wir freuen uns, Ihre Lösungsansätze mit Ihnen zu besprechen. 

Die Aufgabenstellung, kann mit einem **beliebigen Datenbanksystem** umgesetzt werden. Eine Möglichkeit wäre die Verwendung von DuckDB, da hierfür keine zusätzliche Infrastruktur benötigt wird.

Bei Fragen wenden Sie sich gerne an: **martin.schweyen@dz-privatbank.com** oder **sandra.stern@dz-privatbank.com**

## Datenquellen
Im Verzeichnis `seeds` finden sich drei Beispieldateien mit zufällig generierten Testdaten:

| Datei | Beschreibung                                                                                                             |
|-------|--------------------------------------------------------------------------------------------------------------------------|
| `kunden.csv` | Enthält mehrere Zeilen pro Kunde; das Feld `changedate` entspricht dem Änderungsdatum des jeweiligen Datensatzes. |
| `bestaende.csv` | Monatsultimo-Bestände aller Kunden ab dem 01.01.2025.                                                          |
| `mittelfluesse.csv` | Mittelflüsse ab dem 01.01.2025 aggegiert auf Monatsebene ab dem 01.01.2025.                                |


## Umgebung einrichten
1. Es wird eine **Python-Installation** benötigt
2. Virtuelles Environment (`venv`) für das Projekt erstellen
3. **dbt** sowie benötigte Packages installieren (z. B. `dbt-duckdb`, `duckdb-cli`)


## Aufgabenstellung

### 1. Staging-Modelle erstellen
Erstelle ein Staging-Modell für jede Datenquelle mit folgenden Anforderungen. 

Aus dem Feld `vrb_filial_und_betreuernr_an964` sollen zusätzlich folgende Felder abgeleitet werden:
  - `vrb_filialnr`: Zeichen 1–3
  - `vrb_betreuernr`: Zeichen 4–12

### 2. Dimensionstabelle (SCD2)
Erstelle eine Dimensionstabelle, welche die Kundenstammdaten mittels **SCD2** (Slowly Changing Dimension Typ 2) historisiert. Der aktuellste Datensatz pro `kunde_id` soll entsprechend markiert werden (z. B. über ein Flag `is_current`).

### 3. Faktentabelle
Erstelle eine Faktentabelle, welche die Kennzahlen aus `bestaende` und `mittelfluesse` zusammenführt.
- Ergänze eine zusätzliche Kennzahl: **Nettoabsatz** = Mittelzufluss − Mittelabfluss
- *Hinweis:* Zu jedem Kunden in `mittelfluesse` existiert ein entsprechender Eintrag in `bestaende`.

### 4. Mart-Modelle
Erstelle jeweils einen Mart, um die folgenden Fragestellungen zu beantworten:

| Mart | Fragestellung                                                                                                            |
|------|--------------------------------------------------------------------------------------------------------------------------|
| **Mart A** | Wieviel Nettoabsatz haben die Berater im Zeitverlauf akquiriert? Aggregiere auf **Berater-Ebene**.                 |
| **Mart B** | Der Berater benötigt eine Übersicht wie sich AuM und Nettoabsatz seines **aktuelles Kundenbuch** entwickelt haben. |

### 5. Grafische Aufbereitung *(optional)*
Bereiten Sie die Ergebnisse aus Aufgabe 4 und 5 grafisch auf.