rule magscot_contig_to_bin:
    input:
        concoct_zipfile="%s/{sample}/bins_not_filtered/concoct.zip" % input_dir,
        maxbin_zipfile="%s/{sample}/bins_not_filtered/maxbin.zip" % input_dir,
        metabin_zipfile="%s/{sample}/bins_not_filtered/metabin.zip" % input_dir
    output:
        contig_to_bin="{sample}/contig_to_bin.tsv",
    conda: "../../../envs/magscot_env.yml"
    shadow: "shallow"
    group: "binning"
    benchmark: "{sample}/benchmarks/binning_marker_genes.txt"
    log: "{sample}/logs/binning_marker_genes.txt"
    shell:
       """
       unzip -o {input.metabin_zipfile} -d metabin

       cd metabin 

       ls | xargs -I{{}} bash -c 'paste <(yes "{{}}" | head -n $(grep -c "^>" {{}})) <(grep "^>" {{}} | sed -e "s/>//g") <(yes "metabin" | head -n $(grep -c "^>" {{}}))' | sed -e 's/\.fasta//g' > contig_to_bin_tmp.tsv

       cd ..


       unzip -o {input.concoct_zipfile} -d concoct

       cd concoct

       ls | xargs -I{{}} bash -c 'paste <(yes "{{}}" | head -n $(grep -c "^>" {{}})) <(grep "^>" {{}} | sed -e "s/>//g") <(yes "concoct" | head -n $(grep -c "^>" {{}}))' | sed -e 's/\.fasta//g' > contig_to_bin_tmp.tsv

       cd ..       

       unzip -o {input.maxbin_zipfile} -d maxbin

       cd maxbin

       ls | xargs -I{{}} bash -c 'paste <(yes "{{}}" | head -n $(grep -c "^>" {{}})) <(grep "^>" {{}} | sed -e "s/>//g") <(yes "maxbin" | head -n $(grep -c "^>" {{}}))' | sed -e 's/\.fasta//g' > contig_to_bin_tmp.tsv
       
       cd ..
       
       cat metabin/contig_to_bin_tmp.tsv concoct/contig_to_bin_tmp.tsv maxbin/contig_to_bin_tmp.tsv > {output.contig_to_bin} 
       """


