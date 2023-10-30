rule sortmerna_index_database:
    input:
        db_path=config['sortmerna']['db_path'],
    output:
        index_path=directory(os.path.join(config['sortmerna']['db_path'], "idx")),
        donefile=os.path.join(config['sortmerna']['db_path'], "indices.done")
    params: 
        db_path=config['sortmerna']['db_path']
    threads: 14
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "benchmarks/sortmerna_index_database.txt"
    log: "logs/sortmerna_index_database.txt"
    shell: 
        """
        sortmerna \
            --index 1 \
            --threads {threads} \
            --ref {params.db_path}/rfam-5.8s-database-id98.fasta \
            --ref {params.db_path}/silva-arc-16s-id95.fasta \
            --ref {params.db_path}/silva-bac-16s-id90.fasta \
            --ref {params.db_path}/silva-euk-18s-id95.fasta \
            --ref {params.db_path}/rfam-5s-database-id98.fasta \
            --ref {params.db_path}/silva-arc-23s-id98.fasta \
            --ref {params.db_path}/silva-bac-23s-id98.fasta \
            --ref {params.db_path}/silva-euk-28s-id98.fasta \
            --workdir {params.db_path}
        touch {output.donefile}
	"""

rule sortmerna_rrna_removal_paired:
    input:
        paired_read_1 = "{sample}_{lane}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}_{lane}_R2.processed.fastq.gz",
        index_donefile=os.path.join(config['sortmerna']['db_path'], "indices.done")
    output:
        rrna_filtered_paired_read_1 = "{sample}_{lane}_R1.processed.filtered.fastq.gz",
        rrna_filtered_paired_read_2 = "{sample}_{lane}_R2.processed.filtered.fastq.gz",
        rrna_filtered_unpaired_read_1 = temp("{sample}_{lane}_unpaired_R1.processed.filtered.fastq.gz"),
        rrna_filtered_unpaired_read_2 = temp("{sample}_{lane}_unpaired_R2.processed.filtered.fastq.gz")
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
                  --idx-dir {params.db_path}/idx \
                  --reads {input.paired_read_1} \
                  --reads {input.paired_read_2} \
                  --threads {threads} \
                  --other /tmp/{params.out_prefix_paired} \
                  --fastx \
                  --out2 \
                  --sout

        # Since SortMeRNA appends _1 and _2 to the file names for paired reads, 
        # and automatically adds .fastq extension, we can just move them directly.
        mv /tmp/{params.out_prefix_paired}_paired_fwd.fq.gz {output.rrna_filtered_paired_read_1}
        mv /tmp/{params.out_prefix_paired}_paired_rev.fq.gz {output.rrna_filtered_paired_read_2}
        mv /tmp/{params.out_prefix_paired}_singleton_fwd.fq.gz {output.rrna_filtered_unpaired_read_1}
        mv /tmp/{params.out_prefix_paired}_singleton_rev.fq.gz {output.rrna_filtered_unpaired_read_2}
        """

rule sortmerna_rrna_removal_single:
    input:
        unpaired_read = "{sample}_{lane}_SE.processed.fastq.gz",
        rrna_filtered_unpaired_read_1 = "{sample}_{lane}_unpaired_R1.processed.filtered.fastq.gz",
        rrna_filtered_unpaired_read_2 = "{sample}_{lane}_unpaired_R2.processed.filtered.fastq.gz",
        index_donefile=os.path.join(config['sortmerna']['db_path'], "indices.done")
    output:
        rrna_filtered_unpaired_read = "{sample}_{lane}_SE.processed.filtered.fastq.gz"
    params: 
        db_path=config['sortmerna']['db_path'],
        out_prefix_unpaired = "{sample}_{lane}_SE.non_rrna", # output prefix for unpaired reads
        workdir=temp(directory("/tmp/{sample}_{lane}_unpaired_sortmerna_workdir"))
    threads: 14
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "{sample}_{lane}/benchmarks/preprocessing_rrna_removal_single.txt"
    log: "{sample}_{lane}/logs/preprocessing_rrna_removal_single.txt"
    shell: 
        """
        # Check if file is empty
        if [[ -s {input.unpaired_read} ]]; then
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
                      --idx-dir {params.db_path}/idx \
                      --reads {input.unpaired_read} \
                      --threads {threads} \
                      --other /tmp/{params.out_prefix_unpaired} \
                      --fastx

            zcat /tmp/{params.out_prefix_unpaired}.fq.gz \
                 {input.rrna_filtered_unpaired_read_1} \
                 {input.rrna_filtered_unpaired_read_2} | gzip > \
                 {output.rrna_filtered_unpaired_read}
        else
            touch {output.rrna_filtered_unpaired_read}
        fi
        """
