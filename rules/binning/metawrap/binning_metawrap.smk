rule binning_metawrap:
    input:
        assembly = "{input_dir}/{sample}/{sample}_me.fa",
        mg_r1 = "{input_dir}/{sample}/{sample}",
        mg_r2 = "{input_dir}/{sample}/{sample}"
    output:
        outdir = directory("{output_dir}/{sample}/binning_metawrap")
    threads: 12
    mamba: "metawrap-env"
    group: "binning"
    benchmark: "{output_dir}/{sample}/benchmarks/binning_metawrap.txt"
    log: "{output_dir}/{sample}/logs/binning_metawrap.txt"
    shell: 
        """
        metaWRAP binning -a {assembly} -o {outdir} -t {threads} {mg_r1} {mg_r2}
        """
