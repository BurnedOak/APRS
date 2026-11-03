# Systemarchitektur, Regulatorik und Hardware-Evaluation moderner APRS- und LoRa-MeshCom-Systeme im Amateurfunk

![APRS](https://img.shields.io/badge/APRS-144.800_MHz_%7C_433.775_MHz-blue)
![MeshCom 4.0](https://img.shields.io/badge/MeshCom_4.0-433.175_MHz-green)
![Firmware](https://img.shields.io/badge/DK5EN_Fork-v4.40a-orange)
![License](https://img.shields.io/badge/Amateur_Radio-CEPT_%2F_ÖVSV-red)

---

## 1. Paradigmenwechsel in der Positions- und Datenübertragung: Von AX.25 AFSK zu LoRa-Mesh-Netzen

Das Automatic Packet Reporting System (APRS), ursprünglich auf Basis der Spezifikation `APRS101.PDF` von Bob Bruninga (WB4APR) konzipiert **[3]**, hat sich von einem taktischen Positionsmeldesystem zu einer multimodalen Telemetrie-, Wetterdaten- und Kurznachrichten-Plattform im Amateurfunkdienst entwickelt **[1, 3]**. Auf Protokollebene definiert APRS ein strukturiertes Datenformat, das neben geografischen Koordinaten wie Breitengrad, Längengrad und Höhe nach dem APRS-Protokollstandard auch Kurs- und Geschwindigkeitsvektoren, Umweltsensordaten zu Temperatur, Luftdruck, Luftfeuchtigkeit und Niederschlag, Systemtelemetrie wie Akkuspannung, RSSI, SNR und Routing-Pfade sowie gerichtete Textnachrichten mit Ende-zu-Ende-Quittierung (`ack`) und Gruppen-Bulletins umfasst **[1, 3, 5]**.

In der modernen Amateurfunkpraxis und insbesondere in der Programmierlogik aktueller Handfunkgeräte und Mikrocontroller-Plattformen hat sich eine begriffliche Trennung zwischen analogem APRS und digitalem APRS etabliert, die aus nachrichtentechnischer Sicht einer präzisen Differenzierung bedarf **[2, 3, 6]**. Streng genommen ist jede APRS-Aussendung digital, da stets diskrete Zeichenketten und Datenrahmen übertragen werden. Der Begriff des **analogen APRS** bezeichnet jedoch die klassische Basisband-Modulation mittels Audio Frequency Shift Keying (AFSK nach dem Bell-202-Standard mit 1.200 Baud), bei der unnummerierte Informationsrahmen (UI-Frames) des AX.25-Packet-Radio-Protokolls über einen analogen Schmalband-FM-Träger – in Europa standardisiert auf `144,800 MHz` im 2-Meter-Band – ausgestrahlt werden **[3, 7, 8]**.

Demgegenüber spaltet sich das **digitale APRS** heute in zwei fundamental unterschiedliche physikalische Übertragungsverfahren (Physical Layers) im 70-Zentimeter-Band und teilweise im 2-Meter-Band auf:
1. **DMR-APRS (Digital Mobile Radio nach ETSI TS 102 361-1, -2 und -3 für Tier I und II):** Hierbei werden Positions- und Kurznachrichtendaten in einem 4FSK-modulierten TDMA-Zeitschlitzverfahren (Time Division Multiple Access mit zwei Zeitschlitzen à 12,5 kHz Kanalbandbreite; Emissionsklassen `7K60FXD` für reine Daten bzw. `7K60FXW` für kombinierte Daten und Sprache) als Datenpakete an ein digitales Relaisfunkstellen-Netzwerk wie BrandMeister oder DMR+ übermittelt **[2, 9, 10, 11, 12]**.
2. **LoRa-basierte Systeme (Chirp Spread Spectrum – CSS):** Diese nutzen frequenzmodulierte Chirp-Impulse im 70-cm-Band und gliedern sich wiederum in das klassische **LoRa-APRS** (in Europa auf `433,775 MHz` mit 125 kHz Bandbreite) sowie das speziell für den europäischen Amateurfunk entwickelte Off-Grid-Kommunikationssystem **MeshCom 4.0** (in Europa auf `433,175 MHz` mit 250 kHz Bandbreite, Spreading Factor SF 11 und Coding Rate CR 4/6) **[1, 13, 14, 15, 16]**.

### Grafik 1: Systemarchitektur & Frequenz-Bifurkation (APRS & MeshCom 4.0)

~~~mermaid
flowchart TB
    subgraph Endgeraete["Endgeräte-Portfolio & Physikalische Schichten (Physical Layers)"]
        direction TB
        A1["<b>Analoges APRS (2m)</b><br/>144,800 MHz | AFSK 1.200 Bd AX.25<br/><i>Anytone AT-D878UV Plus (TX)</i><br/><i>Anytone AT-D878UVII Plus (RX/TX)</i>"]
        D1["<b>DMR-APRS (70cm / 2m)</b><br/>Relais-QRG | 4FSK TDMA (7K60FXD)<br/><i>Anytone 878 Gen 1 & Gen 2</i><br/><i>Baofeng DM-32 / DM-32UV</i>"]
        L1["<b>LoRa-APRS Tracking (70cm)</b><br/>433,775 MHz | CSS BW 125 kHz<br/><i>Lilygo T-Beam / T-Deck (--track on)</i><br/><i>SmartBeaconing aktiv</i>"]
        M1["<b>MeshCom 4.0 Off-Grid (70cm)</b><br/>433,175 MHz | CSS BW 250 kHz, SF 11, CR 4/6<br/><i>Lilygo T-Beam AXP2101 / Supreme / 1W</i><br/><i>Lilygo T-Deck Plus (DK5EN FW v4.40a)</i>"]
    end

    subgraph Infrastruktur_OE["Empfangsinfrastruktur & Digipeater in Österreich (Beispiel OE5 / OE1)"]
        direction TB
        IG_2M["<b>2m APRS Digi / iGate</b><br/>z.B. OE5XOL-10 (Breitenstein)<br/>OE5XYZ-10 (Linz) | OE1XBA (Wien)"]
        DMR_REP["<b>DMR Tier II Repeater</b><br/>z.B. OE5XLL (Lichtenberg, 927m)<br/>BrandMeister / DMR+ Netz"]
        IG_LORA["<b>70cm LoRa-APRS Digi / iGate</b><br/>z.B. OE5XOL-11 (RX 433,775 / TX 433,900)<br/>OE7XOT (Tirol)"]
        MC_MESH["<b>MeshCom 4.0 Multi-Hop Mesh</b><br/>Bis zu 4 Hops (Autarker Off-Grid-Chat)<br/>Gateways: OE5XYZ, OE1KBC, OE3XOC"]
    end

    subgraph Backbone["Backbone, Server & Visualisierung"]
        direction TB
        HAMNET["<b>HAMNET Backbone</b><br/>(13cm / 6cm Richtfunk-Ringe)"]
        APRS_IS["<b>APRS-IS Weltnetz</b><br/>Visualisierung: <i>aprs.fi</i>"]
        MC_SRV["<b>ÖVSV MeshCom Server-Cluster</b><br/>Dashboard: <i>meshcom.oevsv.at</i><br/>Heatmaps (DK5EN): <i>meshmap.oevsv.at</i>"]
    end

    A1 -->|"FM UI-Frame"| IG_2M
    D1 -->|"TDMA Data Burst"| DMR_REP
    L1 -->|"Dynamischer Track-Hop"| IG_LORA
    M1 <-->|"Statische POS (30/60 Min.),<br/>WX, Chat, DM & ACK"| MC_MESH
    M1 -.->|"Automatische Frequenz-Bifurkation<br/>bei Bewegung (--track on)"| L1

    IG_2M --> HAMNET
    DMR_REP --> HAMNET
    IG_LORA --> HAMNET
    MC_MESH -->|"UDP JSON Stream"| HAMNET

    HAMNET --> APRS_IS
    HAMNET --> MC_SRV
    MC_SRV -.->|"Optionaler APRS-IS Export"| APRS_IS
~~~

Ein tiefgehender Systemvergleich offenbart gravierende kausale Zusammenhänge zwischen Modulationsart, Link-Budget, Kanalzugriffsökonomie und Ausfallsicherheit, die in der nachfolgenden Gegenüberstellung strukturiert sind:

| Systemparameter | Analoges APRS (Classic) | Digitales DMR-APRS | LoRa-APRS (Tracking) | MeshCom 4.0 (Off-Grid & Mesh) |
| :--- | :--- | :--- | :--- | :--- |
| **Primärfrequenz (Europa)** | `144,800 MHz` (2m-Band) **[7, 8]** | 70cm / 2m DMR-Relais-QRG **[11, 17]** | `433,775 MHz` (70cm-Band) **[7, 15, 16]** | `433,175 MHz` (70cm-Band) **[13, 14, 15, 16]** |
| **Modulation & Codierung** | AFSK Bell 202 (1.200 Bd), AX.25 UI **[3, 7]** | 4FSK TDMA (`7K60FXD` / `7K60FXW`) **[2, 9]** | LoRa CSS (typ. SF 12, BW 125 kHz) **[16]** | LoRa CSS (SF 11, BW 250 kHz, CR 4/6) **[13, 15]** |
| **Kanalbandbreite** | 12,5 kHz / 25 kHz (FM) **[2, 9]** | 12,5 kHz (2 Zeitschlitze) **[2, 9]** | 125 kHz **[16]** | 250 kHz (EU-Standard) **[13, 15, 16]** |
| **Dekodierschwelle (SNR / BER)** | Positives SNR erforderlich ($+10$ bis $+14\text{ dB}$) | $0{,}22\text{ }\mu\text{V}$ bei $5\text{ \%}$ BER (Digital Cliff) **[9]** | Tief im negativen SNR (ca. $-20\text{ dB}$) | Negatives SNR (bis ca. $-17{,}5\text{ dB}$) **[1, 13]** |
| **Typische Sendeleistung** | 1 W bis 10 W (Handfunk) **[2, 19]** | 1 W bis 10 W (Handfunk) **[2, 19]** | 0,1 W (20 dBm) bis 1 W (30 dBm) **[13]** | 0,1 W bis 2 W (mit externer PA) **[13]** |
| **Netzwerktopologie** | Store-and-Forward Digipeater (`WIDE1-1,WIDE2-1`) **[3, 7]** | Sternförmig über lokalen DMR-Repeater/Hotspot **[6, 11]** | Single-Hop oder Digipeating zu LoRa-iGate **[7, 20]** | Selbstheilendes Multi-Hop-Mesh (bis 4 Hops) + Gateways **[1, 14]** |
| **Off-Grid-Fähigkeit (ohne Infrastruktur)** | Hoch (Direktdekodierung bei Geräten mit TNC) **[3, 21]** | Gering (ohne DMR-Repeater keine Kartenanzeige) **[6, 11]** | Mittel (primär als Telemetrie-/Tracker-Zulauf) **[14]** | Exzellent (autarker Chat, Ack, POS, Telemetrie) **[1, 13, 22]** |

Die physikalische Überlegenheit der LoRa-Modulation im Schwachsignalbereich resultiert aus der Vorwärtsfehlerkorrektur (Forward Error Correction, CR 4/6) in Verbindung mit der Chirp-Spreizung (SF 11) **[13, 15]**. Während ein klassisches 1.200-Baud-AFSK-Paket auf `144,800 MHz` über keinerlei Fehlerkorrektur verfügt und bereits ein einziges durch Mehrwegeausbreitung (Multipath Fading) gekipptes Bit die Prüfsumme (FCS) des gesamten AX.25-Rahmens entwertet **[3]**, rekonstruiert ein LoRa-Empfänger Signale deutlich unterhalb des thermischen Rauschflur-Niveaus **[1, 13]**.

Im Gegenzug entsteht bei LoRa-basierten Netzen ein fundamentales Dilemma hinsichtlich der Kanalbelegungszeit (Time-on-Air). Da MeshCom 4.0 in der europäischen Standardkonfiguration (`Country-ID 1`) eine 32 Byte lange Präambel mit SF 11 kombiniert **[15]**, benötigt jedes Datenpaket ein Vielfaches der Sendezeit eines kurzen 1.200-Baud-FM-Bursts. Um einen Kollisionskollaps auf der Gemeinschaftsfrequenz `433,175 MHz` zu verhindern, haben die Entwickler des Institute of Citizen Science for Space and Wireless Communication (ICSSW) und des Österreichischen Versuchssenderverbandes (ÖVSV) eine architektonische **Frequenz-Bifurkation** implementiert **[1, 14, 15]**:
* Stationäre Positionsmeldungen, Wetterdaten und Textnachrichten mit bis zu vier zulässigen Weiterleitungs-Sprüngen (Hop-Counter) verbleiben im breitbandigen Mesh-Netz auf `433,175 MHz` **[1, 14]**.
* Sobald ein Knoten jedoch in den mobilen Tracking-Modus (`--track on`) versetzt wird, schaltet die Firmware den Transceiver für jede dynamische Positionsaussendung automatisch auf die europäische LoRa-APRS-Frequenz `433,775 MHz` um **[14, 15, 23]**. Dadurch wird der hochfrequente Bewegungsdatenstrom (SmartBeaconing) auf die dedizierte Tracker-Frequenz ausgelagert, während das MeshCom-Kommunikationsnetz auf `433,175 MHz` für den Notfunk- und Nachrichtenverkehr entlastet bleibt **[14, 22]**.

---

## 2. Rechtliche Rahmenbedingungen und Betriebsbedingungen in Österreich und Europa

Der Betrieb von APRS- und LoRa-Mesh-Systemen auf Amateurfunkfrequenzen bewegt sich im Spannungsfeld zwischen nationalem Telekommunikationsrecht, den Lizenzklassen-Privilegien der CEPT und den subregionalen Bandplänen der IARU Region 1 **[16, 24, 25]**.

### Nationale Gesetzgebung in Österreich (TKG, AFV und FNV Anlage 4)

In Österreich bilden das Telekommunikationsgesetz (TKG, in der mit den Verbesserungen für den Not- und Katastrophenfunk sowie unbefristeten Bewilligungen beschlossenen Fassung **[24, 26]**) sowie die Amateurfunkverordnung (AFV) und die Frequenznutzungsverordnung (FNV, deren Anlage 4 die frühere Anlage 2 der AFV ersetzt hat **[24, 27]**) das verbindliche Rechtsfundament:

1. **Bewilligungsklassen, Leistungsgrenzen und Selbstbau-Privileg:**
   * Inhaber der **Bewilligungsklasse 1 (CEPT-Lizenz)** dürfen im 2-m- und 70-cm-Band regulär mit bis zu 200 W Ausgangsleistung arbeiten (beziehungsweise bis zu 1 kW bei EME- und Meteor-Scatter-Betrieb unter Verwendung von Yagi-Antennen mit mindestens 15 dBd Gewinn) und genießen das uneingeschränkte Selbstbaurecht **[24, 27, 28]**.
   * Inhaber der **Bewilligungsklasse 4 (CEPT-Novice)** sowie der nationalen Einsteigerklasse (**Bewilligungsklasse 3**) verfügen auf 2 m und 70 cm zwar ebenfalls über ein Leistungslimit von bis zu 100 W, unterliegen jedoch gemäß FNV und AFV der strikten technischen Auflage, dass ausschließlich unmodifizierte, kommerzielle Sendeanlagen erlaubt sind **[24, 27, 29]**.
   * **Konsequenz für das Hardware-Portfolio:** Während der Betrieb kommerzieller, zertifizierter Handfunkgeräte wie des Anytone AT-D878UV oder des Baofeng DM-32 in den Klassen 3 und 4 uneingeschränkt zulässig ist, fällt die Modifikation ungekapselter Mikrocontroller-Entwicklerplatinen der Lilygo-T-Beam-Serie oder das Einschleifen externer HF-Leistungsverstärker-Module wie des 2-Watt-Verstärkers AB-OT 433 **[13]** rechtlich unter den Selbstbau beziehungsweise die Anlagenmodifikation und setzt somit zwingend die Bewilligungsklasse 1 voraus **[24, 28, 29]**.

2. **Rechtsstatus im ISM-Segment des 70-cm-Bandes (433,05–434,79 MHz):**
   * Sowohl die MeshCom-Frequenz (`433,175 MHz`) als auch LoRa-APRS (`433,775 MHz`) und Meshtastic (`434,100 MHz`) liegen innerhalb dieses Teilbereichs, der im österreichischen Frequenzbandplan doppelt zugewiesen ist: primär dem Amateurfunkdienst, jedoch gleichzeitig als ISM-Bereich (Industrial, Scientific and Medical) **[13, 16, 24]**.
   * Lizenzfreie Jedermann-Funkanwendungen (SRD) sind in diesem Segment strengen Begrenzungen bei Sendeleistung (typisch 10 mW ERP) und Duty-Cycle unterworfen, was bei mehrstufigen Mesh-Netzen schnell zu betrieblichen Engpässen führt **[13, 30]**.
   * Da MeshCom 4.0 jedoch konsequent als Amateurfunk-System konzipiert wurde, bei dem jeder Knoten zwingend mit einem offiziellen Amateurfunkrufzeichen samt numerischer SSID (beispielsweise `DK5EN-1` oder `DK5EN-12`) im APRS-Protokollheader sendet und auf jegliche Datenverschlüsselung verzichtet wird **[1, 13, 23]**, operiert die Funkstelle unter den Privilegien des Amateurfunkdienstes **[13, 24]**. Damit sind höhere Sendeleistungen wie 1 W beim Lilygo T-Beam 1W oder 2 W mit externer Endstufe im Rahmen der AFV vollkommen legal, sofern das Gebot der geringsten notwendigen Leistung gemäß Fußnote 10 des IARU-Bandplans beachtet wird **[13, 16, 24]**.

3. **Unbeaufsichtigte automatische Stationen vs. persönliche Endgeräte-Nodes:**
   * Für permanent sendende, unbeaufsichtigte Digipeater und Standorte des Relaisfunkdienstes (erkennbar am Buchstaben `X` an erster Stelle des Suffixes in Österreich, wie bei `OE5XOL`, `OE5XLL` oder `OE7XOT`) ist eine behördliche Bewilligung erforderlich **[7, 17, 20, 24, 32]**.
   * Persönliche MeshCom-Nodes und Heimgateways werden hingegen unter dem individuellen Rufzeichen mit SSID (von `-1` bis `-99`) als reguläre Amateurfunkstellen betrieben **[15, 23, 31, 32]**.

### Betriebsbedingungen im europäischen Ausland (CEPT & IARU-Region-1-Bandplan)

Bei Auslandsreisen innerhalb Europas auf Basis der CEPT-Empfehlung T/R 61-01 **[25]** ist beim 2-m-Analog-APRS auf `144,800 MHz` eine europaweit homogene Nutzung gegeben. Im 70-cm-Band (430–440 MHz) hingegen weist der aktuelle UHF-Bandplan der IARU Region 1 (Stand Mai 2025) zwar `433,175 MHz` explizit für MeshCom mit 250 kHz Bandbreite und `433,775 MHz` für LoRa-APRS mit 125 kHz Bandbreite aus, mahnt jedoch in Fußnote 10 ausdrücklich zur Beachtung der abweichenden Nutzung in Nachbarländern sowie zur strikten Einhaltung der Bereichsgrenzen von 433 und 435 MHz **[16]**.

### Grafik 2: Europäische MeshCom-Länderprofile (`Country-ID`) & CEPT-Regulatorik

~~~mermaid
flowchart LR
    subgraph Regulatorik_AT["Österreich: TKG, AFV & FNV Anlage 4"]
        direction TB
        KL1["<b>Bewilligungsklasse 1 (CEPT)</b><br/>Bis 200 W (2m/70cm)<br/>Uneingeschränktes Selbstbaurecht<br/><i>Lilygo-Platinen & PA-Modifikation erlaubt</i>"]
        KL34["<b>Bewilligungsklasse 4 (Novice) & 3</b><br/>Bis 100 W (2m/70cm)<br/>Nur unmodifizierte kommerzielle Geräte<br/><i>Anytone 878 & Baofeng DM-32 erlaubt</i>"]
    end

    subgraph Country_IDs["MeshCom 4.0 Länderprofile (Umschaltung bei Grenzübertritt)"]
        direction TB
        CID1["<b>Country-ID 1 & ID 9 (EU / D-A-CH-IT)</b><br/>AT, DE, CH, IT<br/>Mesh: 433,175 MHz | BW 250 kHz | SF 11 | CR 4/6<br/>Präambel: 32 Byte (ID 1) bzw. 8 Byte (ID 9)<br/>Track: 433,775 MHz"]
        CID3["<b>Country-ID 3 (Belgien)</b><br/>Mesh: 433,175 MHz | BW 250 kHz<br/>SF 10 | CR 4/6 | Präambel: 8 Byte<br/>Track: 433,775 MHz"]
        CID5["<b>Country-ID 5 (Norwegen)</b><br/>433,175 MHz (250 kHz) untersagt!<br/>Mesh: 433,925 MHz | BW 125 kHz<br/>SF 10 | CR 4/6 | Präambel: 8 Byte<br/>Track: 433,775 MHz"]
        CID2["<b>Country-ID 2 & ID 10 (Großbritannien / UK)</b><br/>Unteres 70cm-Segment geschützt!<br/>Mesh: 439,9125 MHz | BW 125 kHz<br/>SF 10 | CR 4/6 | Präambel: 8 Byte<br/>Track: 433,775 MHz"]
        CID_OTHER["<b>Sonder- & Übersee-Profile</b><br/>ID 6: 869,525 MHz (EU ISM, Track aus)<br/>ID 7: 906,875 MHz (US ISM, Track aus)<br/>ID 11: 433,175 MHz (Nordamerika, 8B)<br/>ID 12: 435,775 MHz (Hongkong)<br/>ID 13: 435,750 MHz (SAT1)"]
    end

    Regulatorik_AT -->|"CEPT T/R 61-01<br/>Auslandsbetrieb"| Country_IDs
~~~

Da nationale Fernmeldeverwaltungen in Teilen Europas im Segment um 433 MHz keine 250 kHz breiten Aussendungen dulden oder abweichende Primärnutzer schützen, verfügt die MeshCom-4.0-Firmware über fest einprogrammierte Länderprofile (`Country-ID`), die bei Grenzübertritt über die Konsole oder App umgeschaltet werden müssen **[15]**:

| Country-ID | Region / Land | MeshCom-QRG | Bandbreite | SF / CR | Präambel | Track-QRG (LoRa-APRS) | Regulatorische Besonderheit |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **ID 1 (`EU`)** | **AT, DE, CH, IT (Europa Std.)** | `433,175 MHz` | 250 kHz | SF 11 / CR 4/6 | 32 Byte | `433,775 MHz` | Europäisches Standardprofil (D-A-CH-IT) **[15, 31, 33]** |
| **ID 9 (`EU8`)** | **Europa (Kurz-Präambel)** | `433,175 MHz` | 250 kHz | SF 11 / CR 4/6 | 8 Byte | `433,775 MHz` | Reduzierte Time-on-Air durch 8-Byte-Präambel **[15]** |
| **ID 3 (`ON`)** | **Belgien** | `433,175 MHz` | 250 kHz | SF 10 / CR 4/6 | 8 Byte | `433,775 MHz` | Pflicht zur kürzeren Sendezeit (SF 10 + 8 Byte) **[15]** |
| **ID 5 (`LA`)** | **Norwegen** | `433,925 MHz` | 125 kHz | SF 10 / CR 4/6 | 8 Byte | `433,775 MHz` | 250 kHz auf 433,175 MHz untersagt; Wechsel auf 433,925 MHz **[15]** |
| **ID 2 / ID 10 (`UK`)** | **Großbritannien (UK)** | `439,9125 MHz` | 125 kHz | SF 10 / CR 4/6 | 8 Byte | `433,775 MHz` | Schutz des unteren 70cm-Segments; Wechsel ins obere Band **[15]** |
| **ID 6 (`868`)** | **EU ISM 868 MHz** | `869,525 MHz` | 250 kHz | SF 11 / CR 4/6 | 32 Byte | `999,000 MHz` (Aus) | Experimentelles EU-ISM-Profil ohne LoRa-APRS-Track **[15]** |
| **ID 7 (`915`)** | **Nordamerika ISM 915** | `906,875 MHz` | 250 kHz | SF 11 / CR 4/6 | 32 Byte | `999,000 MHz` (Aus) | ITU-Region-2-ISM-Profil **[15]** |
| **ID 11 (`US`)** | **Nordamerika 70cm** | `433,175 MHz` | 250 kHz | SF 11 / CR 4/6 | 8 Byte | `433,775 MHz` | 70cm-Profil Nordamerika mit 8-Byte-Präambel **[15]** |
| **ID 12 (`VR2`)** | **Hongkong** | `435,775 MHz` | 250 kHz | SF 11 / CR 4/6 | 8 Byte | `433,775 MHz` | Asien-Anpassung oberhalb von 435 MHz **[15]** |
| **ID 13 (`SAT1`)** | **Satellitenbetrieb** | `435,750 MHz` | 250 kHz | SF 10 / CR 4/6 | 8 Byte | `433,775 MHz` | Spezielles Uplink/Downlink-Satellitenprofil **[15]** |

---

## 3. Infrastruktur und empfangende Stationen in Österreich

Die Empfangsinfrastruktur für APRS und MeshCom in Österreich zeichnet sich durch eine europaweit führende Dichte und eine hochgradig redundante Vernetzung über das **HAMNET** (Highspeed Amateurradio Multimedia Network im 13-cm- und 6-cm-Band) aus **[1, 7, 17, 22]**. Während klassische 2-m-AFSK-Pakete und 70-cm-LoRa-APRS-Baken direkt an das globale APRS-IS-Netzwerk (`aprs.fi`) weitergeleitet werden **[7, 8]**, speisen die MeshCom-4.0-Gateways ihre empfangenen Pakete – bestehend aus Textmeldungen, Telemetrie, Geo-Positionen sowie Pfad-Informationen samt RSSI- und SNR-Signalstärken – als JSON-formatierte UDP-Datensätze an die zentralen MeshCom-Server **[1, 14]**.

Auf dem zentralen ÖVSV-Dashboard (`meshcom.oevsv.at`) sind bereits **1.182 registrierte Nodes** sowie **497 Gateways** (davon 489 permanent online, was einer Verfügbarkeitsquote von über $98{,}3\text{ \%}$ entspricht) verzeichnet **[31]**. Zusätzlich hat **Martin (DK5EN)** mit der Plattform `meshmap.oevsv.at` ein analytisches Visualisierungswerkzeug geschaffen, das über eine per Login geschützte Server-Schnittstelle nicht nur Live-Positionen und den Online-Status der MeshCom-Server abbildet, sondern aus den übermittelten Telemetriebaken normierte meteorologische Temperatur- und Luftdruck-Heatmaps berechnet, wobei der Luftdruck präzise nach GPS-Höhe gemäß APRS-Protokoll statt nach reiner WGS84-Ellipsoidhöhe ausgewertet wird **[5]**.

### Übersicht zentraler Empfangsstationen, Digipeater und Gateways in Österreich

Für den praktischen Funkbetrieb – insbesondere mit Fokus auf den oberösterreichischen Zentralraum (OE5) sowie die angrenzenden Bundesländer – bildet die folgende Übersicht die wichtigsten multimodalen Knotenpunkte ab:

| Rufzeichen & SSID | Standort / QTH (Locator) | Betriebsart / System | Empfangs- / Sendefrequenz | Technische Ausstattung & Backbone-Anbindung |
| :--- | :--- | :--- | :--- | :--- |
| **OE5XOL-10** | Kirchschlag b. Linz – Breitenstein (ADL 514) | Analoges APRS (Digi & iGate) | **`144,800 MHz`** (RX/TX, 1.200 Bd AFSK) | Kenwood TK-759, TNC2 APRS4R, Kathrein VPol Omni K 55 29 21; HAMNET via OE5XLL **[7, 36]**. |
| **OE5XOL-11** | Kirchschlag b. Linz – Breitenstein (ADL 514) | LoRa-APRS (Digi & iGate) | **RX: `433,775 MHz`** / TX: `433,900 MHz` | Kathrein VPol Omni K 75 29 21; primärer LoRa-Tracker-Empfänger für den Raum Linz/Mühlviertel **[7, 34, 36]**. |
| **OE5XLL** | Linz – Lichtenberg / Giselawarte, 927 m (`JN78DJ`, ADL 516) | DMR-APRS / DMR Tier II, FM & HAMNET-Hub | **70cm DMR** (sowie `145,600 MHz` & `438,650 MHz` FM) | Zentraler OE5-HAMNET-Backbone (Links zu OE5XBR, OE5XOL, OE5XDO, DB0WGS); DMR-APRS-Einstieg für Anytone/Baofeng **[17, 35, 36]**. |
| **OE5XYZ / -10** | Linz – Stadt (devlol) | Analog-APRS iGate (`-10`) & **MeshCom Gateway** | **`144,800 MHz`** (2m) & **`433,175 MHz`** (LoRa MeshCom) | 13cm HAMNET Mikrotik QRT 2 Link via OE5XLL; direkte Weiterleitung an MeshCom-Server und `aprs.fi` **[37]**. |
| **OE5XBR** | Linz – Froschberg | HAMNET-Knoten & 70cm Datenfunk | 70cm Daten / HAMNET-Link zu OE5XLL | Stützt die innerstädtische Versorgung im Großraum Linz **[17, 36]**. |
| **OE1XBA** | Wien – Laaerberg Hochhaus | Analoges APRS (2m Digi/iGate) | **`144,800 MHz`** (RX/TX) | Weitreichender Höhenstandort für das Wiener Becken **[8]**. |
| **OE1KBC / OE1KFR** | Wien (ÖVSV / ICSSW Zentrale) | MeshCom 4.0 Core-Gateways & Zeitzeichen | **`433,175 MHz`** (MeshCom) / HAMNET | Zentrale Referenzknoten; Wien generiert zudem das zentrale Zeitsignal-Paket für das MeshCom-Netz **[1, 4, 31]**. |
| **OE3XRB / OE3XWJ / OE3XOC** | Niederösterreich (u.a. Jauerling, Buchberg, `JN78VD` 654 m) | HAMNET-Backbone & MeshCom 4.0 Digipeater | **`433,175 MHz`** (MeshCom) / HAMNET | Verbinden den oberösterreichischen Cluster (OE5XOL) über Richtfunkstrecken mit Ostösterreich **[7, 38, 39]**. |
| **OE6XAG** | Graz – Schöckl (`JN77RE`) | Relais- & Daten-Knoten Steiermark | VHF/UHF Relais & HAMNET-Backbone | Exponierter Alpensüdost-Standort mit großem Einzugsgebiet **[40]**. |
| **OE7XOT** | Obtarrenz, Tirol | LoRa-APRS Digipeater (`APRS/-12`) | **`433,775 MHz`** (70cm LoRa) | Alpiner LoRa-APRS-Umsetzer für Westösterreich **[20]**. |

Für den praktischen Betrieb im Raum Oberösterreich (OE5) ergibt sich daraus eine komplementäre Aufgabenteilung der Höhenstandorte: Während `OE5XOL` am Breitenstein in Kirchschlag sowohl das klassische 2-m-AFSK-APRS (`OE5XOL-10` auf `144,800 MHz`) als auch das 70-cm-LoRa-APRS (`OE5XOL-11` auf `433,775 MHz` RX / `433,900 MHz` TX) über leistungsstarke vertikale Kathrein-Rundstrahlantennen abdeckt **[7, 34]**, fungiert `OE5XLL` auf der Giselawarte am Lichtenberg (927 m Seehöhe) als primärer DMR-Repeater für DMR-APRS-Aussendungen sowie als zentraler HAMNET-Richtfunk-Verteiler **[17, 35]**. Für MeshCom 4.0 auf `433,175 MHz` steht neben `OE5XYZ` in Linz **[37]** eine dichte Wolke aus lokalen Gateways und Nodes – unter anderem im Raum Linz und Wels (ADL 512 / ADL 502) **[41, 42]** – zur Verfügung.

---

## 4. Technische Evaluation und Gegenüberstellung des Hardware-Portfolios

Das untersuchte Geräte-Portfolio umfasst sieben Systeme, die sich in zwei technologische Hauptgruppen unterteilen: vier ESP32-basierte LoRa-MeshCom-4.0-Endgeräte der Marke Lilygo, die alle mit der aktuellen Firmware von Martin (DK5EN) in der Version **v4.40a** betrieben werden **[1, 4, 43]**, sowie drei VHF/UHF-Dualband-Handfunkgeräte für DMR und Analog-FM (Anytone AT-D878UV Plus, Anytone AT-D878UVII Plus und Baofeng DM-32) **[2, 21, 50]**.

### Das DK5EN-Firmware-Ökosystem (Version v4.40a & McApp)

Ein entscheidendes Qualitätsmerkmal der vier Lilygo-Geräte im vorliegenden Setup ist der Einsatz des Firmware-Zweigs von **Martin (DK5EN, früheres oberösterreichisches Rufzeichen OE5ODO)**, der als IT-Architekt maßgeblich an der Weiterentwicklung von MeshCom 4.0 beteiligt ist **[4, 43, 44, 45, 46]**. Die aktuelle Version **v4.40a** (im offiziellen Repository als `neo: firmware-only delta of the DK5EN fork, version 4.40a` geführt **[43]**) sowie das zugehörige **McApp**-Backend **[4, 44]** lösen mehrere fundamentale Probleme früherer Firmware-Generationen:
* **Vollautomatische Sommer-/Winterzeitumstellung & GPS-Zeit-Priorisierung:** Während ältere MeshCom-Versionen bei jedem Wechsel zwischen Sommer- und Winterzeit eine manuelle Anpassung des UTC-Offsets über die App oder das serielle Kommando `--utcoffset 2.0` (MESZ) beziehungsweise `--utcoffset 1.0` (MEZ) verlangten **[15, 23]**, führt die v4.40a von DK5EN die Zeitumstellung vollautomatisch durch **[43]**. Sobald ein GPS-Satelliten-Fix vorliegt, wird die präzise GPS-Zeit unmittelbar übernommen und nicht mehr durch die alle 5 Minuten laufende Server-Zeitsynchronisation überschrieben **[43]**.
* **Strikte APRS- und UTF-8-Protokollfilterung & Quarantäne-Gruppe `9999`:** Da es im praktischen Feldbetrieb regelmäßig zu Abstürzen oder Datenmüll durch fehlsendende E22-LoRa-Module oder ungültige Sonderzeichen kam, prüft die Software nun jedes Paket auf Protokollkonformität: Korrupte Binärpakete werden hart verworfen, im APRS-Protokoll unzulässige Zeilenumbrüche (Newlines) werden beim Senden durch die Enter-Taste abgefangen, und erkannte Spam- oder Fehlpakete werden automatisch in die Quarantäne-Gruppe `9999` umgeleitet, um die reguläre Chat-Ansicht sauber zu halten **[4]**.
* **McApp-Anbindung (BLE Keep-Alive, UDP & Drei-Slot-OTA):** Über die externe UDP-Schnittstelle (`--extudpip 192...` und `--extudp on`) **[15]** oder bevorzugt über eine überwachte Bluetooth-Low-Energy-Verbindung (BLE mit automatischem Keep-Alive und Reconnect) lassen sich die Lilygo-Nodes an das ressourcenschonende Python-Backend der McApp auf einem Raspberry Pi Zero 2W anbinden **[4, 44]**. Das als Vue.js 3 Progressive Web App (PWA) ausgeführte Frontend unterstützt automatische OTA-Updates über ein fehlertolerantes Drei-Slot-System auf Port `2985`, überwacht das zentrale Wiener Zeitsignal-Paket mittels Watchdog und liefert bei aktiver BLE-Kopplung detaillierte MHeard-Statistiken inklusive RSSI- und SNR-Signalqualität sowie eine grafische Hervorhebung des konkreten Relay-Pfades auf der Karte **[4, 44]**.

### Detailanalyse der vier Lilygo MeshCom-4.0-Geräte

Obwohl auf allen vier Lilygo-Systemen dieselbe Firmware-Logik (v4.40a) arbeitet, unterscheiden sich die Geräte in ihrer Hardware-Architektur, der Sendeendstufe und ihrem Einsatzzweck erheblich **[13, 23]**:

1. **Lilygo T-Beam AXP-2101:**
   Bildet die bewährte Referenzplattform mit klassischem ESP32-Mikrocontroller, 18650-Lithium-Ionen-Akkuhalterung und dem modernen Power-Management-Chip AXP2101 **[13, 23]**. Die Sendeleistung des Standard-LoRa-Moduls liegt im Milliwatt-Bereich (ca. 0,1 W / 20 dBm), weshalb die mitgelieferte Behelfsantenne zwingend gegen eine resonante 70-cm-Handfunkgeräteantenne oder eine stationäre Außenantenne auszutauschen ist **[13]**. In Regionen mit geringer Node-Dichte lässt sich dieses Board ideal mit einem externen **AB-OT 433 Verstärker** – der rund 2 W Sendeleistung sowie einen rauscharmen Empfangsvorverstärker liefert – und einem 2-Ah-LiFePO4-Pufferakku für über 24 Stunden Notfunk-Autarkie zu einem hochgradig stabilen Heimgateway oder Relais-Knoten ausbauen **[13]**.
2. **Lilygo T-Beam Supreme:**
   Baut auf einem moderneren Systemdesign mit integriertem Multi-GNSS-Empfänger und AXP2101-Power-Management auf und ist für komplexe Sensor- und Telemetrieaufgaben prädestiniert **[15, 23, 47]**. Über den I2C-Bus (abfragbar per `Scan I2C` in der App **[23]**) lassen sich Umweltsensoren wie BME280, BMP280, BME680 oder MCU-811 nahtlos aktivieren (`--bme on`, `--bmp on`, `--680 on`, `--811 on`), um neben präzisen GPS-Tracks periodische APRS-Wetterbaken (`--wx`) für die ÖVSV-MeshMap (`meshmap.oevsv.at`) zu generieren **[5, 15, 47]**.
3. **Lilygo T-Beam 1W:**
   Integriert eine dedizierte **1-Watt-HF-Endstufe (30 dBm)** direkt auf der Platine **[23]**. Dieser Leistungszuwachs ($+10\text{ dB}$ gegenüber den 100-mW-Modulen) verändert die einsatztaktische Rolle fundamental: Während ein Standard-T-Beam im urbanen Umfeld oder in abgeschatteten Tälern auf benachbarte Nodes angewiesen ist, erreicht der T-Beam 1W exponierte LoRa-iGates wie `OE5XOL-11` am Breitenstein oder entfernte Berg-Digipeater oft direkt im ersten Hop **[7, 13]**. Sobald sich jedoch mehrere Nodes in unmittelbarer Nachbarschaft hören können, gebietet die Netzwerk-Disziplin eine Reduzierung der Sendeleistung, um Empfängerübersteuerungen zu vermeiden **[13, 16]**.
4. **Lilygo T-Deck Plus:**
   Während die drei T-Beam-Varianten primär über ein kleines OLED-Statusdisplay verfügen und zum komfortablen Lesen oder Verfassen von Textnachrichten ein per Bluetooth gekoppeltes Smartphone (Standard-MeshCom-App mit Standard-PIN `000000` **[23]** oder DK5ENs McApp **[4]**) beziehungsweise eine serielle USB-Konsole benötigen, stellt das Lilygo T-Deck Plus ein vollintegriertes Standalone-Terminal dar **[1, 23]**. Mit integriertem Farbdisplay, physischer Tastatur, internem GPS und geschlossenem Gehäuse ermöglicht es völlig autarken Off-Grid-Chat- und APRS-Betrieb im Feldeinsatz, ohne dass ein externes Endgerät mitgeführt werden muss **[1, 23]**.

### Detailanalyse der drei VHF/UHF-Handfunkgeräte (Anytone & Baofeng)

Bei den drei kommerziellen DMR/FM-Handfunkgeräten offenbart die technische Untersuchung gravierende Unterschiede in der tatsächlichen APRS-Implementierung **[2, 3, 6, 21, 50]**:

1. **Anytone AT-D878UV Plus (Generation 1):**
   Ein Dualband-DMR- (Tier I & II) und FM-Handfunkgerät mit integriertem GPS und Bluetooth, das sowohl echtes analoges APRS (1.200 Baud AFSK auf `144,800 MHz`) als auch digitales DMR-APRS über BrandMeister- oder DMR+-Relais beherrscht **[21, 49, 50]**. Der entscheidende Engpass dieser ersten Generation besteht darin, dass das Gerät zwar einen AFSK-Modulator zum Senden besitzt, jedoch über **keinen Hardware-Demodulator für analoges APRS** verfügt **[21, 50]**. Es arbeitet auf `144,800 MHz` somit als reiner APRS-Sender (**TX-only**) und kann eingehende analoge Pakete anderer Stationen nicht dekodieren **[21, 50]**.
2. **Anytone AT-D878UVII Plus (Generation 2):**
   Behebt genau dieses Defizit durch eine erweiterte Hauptplatine mit vollwertigem analogen APRS-Empfänger und -Decoder (**APRS RX & TX**) **[3, 21]**. Damit fungiert das AT-D878UVII Plus als komplettes 2-m-APRS-Terminal: Es sendet eigene Positionsbaken – wahlweise unkomprimiert im Format `DDMM.mmN/DDDMM.mmW` oder Base-91-komprimiert inklusive Kurs, Geschwindigkeit und Höhe `/A=` **[3]** – und dekodiert gleichzeitig alle auf `144,800 MHz` gehörten Nachbarstationen auf dem Display **[3, 21]**. Darüber hinaus unterstützt die Plattform den bidirektionalen Versand und Empfang von analogen APRS-Textnachrichten bis 67 Zeichen im Format `:ADDRESSEE:text{NN` inklusive automatischer Quittungs-Wiederholung (`ackNN`) nach 30, 60 und 120 Sekunden bei bis zu drei Sendeversuchen **[3]**.
3. **Baofeng DM-32 (bzw. DM-32UV):**
   Das Baofeng DM-32 (bzw. die baugleiche Bezeichnung DM-32UV, während das UV-32 eine reine Analog-FM-Variante ohne DMR darstellt **[52]**) ist ein Dualband-DMR-Handfunkgerät nach ETSI TS 102 361-1, -2 und -3 mit AMBE+2 Vocoder, bis zu 8 W (DM-32) bzw. 10 W (DM-32UV) Sendeleistung, 4.000 Kanälen, 250 Zonen, bis zu 150.000 digitalen Kontakten ab Firmware v1.47, einem 2-Zoll-LCD-Farbdisplay, 10 Stunden digitaler Sprachaufzeichnung, einem mit Schlitzschraubendreher gesicherten 2.500-mAh-Akku samt direktem USB-C-Ladeanschluss und einem Flugfunk-AM-Empfänger für 108–136 MHz **[2, 9, 12, 19, 51, 52]**. Der integrierte kombinierte **GPS- und Beidou-Satellitenempfänger** überzeugt durch schnelle Ortungszeiten von unter 10 Sekunden beim Warmstart und unter 1 Minute beim Kaltstart sowie eine hohe Positionsgenauigkeit **[2, 18]**.
   * **Kritische APRS-Einschränkung beim Baofeng DM-32:** Trotz der offensiven Herstellerbewerbung mit dem Merkmal „GPS & APRS“ besitzt das Baofeng DM-32 **keinen analogen 1.200-Baud-AFSK-Modulator oder -Demodulator** und kann **kein natives analoges APRS auf `144,800 MHz`** erzeugen oder empfangen **[6]**. Die eingebaute APRS-Funktion beschränkt sich ausschließlich auf den digitalen DMR-Modus (**DMR-APRS**), bei dem das Gerät seine GPS/Beidou-Koordinaten als 4FSK-Datenpaket an einen eingestellten DMR-Repeater wie `OE5XLL` sendet, der die Position über das BrandMeister-Netz an `aprs.fi` weiterleitet **[6, 11, 17, 18]**. Da das DM-32 zudem über kein Bluetooth-Modul verfügt, lässt sich echtes analoges 2-m-APRS mit diesem Gerät nur über einen externen Hardware-Umweg realisieren, indem ein **AIOC-Interface (All-In-One-Cable)** an die 2-polige Kenwood-Zubehörbuchse (K1-Port) angeschlossen und mit einem Smartphone samt der App **APRSdroid** gekoppelt wird **[6, 9]**. Ergänzend steht für das DM-32 die alternative Amateurfunk-Firmware **OpenGD77** zur Verfügung, die das DMR-Bedienkonzept optimiert, jedoch das Fehlen eines Hardware-AFSK-TNCs nicht verändert **[6, 10]**.

---

## 5. Tiefenanalyse der Sendeintervalle und Möglichkeiten der automatischen Aussendung

Für einen zuverlässigen, netzwerkschonenden und unterbrechungsfreien Tracking- und Telemetriebetrieb ist die exakte Kenntnis der Sendeintervall-Timer, der SmartBeaconing-Algorithmen sowie der gerätespezifischen Firmware-Blockaden von entscheidender Bedeutung **[3, 14, 48, 49, 57]**.

### Grafik 3: Sendeintervalle, SmartBeaconing & Firmware-Steuerlogik im Vergleich

~~~mermaid
flowchart TB
    subgraph Lilygo_Logic["Lilygo T-Beam (AXP2101 / Supreme / 1W) & T-Deck Plus (DK5EN FW v4.40a)"]
        direction TB
        L_START["Node Betriebszustand"] --> L_HEY["<b>Hintergrund-Topologie (HEY)</b><br/>Alle 900 s (15 Min.) auf 433,175 MHz"]
        L_START --> L_MODE{"Tracking-Modus?<br/>(--track on / off)"}
        L_MODE -->|"--track off (Statisch)"| L_STAT["<b>MeshCom-Hauptfrequenz (433,175 MHz)</b><br/>Standard: 1.800 s (30 Min.)<br/>Minimum: 300 s (5 Min.) via --postime<br/>Empfehlung Fix-QTH: 3.600 s (60 Min.)"]
        L_MODE -->|"--track on (Dynamisch)"| L_DYN["<b>Frequenz-Bifurkation -> 433,775 MHz</b><br/>SmartBeaconing nach Speed, Kurs & Distanz<br/>Stillstands-Fallback: automatisch auf 1.800 s (30 Min.)"]
        L_START --> L_MAN["<b>Manueller Trigger (--sendpos)</b><br/>Sofort-Aussendung (Hardware-Sperre: min. 15 s)"]
    end

    subgraph Anytone_Logic["Anytone AT-D878UV Plus (Gen 1) & AT-D878UVII Plus (Gen 2)"]
        direction TB
        A_START["CPS / Menü APRS-Timer<br/>(z.B. 120 s / 180 s / 600 s)<br/>oder PTT-Upload"] --> A_CHECK1{"VFO Scan<br/>aktiv?"}
        A_CHECK1 -->|"Ja"| A_BLOCK1["<b>BLOCKIERT!</b><br/>Kein Auto-Timer während Scan<br/>(Nur manueller PTT-Upload möglich)"]
        A_CHECK1 -->|"Nein"| A_CHECK2{"DMR Group/Private<br/>Call Hold Time aktiv?"}
        A_CHECK2 -->|"Timer läuft noch"| A_BLOCK2["<b>BLOCKIERT!</b><br/>Lösung: Group Call Hold Time<br/>in CPS strikt auf 2-5 s begrenzen!"]
        A_CHECK2 -->|"Frei"| A_TX["<b>Automatische Aussendung</b><br/>Hintergrund-Umschaltung auf 144,800 MHz<br/>(Zielrufzeichen zwingend: APAT81)"]
    end

    subgraph Baofeng_Logic["Baofeng DM-32 / DM-32UV (FW v1.47)"]
        direction TB
        B_START["GPS + Beidou Fix (<10 s Warmstart)"] --> B_MODE{"Kanal-Typ?"}
        B_MODE -->|"DMR-Kanal (in Relais-Reichweite)"| B_DMR["<b>Natives DMR-APRS (4FSK TDMA)</b><br/>Zeitgesteuerter Upload via OE5XLL<br/>an BrandMeister -> aprs.fi"]
        B_MODE -->|"Analog-FM (144,800 MHz)"| B_ANA["<b>Kein interner AFSK-TNC!</b><br/>Automatische 2m-Aussendung nur extern<br/>über K1-Port + AIOC-Kabel + APRSdroid"]
    end
~~~

Die folgende Tabelle stellt die sieben untersuchten Endgeräte hinsichtlich ihrer HF-Parameter, der unterstützten APRS- und Mesh-Protokolle sowie der spezifischen Sendeintervall-Steuerung direkt gegenüber:

| Gerätetyp | Max. HF-Leistung | Unterstützte APRS- / Mesh-Modi | Statisches Sendeintervall (Timer) | Dynamische & ereignisgesteuerte Aussendung | Besondere Hardware- & Firmware-Merkmale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Lilygo T-Beam AXP-2101** (DK5EN v4.40a) | ca. 0,1 W (bis 2 W mit AB-OT 433 PA) **[13]** | MeshCom (`433,175 MHz` TX/RX) & LoRa-APRS (`433,775 MHz` TX) **[14, 15]** | Std.: **1.800 s** (30 Min.); Min.: **300 s** (5 Min.); Fix-QTH: **3.600 s** (60 Min.) **[14, 15]** | **SmartBeaconing** (`--track on` auf `433,775 MHz` mit 30-Min.-Ruhe-Fallback); `HEY` alle **900 s**; Manuell min. **15 s** **[14, 23]** | AXP2101 PMU, 18650-Zelle; ideal für Heimgateway oder Raspberry-Pi-McApp-Kopplung (BLE/UDP) **[4, 13, 44]**. |
| **Lilygo T-Beam Supreme** (DK5EN v4.40a) | ca. 0,1 W **[13, 23]** | MeshCom (`433,175 MHz` TX/RX) & LoRa-APRS (`433,775 MHz` TX) **[14, 15]** | Std.: **1.800 s**; Min.: **300 s** (`--postime`); Fix-QTH: **3.600 s** **[14, 15]** | **SmartBeaconing** (Speed, Heading, Distanz); periodische I2C-Wetterbaken (`--bme on`, `--wx`) **[14, 15, 47]** | Präzises GNSS & I2C-Sensorbus für Temperatur/Luftdruck-Heatmaps auf `meshmap.oevsv.at` **[5, 15, 47]**. |
| **Lilygo T-Beam 1W** (DK5EN v4.40a) | **1,0 W** (30 dBm) **[23]** | MeshCom (`433,175 MHz` TX/RX) & LoRa-APRS (`433,775 MHz` TX) **[14, 15]** | Std.: **1.800 s**; Min.: **300 s**; Fix-QTH: **3.600 s** **[14, 15]** | **SmartBeaconing** auf `433,775 MHz` mit automatischer Stillstandserkennung (Fallback auf 1.800 s) **[14, 23]** | $+10\text{ dB}$ Link-Budget-Vorteil für direkten LoRa-iGate-Zugang (z.B. `OE5XOL-11`) im alpinen Gelände **[7, 23]**. |
| **Lilygo T-Deck Plus** (DK5EN v4.40a) | ca. 0,1 W **[23]** | MeshCom (`433,175 MHz` TX/RX) & LoRa-APRS (`433,775 MHz` TX) **[14, 15]** | Std.: **1.800 s**; Min.: **300 s**; Fix-QTH: **3.600 s** **[14, 15]** | **SmartBeaconing** (`--track on`), manuelles `Send POS` (max. alle **15 s**) & direkter Tastatur-Chat **[14, 23]** | Autarkes Handterminal mit Farbdisplay, Tastatur und internem GPS ohne Smartphone-Zwang **[1, 23]**. |
| **Anytone AT-D878UV Plus** (Gen. 1) | ca. 7 W (VHF) / 6 W (UHF) **[50]** | **Analog-APRS TX-only** (`144,800 MHz`) & **DMR-APRS TX** **[21, 50]** | Frei wählbarer CPS-Timer (`Intervals Set`, z.B. **120 s**, **150 s**, **600 s**) **[49, 53]** | **PTT Upload** (Senden bei PTT-Loslassen mit `Manual TX Delay`) **[49]**; SmartBeaconing nur mit Custom-FW **[3, 56]** | Sendet im Hintergrund auf `144,800 MHz` ohne VFO-Verlust **[50]**; **kein analoger APRS-RX-Decoder** **[21]**. |
| **Anytone AT-D878UVII Plus** (Gen. 2) | ca. 7 W (VHF) / 6 W (UHF) **[21]** | **Analog-APRS TX & RX** (`144,800 MHz`) & **DMR-APRS TX/RX** **[3, 21]** | Frei wählbarer CPS-Timer (`Intervals Set`, z.B. **120 s** bis **1.800 s**) **[49, 53]** | **PTT Upload**, automatisches Message-Retry nach **30 s, 60 s, 120 s** **[3, 49]**; SmartBeaconing in Custom-FW **[3]** | Vollwertiger 2m-AFSK-Hardware-Decoder für Live-Positionsanzeige und bidirektionales APRS-Messaging **[3, 21]**. |
| **Baofeng DM-32 / DM-32UV** (FW v1.47) | **8 W** (DM-32) / **10 W** (DM-32UV) **[2, 19, 52]** | **Nur DMR-APRS TX** (4FSK TDMA über DMR-Repeater) **[6, 18]** | Konfigurierbarer Upload-Timer in CPS (nur auf aktiven DMR-Kanälen wirksam) **[6, 18]** | DMR-Positionsupload an Private/Group-ID **[18]**; **Analog-SmartBeaconing nur extern via AIOC + APRSdroid** **[6]** | Schnelles GPS+Beidou ($<10\text{ s}$ Warmstart) **[2]**; **kein eingebautes `144,800-MHz`-Analog-APRS**, kein Bluetooth **[6]**. |

### Sendeintervalle und Automatik-Steuerung der Lilygo-Geräte (MeshCom 4.0 / DK5EN v4.40a)

Die Firmware der vier Lilygo-Einheiten (`T-Beam AXP-2101`, `T-Beam Supreme`, `T-Beam 1W` und `T-Deck Plus`) bietet ein mehrstufiges System für automatische Aussendungen, das über Konsolenbefehle per USB-Seriell oder Webinterface (auch gesammelt per Copy-Paste aus einem Texteditor **[15]**), über die User-Buttons der Smartphone-App oder über das McApp-Backend gesteuert wird **[4, 14, 15, 23]**:

1. **Statischer MeshCom-Positionsbetrieb (`--track off`):**
   * Ohne aktiviertes Tracking sendet jeder Node automatisch alle **1.800 Sekunden (30 Minuten)** ein Positionspaket auf der MeshCom-Hauptfrequenz `433,175 MHz` aus **[14]**.
   * Über den Befehl `--postime 9999` (Angabe in Sekunden) lässt sich dieses Intervall individuell anpassen, wobei die Firmware eine harte Untergrenze von **minimal 300 Sekunden (5 Minuten)** erzwingt **[14, 15]**.
   * **Kanalökonomie & Empfehlung für Fixstationen:** In gut ausgebauten Regionen wie Oberösterreich oder dem Großraum Wien ist ein Herabsetzen von `--postime` auf 300 Sekunden im stationären Betrieb äußerst schädlich für die Kanalökonomie, da jede Positionsmeldung über bis zu vier Hops im gesamten regionalen Mesh wiederholt wird **[1, 14]**. Für einen festen Standort oder ein Heimgateway wird daher ausdrücklich ein Intervall von **`--postime 3600` (60 Minuten)** empfohlen **[14]**. Dies harmoniert präzise mit den Inaktivitäts-Schwellenwerten der ÖVSV-MeshCom-Server, auf denen ein Rufzeichen erst nach 60 Minuten Inaktivität orange unterlegt, nach 120 Minuten (2 Stunden) rot markiert und erst nach 180 Minuten (3 Stunden) aus der aktiven Online-Liste entfernt wird **[14]**.
   * Bei Geräten ohne GPS-Empfang im Gebäude lassen sich feste Koordinaten dauerhaft mittels `--setlat xx.xxxxxx`, `--setlon xxx.xxxxxx` und `--setalt xxxxx` einspeichern **[15]**. Für Reichweitentests kann über den App-Button `SENDPOS` oder das Konsolenkommando `--sendpos` die zuletzt gespeicherte Position sofort ausgesendet werden, wobei zum Schutz vor Kanalflutung eine interne Sperre von **maximal einer Aussendung alle 15 Sekunden** greift **[14, 15, 23]**.

2. **Dynamischer SmartBeaconing-Modus (`--gps on` und `--track on`):**
   * Durch Eingabe von `--gps on` und `--track on` (oder Betätigung des Buttons `Track` in der App) wechselt der Lilygo-Node in den dynamischen SmartBeaconing-Modus **[14, 15, 23, 54]**. Anstelle eines starren Timers berechnet die Firmware das Sendeintervall nun kontinuierlich aus der aktuellen Bewegungsgeschwindigkeit, der zurückgelegten Distanz in Metern zum letzten Sendepunkt sowie der Richtungsänderung (Heading in Grad) **[14, 23]**. Auf dem Display des Geräts werden im Track-Modus das aktuell berechnete Sendeintervall in Sekunden, der Kurs (letzter und aktueller Wert in Grad) sowie die Distanz zum letzten Punkt live angezeigt **[23]**.
   * **Automatische Frequenz-Umschaltung & Ruhe-Fallback:** Sobald `--track on` aktiv ist, schaltet der LoRa-Transceiver für jede Positionsbake automatisch von `433,175 MHz` auf die europäische LoRa-APRS-Frequenz `433,775 MHz` um, sodass die hochfrequenten Spurpunkte direkt von LoRa-APRS-iGates wie `OE5XOL-11` aufgenommen werden, ohne die Text- und Notfunk-Bandbreite auf `433,175 MHz` zu belasten **[7, 14, 23]**. Ein wesentlicher Vorteil für das Energiemanagement der drei T-Beams und des T-Deck Plus ist der intelligente Stillstands-Fallback: Selbst bei aktiviertem `--track on` erkennt die Firmware, wenn das Fahrzeug parkt oder keine Standortveränderung mehr stattfindet, und regelt das Sendeintervall automatisch wieder auf **30 Minuten (1.800 Sekunden)** zurück, bis erneut Bewegung registriert wird **[14, 23]**.
   * Wird bei aktivem `TRACK` der manuelle Button `Send POS` betätigt, prüft die App zunächst den GPS-Fix-Status des Nodes; liegt ein gültiger Satelliten-Fix vor, wird die Position direkt gesendet, andernfalls lässt sich auswählen, ob eine LoRa-APRS-Position (`433,775 MHz`) oder eine MeshCom-Position (`433,175 MHz`) abgesetzt werden soll, während `--sendtrack` gezielt ein einzelnes LoRa-APRS-Paket auslöst **[15, 23, 55]**.

3. **Hintergrund-Topologie (`HEY`), McApp-Sende-Queue und `Test`-Filter:**
   * Unabhängig vom Positionsintervall sendet jeder MeshCom-Node im Hintergrund exakt **alle 900 Sekunden (15 Minuten)** automatisch ein kurzes `HEY`-Paket auf `433,175 MHz` aus, um die Nachbarschaftstabellen (MHeard) und die Pfadlängen (`pl`) für das Routing von Direct Messages (DM) im Netz aktuell zu halten **[14]**.
   * Werden über DK5ENs McApp-Webinterface Textnachrichten abgesetzt, durchlaufen diese eine Sende-Warteschlange mit einer Verzögerung von **12 Sekunden** zwischen den Paketen (beziehungsweise einer dynamischen Verzögerung über BLE-Feedback), damit das HF-Modul des Lilygo-Nodes nicht überfordert wird **[4, 44]**.
   * Für reine Pfadtests ohne Netzwerkbelastung bietet MeshCom zudem eine besondere Filterlogik: Jede Text-, Gruppen- oder Direct-Message, die mit dem Wort `Test` (unabhängig von Groß- oder Kleinschreibung) beginnt, wird nicht im Mesh weitergeleitet und erzeugt keine Empfangsquittung, erscheint jedoch zur Kontrolle unter dem Test-Button am Dashboard **[13]**.
   * Schließlich ermöglicht die externe UDP-Schnittstelle (`--extudp on`) oder das Webinterface zeitgesteuertes Scripting, über das beispielsweise mittels eines angeschlossenen Raspberry Pi oder der Software `meteo_mc` von IK5XMK externe Wetterdaten geparst und vollautomatisch zweimal täglich in die Mesh-Cloud gesendet werden können **[15, 33]**.

### Sendeintervalle, Automatik-Modi und Blockade-Fallstricke bei Anytone AT-D878UV Plus & UVII Plus

Die beiden Anytone-Handfunkgeräte bieten in der Programmiersoftware (CPS) unter dem Menüpunkt `APRS` umfangreiche Automatisierungsfunktionen sowohl für Analog-APRS (`144,800 MHz`) als auch für DMR-APRS, weisen jedoch im praktischen Betrieb mehrere kritische Firmware-Abhängigkeiten auf **[3, 48, 49, 50, 53]**:

* **Zeitintervalle (`Intervals Set`) & Hintergrund-Aussendung:** Im Gerätemenü (`Menu -> APRS -> Intervals Set`) beziehungsweise in der CPS lässt sich ein festes Zeitintervall in Sekunden definieren, wobei in der Praxis Werte wie `120 s`, `150 s` oder `180 s` für den mobilen Einsatz und `600 s` für längere Touren genutzt werden **[49, 53]**. Die Besonderheit der Anytone-Architektur liegt darin, dass die APRS-Sendefrequenz (`144,800 MHz`) global in den APRS-Einstellungen hinterlegt wird. Sobald der Intervall-Timer abläuft, schaltet das Gerät im Hintergrund kurzzeitig von den beiden überwachten Sprechfunkkanälen (VFO A und VFO B) auf `144,800 MHz` um, strahlt das AFSK-Paket aus und kehrt unmittelbar auf die Sprechfunkkanäle zurück, sodass beide VFOs für die Sprachüberwachung erhalten bleiben **[50]**.
* **Ereignisgesteuertes `Upload on PTT` & SmartBeaconing:** Zusätzlich oder alternativ zum Zeitintervall kann das Gerät über die Funktion `Upload on PTT` bei jedem Loslassen der Sprechtaste (mit konfigurierbarer Verzögerung `Manual TX Delay`) automatisch eine Positionsbake aussenden **[49]**. Während die reguläre Anytone-Werks-CPS traditionell mit festen Zeitintervallen arbeitet und dynamisches SmartBeaconing dort lange als unerfüllter Nutzerwunsch galt **[56]**, unterstützen alternative Firmware-Implementierungen für die AT-D868/878/578-Hardwareplattform (wie der RadioFoundry-Stack) vollwertiges SmartBeaconing mit linearer Interpolation zwischen $5\text{ km/h}$ (30 Minuten Intervall) und $90\text{ km/h}$ (3 Minuten Intervall), Corner Pegging bei Kurvenwinkeln größer als $28^\circ + 400 / \text{Geschwindigkeit}$ mit 30 Sekunden Mindestabstand sowie reine Distanz-Trigger nach $N$ zurückgelegten Metern **[3, 57]**.

**Vier kritische Blockade-Mechanismen im Anytone-Codeplug (Praxis-Checkliste):**
In der Betriebspraxis kommt es bei den Anytone-878-Modellen häufig vor, dass das Funkgerät trotz stabilem GPS-Fix nur ein einziges Mal sendet und danach die automatische Aussendung einstellt **[48, 53]**. Dieses Verhalten wird durch vier spezifische Firmware-Mechanismen verursacht:
1. **Blockade durch aktiven Suchlauf (`Scan`):** Die Aktivierung des Suchlaufs auf einem der beiden VFO-Kanäle führt dazu, dass die Anytone-Firmware sämtliche zeitgesteuerten automatischen APRS-Aussendungen vollständig einstellt; während eines aktiven Scans lassen sich Baken ausschließlich manuell über das Loslassen der PTT-Taste auslösen, bis der Suchlauf wieder beendet wird **[49]**.
2. **Blockade durch `Group Call Hold Time` / `Private Call Hold Time`:** Die DMR-Anrufhaltezeit blockiert im Hintergrund jegliche APRS-Aktivität: Solange das Gerät einen DMR-Anruf als aktiv betrachtet oder der Nachlauf-Timer nach einem Durchgang noch läuft, sind sowohl das automatische APRS-Beaconing (analog wie digital) als auch der APRS-Empfang und das Roaming komplett gesperrt **[48]**. Steht dieser Timer auf hohen Werten, verhindert bereits mäßiger Sprechfunkverkehr auf einer überwachten DMR-Talkgroup jede automatische Positionsmeldung, weshalb die `Group Call Hold Time` in der CPS zwingend auf **2 bis 5 Sekunden** begrenzt werden muss **[48]**.
3. **Kombination aus `APRS Report Type` und `Analog APRS PTT Mode`:** Der automatische Intervall-Timer arbeitet in bestimmten Firmware-Ständen nur dann zuverlässig, wenn in den Kanaleinstellungen `APRS Report Type` auf `Analog` und `Analog APRS PTT Mode` auf `Off` gesetzt ist, während gleichzeitig im jeweiligen Kanalprofil die APRS-Option aktiviert sein muss **[53]**.
4. **Zwingendes Zielrufzeichen `APAT81` & Höheneinheit:** In der CPS muss unter `APRS -> Destination Call Sign` zwingend die Zielkennung `APAT81` (zusammen mit einem Digipeater-Pfad wie `WIDE1-1,WIDE2-1`) eingetragen sein, da viele iGates Pakete ohne gültiges Zielrufzeichen verwerfen und nicht an `aprs.fi` weiterleiten **[48]**; zudem sollte die Höheneinheit auf das metrische System eingestellt werden, um den bis Firmware v1.25 auftretenden $10\text{-}\%$-Umrechnungsfehler bei der Höhenangabe auszuschließen **[48]**.

### Sendeintervalle und Automatik-Optionen beim Baofeng DM-32 (DM-32UV)

Beim Baofeng DM-32 gestaltet sich die Konfiguration der automatischen Aussendung übersichtlicher, unterliegt jedoch den engen Systemgrenzen des reinen DMR-Datenbetriebs **[2, 6, 18]**:
* In der CPS des DM-32 sowie im Gerätemenü wird zunächst die Satellitenortung (GPS, Beidou oder der kombinierte Modus **GPS+Beidou**) aktiviert **[2, 18]**. Anschließend werden im digitalen APRS-Menü das automatische Upload-Zeitintervall sowie das Zielobjekt (`Target Object`) als Gruppen- oder Einzelruf an das BrandMeister-APRS-Gateway konfiguriert **[11, 18]**.
* **Wichtige Betriebsgrenze:** Da das DM-32 keinen analogen AFSK-TNC besitzt, greift dieser automatische Intervall-Timer ausschließlich dann, wenn das Funkgerät auf einem **digitalen DMR-Kanal** eingeschaltet ist und sich in Reichweite eines vernetzten DMR-Repeaters wie `OE5XLL` oder eines persönlichen Hotspots befindet **[6, 17, 18]**. Wird das Gerät auf einem analogen FM-Kanal betrieben oder bewegt sich die Station außerhalb der DMR-Relaisabdeckung, findet trotz aktivem Timer keine HF-Aussendung in das APRS-Netz statt **[6]**.
* Soll die hohe Sendeleistung des Baofeng DM-32 von 8 bis 10 W **[2, 19, 52]** dennoch für vollautomatisches, geschwindigkeitsabhängiges SmartBeaconing im analogen 2-m-Netz auf `144,800 MHz` eingesetzt werden, erfordert dies die externe Beschaltung der Kenwood-K1-Zubehörbuchse mit einem **AIOC-Kabelinterface** und einem Android-Smartphone unter Verwendung von **APRSdroid**, wodurch einer der beiden VFOs auf `144,800 MHz` mit aktivierter Sprachsteuerung (VOX) für die Paketübertragung reserviert wird **[6, 9]**.

---

## 6. Synthese und einsatztaktische Empfehlungen für den Gerätepark

Die Gesamtschau der technischen Parameter, der österreichischen Empfangsinfrastruktur und der Firmware-Mechanismen ermöglicht eine präzise einsatztaktische Orchestrierung des siebenköpfigen Geräteparks für den stationären, mobilen und portablen Betrieb:

1. **Stationärer Anker & Heimgateway (`Lilygo T-Beam AXP-2101`):**
   In Verbindung mit einer externen 70-cm-Außenantenne, einem 2-Ah-LiFePO4-Notstromakku und DK5ENs Firmware v4.40a eignet sich dieses Board ideal für den 24/7-Dauerbetrieb, gekoppelt per BLE oder UDP an einen Raspberry Pi Zero 2W mit laufendem McApp-Server **[4, 13, 43, 44]**. Das Positionsintervall sollte in dieser Rolle fest auf **`--postime 3600` (60 Minuten)** bei deaktiviertem Tracking (`--track off`) konfiguriert werden, um den Knoten auf `meshcom.oevsv.at` dauerhaft im grünen Aktivitätsstatus zu halten, ohne das lokale `433,175-MHz`-Mesh mit unnötiger Sendezeit zu belasten **[14, 15, 31]**.
2. **Mobiles Präzisions-Tracking & Telemetrie (`Lilygo T-Beam 1W` & `Lilygo T-Beam Supreme`):**
   Für den Einsatz im Kraftfahrzeug sowie für alpine SOTA- und Fieldday-Aktivitäten spielen diese beiden Einheiten die automatische Frequenz-Bifurkation von MeshCom 4.0 voll aus **[14, 23]**. Mit aktiviertem `--gps on` und `--track on` arbeiten beide Geräte im dynamischen SmartBeaconing-Modus auf `433,775 MHz`, werden direkt von hochgelegenen LoRa-APRS-iGates wie `OE5XOL-11` empfangen, regeln ihr Intervall bei Pausen oder Stillstand selbstständig auf schonende 1.800 Sekunden herunter und bleiben parallel auf `433,175 MHz` im MeshCom-Chat erreichbar **[7, 14, 23, 54]**. Das **T-Beam 1W** fungiert dabei dank seiner 1-Watt-Endstufe als reichweitenstarker Tracker für topografisch abgeschattete Täler ohne nahegelegene Nachbar-Nodes **[23]**, während das **T-Beam Supreme** über seinen I2C-Sensorbus (`--bme on`) kontinuierlich meteorologische Messwerte in die Heatmaps von `meshmap.oevsv.at` einspeist **[5, 15, 47]**.
3. **Autarkes Off-Grid-Handterminal (`Lilygo T-Deck Plus`):**
   Ergänzt die LoRa-Flotte als eigenständiges Kommandoterminal im Rucksack, mit dem sich quittierte Direct Messages und Gruppenmeldungen direkt über die physische Tastatur verfassen und manuelle Positionsmeldungen (`--sendpos`) absetzen lassen **[1, 15, 23]**.
4. **Bidirektionales 2m-Analog-APRS & Dual-Mode-Tracking (`Anytone AT-D878UVII Plus` & `AT-D878UV Plus`):**
   Im leistungsstarken VHF/UHF-Sprechfunkbetrieb übernimmt das **Anytone AT-D878UVII Plus** die Führungsrolle als primäres 2-m-APRS-Transceiver-System: Durch seinen integrierten analogen AFSK-Decoder (RX & TX) gewährleistet es auf `144,800 MHz` über Digipeater wie `OE5XOL-10` oder `OE1XBA` volle bidirektionale Situational Awareness inklusive APRS-Kurzmitteilungsverkehr **[3, 7, 8, 21]**. Das **Anytone AT-D878UV Plus** (Generation 1) dient als zuverlässiger Dual-Mode-Positionsmelder (Analog `144,800 MHz` TX und DMR-APRS TX) **[21, 50]**, sofern in den Codeplugs beider Anytone-Geräte die `Group Call Hold Time` strikt auf 2 bis 5 Sekunden reduziert, das Zielrufzeichen auf `APAT81` gesetzt und während des automatischen Intervall-Beaconings auf den VFO-Suchlauf verzichtet wird **[48, 49]**.
5. **10-Watt-DMR-APRS-Arbeitspferd (`Baofeng DM-32 / DM-32UV`):**
   Komplettiert die Ausstattung als robustes DMR-Handfunkgerät mit extrem schneller GPS+Beidou-Ortung ($<10\text{ s}$ Warmstart) für das digitale DMR-APRS-Tracking über vernetzte Relaisfunkstellen wie `OE5XLL` am Linzer Lichtenberg **[2, 6, 17, 18, 19]**.

---

## 7. Quellen- und Referenzverzeichnis (Danksagung & Nachweise)

> **Ehre, wem Ehre gebührt:** Besonderer Dank gilt den Entwicklern, Systemarchitekten und Betreibern der Amateurfunk-Infrastruktur im ÖVSV, im ICSSW sowie in der Open-Source-Community – insbesondere **Martin (DK5EN, ex-OE5ODO)** für den v4.40a-Firmware-Fork, McApp und die ÖVSV-MeshMap sowie dem Kernteam rund um **Kurt (OE1KBC)**, **Mike (OE3MZC)** und **Rainer (OE1KFR)** für die MeshCom-4.0-Gesamtarchitektur.

* **[1]** **ICSSW & ÖVSV (Kurt OE1KBC, Mike OE3MZC, Rainer OE1KFR, Martin DK5EN et al.):** *MeshCom 4.0 – Off-Grid LoRa-Mesh-Kommunikationssystem auf Basis des APRS-Protokolls.* Systemdokumentation und GitHub-Repository (`icssw-org/MeshCom-Firmware`, `icssw.org/meshcom/`).
* **[2]** **Baofeng Elec. Co.:** *Baofeng DM-32 / DM-32UV Dual-Band Digital DMR & Analog Two-Way Radio – Technische Spezifikationen & Benutzerhandbuch.* (DMR Tier I/II, GPS+Beidou, AMBE+2).
* **[3]** **Bob Bruninga (WB4APR) / APRS Working Group & RadioFoundry:** *APRS Protocol Reference – Protocol Version 1.0 (`APRS101.PDF`)* sowie *RadioFoundry APRS Implementation Specification for Anytone AT-D868/878/578* (AX.25 UI-Frames, Base-91-Kompression, `:ADDRESSEE:text{NN`, SmartBeaconing-Formeln).
* **[4]** **Martin (DK5EN, ex-OE5ODO):** *McApp & MeshCom-Firmware DK5EN-Fork – Architektur, BLE-Keep-Alive, UTF-8/APRS-Sanitizing, Quarantäne-Gruppe 9999 und Drei-Slot-OTA-System (Port 2985).* GitHub-Dokumentation (`github.com/DK5EN`).
* **[5]** **Martin (DK5EN) & ÖVSV:** *ÖVSV MeshMap (`meshmap.oevsv.at`) – Live-Topologie, Temperatur- und Luftdruck-Heatmaps mit barometrischer Höhenkorrektur nach APRS-Protokoll.*
* **[6]** **Amateurfunk-Praxisanalyse DM-32 / DM-32UV:** *Differenzierung zwischen nativem DMR-APRS (4FSK TDMA) und analogem 1.200-Baud-AFSK-APRS über K1-Zubehörbuchse (AIOC-Interface & APRSdroid).*
* **[7]** **ÖVSV Landesverband Oberösterreich (OE5) / ADL 514:** *Standortdokumentation `OE5XOL` (Breitenstein, Kirchschlag bei Linz) – `OE5XOL-10` (2m Analog-APRS Digi/iGate 144,800 MHz) & `OE5XOL-11` (70cm LoRa-APRS Digi/iGate 433,775 MHz).* (`oe5.oevsv.at`).
* **[8]** **ÖVSV Landesverband Wien (OE1):** *Standortdokumentation `OE1XBA` (Wien – Laaerberg Hochhaus, 2m APRS Digipeater & iGate auf 144,800 MHz).* (`oe1.oevsv.at`).
* **[9]** **FCC / CE Prüfberichte & Technische Datenblätter Baofeng DM-32:** *Modulationsarten `7K60FXD` (Daten) und `7K60FXW` (Sprache+Daten), Empfängerempfindlichkeit ($0{,}22\text{ }\mu\text{V}$ bei $5\text{ \%}$ BER) und Audio-/K1-Schnittstelle.*
* **[10]** **OpenGD77 Project & BrandMeister Wiki:** *Alternative Amateurfunk-Firmware-Unterstützung und DMR-APRS-Konfiguration für kompatible Dualband-DMR-Handfunkgeräte.*
* **[11]** **BrandMeister DMR Network:** *APRS & SelfCare Konfigurationsleitfaden – Weiterleitung von DMR-Positionsdatenpaketen an das globale APRS-IS (`aprs.fi`).* (`wiki.brandmeister.network`).
* **[12]** **ETSI (European Telecommunications Standards Institute):** *ETSI TS 102 361-1, -2, -3 – Electromagnetic compatibility and Radio spectrum Matters (ERM); Digital Mobile Radio (DMR) Systems (Tier I & Tier II).*
* **[13]** **ICSSW / ÖVSV MeshCom Hardware-Praxisleitfaden:** *Einsatz von Lilygo T-Beam AXP2101, externer 2-Watt-Endstufe AB-OT 433, LiFePO4-Notstrompufferung und `Test`-Nachrichtenfilterung.* (`icssw.org`).
* **[14]** **ICSSW / ÖVSV MeshCom 4.0 Betriebshandbuch:** *Frequenz-Bifurkation (433,175 MHz vs. 433,775 MHz), Positionsintervalle (`--postime` 300 s bis 3.600 s), SmartBeaconing-Ruhe-Fallback (1.800 s), `HEY`-Topologiepakete (900 s) und Dashboard-Farbcodierung.*
* **[15]** **MeshCom 4.0 Command Line & Parameter Reference:** *Serielle/Web-Befehlsübersicht (`--setlat`, `--setlon`, `--bme`, `--wx`, `--sendpos`) und Spezifikation der internationalen Länderprofile (`Country-ID` 1 bis 13).*
* **[16]** **IARU Region 1:** *UHF Bandplan (430–440 MHz), Stand Mai 2025 – Ausweisung von 433,175 MHz (MeshCom, 250 kHz BW) und 433,775 MHz (LoRa-APRS, 125 kHz BW) inkl. Fußnote 10.* (`iaru-r1.org`).
* **[17]** **ÖVSV Landesverband Oberösterreich (OE5) / ADL 516:** *Standortdokumentation `OE5XLL` (Linz – Lichtenberg / Giselawarte, 927 m, `JN78DJ`) – DMR-Relais, FM-Relais und zentraler HAMNET-Richtfunkknoten.* (`oe5.oevsv.at`).
* **[18]** **Baofeng DM-32 CPS (Customer Programming Software) Dokumentation:** *Konfiguration von GPS/Beidou-Polling, Upload-Intervallen und `Target Object` auf digitalen DMR-Kanälen.*
* **[19]** **Hersteller- & Distributorendatenblatt Baofeng DM-32UV:** *Ausstattungsmerkmale (10 W Sendeleistung, 2.500-mAh-USB-C-Akku, 10h Sprachrekorder, 108–136 MHz AM-Flugfunkempfänger).*
* **[20]** **ÖVSV Landesverband Tirol (OE7):** *Standortdokumentation `OE7XOT` (Obtarrenz, Tirol – Alpiner 70cm LoRa-APRS Digipeater auf 433,775 MHz).* (`oe7.oevsv.at`).
* **[21]** **Anytone (Qixiang Electron Science & Technology Co.):** *Anytone AT-D878UVII Plus – Technische Spezifikation des integrierten analogen 1.200-Baud-AFSK-Hardware-Decoders (APRS RX & TX).*
* **[22]** **Österreichischer Versuchssenderverband (ÖVSV) – Referat Not- und Katastrophenfunk:** *Krisenfeste Text- und Telemetriekommunikation mittels MeshCom 4.0 und HAMNET.* (`oevsv.at`).
* **[23]** **MeshCom App & Hardware-Bedienungsanleitung:** *Steuerung der App-User-Buttons (`Track`, `Send POS`, `Scan I2C`) auf Lilygo T-Beam AXP2101, T-Beam Supreme, T-Beam 1W und T-Deck Plus.*
* **[24]** **Republik Österreich (RIS – Rechtsinformationssystem des Bundes):** *Telekommunikationsgesetz (TKG 2021), Amateurfunkverordnung (AFV) und Frequenznutzungsverordnung (FNV) – Frequenzbereichszuweisungen, Leistungsklassen und ISM-Koexistenz.* (`ris.bka.gv.at`).
* **[25]** **CEPT / ECC:** *CEPT Recommendation T/R 61-01 (CEPT Radio Amateur Licence) & ECC Recommendation (05)06 (CEPT Novice Radio Amateur Licence).* (`cept.org`).
* **[26]** **ÖVSV Rechtsinformation zur TKG-Novelle:** *Unbefristete Amateurfunkbewilligungen und gesetzliche Verankerung des Not- und Katastrophenfunks in Österreich.* (`oevsv.at`).
* **[27]** **Fernmeldebehörde Republik Österreich / FNV Anlage 4:** *Technische Rahmenbedingungen für den Amateurfunkdienst (Nachfolgeregelung der früheren Anlage 2 der AFV).*
* **[28]** **AFV / FNV Anlage 4 – Bewilligungsklasse 1 (CEPT):** *Berechtigungsumfang zum Selbstbau und zur Modifikation von Sendeanlagen sowie Leistungsgrenzen (200 W regulär / 1.000 W EME & MS).*
* **[29]** **AFV / FNV Anlage 4 – Bewilligungsklassen 3 und 4 (CEPT-Novice):** *Auflage der Verwendung unmodifizierter, kommerziell gefertigter Sendeanlagen bis 100 W auf VHF/UHF.*
* **[30]** **CEPT ERC Recommendation 70-03:** *Relating to the use of Short Range Devices (SRD) – Beschränkungen für lizenzfreie ISM-Anwendungen im Bereich 433,05–434,79 MHz.*
* **[31]** **ÖVSV MeshCom Dashboard (`meshcom.oevsv.at`):** *Live-Netzwerkstatistik der registrierten Nodes und Gateways in Österreich, Deutschland und der Schweiz sowie Referenzknoten `OE1KBC` und `OE1KFR`.*
* **[32]** **Fernmeldebehörde Österreich / ÖVSV:** *Rufzeichensystematik im österreichischen Amateurfunkdienst – `X`-Suffixe für automatische Stationen/Relais vs. persönliche SSIDs (`-1` bis `-99`).*
* **[33]** **IK5XMK & MeshCom Italia:** *Software-Tool `meteo_mc` zur automatisierten Einspeisung externer Wetterstationsdaten über die MeshCom-Schnittstelle.*
* **[34]** **ADL 514 / OE5XOL-11 Frequenzkoordination:** *Split-Frequenzbetrieb für LoRa-APRS am Breitenstein (Empfang 433,775 MHz / Aussendung 433,900 MHz).*
* **[35]** **ADL 516 / OE5XLL Frequenzliste:** *Analoge FM-Relaisfrequenzen (145,600 MHz & 438,650 MHz) und digitale Systeme am Standort Lichtenberg.*
* **[36]** **ÖVSV Landesverband Oberösterreich (OE5):** *Gesamtübersicht der oberösterreichischen Relais-, Digipeater- und Bakenstandorte.* (`oe5.oevsv.at`).
* **[37]** **devlol (Linz) / Station `OE5XYZ` & `OE5XYZ-10`:** *Technische Dokumentation des Linzer Stadt-Gateways für 2m-APRS (144,800 MHz), 70cm-MeshCom (433,175 MHz) und 13cm-HAMNET-Anbindung.* (`devlol.org`).
* **[38]** **ÖVSV Landesverband Niederösterreich (OE3):** *HAMNET- und MeshCom-Höhenstandorte `OE3XRB` (Jauerling) und `OE3XWJ` (Buchberg).* (`oe3.oevsv.at`).
* **[39]** **ÖVSV / MeshCom-Standort `OE3XOC` (`JN78VD`, 654 m):** *Niederösterreichischer MeshCom-4.0-Digipeater und Ost-West-Brückenknoten.*
* **[40]** **ÖVSV Landesverband Steiermark (OE6):** *Standortdokumentation `OE6XAG` (Graz – Schöckl, `JN77RE`) – VHF/UHF-Relais und HAMNET-Backbone Südost.* (`oe6.oevsv.at`).
* **[41]** **ÖVSV Ortsstelle Wels (ADL 512):** *Regionale MeshCom-4.0-Aktivitäten und Gateway-Ausbau im Raum Wels.*
* **[42]** **ÖVSV Ortsstelle Linz (ADL 502):** *Regionale MeshCom-4.0-Aktivitäten und Knoten-Infrastruktur im Großraum Linz.*
* **[43]** **GitHub Release `icssw-org/MeshCom-Firmware` v4.40a:** *Release-Notes `neo: firmware-only delta of the DK5EN fork, version 4.40a` (Automatische Sommer-/Winterzeitumstellung und GPS-Zeit-Priorisierung).*
* **[44]** **Martin (DK5EN) – McApp Server- & Client-Dokumentation:** *Python-Backend für Raspberry Pi Zero 2W, Vue.js 3 PWA-Frontend, BLE-Reconnect-Logik und MHeard-Relay-Pfad-Visualisierung.*
* **[45]** **QRZ.com / Amateurfunk-Register:** *Stations- und Entwicklerprofil Martin (DK5EN, vormals OE5ODO).*
* **[46]** **ICSSW (Institute of Citizen Science for Space and Wireless Communication):** *Entwicklerbeiträge und Systemarchitektur von MeshCom 4.0.* (`icssw.org`).
* **[47]** **MeshCom 4.0 Telemetrie- und I2C-Sensordokumentation:** *Einbindung von BME280, BMP280, BME680 und MCU-811 an Lilygo-Entwicklerboards.*
* **[48]** **Anytone AT-D878UV / UVII Plus Firmware- & CPS-Analyse:** *Wechselwirkung zwischen `Group Call Hold Time` und APRS-Blockade, `APAT81`-Zielkennung sowie Höhen-Umrechnungsfehler bis FW v1.25.*
* **[49]** **BridgeCom Systems & Anytone APRS Configuration Guide:** *Konfiguration von `Intervals Set`, `Upload on PTT`, `Manual TX Delay` und Unterdrückung des Auto-Timers bei aktivem VFO-Scan.*
* **[50]** **Anytone AT-D878UV Plus (Gen. 1) Hardware-Spezifikation:** *Hintergrund-APRS-Aussendung auf 144,800 MHz ohne Verlust der Dual-VFO-Sprachüberwachung.*
* **[51]** **Baofeng DM-32 Firmware-Historie (v1.47):** *Erweiterung des internen CSV-Kontaktspeichers auf 150.000 DMR-Kontakte.*
* **[52]** **Hardware-Revisionsvergleich Baofeng DM-32 / DM-32UV / UV-32:** *Abgrenzung der Sendeleistungsstufen (8 W vs. 10 W) und der DMR-Funktionalität.*
* **[53]** **Praxis-Troubleshooting Anytone AT-D878UV APRS-Timer:** *Abhängigkeiten der CPS-Parameter `APRS Report Type: Analog` und `Analog APRS PTT Mode: Off` für kontinuierliche Intervall-Aussendungen.*
* **[54]** **MeshCom 4.0 Tracking-Konfiguration:** *Kombinierte Aktivierung von `--gps on` und `--track on` für geschwindigkeits- und richtungsabhängiges SmartBeaconing.*
* **[55]** **MeshCom 4.0 Manuelle Positionssteuerung:** *Funktionsunterschied zwischen `--sendpos`, `--sendtrack` und dem App-Auswahldialog bei fehlendem GPS-Fix.*
* **[56]** **Anytone 878 Community & Feature-Tracker:** *Diskussion zum Fehlen von nativem SmartBeaconing in der regulären Anytone-Werks-Firmware.*
* **[57]** **APRS-Netzwerkökonomie im Amateurfunk:** *Vergleich der Kanalbelastung von starren Zeit-Timern gegenüber dynamischem SmartBeaconing und Corner Pegging.*