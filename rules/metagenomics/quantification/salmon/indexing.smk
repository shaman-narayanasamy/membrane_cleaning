rule concatenate_all_mags:
    input:
        bin_annotation_path=config["bin_annotation_path"]
    output:
        all_bins="all_bins.fna"
    shell:
        """
        cat {input}/*/*.fna > {output.all_bins}
        """

rule index_all_mags:
    input:
        all_bins="all_bins.fna"
    output:
        index_dir=directory("salmon/index/all_bins")
    threads: 14
    conda: 
        "../../../../envs/salmon_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "benchmarks/salmon/index/all.txt"
    log: "log/salmon/index/all.log"
    shell:
        """
        salmon index -t {input.all_bins} -i {output.index_dir} --gencode -p {threads}
        """
