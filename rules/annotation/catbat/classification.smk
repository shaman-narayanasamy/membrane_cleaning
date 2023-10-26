rule catbat_classification:
    input:
        bin_folder = "%s/dereplicated_bins/dereplicated_genomes" % input_dir
    output:
        donefile = "catbat/catbat.done",
        bin_classification = "catbat/BAT.bin2classification.txt"
    params: 
        db_path=config['catbat']['db_path'],
        tx_path=config['catbat']['tx_path']
    threads: 24
    conda: 
        "../../../envs/catbat_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/cat:5.2.3--hdfd78af_1"
    shadow: "shallow"
    benchmark: "catbat/benchmarks/catbat_annotation.txt"
    log: "catbat/logs/catbat_annotation.txt"
    shell: 
        """ 
        # Create temporary directory for "corrected" fasta files (required by CAT/BAT)
        mkdir -p {input.bin_folder}/fixed_fasta
        
        # Generate new fasta files without spaces in the header
        for fasta in {input.bin_folder}/*.fasta; do
            base=$(basename "$fasta" .fasta)
            cat "$fasta" | sed -e 's/> />/g' > "{input.bin_folder}/fixed_fasta/${{base}}.fasta"
        done
        
        # Run program on new folder with corrected fasta files
        mkdir -p catbat
	CAT bins -b {input.bin_folder}/fixed_fasta -d {params.db_path} -t {params.tx_path} -n {threads} -s fasta -o catbat/BAT

        touch {output.donefile}
	"""

rule catbat_summary:
    input:
        donefile = "catbat/catbat.done",
        bin_classification = "catbat/BAT.bin2classification.txt"
    output:
        bin_classification_names_added = "catbat/BAT.bin2classification.names_added.txt",
        donefile = "catbat/catbat_summary.done"
    params: 
        db_path=config['catbat']['db_path'],
        tx_path=config['catbat']['tx_path']
    conda: 
        "../../../envs/catbat_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/cat:5.2.3--hdfd78af_1"
    benchmark: "catbat/benchmarks/catbat_summary.txt"
    log: "catbat/logs/catbat_summary.txt"
    shell: 
        """        
        CAT add_names -i {input.bin_classification} -o {output.bin_classification_names_added} -t {params.tx_path} --only_official

        touch {output.donefile}
        """
