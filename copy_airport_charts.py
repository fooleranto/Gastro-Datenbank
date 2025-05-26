import os
import shutil
import re

def extract_airport_names(briefing_path):
    dep_airport = None
    arr_airport = None
    alt_airport = None
    with open(briefing_path, encoding="cp1252") as file:
        lines = file.readlines()
    in_comm_ladder = False
    started_parsing = False
    section_endings = ["Iff", "Link 16", "Ordnance:", "Weather:", "Support:", "Emergency Procedures:", "END_OF_BRIEFING"]
    for idx, line in enumerate(lines):
        if "Comm Ladder:" in line:
            print("Comm Ladder gefunden in Zeile", idx)
            in_comm_ladder = True
            continue
        if in_comm_ladder:
            # Überspringe Leerzeilen zu Beginn des Abschnitts
            if not started_parsing and line.strip() == "":
                continue
            started_parsing = True
            # Prüfe, ob eine neue Überschrift beginnt
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
                
    return dep_airport, arr_airport, alt_airport
    
def clear_and_copy(src_dir, dst_dir):
    if not os.path.exists(src_dir):
        print(f"Source directory does not exist: {src_dir}")
        return
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
    # Remove all files in target directory
    for filename in os.listdir(dst_dir):
        file_path = os.path.join(dst_dir, filename)
        if os.path.isfile(file_path) or os.path.islink(file_path):
            os.unlink(file_path)
        elif os.path.isdir(file_path):
            shutil.rmtree(file_path)
    # Copy all files from src_dir to dst_dir
    for filename in os.listdir(src_dir):
        src_file = os.path.join(src_dir, filename)
        dst_file = os.path.join(dst_dir, filename)
        if os.path.isfile(src_file):
            shutil.copy2(src_file, dst_file)

def main():
    briefing_file = r"C:\BMS\Falcon BMS 4.37\User\Briefings\briefing.txt"
    charts_base_dir = r"C:\BMS\Falcon BMS 4.37\Docs\03 KTO Charts\01 South Korea"
    dep_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Departure Charts"
    alt_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Alternate Charts"
    arr_charts_dst = r"C:\BMS\BMS Apps\BMS Kneeboard\Arrival Charts"


    dep_airport, arr_airport, alt_airport = extract_airport_names(briefing_file)
    if not dep_airport or not arr_airport or not alt_airport:
        print("Could not find all Departure, Alternate and Arrival airport names in briefing.")
        return

    print(f"Departure Airport: {dep_airport}")
    print(f"Arrival Airport: {arr_airport}")
    print(f"Alternate Airport: {alt_airport}")

    dep_airport_dir = os.path.join(charts_base_dir, dep_airport)
    arr_airport_dir = os.path.join(charts_base_dir, arr_airport)    
    alt_airport_dir = os.path.join(charts_base_dir, alt_airport)

    print(f"Copying departure charts from '{dep_airport_dir}' to '{dep_charts_dst}'...")
    clear_and_copy(dep_airport_dir, dep_charts_dst)
    
    print(f"Copying arrival charts from '{arr_airport_dir}' to '{arr_charts_dst}'...")
    clear_and_copy(arr_airport_dir, arr_charts_dst)    

    print(f"Copying alternate charts from '{alt_airport_dir}' to '{alt_charts_dst}'...")
    clear_and_copy(alt_airport_dir, alt_charts_dst)

    print("Done.")

if __name__ == "__main__":
    main()