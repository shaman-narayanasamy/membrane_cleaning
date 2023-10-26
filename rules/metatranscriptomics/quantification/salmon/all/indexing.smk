rule concatenate_all_transcripts:
    input:
        bin_annotation_path=config["bin_annotation_path"]
    output:
        all_transcripts="all_bin_transcripts.ffn"
    shell:
        """
        cat {input}/*/*.ffn > {output.all_transcripts}
        """

rule index_all_transcripts:
    input:
        all_transcripts="all_bin_transcripts.ffn"
    output:
        index_dir="salmon/index/all_transcripts"
    threads: 14
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "benchmarks/salmon/index/all.txt"
    log: "log/salmon/index/all.log"
    shell:
        """
        salmon index -t {input.all_transcripts} -i {output.index_dir} --gencode -p {threads}
        """
