rule sortmerna_rrna_removal_paired:
    input:
        paired_read_1 = "{sample}_{lane}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}_{lane}_R2.processed.fastq.gz",
    output:
        rrna_filtered_paired_read_1 = "{sample}_{lane}_R1.processed.filtered.fastq.gz",
        rrna_filtered_paired_read_2 = "{sample}_{lane}_R2.processed.filtered.fastq.gz",
    params: 
        db_path=config['sortmerna']['db_path'],
        out_prefix_paired = "{sample}_{lane}_tmp_paired.non_rrna", # output prefix for paired reads
    threads: 12
    conda: "../../../envs/sormterna_env.yml"
    benchmark: "{sample}_{lane}/benchmarks/preprocessing_rrna_removal_paired.txt"
    log: "{sample}_{lane}/logs/preprocessing_rrna_removal_paired.txt"
    shell: 
        """ 
        # Run SortMeRNA for paired-end reads
        sortmerna --ref {params.db_path} \
                  --reads {input.paired_read_1} \
                  --reads {input.paired_read_2} \
                  --threads {threads} \
                  --other /tmp/{params.out_prefix_paired} \
                  --paired_out

        # Since SortMeRNA appends _1 and _2 to the file names for paired reads, 
        # and automatically adds .fastq extension, we can just move them directly.
        gzip -c /tmp/{params.out_prefix_paired}_1.fastq > {output.rrna_filtered_paired_read_1}
        gzip -c /tmp/{params.out_prefix_paired}_2.fastq > {output.rrna_filtered_paired_read_2}
        """

rule sortmerna_rrna_removal_single:
    input:
        unpaired_read = "{sample}_{lane}_SE.processed.fastq.gz"
    output:
        rrna_filtered_unpaired_read = "{sample}_{lane}_SE.processed.filtered.fastq.gz"
    params: 
        db_path=config['sortmerna']['db_path'],
        out_prefix_unpaired = "{sample}_{lane}_SE.non_rrna" # output prefix for unpaired reads
    threads: 12
    conda: "../../../envs/sormterna_env.yml"
    benchmark: "{sample}_{lane}/benchmarks/preprocessing_rrna_removal_single.txt"
    log: "{sample}_{lane}/logs/preprocessing_rrna_removal_single.txt"
    shell: 
        """
        # Run SortMeRNA for unpaired reads
        sortmerna --ref {params.db_path} \
                  --reads {input.unpaired_read} \
                  --threads {threads} \
                  --other /tmp/{params.out_prefix_unpaired}

        gzip -c /tmp/{params.out_prefix_unpaired}.fastq > {output.rrna_filtered_unpaired_read}
        """

