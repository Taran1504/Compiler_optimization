import csv

input_file = "merged_benchmark_results.csv"
output_file = "cleaned_benchmark_results.csv"

with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    # Write header
    writer.writerow(["Benchmark", "Time", "CPU", "Iterations", "Optimization", "Category"])
    
    for row in reader:
        # Skip metadata and empty rows
        if not row or 'BM_' not in row[0]:
            continue

        name = row[0].strip('"')
        
        # Only keep actual measurements (exclude mean/median/stddev/cv)
        if any(x in name for x in ["_mean", "_median", "_stddev", "_cv"]):
            continue
        
        # Extract values
        try:
            cpu_time = float(row[1])
            optimization = row[-2] if len(row) >= 6 else ""
            category = row[-1] if len(row) >= 6 else ""
            
            # Fill dummy values for wall time and iterations if not present
            writer.writerow([name, "", cpu_time, "", optimization, category])
        except ValueError:
            continue