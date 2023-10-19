rule trimmomatic_trimming:
    input:
         read_1 = lambda wildcards: get_input_files(wildcards)['read_1'],
         read_2 = lambda wildcards: get_input_files(wildcards)['read_2']
    output:
        paired_read_1 = "{sample}_{lane}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}_{lane}_R2.processed.fastq.gz",
        unpaired_read_1 = "{sample}_{lane}_R1.unpaired.processed.fastq.gz",
        unpaired_read_2 = "{sample}_{lane}_R2.unpaired.processed.fastq.gz"
    params:
        adapters=config['trimmomatic']['adapters_path']
    conda: "../../../envs/trimmomatic_env.yml"
    benchmark: os.path.join(output_dir, "{sample}_{lane}/benchmarks/preprocessing_trimming.txt")
    log: os.path.join(output_dir, "{sample}_{lane}/logs/preprocessing_trimming.txt")
    shell: 
        """ 
        trimmomatic PE -phred33 \
            {input.read_1} {input.read_2} \
            {output.paired_read_1} {output.unpaired_read_1} \
            {output.paired_read_2} {output.unpaired_read_2} \
            ILLUMINACLIP:{params.adapters}:2:30:10 \
            LEADING:3 \
            TRAILING:3 \
            SLIDINGWINDOW:4:15 \
            MINLEN:36
        """
