..Modul f�r Tabelle Bewirtung
.SV 1
..Strenge Typ-Pr�fung bei Zuweisung an Variable

Procedure OnOpenProject;
  OpenForm("BEWIRTUNG.Bewirtung-Formular");
  ViewPage(-4);
  SetSortOrder("Bewirtung-Datum.ind");
  TopOfTable;  
endproc;

Procedure OnOpenProjectTest(Dummy: Real);
  OnOpenProject;
endproc;
