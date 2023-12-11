# Membrane cleaning repository

This repository contains the code related to the membrane cleaning project. It
covers the following processing/analyses steps:
1. MAG refinement, selection and de-replication
2. Metatranscriptomics read preprocessing
3. Metatranscriptomics based differential expression (DE) analysis

## Snakemake files
Snakemake workflows (in the `wofkflows` folder) are used to call the individual
rules (in the `rules` folder). It also relies on the configuration within the
various `yml` files in the `config` folder. The `envs` folder contains the
recipes for the different python conda/mamba virtual environments used in the
entire workflow.

## Launching analysis on high-performance computing (HPC) cluster
Users can launch the analyis on a slurm-based HPC system using the launcher
scripts located in the `launcher` folder. The launchers can be executed as
follows:
```
$ launchers/sbatch_<launch_name>.sh
```

To ensure that a given launcher is launching the correct jobs, you can call it
using the dry-run option: 
```
$ launchers/sbatch_<launch_name>.sh --dry-run
```

If you want to snakemake to recognised completed analysis, you may use the `touch` directive:
```
$ launchers/sbatch_<launch_name>.sh --touch
```

If an analysis has been unexpectedly halted or corrupted, snakemake may lock
the directory. It can be unlocked as follows: 
```
$ launchers/sbatch_<launch_name>.sh --unlock
```

## Configuration
The `config` folder contains multiple `.yml` configuration files that you can use to set the parameters of 
various programs used within the snakemake rules.

## Reproducibility
The `envs` folder contains the `yml` recipes for the conda environments.
Invoking the workflow in a new (HPC) environment should also install the
necessary programs before the given rules are executed. Wherever possible, the
versions of the programs are also maintained. In some rules, Singularity
container were used instead of conda virtual environments.

## Directory structure
```
├── config
├── docs
│   └── binning_workflow.pdf
├── envs
├── launchers
├── rules
│   ├── annotation
│   │   ├── bakta
│   │   ├── catbat
│   ├── binning
│   │   ├── magscot
│   │   └── metawrap
│   ├── dereplication
│   │   └── drep
│   ├── metagenomics
│   │   └── quantification
│   │       └── salmon
│   └── metatranscriptomics
│       ├── preprocessing
│       └── quantification
│           └── salmon
│               └── all
├── scripts
└── workflows
    ├── annotation.smk
    ├── binning.smk
    ├── dereplication.smk
    ├── metagenomics
    │   └── quantification.smk
    └── metatranscriptomics
        ├── preprocessing.smk
        └── quantification.smk
```
