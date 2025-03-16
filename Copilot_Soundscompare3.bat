@echo off
setlocal enabledelayedexpansion

rem ===== Konfiguration =====
set "input_dir=D:\Sounds\Soundoriginal"
set "compare_dir=D:\Sounds\SoundWIPMod"
set "output_dir=D:\Sounds\Soundneu"
set "log_file=D:\Sounds\log.txt"
set "debug=1"

echo *** DEBUG: Starte Batch-Skript *** >> "%log_file%"
echo Eingabe-Verzeichnis: "%input_dir%" >> "%log_file%"
echo Vergleichs-Verzeichnis: "%compare_dir%" >> "%log_file%"
echo Ausgabe-Verzeichnis: "%output_dir%" >> "%log_file%"
echo -------------------------------------------- >> "%log_file%"

rem Durchlaufe alle OGG-Dateien im Eingabeverzeichnis
for /f "delims=" %%F in ('dir /b /s "%input_dir%\*.ogg"') do (
    set "input_file=%%F"
    set "filename=%%~nxF"
    
    rem Korrigierter relativer Pfad
    set "relative_path=!input_file:%input_dir%\=!"

    rem Vergleichs- und Ausgabepfad korrekt setzen
    set "compare_file=!compare_dir!\!relative_path!"
    set "output_file=!output_dir!\!relative_path!"

    rem Debugging-Ausgabe
    if "%debug%"=="1" (
        echo. >> "%log_file%"
        echo DEBUG: Originaldatei: "!input_file!" >> "%log_file%"
        echo DEBUG: Relativer Pfad: "!relative_path!" >> "%log_file%"
        echo DEBUG: Vergleichsdatei: "!compare_file!" >> "%log_file%"
        echo DEBUG: Zieldatei: "!output_file!" >> "%log_file%"
    )

    rem Wenn die Vergleichsdatei existiert
    if exist "!compare_file!" (
        echo DEBUG: Vergleichsdatei gefunden. >> "%log_file%"

        rem Lautstärke aus der Originaldatei ermitteln
        set "volume_1=0"
        for /f "tokens=2 delims=:" %%A in ('ffmpeg -i "!input_file!" -af volumedetect -f null NUL 2^>^&1 ^| findstr /C:"max_volume"') do (
            set "volume_1=%%A"
        )
        set "volume_1=!volume_1: =!"
        set "volume_1=!volume_1:dB=!"
        if not defined volume_1 set "volume_1=0"
        echo DEBUG: Lautstärke Original: "!volume_1!" >> "%log_file%"

        rem Lautstärke aus der WIP-Datei ermitteln
        set "volume_2=0"
        for /f "tokens=2 delims=:" %%A in ('ffmpeg -i "!compare_file!" -af volumedetect -f null NUL 2^>^&1 ^| findstr /C:"max_volume"') do (
            set "volume_2=%%A"
        )
        set "volume_2=!volume_2: =!"
        set "volume_2=!volume_2:dB=!"
        if not defined volume_2 set "volume_2=0"
        echo DEBUG: Lautstärke WIP: "!volume_2!" >> "%log_file%"

        rem Berechnung der Lautstärkeanpassung
        set "adjustment=0"
        for /f "tokens=1,2 delims=." %%A in ("!volume_1!") do (
            set "vol1_int=%%A"
            set "vol1_dec=%%B"
        )
        for /f "tokens=1,2 delims=." %%A in ("!volume_2!") do (
            set "vol2_int=%%A"
            set "vol2_dec=%%B"
        )
        set /a vol1_total=!vol1_int! * 100 + !vol1_dec!
        set /a vol2_total=!vol2_int! * 100 + !vol2_dec!
        set /a adjustment=!vol1_total! - !vol2_total!
        set /a adjustment=adjustment / 100

        echo DEBUG: Lautstärke-Anpassung: "!adjustment! dB" >> "%log_file%"

        rem Zielverzeichnis erstellen, falls es noch nicht existiert
        for %%D in ("!output_file!") do set "target_dir=%%~dpD"
        if not exist "!target_dir!" mkdir "!target_dir!"

        rem Datei anpassen oder kopieren
        if "!adjustment!"=="0" (
            echo DEBUG: Keine Anpassung nötig – Kopiere Datei. >> "%log_file%"
            copy /Y "!compare_file!" "!output_file!" >nul
        ) else (
            echo DEBUG: Passe Lautstärke an um "!adjustment! dB". >> "%log_file%"
            ffmpeg -i "!compare_file!" -af "volume=!adjustment!dB" "!output_file!" >> "%log_file%" 2>&1
        )
    ) else (
        echo WARN: Vergleichsdatei existiert nicht: "!compare_file!" >> "%log_file%"
    )
)

echo. >> "%log_file%"
echo *** DEBUG: Batch-Skript abgeschlossen. *** >> "%log_file%"
pause