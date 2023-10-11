rule bin_refinement_metawrap: 
    input:
        maxbin_zip "{sample}/bins_not_filtered/max_bin_{sample}.FASTA_SET.zip",
        metabin_zip "{sample}/bins_not_filtered/meta_bin_{sample}.FASTA_SET.zip",
        concoct_zip "{sample}/bins_not_filtered/bin_con_{sample}.FASTA_SET.zip"
    output:
        outdir = directory("{output_dir}/{sample}/bin_refinement_metawrap_metabin_maxbin_concoct")
    params: 
        completeness = config["metawrap"]["bin_refinement"]["completeness"], 
        contamination = config["metawrap"]["bin_refinement"]["contamination"]
    threads: 12
    mamba: "metawrap-env"
    group: "bin_refinement"
    benchmark: "{output_dir}/{sample}/benchmarks/bin_refinement_metawrap.txt"
    log: "{output_dir}/{sample}/logs/bin_refinement_metawrap.txt"
    shell: 
        """
        metaWRAP bin_refinement -A <(unzip -p {input.metabin_zip}) -B <(unzip -p {input.maxbin_zip}) -C <(unzip -p {input.concoct_folder}) -o {output.outdir} -t {threads} -c {params.completeness} -x {params.contamination}
        """
