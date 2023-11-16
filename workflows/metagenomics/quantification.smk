import subprocess
import yaml
import pandas as pd

PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
# Default to the processing the directory where all bins from all experimental conditions were dereplicated. This can be adjusted in the snakemake command, if required

configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = "/scratch/users/snarayanasamy/membrane_cleaning/MG"

## Define output directory
output_dir = "/scratch/users/snarayanasamy/membrane_cleaning/output/metagenomics/quantification"

## Define input files
# Read the sample table
#sample_table = pd.read_csv(config["mt_data_table"], sep="\t", comment = "#")
[samples] = glob_wildcards("trimmed_paired_{sample}_R1.fastq.gz")


## Define samples, lanes and reads for output file wildcards
#samples = sample_table["sample"].tolist()

workdir:
    output_dir

## All workflow
include:
    '../../rules/metagenomics/quantification/salmon/indexing.smk'

include:
    '../../rules/metagenomics/quantification/salmon/pseudoalignment.smk'

## Isolated bin workflow

rule all:
    input:
        "all_bins.fna",
        "salmon/index/all_bins",
        expand("salmon/all/{sample}_quant", sample = samples)
