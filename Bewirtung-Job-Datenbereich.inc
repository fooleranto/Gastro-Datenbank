$(@a12b VX "Bewirtung ")
.VL 65, VL   
.HL
$(@a10n VX "Bewirtung am: " @a10b $Datum @a10n ", zwischen " @a10b TimeStr($von) @a10n " Uhr und " @a10b TimeStr($bis) @a10n " Uhr")
.HL                                                                                              
$(@a10n VX "Die G�ste sa�en zu dieser Zeit an Tisch Nummer: " @a10b $Tischnummer)
.HL
$(@a10n VX "Die G�ste wurden bedient von: " @a10b $Bedienungen)
.HL
.EVL
$(@a12b VX "Liste der G�ste")
.SETFONT a10n   
.VL 65, VL
.HL
$(VX $G�stedaten)
.HL
.IF Length($BEWIRTUNG.G�ste-Visitenkarten) > 0      
$(VX $BEWIRTUNG.G�ste-Visitenkarten:60:20)
.HL
.END
.EVL