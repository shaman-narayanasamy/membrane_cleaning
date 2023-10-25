rule drep_dereplication:
    input:
        bins = "{condition}/bin_paths.txt"
    output:
        output_dir = directory("{condition}/dereplicated_bins")
    threads: 16
    conda: 
        "../../../envs/drep_env.yml"
    benchmark: "{condition}/benchmarks/drep_derepliction.txt"
    log: "{condition}/logs/drep.txt"
    shell: 
        """
        dRep dereplicate \
        {output.output_dir} \
        -p {threads} \
        -comp {config[drep][completeness]} \
        -con {config[drep][contamination]} \
        -strW {config[drep][strain_heterogeneity_weight]} \
        --P_ani {config[drep][P_ani]} \
        --S_ani {config[drep][S_ani]} \
        -g {input.bins}
        """
