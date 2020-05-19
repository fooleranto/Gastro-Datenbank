$(@a12b VX "Bewirtung ")
.VL 65, VL   
.HL
$(@a10n VX "Bewirtung am: " @a10b $Datum @a10n ", zwischen " @a10b TimeStr($von) @a10n " Uhr und " @a10b TimeStr($bis) @a10n " Uhr")
.HL                                                                                              
$(@a10n VX "Die Gäste saßen zu dieser Zeit an Tisch Nummer: " @a10b $Tischnummer)
.HL
$(@a10n VX "Die Gäste wurden bedient von: " @a10b $Bedienungen)
.HL
.EVL
$(@a12b VX "Liste der Gäste")
.SETFONT a10n   
.VL 65, VL
.HL
$(VX $Gästedaten)
.HL
.IF Length($BEWIRTUNG.Gäste-Visitenkarten) > 0      
$(VX $BEWIRTUNG.Gäste-Visitenkarten:60:20)
.HL
.END
.EVL