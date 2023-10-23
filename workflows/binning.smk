import subprocess
import pandas as pd

# pwd of the directory where running the snakefile ("/home/users/smartinezarbas/git/gitlab/CRISPR_analysis_pipeline")
PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
SRCDIR = os.environ.get("SRCDIR", "%s/src" % PWD)
 
configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## input directories
input_dir = os.environ.get("input_dir", config['input_dir_binning'])

## Define output directory
output_dir = os.path.join(config['output_dir'], "binning")
 
## Define samples
# Read the sample table
sample_table = pd.read_csv(config["sample_info"], sep="\t", comment = "#")

# Extract the sample IDs
samples = sample_table["sample_id"].tolist()

workdir:
    output_dir 

include:
    '../rules/binning/magscot/marker_genes.smk'

include:
    '../rules/binning/magscot/contig_to_bin.smk'

include:
    '../rules/binning/magscot/bin_refinement.smk'

include:
    '../rules/binning/magscot/separate_bins.smk'

rule master:
    input:
        expand("{sample}/magscot", sample = samples),
        expand("{sample}/contig_to_bin.tsv", sample = samples),
        expand("{sample}/magscot_bins", sample = samples)
    output:
        touch('magscot_all.done')
