Die VWL-Zusammenfassung ist wegen ihrer vielen Bilder zu gross für das Studentenportal. Mit dem folgenden GhostScript-Befehl
kann das PDF auf eine angemessene Grösse komprimiert werden, ohne einen gross sichtbaren Qualitätsverlust der Bilder.

```sh
gs -sDEVICE=pdfwrite -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -sOutputFile=VWL-TG/VwlWp_Zusammenfassung_FS25_JT_MG_MS.pdf VWL-TG/VwlWp_Zusammenfassung_FS25_JT_MG_MS.pdf
```
