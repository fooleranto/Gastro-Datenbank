..formulargebundenes Modul für Formular SYSTEM-Formular
.SV 1
..Strenge Typ-Prüfung bei Zuweisung an Variable


procedure Button1BeimAnklicken;
  vardef CrLf: String
  vardef x: integer;
  vardef MemoLen: Integer;
  vardef i: Integer;
  MemoLen := Length(SYSTEM.Standortadresse);
  CrLf:= Chr(13)+Chr(10);
  i := Scan(CrLf, SYSTEM.Standortadresse);  
  message("Achtung, Sie sollten bei der Standortadresse nicht mehr als 10 Zeilen eingeben, da mehr Zeilen beim Drucken nicht ausgegeben werden.","Hinweis",0);
endproc;


procedure StandortadresseEditBeimÄndern;
  vardef CrLf: String
  vardef x: integer;
  vardef MemoLen: Integer;
  vardef i: Integer;
  MemoLen := Length(SYSTEM.Standortadresse);
  CrLf:= Chr(13)+Chr(10);
  i := Scan(CrLf, SYSTEM.Standortadresse);
  If i > 10
    message("Achtung, Sie sollten bei der Standortadresse nicht mehr als 10 Zeilen eingeben, da mehr Zeilen beim Drucken nicht ausgegeben werden.","Hinweis",0);
  End;
endproc;


procedure StandortadresseEditBeimVerlassen;
  vardef CrLf: String
  vardef x: integer;
  vardef MemoLen: Integer;
  vardef i: Integer;
  vardef LabelCtrl: Label;                     
  LabelCtrl := FindControl("FehlerausgabeLabel") as Label;
  ..if Assigned(LabelCtrl)
    ..EditCtrl.Text := "Achtung, Sie sollten bei der Standortadresse nicht mehr als 10 Zeilen eingeben, da mehr Zeilen beim Drucken nicht ausgegeben werden.";
  ..else
   ..Message('Spalte1Edit gibt es nicht');
  ..end;
  
  MemoLen := Length(SYSTEM.Standortadresse);
  CrLf:= Chr(13)+Chr(10);
  i := Scan(CrLf, SYSTEM.Standortadresse);
  ..message("Anzahl CrLf: " + Str(i));
  If i > 10                      
    LabelCtrl.Text := "Achtung, Sie sollten bei der Standortadresse nicht mehr als 10 Zeilen eingeben, da mehr Zeilen beim Drucken nicht ausgegeben werden.";
  Else
    LabelCtrl.Text := "";    
  End;
endproc;
