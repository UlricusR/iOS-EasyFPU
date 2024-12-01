# Benutzerhandbuch

## Installieren

Die App ist im Apple App Store verfügbar:

[![Apple App Store](assets/images/appstore.png){ .off-glb }](https://apps.apple.com/de/app/easyfpu/id1529949520){:target="_blank"}

## Die Menüleiste

![Das Tab-Menü](assets/images/00TabMenu.png){align=center}

Über das Tab-Menü am unteren Bildschirmrand kann man zwischen folgenden Bildschirmen wechseln:

- [Essen](#bildschirm-essen): Hier wird eine neue Mahlzeit aus einer oder mehreren Speisen erstellt, von der anschließend die Nährwerte berechnet und nach Loop exportiert werden können.
- [Kochen & Backen](#bildschirm-kochen-backen): Hier können eigene Rezepte angelegt und verwaltet werden.
- [Speisen](#bildschirm-speisen): Hier werden die Speisen verwaltet, aus denen Mahlzeiten erstellt werden.
- [Zutaten](#bildschirm-zutaten): Hier werden die Zutaten verwaltet, die in Rezepten verwendet werden.
- [Einstellungen](#bildschirm-einstellungen): Hier können verschiedene Therapie- und App-Einstellungen vorgenommen werden.

## Bildschirm: Essen

![Mahlzeit berechnen - Startbildschirm](assets/images/01CalculateMeal.png){style="width:100px", align=right}

### Erstellen einer Mahlzeit

Auf diesem Bildschirm, der beim Öffnen der App erscheint, wird eine neue Mahlzeit erstellt, von der anschließend die Nährwerte berechnet und nach Loop exportiert werden können. Eine Mahlzeit besteht aus einer oder mehreren Speisen, die vor der ersten Benutzung [angelegt werden müssen](#bildschirm-speisen).

Zum Erstellen einer Mahlzeit tippt man auf den gelben Button "Füge Speisen zur Mahlzeit hinzu".

### Auswahl von Speisen

![Speisen auswählen](assets/images/02ListFoodSelection.png){style="width:100px", align=left}

Es erscheint die Liste der angelegten Speisen. Klickt man auf den kleinen Stern über der Liste der Speisen, werden nur die Speisen angezeigt, die als Favoriten markiert wurden. Außerdem kann man über das Suchfeld nach Speisen suchen (beliebige Suche innerhalb der Namen).

![Menge eingeben](assets/images/03SelectAmount.png){style="width:100px", align=right}

Zum Hinzufügen einer Speise zur Mahlzeit wählt tippt man diese einmal an, was das Fenster zur Eingabe der gegessenen Menge öffnet. Wurden beim Anlegen der Speise typische Mengen festgelegt, kann nun eine typische Menge gewählt oder immer auch eine eigene Mengenangabe gemacht werden. Alternativ stehen grüne Knöpfe zur Verfügung, die ihren abgebildeten Wert zur bereits eingestellten Menge addieren. Die hier eingegegebene Menge sollte der tatsächlich gegessenen Menge der Speise in Gramm entsprechen.

Außerdem besteht die Möglichkeit, die aktuell eingegebene Menge als neue typische Menge abzuspeichern. Dazu tippt man auf "Zu typischen Mengen hinzufügen", gibt man einen Kommentar ein und bestätigt mit dem grünen Plus-Symbol. Die Pflege oder Änderung von typischen Mengen geschieht im Dialog zum [Bearbeiten von Speisen](#bildschirm-speisen).

Diesen Vorgang wiederholt man optional für weitere Speisen der Mahlzeit.

### Die Zusammenfassung der Mahlzeit

![Die Nährwerte der Mahlzeit](assets/images/04CalculateMealOverview.png){style="width:100px", align=left}

Wurde mindestens eine Speise ausgewählt, erscheint eine Zusammenfassung der Nährwerte der Mahlzeit mit den drei Arten von Kohlenhydraten - Zucker, reguläre und verlängerte Kohlenhydrate:

- Rotes Zuckerwürfelsymbol: Kohlenhydrate aus Zucker werden in der Regel am schnellsten absorbiert. Die entsprechenden Parameter können in den Therapieeinstellungen angepasst werden.
- Grünes Hasensymbol: Reguläre Kohlenhydrate werden langsamer als Zucker absorbiert. Auch diese Parameter können in den Therapieeinstellungen angepasst werden.
- Blaues Schildkrötensymbol: Verlängerte Kohlenhydrate (im Englischen auch bekannt unter e-Carbs oder Fake Carbs) stammen nicht aus Kohlenhydraten, sondern aus Fett und Proteinen. Daher werden sie viel später und viel länger absorbiert.

An dieser Stelle kann auch der Spritz-Ess-Abstand eingestellt werden.

Über den Link "Speisen bearbeiten" können weitere Speisen hinzugefügt oder bestehende entfernt werden.

Durch Antippen des roten Kreuzes am oberen Bildschirmrand wird die Mahlzeit zurückgesetzt, d.h. alle Essensbestandteile sowie der Spritz-Ess-Abstand werden auf Null gesetzt.

### Die Details der Mahlzeit

![Die Details der Mahlzeit und dessen Speisen](assets/images/05CalculateMealDetails.png){style="width:100px", align=right}

Beim Antippen des Info-Symbols öffnet sich die Ansicht mit den Details der Mahlzeit.

### Export nach Apple Health

EasyFPE kann schnelle und normale Kohlenhydrate, die aus den Fett-Protein-Einheiten berechneten "verlängerten" Kohlenhydrate und die Kalorien nach Apple Health exportieren. Dies ist dann sinnvoll, wenn die Daten von anderen Apps (z.B. Ernährungs-Apps), insbesondere aber von [Loop](https://loopkit.github.io/loopdocs/){:target="_blank"}, einer App zur Steuerung von Insulinpumpen, genutzt werden sollen.

![Die Vorschau des Exports nach Apple Health](assets/images/06AppleHealthExportOverview.png){style="width:100px", align=left}

Durch Tippen des Export-Knopfes (ein Rechteck mit Pfeil nach oben) können die berechneten Kohlenhydrate, aber auch die Kalorien der Mahlzeit nach Apple Health exportiert werden.

Durch An- oder Abwählen der Schalter werden die zu exportierenden Daten ausgewählt.

Außerdem kann auch hier der Spriz-Ess-Abstand eingestellt werden.

Für die Kohlenhydrate wird eine Vorschau erstellt, die zeigt, zu welchem Zeitpunkt welcher Kohlenhydratanteil welcher Art aktiv ist. In rot werden die Kohlenhydrate aus Zucker dargestellt, in grün die regulären Kohlenhydrate und in blau die verlängerten Kohlenhydrate.

In wievielen kleinen Teilmengen die jeweiligen Kohlenhydrate über die Zeitspanne der Absorptionszeit verteilt werden, regelt man mit den jeweiligen Intervall-Parametern in den Therapieeinstellungen.

### Loop-Anbindung

Sollen die von EasyFPE berechneten Kohlenhydrate in Loop genutzt werden, so muss Loop auf Apple Health zuzugreifen dürfen:

- [Loop 2.2.x Apple Health Permissions](https://loopkit.github.io/loopdocs/build/health/){:target="_blank"}
- [Loop 3 Apple Health Permissions](https://loopkit.github.io/loopdocs/loop-3/onboarding/#apple-health-permissions){:target="_blank"}

!!! warning "Wichtiger Hinweis für Loop 3"

    Seit Loop Version 3 muss das Lesen von Daten aus Apple Health beim Kompilieren der Loop-App explizit erlaubt werden, sonst funktionert der Datentransfer nicht. Dazu müssen Sie [das Build-Feature "OBSERVE_HEALTH_KIT_CARB_SAMPLES_FROM_OTHER_APPS_ENABLED"](https://loopkit.github.io/loopdocs/build/code_customization/#build-time-features){:target="_blank"} setzen.

Sobald EasyFPE die Daten exportiert hat, öffnen Sie Loop und lassen Sie sich einen Bolusvorschlag anzeigen. Die Kohlenhydrate aus EasyFPE werden nun mit eingerechnet, es ist keine manuelle Dateneingabe mehr notwendig.

!!! warning "Wichtige Hinweise für Looper"

    Dieses Feature kann sehr nützlich für Typ 1-Diabetiker sein, die ihre Insulintherapie über Loop steuern. Loop liest, wenn Sie dies in den Einstellungen von Apple Health erlauben, die von EasyFPE exportierten Kohlenhydratdaten und passt den Insulinbedarf entsprechend an. Geben Sie die Mahlzeit auf keinen Fall erneut in Loop ein, denn das könnte zu doppelten Einträgen und einer Unterzuckerung führen.

    Wenn Sie die Kohlenhydrate einer Mahlzeit jedoch versehentlich doppelt exportieren, kann das zur Unterzuckerung oder sogar schweren Unterzuckerung führen.

    Zwei Sicherheitsmechanismen versuchen das zu verhindern:

    - Bevor Daten nach Apple Health exportiert werden, überprüft EasyFPE den Zeitpunkt des letzten Datenexports. Liegt dieser innerhalb einer Zeitspanne x, wird eine Warnung angezeigt und Sie müssen den Export explizit ein zweites Mal bestätigen. Die Zeitspanne x kann in den App-Einstellungen konfiguriert werden. Voreinstellung ist 15 Minuten.
    - Als zweite Bestätigung vor dem Export werden Sie gebeten, sich zu authentifizieren - abhängig von den iOS-Einstellungen per FaceID, TouchID oder Code.

## Bildschirm: Kochen & Backen

![Die Rezeptliste](assets/images/10RecipeList.png){style="width:100px", align=left}

Seit Version 2.0.0 ist es möglich, eigene Rezepte in EasyFPE zu verwalten. Alle Rezepte werden in der Rezeptliste angezeigt.

Ein Rezept besteht aus einer oder mehreren Zutaten, die zunächst [angelegt werden müssen](#bildschirm-zutaten).

Zum Anlegen eines neuen Rezepts tippt man auf den grünen Plus-Button oben am Bildschirm.

### Schritt 1: Zutaten eines Rezepts auswählen

![Zutaten auswählen](assets/images/12SelectIngredient.png){style="width:100px", align=right}

Genauso wie man bei Mahlzeiten Speisen hinzufügt, wählt man für sein Rezept zunächst alle Zutaten per Antippen aus.

### Schritt 2: Name, Gesamtgewicht und Anzahl der Portionen festlegen

![Eingabe eines Namens, des Gesamtgewichts und der Anzahl der Portionen](assets/images/14RecipeFinished.png){style="width:100px", align=left}

Für den nächsten wichtigen Schritt sind folgende Daten einzugeben:

- Der Name des Rezepts, z.B. "Marmorkuchen mit Schokoglasur"
- Das Gesamtgewicht des fertigen Rezepts - die ist wichtig für die korrekte Berechnung der Nährwerte pro 100g
- Die Anzahl der Portionen, die aus dem fertigen Produkt (möglichst gleichmäßig) geschnitten wird

### Schritt 3: Speichern des Rezepts

Zum Speichern der fertigen Speise tippt man auf das Häkchen oben am Bildschirm. Damit wird das Rezept in der Liste der Speisen abgelegt. Sollte das Gesamtgewicht des Rezept von der Summe seiner Zutaten abweichen, muss dies noch bestätigt werden.

### Schritt 4: Bearbeiten eines Rezepts

Will man ein Rezept bearbeiten, so wischt man in der Rezeptliste nach links und wählt das Stiftsymbol.

## Bildschirm: Speisen

![Die Liste der Speisen](assets/images/20DishesList.png){style="width:100px", align=right}

Auf diesem Bildschirm werden die Speisen verwaltet, die für Mahlzeiten verwendet werden können. Die Liste ist beim allerersten Öffnen zunächst leer - nach einem Update wird die vorhandene Liste mit Speisen übernommen.

In dieser App ist mit einer Speise eine einzelne Komponente einer Mahlzeit gemeint, die in sich „homogen“ ist. Mehrere Speisen können dann zu einer Mahlzeit zusammengestellt werden. So bestünde z.B. die Mahlzeit Schnitzel mit Pommes und Ketchup aus drei Speisen, nämlich dem Schnitzel, den Pommes und dem Ketchup.

Die Liste der Speisen ist alphabetisch sortiert. Es empfiehlt sich, jeder Speise einen eindeutigen Namen zu geben und nicht zweimal denselben Namen zu verwenden.

Klickt man auf den kleinen Stern über der Liste der Speisen, werden nur die Speisen angezeigt, die als Favoriten markiert wurden. Außerdem kann man über das Suchfeld nach Speisen suchen (beliebige Suche innerhalb der Namen).

Durch Wischen nach links kann die Speise bearbeitet, gelöscht oder dupliziert werden.

Durch Wischen nach rechts kann sie mit anderen Nutzern von EasyFPE geteilt oder auf die Liste der Zutaten verschoben werden.

Zum Anlegen einer neuen Speise tippt man auf das große, grüne Plus-Symbol oben am Bildschirm. Es gibt drei Möglichkeiten um Anlegen einer neuen Speise.

### Option 1: Manueller Eintrag

![Neue Speise anlegen / Speise bearbeiten](assets/images/21AddFoodItemEmpty.png){style="width:100px", align=right}

Es öffnet sich ein Dialog zur Eingabe der notwendigen Daten:

- Name (Pflichtfeld): Der Name der Speise
- Lieblingsessen: Auswahl, ob die Speise in der Liste der Lieblingsessen angezeigt wird
- Kalorien pro 100g (Pflichtfeld): Die Kalorien der Speise pro 100g in kcal
- Kohlenhydrate pro 100g (Pflichtfeld): Die Kohlenhydrate der Speise pro 100g in Gramm
- Davon Zucker pro 100g (Pflichtfeld): Die Menge an Kohlenhydraten aus Zucker pro 100g als Teilmenge der Kohlenhydrate

Außerdem können optional noch beliebig viele typische Mengen der Speise hinzugefügt werden, jeweils versehen mit einem Kommentar. Man bestätigt die Eingabe durch Antippen des kleinen grünen Plus-Symbols.

Die typischen Mengen werden später bei der Auswahl der Speise im Berechnungsdialog angezeigt. Die Eingabe der typischen Menge ist besonders bei vorher bekannten Mengen nützlich (z.B. abgepacktes Essen oder „4 Stück“ ChickenMcNuggets) und erleichtert die spätere Nutzung der App insbesondere für Kinder.

Nach dem Abspeichern erscheint die neu angelegte Speise in der Liste der Speisen (alphabetisch sortiert).

### Option 2: Suche in der Lebensmitteldatenbank

![Die Ergebnisliste der Suche](assets/images/23SearchResults.png){style="width:100px", align=left }
![Die Detailansicht der Suche / des Scans](assets/images/24SearchResultDetails.png){style="width:100px", align=left }

Seit Version 2.0.0 kann eine Speise in einer Lebensmitteldatenbank gesucht werden. Geben Sie dazu den Suchbegriff in das Namensfeld ein und tippen Sie anschließend auf das Such-Symbol.

Derzeit ist nur eine Lebensmitteldatenbank angebunden, nämlich [OpenFoodFacts](https://world.openfoodfacts.org/){:target=blank}. OpenFoodFacts ist eine offene Lebensmitteldatenbank, d.h. jeder kann beitragen. Das bedeutet, dass dort auch falsche Nährwerte eingetragen sein können. Überprüfen Sie daher bitte immer, ob die in der Datenbank gefundenen Nährwerte auch den tatsächlichen Nährwerten entsprechen. Nutzen Sie hierzu das Detailanzeigefenster, wo Sie auch Produktbilder finden, in die Sie hineinzoomen können.

### Option 3: Scannen des Barcodes

Tippen Sie zum Scannen eines Barcodes auf das Scan-Symbol neben dem Such-Symbol und richten Sie dann die Kamera Ihres Geräts auf den Barcode des Produkts. Wird das Produkt in der Datenbank gefunden, wird Ihnen das Detailanzeigefenster angezeigt, wo Sie entscheiden können, ob das Produkt übernommen wird oder nicht.

Sollte kein Scan möglich sein, wischen Sie das Kamerafenster einfach von oben nach unten weg.

## Bildschirm: Zutaten

![Die Liste der Zutaten](assets/images/30IngredientsList.png){style="width:100px", align=right }

Um ein Rezept anlegen zu können, benötigt man zunächst all seine Zutaten in der Zutatenliste. Die Zutatenliste befindet sich im Reiter "Zutaten" rechts neben den Produkten. Zutaten können Wischen nach rechts zwischen der Produkt- und der Zutatenliste verschoben werden.

Das Anlegen von Zutaten funktioniert identisch wie das [Anlegen von Speisen](#bildschirm-essen) - per manueller Eingabe, per Suche in einer Essensdatenbank oder per Scan eines Barcodes. Der einzige Unterschied besteht in der Auswahl der Kategorie "Zutat" statt "Produkt".

## Bildschirm: Einstellungen

![Einstellungen](assets/images/40SettingsMenu.png){style="width:100px", align=left }

- Therapieeinstellungen: Öffnet den Dialog zum Bearbeiten der Absorptionsschemata
- App-Einstellungen: Öffnet den Dialog zu verschiedenen App-Einstellungen
- Importieren (Format: JSON): Importiert die Datenbank aus einer JSON-Datei - Sie können im Anschluss wählen, ob Sie die bestehende Essensliste ersetzen oder ergänzen wollen
- Exportieren (Format: JSON): Export der Essensliste (exportiert werden Speisen, Zutaten und Rezepte) zwecks Backup oder Austausch mit anderen
- Über: Infos über die App
- Haftungsausschluss: Zeigt den [Haftungsausschluss](index.de.md/#haftungsausschluss) an
- Hilfe im Web: Der Link zu dieser Dokumentation

### Therapieeinstellungen

![Therapieeinstellungen 1](assets/images/41TherapySettings1.png){style="width:100px", align=left}
![Therapieeinstellungen 2](assets/images/43TherapySettings3.png){style="width:100px", align=left}

In den Therapieeinstellungen können Sie die Absorptionsschemata für Kohlenhydrate aus Zucker, reguläre Kohlenhydrate und verlängerte Kohlenhydrate bearbeiten.

Jedes dieser Absorptionsschemata hat drei Parameter:

- Verzögerung: Die Zeit, die Ihr Körper benötigt, um die jeweiligen Kohlenhydrate zu verdauen, d.h. nach dieser Zeit wirken diese Kohlenhydrate auf Ihren Blutzucker.
- Absorptionszeit: Die Dauer, in der diese Kohlenhydrate auf Ihren Blutzucker wirken, nachdem sie (nach der Verzögerung) begonnen haben (dieser Parameter kann nur für Zucker und reguläre Kohlenhydrate eingegeben werden, für verlängerte Kohlenhydrate wird er berechnet).
- Intervall: Dieser Parameter wird lediglich für den Export der Kohlenhydrate nach Apple Health benötigt. Die Gesamtmenge der jeweiligen Kohlenhydrate wird für den Export gleichmäßig in diesem Abstand über die Absorptionszeit verteilt. Beispiel: Bei einer 3-stündigen (=180min) Absorptionszeit und einem 10-Minuten-Intervall wird eine Kohlenhydratmenge von 36g auf 18 Teile zu je 2g verteilt: 36g / (180min / 10min).

#### Absorptionsschema für Kohlenhydrate aus Zucker

Sie können auswählen, ob Kohlenhydrate aus Zucker getrennt von regulären Kohlenhydraten ausgewiesen werden sollen. Sollten Sie dies nicht nutzen, werden Kohlenhydrate aus Zucker wie reguläre Kohlenhydrate behandelt.

Kohlenhydrate aus Zucker werden in der Regel relativ schnell absorbert. Die Voreinstellung ist 2 Stunden mit keiner Verzögerung (sofortige Wirkung).

#### Absorptionsschema für reguläre Kohlenhydrate

Sollten Sie die separate Behandlung von Kohlenhydraten aus Zucker ausgewählt haben, werden diese von den regulären Kohlenhydraten abgezogen.

Reguläre Kohlenhydrate werden in der Regel langsamer absorbiert als die aus Zucker. Die Voreinstellung ist 3 Stunden mit einer Verzögerung von 5 Minuten.

#### Absorptionsschema für verlängerte Kohlenhydrate

Verlängerte Kohlenhydrate sind eigentlich gar keine Kohlenhydrate, sondern Fett-Protein-Einheiten (FPE), sie wirken jedoch sehr ähnlich auf den Blutzucker. Da sie aus Fett und Proteinen stammen, die zunächst vom Körper verdaut werden müssen, beginnt ihre Wirkung eher spät (Voreinstellung ist 90 Minuten).

Das Absorptionsschema legt fest, welche Absorptionszeit bei einer gegebenen Anzahl an FPE ausgegeben wird. Das voreingestellte Absorptionsschema entspricht den heutigen Erkenntnissen der Ernährungswissenschaft und ist wie folgt angelegt:

- 1 FPE (= 10g verlängerte Kohlenhydrate): 3 Stunden Absorptionszeit
- 2 FPE (= 20g verlängerte Kohlenhydrate): 4 Stunden Absorptionszeit
- 3 FPE (= 30g verlängerte Kohlenhydrate): 5 Stunden Absorptionszeit
- 4 FPE (= 40g verlängerte Kohlenhydrate): 6 Stunden Absorptionszeit
- 6 FPE (= 60g verlängerte Kohlenhydrate) und mehr: 8 Stunden Absorptionszeit

Dieses Absorptionsschema kann auch bearbeitet werden.

Da jeder Körper anders auf Fett-Protein-Einheiten reagiert, ist es wichtig, dass Sie ihren eigenen Kohlenhydrate-pro-FPE-Faktor herausfinden und hier einstellen. Voreinstellung ist 10g Kohlenhydrate pro FPE, für Kinder rate ich jedoch zu deutlich niedrigeren Faktoren.

Die Berechnungslogik der App geht wie folgt vor:

Schritt 1: Berechnung der Gesamtkalorien, z.B. bei 72g ChickenMcNuggets (249 kcal pro 100g): 72g * 249 kcal / 100g = 179 kcal

Schritt 2: Berechnung der Kalorien, die durch Kohlenhydrate verursacht werden (4 kcal pro 1 g Kohlenhydrate), z.B. bei 72g ChickenMcNuggets (17g Kohlenhydrate pro 100g): 72g * 17gKH / 100g * 4 kcal/gKH = 49 kcal

Schritt 3: Abzug der Kalorien aus Kohlenhydraten von den Gesamtkalorien; die sich ergebenden Kalorien stammen dann aus Fett und Proteinen, im obigen Beispiel: 179 kcal - 49 kcal = 130 kcal

Schritt 4: Da 100 kcal einer FPE entsprechen, ergeben sich im Beispiel 1,3 FPE, was bei einem Kohlenhydrate-pro-FPE-Faktor von 10 dann 13,0 g verlängerter Kohlenhydrate entsprechen würde.

Schritt 5: Die FPE werden gerundet, im Beispiel auf 1 FPE, und damit die Absorptionszeit nachgeschlagen, im Beispiel 3 Stunden.

Eine Änderung des Absorptionsschemas wird nur ernährungswissenschaftlich erfahrenen Personen empfohlen. Alle Absorptionsdaten können auf die Voreinstellungen zurückgesetzt werden.

### App-Einstellungen

![App-Einstellungen](assets/images/44AppSettings.png){style="width:100px", align=left}

Um zu vermeiden, dass Kohlenhydrate aus Mahlzeiten versehentlich mehrfach hintereinander nach Apple Health exportiert werden und damit ggf. die Insulinmenge Ihres Loop-Systems erhöhen, wird Sie EasyFPE darauf hinweisen, wenn Sie innerhalb einer gegebenen Zeitspanne nach dem letzten Export einen erneuten Export vornehmen. Diese Zeitspanne kann hier eingestellt werden. Voreinstellung ist 15 Minuten.

Außerdem kann hier ausgewählt werden, in welchem Land OpenFoodFacts suchen soll.

## Beispieldaten

[Diese JSON-Datei](assets/EasyFPU_FoodList.json) können Sie herunterladen und als Beispieldaten nutzen. Importieren Sie die Datei über den Menüpunkt "JSON-Import".

Ich empfehle jedoch dringend, Ihre eigenen Speisen anzulegen, da auch die typischen Mengen von Person zu Person unterschiedlich sind.
