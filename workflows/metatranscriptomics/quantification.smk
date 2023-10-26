import subprocess
import yaml
import pandas as pd

PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
# Default to the processing the directory where all bins from all experimental conditions were dereplicated. This can be adjusted in the snakemake command, if required

configfile: CONFIG

# Load the bins config
with open(config["bins_config"], "r") as file:
    bins_config = yaml.safe_load(file)

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = "/scratch/users/snarayanasamy/membrane_cleaning/output/metatranscriptomics/preprocessing/test"

## Define output directory
output_dir = "/scratch/users/snarayanasamy/membrane_cleaning/output/metatranscriptomics/quantification"

## Define input files
# Read the sample table
sample_table = pd.read_csv(config["mt_data_table"], sep="\t", comment = "#")

## Extract input files based on the output of the preprocessing workflow
#input_files = []
#for _, row in sample_table.iterrows():
#    sample_name = row['sample']
#    lane = row['lane']
#    input_files.append(f"{sample_name}_{lane}_R1.processed.filtered.fastq.gz")
#    input_files.append(f"{sample_name}_{lane}_R2.processed.filtered.fastq.gz")

## Define samples, lanes and reads for output file wildcards
samples = sample_table["sample"].tolist()
lanes = sample_table["lane"].tolist()

workdir:
    output_dir

## All workflow
include:
    '../../rules/metatranscriptomics/quantification/salmon/all/indexing.smk'

include:
    '../../rules/metatranscriptomics/quantification/salmon/all/pseudoalignment.smk'

include:
    '../../rules/metatranscriptomics/quantification/map_ids.smk'

## Isolated bin workflow

rule all:
    input:
        "all_bin_transcripts.ffn",
        "salmon/index/all_transcripts",
        "bin2bakta_id_mappings.tsv",
        expand("salmon/all/{sample}_{lane}_quant", sample = samples, lane = lanes)
