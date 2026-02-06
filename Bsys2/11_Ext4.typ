#import "../template_zusammenf.typ": *

/*#show: project.with(
  authors: ("Nina Grässli", "Jannis Tschan"),
  fach: "BSys2",
  fach-long: "Betriebssysteme 2",
  semester: "FS24",
  tableofcontents: (enabled: true),
  language: "de"
) */

= Ext4
In Ext4 sind die wichtigen Datenstrukturen vergrössert #hinweis[(_Inodes_ haben 256 Byte
statt 128, _Gruppendeskriptoren_ 64 Byte statt 32, _Blockgrösse_ bis 64 KB)].
Grosse Blöcke sind besser für viele grosse Dateien, da weniger Metadaten benötigt werden.
Erlaubt höhere maximale Dateigrösse. Zudem werden Blöcke von den Inodes mit _Extent Trees_
verwaltet und _Journaling_ wird verwendet.

== Extents
#grid(
  columns: (80%, 20%),
  [
    Ein _Extent_ beschreibt ein _Intervall physisch konsekutiver Blöcke_. Ist 12 Byte gross
    #hinweis[(4 Byte logische Blocknummer, 6 Byte physische Blocknummer, 2 Byte Anzahl Blöcke)].\
    Positive Zahlen = Block initialisiert, Negativ = Block voralloziert.

    Da eine Einschränkung auf ausschliesslich konsekutive Dateien nicht praktikabel ist,
    muss eine Datei _mehr als einen Extent umfassen_ können. Im Inode hat es in den 60 Byte
    für direkte und indirekte Block-Adressierung Platz für 4 Extents und einen Header.

    == Extent Trees
    _Index-Knoten_ #hinweis[(Innerer Knoten des Baums, besteht aus Index-Eintrag und Index-Block)]\
    _Index-Eintrag_ #hinweis[(Enthält Nummer des physischen Index-Blocks und kleinste logische Blocknummer
    aller Kindknoten)]
  ],
  image("img/bsys_47.png"),
)

=== Extent Tree Header
Für mehr als 4 Extents braucht man einen zusätzlichen Block. Deshalb sind die ersten
12 Byte im Inode kein Extent, sondern der Extent Tree Header:
- 2 Byte _Magic Number_ #hex("F30A")
- 2 Byte _Anzahl Einträge_, die _direkt_ auf den Header folgen
  #hinweis[(Wie viele Extents folgen dem Header?)]
- 2 Byte _Anzahl Einträge_, die _maximal_ auf den Header folgen können
- 2 Byte _Tiefe des Baums_
  #hinweis[(0: Einträge sind Extents, $>=$1: Einträge sind Index Nodes)]
- 4 Byte _reserviert_

=== Index Nodes
Ein Index-Node spezifiziert _einen Block, der Extents enthält_. Der Block enthält am
Anfang einen _Header_ und danach die Extents #hinweis[(max. 340 bei 4 KB Blockgrösse)].
- 4 Byte _kleinste logische Blocknummer_ aller Kind-Extents
- 6 Byte _physische Blocknummer_ des Blocks, auf den der Index-Node verweist
- 2 Byte _unbenutzt_

Werden mehr als $4 dot 340 =$ _$bold(1360)$ Extents_ #hinweis[(#hex(550))] benötigt,
muss man Blöcke mit Index-Nodes einführen. Statt Extents stehen dann _Index Nodes
im Block_. Die _Tiefe_ im Inode wird auf _2_ gesetzt, in den Index-Node-Blöcken auf 1.
Die _kleinste logische Blocknummer_ aller Kind-Extents _propagiert_ dann bis in den
jeweils obersten Index-Node. Benötigt man dann _noch mehr Extents_, kann die _Tiefe_ im
Inode bis auf _5_ gesetzt werden #hinweis([(Dann wird das Maximum von $2^32 = 4"G"$
Blöcken pro Datei erreicht)]).

=== Index-Block
#grid(
  columns: (50%, 50%),
  [
    Ein Index-Block enthält einen eigenen _Tree-Header_, Tiefe ist um 1 kleiner als beim
    übergeordneten Knoten. Enthält _Referenz auf die Kind-Knoten_: je nach Tiefe entweder
    Index-Einträge oder Extents. `i_block[0...14]` kann als (sehr kleiner) Index-Block
    aufgefasst werden.
  ],
  image("img/bsys_48.png"),
)

=== Notation
#table(
  columns: (1fr, 1fr),
  table.header([(in)direkte Adressierung], [Extent-Trees]),
  [_direkte Blöcke:_ \<Index> $|->$ \<Blocknummer>],
  [_Indexknoten:_ \<Index> $|->$ (\<Kindblocknummer>, \<kleinste Nummer der 1. logischen Blöcke aller Kinder>)],

  [_indirekte Blöcke:_ \<indirekter Block>.\<Index> $|->$ \<direkter Block>],
  [_Blattknoten:_ <Index> $|->$ (\<1. logischer Block>, \<1. physischer Block>, \<Anzahl Blöcke>)],

  [], [_Header:_ \<Index> $|->$ (\<Anz. Einträge>, \<Tiefe>)],
)


==== Beispiel-Berechnung: 4MB grosse, konsekutiv gespeicherte Datei, 4KB Blöcke ab Block #hex("1000")
_(In-)direkte Block-Adressierung_\
4 MB = $2^22$B, #math.quad 4 KB = $2^12$B, #math.quad $2^(22-12) = 2^10 = #fxcolor("rot", hex("400"))$
Blöcke von #fxcolor("grün", hex("1000")) bis #fxcolor("orange", hex("13FF"))

