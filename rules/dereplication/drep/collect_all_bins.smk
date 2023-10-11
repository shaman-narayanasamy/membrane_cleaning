rule drep_collect_all_bins:
    input:
        donefile = expand("{input_dir}/magscot_all.done", input_dir = input_dir),
        sample_bins = expand("{input_dir}/{sample}/magscot_bins", input_dir = input_dir, sample=samples),
        sample_info = config['sample_info']
    output:
        bins = "{condition}/bin_paths.txt"
    group: "dereplication"
    benchmark: "{condition}/benchmarks/collect_all_bins.txt"
    log: "{condition}/logs/collect_all_bins.txt"
    shell:
        """
        ## Define condition based on input

        condition={wildcards.condition}

        ## If conditions are "all" then just list the bins into a single file
        if [ "$condition" == "all" ]; then 
            find {input.sample_bins} -type f | grep ".fasta$" > {output.bins}
        else
            ## If conditions are "treatment"/"control"
            grep -Ff <(cat {input.sample_info} | cut -f1,3 | grep -v "^#" | grep -v "^sample_id" | grep $condition | cut -f1) \
            <(find {input.sample_bins} -type f) | grep ".fasta$" > {output.bins}
        fi
        """

#rule drep_collect_all_bins:
#    input:
#        donefile = expand("{input_dir}/magscot_all.done", input_dir = input_dir),
#        sample_bins = expand("{input_dir}/{sample}/magscot/separate_bins", input_dir = input_dir, sample=samples)
#    output:
#        all_bins = temp("all_bins_path.txt")
#    threads: 12
#    group: "dereplication"
#    benchmark: "benchmarks/collect_all_bins.txt"
#    log: "logs/collect_all_bins.txt"
#    shell:
#        """
#        find {input.sample_bins} -type f > {output.all_bins}
#        """
#
#
#        # Create the output directory
#        mkdir -p {output.all_bins}
#        
#        pushd {output.all_bins} 
#
#        # Soft link the bins from each sample into the all_bins folder
#        for sample_bin in $(ls {input.sample_bins}/*);
#        do
#            ln -s $(realpath $sample_bin) $(basename $sample_bin);
#        done



