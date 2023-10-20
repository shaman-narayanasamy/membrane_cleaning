rule concatenate_transcripts:
    input:
        expand("{bin_annotation_path}/{bin}/{bin}.ffn", 
               bin_annotation_path=bins_config["bin_annotation_path"], 
               bin=bins_config["bins"])
    output:
        "concatenated_transcripts.fasta"
    shell:
        """
        cat {input} > {output}
        """

rule index_transcripts:
    input:
        transcripts="concatenated_transcripts.fasta"
    output:
        directory("salmon/index")
    shell:
        """
        salmon index -t {input.transcripts} -i {output} --gencode
        """

