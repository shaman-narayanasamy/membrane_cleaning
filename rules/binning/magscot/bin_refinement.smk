rule magscot_bin_refinement:
    input:
        contig_to_bin = "{sample}/contig_to_bin.tsv",
        markers_hmm = "{sample}/markers.hmm"
    output:
        outdir = ensure(directory("{sample}/magscot"), non_empty = True),
        binning_results="{sample}/magscot/MAGScoT.refined.contig_to_bin.out"
    params: magscot_folder = config["magscot"]["folder"]
    conda: "../../../envs/magscot_env.yml"
    group: "binning"
    benchmark: "{sample}/benchmarks/binning_magscot.txt"
    log: "{sample}/logs/binning_magscot.txt"
    shell: 
        """
        mkdir -p {wildcards.sample}/magscot
        Rscript {params.magscot_folder}/MAGScoT.R -i {input.contig_to_bin} --hmm {input.markers_hmm} -o {wildcards.sample}/magscot/MAGScoT
        """
