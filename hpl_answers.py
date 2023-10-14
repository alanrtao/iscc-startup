```
#!/usr/bin/env python3

import os
import re

hpl_runs_home_dir = "hpl_openmpi_IntelLAlib"

with open(hpl_runs_home_dir + "_runs.csv", "w") as outfile:
    outfile.write("nodes,cpus,T/V,N,NB,P,Q,Time,Gflops\n")

for dir_paths, subdir_contents, files in os.walk(hpl_runs_home_dir):
    for file in files:
        if file.endswith("stdout_hpl_test"):  # CHANGE string to match HPL stdout outfile.
            file_contents = open(os.path.join(dir_paths, file), "r")
            nodes_cpus = re.search("nodes([0-9]+)cpus([0-9]+)", dir_paths)
            for lines in file_contents:
                if lines.endswith("Gflops\n"):
                    dashed_line = next(file_contents)  # Do not remove. It's a useless variable, but it is needed to call the next line.
                    output_line = next(file_contents).split(" ")
                    #print(output_line)
                    output_line2 = list(filter(None, output_line))
                    #print(output_line2)
                    with open(hpl_runs_home_dir + "_runs.csv", "a") as outfile:
                        outfile.write(nodes_cpus.group(1) + "," + nodes_cpus.group(2) + "," + ",".join(output_line2))
```