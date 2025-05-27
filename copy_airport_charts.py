import os
import shutil
import re
import subprocess

def extract_airport_names(briefing_path):
    dep_airport = None
    arr_airport = None
    alt_airport = None
    with open(briefing_path, encoding="cp1252") as file:
        lines = file.readlines()
    in_comm_ladder = False
    started_parsing = False
    section_endings = [
        "Iff", "Link 16", "Ordnance:", "Weather:", "Support:",
        "Emergency Procedures:", "END_OF_BRIEFING"
    ]
    for idx, line in enumerate(lines):
        if "Comm Ladder:" in line:
            print("Comm Ladder gefunden in Zeile", idx)
            in_comm_ladder = True
            continue
        if in_comm_ladder:
            if not started_parsing and line.strip() == "":
                continue
            started_parsing = True
            if any(line.strip().startswith(se) for se in section_endings):
                print("--- Ende Comm Ladder Abschnitt (wegen neuem Abschnitt) ---")
                break
            print(f"Zeile {idx}: {repr(line)}")  # Debug-Ausgabe aller Zeilen im Abschnitt
            dep_match = re.match(r"^\s*Dep Atis:\s+(.+?)\s+ATIS", line, re.IGNORECASE)
            arr_match = re.match(r"^\s*Arr Atis:\s+(.+?)\s+ATIS", line, re.IGNORECASE)
            alt_match = re.match(r"^\s*Alt Atis:\s+(.+?)\s+ATIS", line, re.IGNORECASE)
            if dep_match:
                print("Dep Match gefunden:", dep_match.group(1))
                dep_airport = dep_match.group(1).strip()
            if arr_match:
                print("Arr Match gefunden:", arr_match.group(1))
                arr_airport = arr_match.group(1).strip()                
            if alt_match:
                print("Alt Match gefunden:", alt_match.group(1))
                alt_airport = alt_match.group(1).strip()
    print(f"extract_airport_names Ergebnis: dep={dep_airport}, arr={arr_airport}, alt={alt_airport}")
    return dep_airport, arr_airport, alt_airport

def clear_and_copy(src_dir, dst_dir):
    print(f"clear_and_copy: src_dir={src_dir}, dst_dir={dst_dir}")
    if not os.path.exists(src_dir):
        print(f"Source directory does not exist: {src_dir}")
        return
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
        print(f"Target directory '{dst_dir}' wurde erstellt.")
    # Remove all files in target directory
    for filename in os.listdir(dst_dir):
        file_path = os.path.join(dst_dir, filename)
        if os.path.isfile(file_path) or os.path.islink(file_path):
            os.unlink(file_path)
            print(f"Datei gelöscht: {file_path}")
        elif os.path.isdir(file_path):
            shutil.rmtree(file_path)
            print(f"Verzeichnis gelöscht: {file_path}")
    # Copy all files from src_dir to dst_dir
    for filename in os.listdir(src_dir):
        src_file = os.path.join(src_dir, filename)
        dst_file = os.path.join(dst_dir, filename)
        if os.path.isfile(src_file):
            shutil.copy2(src_file, dst_file)
            print(f"Datei kopiert: {src_file} -> {dst_file}")

def clear_directory(dir_path):
    print(f"clear_directory: {dir_path}")
    if not os.path.exists(dir_path):
        print(f"Directory does not exist: {dir_path}")
        return
    for filename in os.listdir(dir_path):
        file_path = os.path.join(dir_path, filename)
        if os.path.isfile(file_path) or os.path.islink(file_path):
            os.unlink(file_path)
            print(f"Datei gelöscht: {file_path}")
        elif os.path.isdir(file_path):
            shutil.rmtree(file_path)
            print(f"Verzeichnis gelöscht: {file_path}")