$0 arrow.bar #fxcolor("grün", hex("1000")), quad
  1 arrow.bar #hex("1002"), space ..., space
  #hex("B") arrow.bar #hex("100B"), quad
  #hex("C") arrow.bar #hex("1400")$ #hinweis[(indirekter Block, #fxcolor("rot", hex("400")) nach Startblock)]

$#hex("1400").#hex("0") arrow.bar #hex("100C"), quad
  #hex("1400").#hex("1") arrow.bar #hex("100D"), space
  ..., space
  #hex("1400").#hex("3F3") arrow.bar #fxcolor("orange", hex("13FF"))$

_Extent Trees_ \
*Header:* $0 arrow.bar (1,0)$\
*Extent:* $1 arrow.bar (0, #fxcolor("grün", hex(1000)), #fxcolor("rot", hex("400")))$

#pagebreak()

== Journaling
Wird eine Datei _erweitert_, passiert folgendes:
- _Neue Blöcke_ werden für die Daten _alloziert_
- Der _Inode_ der Datei wird _angepasst_, um die Blöcke zu referenzieren
- Die _Block-Usage-Bitmaps_ werden _angepasst_
- Die _Counter_ freier und benutzter Blöcke werden _angepasst_
- Die _Daten_ werden in die Datei geschrieben

Wenn das Dateisystem dabei _unterbrochen_ wird, kann es zu _Inkonsistenzen_ kommen.
Ein System _ohne_ Journaling kann sehr lange brauchen, um ein Dateisystem auf
Inkonsistenzen zu prüfen, da _alle Metadaten_ überprüft werden müssen.
_Journaling verringert diese Prüfung erheblich_.
Dateisystem muss nur die Metadaten überprüfen, die noch im Journal referenziert sind.

=== Journal
Das Journal ist eine _reservierte Datei_, in die Daten relativ _schnell geschrieben_
werden können. Besteht aus _wenigen sehr grossen Extents_ oder bestenfalls aus
_einem einzigen Extent_ #hinweis[(Typischerweise Inode 8, 128MB)].

Eine _Transaktion_ ist eine Folge von Einzelschritten, die das Dateisystem gesamtheitlich
vornehmen soll.

=== Journaling und Committing
Daten werden zuerst als _Transaktion ins Journal_ geschrieben #hinweis[(Journaling)].
Daten werden erst _danach_ an ihre _endgültige Position_ geschrieben #hinweis[(Committing)].
Daten werden nach dem Commit aus dem Journal _entfernt_.

Journaling ist _schneller_, weil alle Daten in _konsekutive_ Blöcke geschrieben werden.
Committing muss u.U. _viele verschiedene_ Blöcke modifizieren.

=== Journal Replay
Startet das System neu, kann es _anhand der Journal-Einträge_ die Metadaten untersuchen,
die _potenziell korrupt_ sein könnten. Alle Transaktionen, die noch im Journal sind,
wurden _noch nicht durchgeführt_ und werden mit Journal Replay (noch einmal) ausgeführt
oder auf Fehler überprüft. _Im Gegensatz zu ext2 muss nicht der gesamte Datenträger auf
Fehler untersucht werden._

=== Journaling Modi
Es gibt 3 Modi: (Full) Journal, Ordered und Writeback. Die Modi _Ordered_ und _Writeback_
schreiben nur _Metadaten_, _Journal_ schreibt auch _Datei-Inhalte_ ins Journal.

==== (Full) Journal
#grid(
  columns: (50%, 50%),
  [
    _Metadaten und Datei-Inhalte_ kommen ins Journal.
    Grosse Änderungen werden in mehrere Transaktionen gesplittet.

    _Vorteil:_ maximale Datensicherheit\
    _Nachteil:_ grosse Geschwindigkeitseinbussen.
  ],
  image("img/bsys_49.png"),
)

==== Ordered
#grid(
  columns: (60%, 40%),
  [
    _Nur Metadaten_ kommen ins Journal. Dateiinhalte werden immer _vor_ dem Commit geschrieben:
    + Transaktion ins Journal
    + Dateiinhalte an endgültige Position schreiben
    + Commit ausführen
    _Vorteil:_ Dateien enthalten nach dem Commit den richtigen Inhalt
    _Nachteil:_ Etwas geringere Geschwindigkeit als Writeback.\
    #hinweis[(In Linux gibt es einen lost+found Ordner im Root-Verzeichnis, Dateien mit
    unvollständigen Transaktionen bei z.B. Absturz werden da deponiert)]
  ],
  image("img/bsys_50.png"),
)

==== Writeback
#grid(
  columns: (60%, 40%),
  [
    _Nur Metadaten_ kommen ins Journal.
    Commit und Schreiben der Dateiinhalte werden in _beliebiger Reihenfolge_ ausgeführt.

    _Vorteil:_ Sehr schnell, keine Synchronisation von Commit und Datenschreiben nötig.\
    _Nachteil:_ Dateien können Datenmüll enthalten.
  ],
  image("img/bsys_51.png"),
)

== Vergleich Ext2 & Ext4
#table(
  columns: (auto, auto),
  table.header([Ext2], [Ext4]),
  [
    - schlank und leistungsfähig
    - einfach zu implementieren
    - mächtiger als FAT, weniger mächtig als NTFS
  ],
  [
    - fügt wichtige Features hinzu
    - Journaling
    - Effizientere Verwaltung grosser Verzeichnisse und Dateien
  ],
)
