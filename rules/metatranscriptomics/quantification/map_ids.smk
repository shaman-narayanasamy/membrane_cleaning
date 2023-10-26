rule map_ids:
    input:
        bin_annotation_path=config["bin_annotation_path"]
    output:
        mappings = "bin2bakta_id_mappings.tsv",
    shell:
        """
        grep "^>" {input.bin_annotation_path}/*/*.ffn | \
        cut -f2 -d "/" | \
        sed -e 's/.ffn:>/\t/g' | \
        cut -f1 -d' ' | \
        cut -f1,2,3,4 -d_ | \
        sort | uniq > {output.mappings}
        """