def create_briefing_images(briefing_txt_path, output_dir, lines_per_page=50):
    print(f"create_briefing_images: briefing_txt_path={briefing_txt_path}, output_dir={output_dir}, lines_per_page={lines_per_page}")
    # Read briefing.txt
    with open(briefing_txt_path, encoding="cp1252") as fin:
        all_lines = fin.readlines()
    print(f"Anzahl Zeilen in briefing.txt: {len(all_lines)}")

    # Split into pages
    pages = [all_lines[i:i+lines_per_page] for i in range(0, len(all_lines), lines_per_page)]
    print(f"Briefing wird aufgeteilt in {len(pages)} Seite(n).")
    image_paths = []

    for idx, page_lines in enumerate(pages, 1):
        html_path = os.path.join(output_dir, f"Briefing-BMS-{idx}.html")
        img_path = os.path.join(output_dir, f"Briefing-BMS-{idx}.png")
        print(f"Erzeuge HTML-Datei: {html_path}")
        with open(html_path, "w", encoding="utf-8") as fout:
            fout.write("<html><body><pre style='font-family:Consolas,monospace;font-size:22px;white-space:pre-wrap;word-break:break-word;'>\n")
            for line in page_lines:
                fout.write(line)
            fout.write("\n</pre></body></html>\n")
        # Generate image
        wkhtmltoimage = "bin\wkhtmltoimage.exe"
        print(f"Erzeuge Bild aus HTML: {img_path}")
        try:
            subprocess.run([
                wkhtmltoimage,
                "--width", "1024",
                "--height", "1554",
                "--disable-smart-width",
                "--enable-local-file-access",
                html_path,
                img_path
            ], check=True)
            print(f"Erstellt: {img_path}")
            image_paths.append(img_path)
        except Exception as e:
            print(f"Fehler beim Erstellen von {img_path}: {e}")
        # Clean up html file after conversion (optional)
        try:
            os.remove(html_path)
            print(f"Temporäre HTML-Datei gelöscht: {html_path}")
        except Exception:
            print(f"Temporäre HTML-Datei konnte nicht gelöscht werden: {html_path}")
    return image_paths

def main():
    briefing_file = r"C:\BMS\Falcon BMS 4.37\User\Briefings\briefing.txt"
    charts_base_dir = r"C:\BMS\Falcon BMS 4.37\Docs\03 KTO Charts\01 South Korea"
    dep_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Departure Charts"
    alt_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Alternate Charts"
    arr_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Arrival Charts"
    briefing_image_dir = r"C:\BMS\BMS Apps\BMS Kneeboard\Briefing"

    print(f"Lese Flughafen-Namen aus Briefing: {briefing_file}")
    dep_airport, arr_airport, alt_airport = extract_airport_names(briefing_file)
    if not dep_airport or not arr_airport:
        print("Could not find all Departure and Arrival airport names in briefing.")
        return

    print(f"Departure Airport: {dep_airport}")
    print(f"Arrival Airport: {arr_airport}")
    if alt_airport:
        print(f"Alternate Airport: {alt_airport}")
    else:
        print("No Alternate Airport found in briefing.")

    dep_airport_dir = os.path.join(charts_base_dir, dep_airport)
    arr_airport_dir = os.path.join(charts_base_dir, arr_airport)
    if alt_airport:
        alt_airport_dir = os.path.join(charts_base_dir, alt_airport)

    print(f"Copying departure charts from '{dep_airport_dir}' to '{dep_charts_dst}'...")
    clear_and_copy(dep_airport_dir, dep_charts_dst)

    print(f"Copying arrival charts from '{arr_airport_dir}' to '{arr_charts_dst}'...")
    clear_and_copy(arr_airport_dir, arr_charts_dst)

    if alt_airport:
        print(f"Copying alternate charts from '{alt_airport_dir}' to '{alt_charts_dst}'...")
        clear_and_copy(alt_airport_dir, alt_charts_dst)
    else:
        print("No Alternate Airport: Lösche alle Dateien im Alternate Charts-Verzeichnis ...")
        clear_directory(alt_charts_dst)

    # Create briefing images (multi-page if needed)
    print(f"Erzeuge Briefing-Bilder im Verzeichnis '{briefing_image_dir}' ...")
    if not os.path.exists(briefing_image_dir):
        os.makedirs(briefing_image_dir)
        print(f"Briefing-Verzeichnis erstellt: {briefing_image_dir}")
    image_paths = create_briefing_images(briefing_file, briefing_image_dir, lines_per_page=50)
    print(f"{len(image_paths)} Briefing-Bild(er) wurden erzeugt und nach '{briefing_image_dir}' kopiert.")

    print("Done.")

if __name__ == "__main__":
    main()