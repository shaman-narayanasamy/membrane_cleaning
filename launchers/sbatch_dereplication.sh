#!/bin/bash -l

# NOTE
#   Do NOT push user-specific changes to the repository!
#   Change settings tagged with "USER SETTING" and the SBATCH settings below before using this file.

#SBATCH -J memclean_binning
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 12
#SBATCH -p batch
#SBATCH --time=02-00:00:00
#SBATCH --qos=normal

# ARGS:
#   1: --dry-run for a snakemake dry-run, leave empty for execution

SMK_PRF=""
SMK_FILE="workflows/dereplication.smk"
SMK_JOBS=10 # USER SETTING: number of slurm jobs to be executed in parallel
SMK_ARG="$1" # ARG: add snakemake directives "--dry-run", "--touch" or "--unlock". Empty value will launch the analysis and other values will invoke an error.
SMK_CONFIG="config/config.yml"
SMK_SLURM_CONFIG="config/iris_cluster_config.yml"
SMK_CLUSTER_ARGS="sbatch -p {cluster.partition} --qos {cluster.qos} -N {cluster.nodes} -n {cluster.ntasks} -c {cluster.ncpus} -t {cluster.time} -J {cluster.job-name} -o {cluster.output} -e {cluster.error} --mail-user={cluster.mail-user}"


# Ativate snakemake
source ~/miniconda3/bin/activate snakemake

case "${SMK_ARG}" in
    "--dry-run") echo "Performing dry-run"
        ;;
    "--touch") echo "Touching files"
        ;;
    "--unlock") echo "Unlocking analysis folders"
        ;;
    "") echo "No dry-run"
        ;;
    *) echo "Error: unexpected argument: ${SMK_ARG}"; exit 1
        ;;
esac

snakemake ${SMK_ARG} \
	--rerun-incomplete \
	--use-conda \
	--conda-frontend mamba \
	--cores all \
	-fs ${SMK_FILE} \
	dereplication.done 
