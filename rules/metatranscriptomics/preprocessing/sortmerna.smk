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
        workdir=temp(directory("/tmp/{sample}_{lane}_paired_sortmerna_workdir"))
    threads: 12
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "{sample}_{lane}/benchmarks/preprocessing_rrna_removal_paired.txt"
    log: "{sample}_{lane}/logs/preprocessing_rrna_removal_paired.txt"
    shell: 
        """ 
        # Run SortMeRNA for paired-end reads
        sortmerna \
                  --workdir {params.workdir} \
                  --ref {params.db_path}/rfam-5.8s-database-id98.fasta \
                  --ref {params.db_path}/silva-arc-16s-id95.fasta \
                  --ref {params.db_path}/silva-bac-16s-id90.fasta \
                  --ref {params.db_path}/silva-euk-18s-id95.fasta \
                  --ref {params.db_path}/rfam-5s-database-id98.fasta \
                  --ref {params.db_path}/silva-arc-23s-id98.fasta \
                  --ref {params.db_path}/silva-bac-23s-id98.fasta \
                  --ref {params.db_path}/silva-euk-28s-id98.fasta \
                  --reads {input.paired_read_1} \
                  --reads {input.paired_read_2} \
                  --threads {threads} \
                  --other /tmp/{params.out_prefix_paired} \
                  --paired_out \
                  --fastx

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
        out_prefix_unpaired = "{sample}_{lane}_SE.non_rrna", # output prefix for unpaired reads
        workdir=temp(directory("/tmp/{sample}_{lane}_unpaired_sortmerna_workdir"))
    threads: 12
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "{sample}_{lane}/benchmarks/preprocessing_rrna_removal_single.txt"
    log: "{sample}_{lane}/logs/preprocessing_rrna_removal_single.txt"
    shell: 
        """
        # Run SortMeRNA for unpaired reads
        sortmerna \
                  --workdir {params.workdir} \
                  --ref {params.db_path}/rfam-5.8s-database-id98.fasta \
                  --ref {params.db_path}/silva-arc-16s-id95.fasta \
                  --ref {params.db_path}/silva-bac-16s-id90.fasta \
                  --ref {params.db_path}/silva-euk-18s-id95.fasta \
                  --ref {params.db_path}/rfam-5s-database-id98.fasta \
                  --ref {params.db_path}/silva-arc-23s-id98.fasta \
                  --ref {params.db_path}/silva-bac-23s-id98.fasta \
                  --ref {params.db_path}/silva-euk-28s-id98.fasta \
                  --reads {input.unpaired_read} \
                  --threads {threads} \
                  --other /tmp/{params.out_prefix_unpaired} \
                  --fastx

        gzip -c /tmp/{params.out_prefix_unpaired}.fastq > {output.rrna_filtered_unpaired_read}
        """
