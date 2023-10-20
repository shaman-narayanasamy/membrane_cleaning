rule salmon_quant:
    input:
        index = "salmon/index",  # Salmon index directory
        r1 = "{sample}_{lane}_R1.processed.filtered.fastq.gz",
        r2 = "{sample}_{lane}_R2.processed.filtered.fastq.gz"
    output:
        quant_dir = directory("salmon/{sample}_{lane}_quant")
    params:
        lib_type = "A",  # Automatic detection of library type. Adjust as necessary.
        threads = 12     # Adjust based on available resources
    shell:
        """
        salmon quant -i {input.index} -l {params.lib_type} \
                     -1 {input.r1} -2 {input.r2} \
                     -p {params.threads} \
                     -o {output.quant_dir}
        """

