import subprocess
import pandas as pd

PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
SRCDIR = os.environ.get("SRCDIR", "%s/src" % PWD)
# Default to the processing the directory where all bins from all experimental conditions were dereplicated. This can be adjusted in the snakemake command, if required
CONDITION = os.environ.get("CONDITION", "all")

configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define condition. Input/output directories will be constructed based on this information
condition = CONDITION

## Define input directory
input_dir = os.path.join("/ibex/scratch/projects/c2188/membrane_cleaning/output/dereplication", condition)

## Define output directory
#output_dir = os.path.join("/ibex/scratch/projects/c2188/membrane_cleaning/output/annotation_2", condition)
output_dir = os.path.join("/ibex/user/naras0c/membrane_cleaning/output/annotation_2", condition)

## Get path to directory containing all the bins
bin_directory = os.path.join(input_dir, "dereplicated_bins/dereplicated_genomes")

# List the files in the dereplicated_genomes folder
bin_files = os.listdir(bin_directory)

# Extract the bin IDs from the file names
bin_ids = [bin_files.split(".")[0] for bin_files in bin_files if bin_files.endswith(".fasta")]

workdir:
    output_dir

include:
    '../rules/annotation/bakta/annotation.smk'

include:
    '../rules/annotation/catbat/classification.smk'

rule all:
    input:
        expand("bakta/{bin_id}/bakta.done", bin_id=bin_ids),
        expand("catbat/{db_name}/catbat.done", db_name=["gtdb", "nr"]),
        expand("catbat/{db_name}/catbat_summary.done", db_name=["gtdb", "nr"]),
        expand("catbat/{db_name}/BAT.bin2classification.txt", db_name=["gtdb", "nr"])
    output:
        touch("annotation.done")
