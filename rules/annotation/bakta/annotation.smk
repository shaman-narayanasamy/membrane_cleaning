rule bakta_annotation:
    input:
        bin_fasta = "%s/dereplicated_bins/dereplicated_genomes/{bin_id}.fasta" % input_dir
    output:
        donefile = "bakta/{bin_id}/bakta.done",
        out_dir = directory("bakta/{bin_id}")
    params: 
        db_path=config['bakta']['db_path']
    threads: 12
    conda: 
        "../../../envs/bakta_env.yml"
    container:
        "docker://oschwengers/bakta:latest"
    benchmark: "bakta/{bin_id}/benchmarks/bakta_annotation.txt"
    log: "bakta/{bin_id}/logs/bakta_annotation.txt"
    shell: 
        """ 
        bakta {input.bin_fasta} --force --db {params.db_path} --output {output.out_dir}/ --prefix {wildcards.bin_id}
        touch {output.donefile}
        """
