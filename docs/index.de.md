# EasyFPE für iOS

![EasyFPE-App-Icon](assets/images/pizza_small.png){ align=left }

Eine iOS-App - hauptsächlich für Typ 1-Diabetiker - zum einfachen Berechnen von Kohlenhydraten aus Zucker, regulären Kohlenhydraten und Fett-Protein-Einheiten (FPE) bzw. verzögerten Kohlenhydraten (auch bekannt als e-Carbs oder Fake Carbs) - synchronisiert zwischen allen Ihren iOS-Geräten via iCloud (optional).

## Haftungsausschluss

!!! warning "Warnung"

    Ich muss und will vorab darauf hinweisen, dass die Nutzung dieser App auf eigenes Risiko erfolgt.

Die von der App errechneten Fett-Protein-Einheiten und Absorptionszeiten orientieren sich an den Empfehlungen z.B. der Deutschen Diabeteshilfe (siehe Links), wobei mit Absicht die vereinfachte Berechnungslogik angewandt wird: Statt die Fettmenge eines Essens mit 9 kcal/g und die Proteinmenge mit 4 kcal/g zu berechnen, werden von der Gesamtkalorienmenge die Kalorien aus Kohlenhydraten (4 kcal/g) abgezogen. Die Differenz ergibt dann die Kalorienmenge aus Fett und Proteinen. Die detaillierten Berechnungsschritte sind im Kapitel über das Absorptionsschema beschrieben.

Vorteil dieser Methode: Der Nutzer muss nur die Kalorien und die Kohlenhydrate pro 100g Essen eingeben und nicht zusätzlich noch die spezifischen Fett- und Proteinmengen.

!!! warning "Warnung"

    Wie Sie mit dieser Berechnung dann umgehen, ist Ihr eigenes Risiko. Obwohl ich den Rechenalgorithmus gründlich getestet habe und ihn selbst im Rahmen einer Insulinpumpentherapie in meiner Familie einsetze, lehne ich jede Garantie für dessen Korrektheit ab.

Ich will hier explizit die [Deutsche Diabeteshilfe](https://www.diabetesde.org/ueber_diabetes/was_ist_diabetes_/diabetes_lexikon/fett-protein-einheit-fpe){:target="_blank"} zitieren, die schreibt:

!!! quote "Deutsche Diabeteshilfe"

    Egal ob Pumpe oder Pen – wenn Sie nach Absprache mit Ihrem Diabetologen die ersten Versuche mit Insulingaben für Fett-Eiweiß-Einheiten machen, sollten Sie Ihren Blutzuckerspiegel sehr gut im Auge behalten.

Ein paar persönliche Erfahrungswerte zum Schluss:

- Wenn Sie loopen, ist es von Vorteil, wenn der Loop weiß, dass weitere Kohlenhydrate über die nächste Zeit zu erwarten sind. Er wird dann entweder die Menge oder die Anzahl der Autobolus-Gaben erhöhen.
- Wenn Ihre Auto-Bolus-Einstellungen aus Sicherheitsgründen eine höhere oder häufigere Bolusgabe verhindern, werden Sie eine sehr hohe Insulinmenge als manuelle Abgabe vorgeschlagen bekommen (z.B. 1,5 IE bei einem Blutzucker von 180). Reduzieren Sie diese Menge am Anfang aus Sicherheitsgründen auf die Hälfte.
- Und behalten Sie bei Erstanwendung bitte stets Ihren Blutzuckerverlauf im Blick.
