import subprocess
import pandas as pd

# pwd of the directory where running the snakefile ("/home/users/smartinezarbas/git/gitlab/CRISPR_analysis_pipeline")
PWD = os.getcwd()

# Definition of environmental variables: paths for the source codes, among others
CONFIG = os.environ.get("CONFIG", "%s/config/config.yml" % PWD)
SRCDIR = os.environ.get("SRCDIR", "%s/src" % PWD)

configfile: CONFIG

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = os.environ.get("input_dir", config['input_dir_dereplication'])

## Define output directory
output_dir = os.path.join(os.environ.get("output_dir", config['output_dir']), "dereplication")

## Define samples
# Read the sample table
sample_table = pd.read_csv(config["sample_info"], sep="\t", comment="#")

# Extract the sample IDs and conditions
samples = sample_table["sample_id"].tolist()
conditions = list(set(sample_table["condition"].tolist() + ["all"]))

workdir:
    output_dir

include:
    '../rules/dereplication/drep/collect_all_bins.smk'

include:
    '../rules/dereplication/drep/dereplication.smk'


# Target rule
rule master:
    input:
        expand("{condition}/dereplicated_bins", condition = conditions)
    output:
        touch('dereplication.done')

