#!/bin/bash -l

# ARGS:
#   1: --dry-run for a snakemake dry-run, leave empty for execution

SMK_PRF=""
SMK_FILE="workflows/annotation.smk"
SMK_JOBS=10 # USER SETTING: number of slurm jobs to be executed in parallel
SMK_ARG="$1" # ARG: add snakemake directives "--dry-run", "--touch" or "--unlock". Empty value will launch the analysis and other values will invoke an error.
SMK_CONFIG="config/config.yml"
SMK_SLURM_CONFIG="/home/users/snarayanasamy/repositories/github/membrane_cleaning/config/iris_cluster_config.yml"
SMK_CLUSTER_ARGS="sbatch -p {cluster.partition} -N {cluster.nodes} -n {cluster.ntasks} -c {cluster.ncpus} -t {cluster.time}"

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

CMD="snakemake ${SMK_ARG} \
	-rp \
	--configfile $SMK_CONFIG \
	--conda-prefix /mnt/irisgpfs/users/snarayanasamy/miniconda3/envs \
	--use-conda \
	--conda-frontend mamba \
	--configfile $SMK_CONFIG \
	--jobs $SMK_JOBS \
	--cluster-config ${SMK_SLURM_CONFIG} \
	--cluster \"${SMK_CLUSTER_ARGS}\"  \
	--cluster-cancel scancel \
	--notemp \
	-ks ${SMK_FILE} \
	annotation.done"

echo $CMD
eval $CMD
