# Debugging aktivieren (jede Zeile wird ausgegeben)
Set-PSDebug -Trace 2
$ErrorActionPreference = "Stop"

# Konfiguration
$input_dir = "D:\Sounds\Soundoriginal"
$compare_dir = "D:\Sounds\SoundWIPMod"
$output_dir = "D:\Sounds\Soundneu"
$log_file = "D:\Sounds\log.txt"
$debug = $true

function Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $log_file -Value "$timestamp - $message"
    Write-Host "LOG: $message"
}

function Get-RMSAmplitude {
    param ([string]$file_path)
    try {
        Write-Host "DEBUG: Prüfe Lautstärke von $file_path"
        $result = & sox $file_path -n stat 2>&1
        foreach ($line in $result) {
            if ($line -match "RMS\s+amplitude") {
                return [float]$line.Split()[-1]
            }
        }
    } catch {
        $errorMessage = "ERROR in Zeile $($_.InvocationInfo.ScriptLineNumber): $_"
        Log $errorMessage
        throw $_
    }
    return 0.0
}

function Adjust-Volume {
    param ([string]$input_file, [string]$output_file, [float]$adjustment)
    try {
        Write-Host "DEBUG: Passe Lautstärke um $adjustment dB an für $input_file"
        & sox $input_file $output_file gain $adjustment
    } catch {
        $errorMessage = "ERROR in Zeile $($_.InvocationInfo.ScriptLineNumber): $_"
        Log $errorMessage
        throw $_
    }
}

function Process-Files {
    try {
        Log "*** DEBUG: Starte Batch-Skript ***"
        Log "Eingabe-Verzeichnis: $input_dir"
        Log "Vergleichs-Verzeichnis: $compare_dir"
        Log "Ausgabe-Verzeichnis: $output_dir"
        Log "--------------------------------------------"

        Get-ChildItem -Path $input_dir -Recurse -Filter *.ogg | ForEach-Object {
            try {
                $input_file = $_.FullName
                $relative_path = $input_file.Substring($input_dir.Length + 1)
                $compare_file = Join-Path $compare_dir $relative_path
                $output_file = Join-Path $output_dir $relative_path

                Log "DEBUG: Originaldatei: $input_file"
                Log "DEBUG: Vergleichsdatei: $compare_file"
                Log "DEBUG: Zieldatei: $output_file"

                if (Test-Path $compare_file) {
                    $volume_1 = Get-RMSAmplitude -file_path $input_file
                    $volume_2 = Get-RMSAmplitude -file_path $compare_file
                    $adjustment = $volume_1 - $volume_2
                    Log "DEBUG: Lautstärke-Anpassung: $adjustment dB"

                    $output_dir_path = Split-Path $output_file
                    if (-not (Test-Path $output_dir_path)) {
                        New-Item -Path $output_dir_path -ItemType Directory | Out-Null
                    }

                    if ($adjustment -eq 0.0) {
                        Log "DEBUG: Keine Anpassung nötig – Kopiere Datei."
                        Copy-Item -Path $compare_file -Destination $output_file -Force
                    } else {
                        Log "DEBUG: Passe Lautstärke an um $adjustment dB."
                        Adjust-Volume -input_file $compare_file -output_file $output_file -adjustment $adjustment
                    }
                } else {
                    Log "WARN: Vergleichsdatei existiert nicht: $compare_file"
                }
            } catch {
                $errorMessage = "ERROR in Zeile $($_.InvocationInfo.ScriptLineNumber): $_"
                Log $errorMessage
                throw $_
            }
        }

        Log "*** DEBUG: Batch-Skript abgeschlossen. ***"
    } catch {
        $errorMessage = "FATAL ERROR in Zeile $($_.InvocationInfo.ScriptLineNumber): $_"
        Log $errorMessage
        throw $_
    }
}

Process-Files
