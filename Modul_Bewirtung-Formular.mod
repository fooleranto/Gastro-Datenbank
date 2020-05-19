.SV 1
..Strenge Typ-Prüfung bei Zuweisung an Variable

vardef GV_Datensatznummer : Integer
vardef GV_Standortadresse: String
vardef GV_AnzahlStars: Integer;
..vardef GV_AnzahlMarks: Integer; 

procedure VolltextIndexRegenerieren(Dummy: Real); 
  Vardef Erfolg : Integer
  Erfolg := ScanRecs(BEWIRTUNG, VOLLTEXTINDEX, Stichwörter, Fields(Bedienungen, Gästedaten), "", 200, BaseDir+"VolltextindexKontra.txt", 0)
  Trace("Prozedur VolltextIndexRegenerieren: Erfolg beim regenerieren des Volltextindex (>0 ist in Ordnung)? " + STR(Erfolg))
endproc;


procedure DruckenButtonBeimAnklicken(Dummy: Real);
  ReadRec(SYSTEM,1);
  GV_Standortadresse := SYSTEM.Standortadresse;
  GV_Datensatznummer := BEWIRTUNG.Laufende_Nummer;
  Run("Bewirtung-DS-drucken");
endproc;

procedure MemoBeimÄndern(Dummy: Real);
  Vardef Erfolg : Integer
  Erfolg := ScanRec(BEWIRTUNG, VOLLTEXTINDEX, Stichwörter, Fields(Bedienungen, Gästedaten), "", 200, BaseDir+"VolltextindexKontra.txt")
  Trace("Prozedur MemoBeimÄndern: Erfolg beim Aufnehmen des DS in den Volltextindex (0 ist in Ordnung)? " + STR(Erfolg))
endproc;

procedure MarkierteDSDruckenButtonBeimAnklicken(Dummy: Real);
  vardef ArrayStars: Integer[0];
  
  ..Wir ermitteln die Anzahl der sichtbar markierten Datensätze und übernehmen den Wert in die
  ..globale Variable GV_AnzahlStars. Diese wird im Datenbankjob benötigt, um den Seitenzähler
  ..zu steuern. 
  GV_AnzahlStars := GetStars(ArrayStars);
      
  ..Trace("Prozedur MarkierteDSDruckenButtonBeimAnklicken: GV_AnzahlStars -> " + Str(GV_AnzahlStars));
                                            
  IF GV_AnzahlStars = 0            
    Message("Es sind keine Datensätze markiert. Bitte markieren Sie diese mit der F8-Taste.","Hinweis",0)
    Halt;
  END;
  
  ReadRec(SYSTEM,1);
  GV_Standortadresse := SYSTEM.Standortadresse;
  Run("Bewirtung-markierte-DS-drucken");

endproc;                                      

..Im Formular Bewirtung-Formular befindet sich ein unsichtbares Datenfeld namens ErfassungsdatumEdit,
..dieses wird bei der Neuerfassung eines Datensatzes (GetMode = 2) mit dem aktuellen Tagesdatum
..belegt und dann beim Speichern des Datensatzes in die Tabelle geschrieben.
procedure FormOnExit(Dummy: Real);
  vardef EditCtrl: Edit;
  Trace("Prozedur FormOnExit: " + Str(GetMode));
  IF GetMode = 2
    EditCtrl := FindControl("ErfassungsdatumEdit") as Edit;
    if Assigned(EditCtrl)
      EditCtrl.Text := $heute;
    else
      Message('Fehler in der Prozedur FormOnExit im Formular Bewirtung-Formular, das Feld ErfassungsdatumEdit gibt es nicht. Bitte verständigen Sie Ihren Administrator');
    end;
  END
endproc;

procedure LoeschProzedur(Dummy: Real);
  vardef AnzahlDatensätze: Integer;
  vardef Löschdatum: Date;
  vardef o: DataWnd;
  o := FindDataWnd("BEWIRTUNG.Bewirtung-Formular");
  if not Assigned(o)
    Trace("Prozedur Löschprozedur: Das Formular Bewirtung-Formular ist nicht geöffnet. Prozedur wird beendet. " + jetzt);  
    Halt;
  end;

  Trace("Prozedur Löschprozedur: Löschroutine wird gestartet. " + jetzt);
  Löschdatum := Today + 28;
  Trace("Prozedur Löschprozedur: Das ermittelte Löschdatum ist: " + DateStr(Löschdatum));
  AnzahlDatensätze := BySelection("Erfassungsdatum >= Löschdatum",1 ,2);
  IF AnzahlDatensätze = 1
    Message("Zur Information: Es steht 1 Datensatz zur Löschung heran, welcher schon 4 Wochen alt ist.", "Maßnahme aufgrund der Datenschutzvorschriften", 0);
  END;
  IF AnzahlDatensätze >1
    Message("Zur Information: Es stehen " + Str(AnzahlDatensätze) + " Datensätze zur Löschung heran, die schon 4 Wochen alt sind.", "Maßnahme aufgrund der Datenschutzvorschriften", 0);
  END;  
  IF AnzahlDatensätze > 0
    Trace("Prozedur FormOnOpen: Anzahl der gefundenen DS die älter als 28 Tage sind: " + Str(AnzahlDatensätze));
    DeleteStars(1,0);
    RemoveAllStars(1);
    VolltextIndexRegenerieren(0);
    Attach;
  END;

endproc;

procedure FormOnOpen(Dummy: Real);
 LoeschProzedur(0);
endproc;


procedure TimerAktion(Dummy: Real);
  Trace("Prozedur TimerAktion: Timer gestartet.");
  LoeschProzedur(0);
endproc;

