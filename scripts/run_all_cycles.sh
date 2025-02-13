#!/bin/bash

# Define arrays for cycles and phases
cycles=(1 2 3)
phases=("initial" "backflush")
mag_id="TI2_MAGScoT_cleanbin_000096"

# Loop through cycles
for cycle in "${cycles[@]}"
do
    # Loop through phases
    for phase in "${phases[@]}"
    do 
	    outdir="$mag_id/$phase/cycle_$cycle" 
	    # Print the current cycle and phase (replace with your actual commands)
            echo "Processing Cycle $cycle, Phase $phase"

            # Run your commands here for each combination of cycle and phase
            # Example:
	    quarto render ./MAG_cycle_metatranscriptomics_analysis.qmd --to html -P mag_id=$mag_id -P cycle_id=$cycle -P phase_id=$phase --output-dir $outdir

    done
done
