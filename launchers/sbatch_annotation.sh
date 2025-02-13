#!/bin/bash -l

# ARGS:
#   1: --dry-run for a snakemake dry-run, leave empty for execution

SMK_PRF=""
SMK_FILE="workflows/annotation.smk"
SMK_JOBS=56 # USER SETTING: number of slurm jobs to be executed in parallel
SMK_ARG="$1" # ARG: add snakemake directives "--dry-run", "--touch" or "--unlock". Empty value will launch the analysis and other values will invoke an error.
SMK_CONFIG="config/config.yml"
SMK_SLURM_CONFIG="/home/naras0c/repositories/github/membrane_cleaning/config/ibex_cluster_config.yml"
#SMK_CLUSTER_ARGS="sbatch -p {cluster.partition} -N {cluster.nodes} -n {cluster.ntasks} -c {cluster.ncpus} -t {cluster.time}"
SMK_CLUSTER_ARGS="sbatch -p {cluster.partition} -N {cluster.nodes} -n {cluster.ntasks} -c {cluster.ncpus} -t {cluster.time} --mem {cluster.mem_gb} --mail-user {cluster.mail-user} --job-name {cluster.job-name} --output {cluster.stdout}"

# Ativate snakemake
#source ~/miniconda3/bin/activate snakemake
module load snakemake/7.32.3

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
	--conda-prefix /ibex/user/naras0c/conda-environments/ \
	--use-conda \
	--conda-frontend mamba \
	--jobs $SMK_JOBS \
	--cluster-config ${SMK_SLURM_CONFIG} \
	--cluster \"${SMK_CLUSTER_ARGS}\"  \
	--cluster-cancel scancel \
	--notemp \
	-ks ${SMK_FILE} \
	catbat/gtdb/catbat_summary.done"
	#annotation.done"

echo $CMD
eval $CMD
