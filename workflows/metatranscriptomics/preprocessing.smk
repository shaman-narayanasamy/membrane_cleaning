import subprocess
import pandas as pd

PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
# Default to the processing the directory where all bins from all experimental conditions were dereplicated. This can be adjusted in the snakemake command, if required

configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = "/scratch/users/snarayanasamy/membrane_cleaning/MT"

## Define output directory
output_dir = "/scratch/users/snarayanasamy/membrane_cleaning/output/metatranscriptomics/preprocessing"

## Define samples
# Read the sample table
sample_table = pd.read_csv(config["mt_data_table"], sep="\t", comment = "#")

## Extract input files and sample names
def get_input_files(wildcards):
    subset = sample_table[(sample_table['sample'] == wildcards.sample) & (sample_table['lane'] == wildcards.lane)]
    
    read_1 = os.path.join(input_dir, subset['R1'].iloc[0])
    read_2 = os.path.join(input_dir, subset['R2'].iloc[0])
    
    return {"read_1": read_1, "read_2": read_2}

# Generate list of expected outputs
expected_outputs = []
for _, row in sample_table.iterrows():
    sample_name = row['sample']
    lane = row['lane']
    expected_outputs.append(f"{sample_name}_{lane}_R1.processed.fastq.gz")
    expected_outputs.append(f"{sample_name}_{lane}_R2.processed.fastq.gz")

workdir:
    output_dir

#include:
#    '../../rules/metatranscriptomics/preprocessing/multiqc.smk'

include:
    '../../rules/metatranscriptomics/preprocessing/trimmomatic.smk'

#include:
#    '../../rules/metatranscriptomics/preprocessing/sortmerna.smk'

#print("Expected outputs:")
#expected_outputs=expand("{sample_name}_{lane}_{read}.processed.fastq.gz", sample_name=sample_names, lane=lanes, read=reads)
#
#print(expected_outputs)

rule all:
    input:
        expected_outputs
        #expand("{sample}_{lane}_{read}.processed.fastq.gz", sample_name=sample_names, lane=lanes, read=reads)
