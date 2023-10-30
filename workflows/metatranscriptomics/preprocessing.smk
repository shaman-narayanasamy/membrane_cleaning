import subprocess
import pandas as pd

PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = "/scratch/users/snarayanasamy/membrane_cleaning/MT"

## Define output directory
output_dir = "/scratch/users/snarayanasamy/membrane_cleaning/output/metatranscriptomics/preprocessing"

## Define input files
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
    expected_outputs.append(f"{sample_name}_{lane}_SE.processed.fastq.gz")
    expected_outputs.append(f"{sample_name}_{lane}_R1.processed.filtered.fastq.gz")
    expected_outputs.append(f"{sample_name}_{lane}_R2.processed.filtered.fastq.gz")
    expected_outputs.append(f"{sample_name}_{lane}_SE.processed.filtered.fastq.gz")

workdir:
    output_dir

include:
    '../../rules/metatranscriptomics/preprocessing/multiqc.smk'

include:
    '../../rules/metatranscriptomics/preprocessing/trimmomatic.smk'

include:
    '../../rules/metatranscriptomics/preprocessing/sortmerna.smk'

rule all:
     input:
        expected_outputs,
        "multiqc/report.html"
