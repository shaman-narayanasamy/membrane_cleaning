rule magscot_marker_genes:
    input:
        contigs = "%s/{sample}/{sample}_me.fa" % input_dir
    output:
        faa = "{sample}/prodigal.faa",
        ffn = "{sample}/prodigal.fna",
        tigr_out = temp("{sample}/hmm.tigr.out"),
        tigr_tab = temp("{sample}/hmm.tigr.hit.out"),
        pfam_out = temp("{sample}/hmm.pfam.out"),
        pfam_tab = temp("{sample}/hmm.pfam.hit.out"),
        markers_hmm = "{sample}/markers.hmm"
    shadow: "shallow"
    params: 
        magscot_folder = config["magscot"]["folder"]
    threads: 12
    conda: "../../../envs/magscot_env.yml"
    group: "binning"
    benchmark: "{sample}/benchmarks/binning_marker_genes.txt"
    log: "{sample}/logs/binning_marker_genes.txt"
    shell: 
        """
        cat {input.contigs} | parallel -j {threads} --block 999k --recstart '>' --pipe prodigal -p meta -a prodigal_temp.{{#}}.faa -d prodigal_temp.{{#}}.ffn -o prodigal_tmpfile

        cat prodigal_temp.*.faa > {output.faa}
        cat prodigal_temp.*.ffn > {output.ffn}
        
        hmmsearch -o {output.tigr_out} --tblout {output.tigr_tab} --noali --notextw --cut_nc --cpu {threads} {params.magscot_folder}/hmm/gtdbtk_rel207_tigrfam.hmm {output.faa}
        hmmsearch -o {output.pfam_out} --tblout {output.pfam_tab} --noali --notextw --cut_nc --cpu {threads} {params.magscot_folder}/hmm/gtdbtk_rel207_Pfam-A.hmm {output.faa}
        
        cat {output.tigr_tab} | grep -v "^#" | awk '{{print $1"\t"$4"\t"$5}}' > {output.markers_hmm}
        cat {output.pfam_tab} | grep -v "^#" | awk '{{print $1"\t"$4"\t"$5}}' >> {output.markers_hmm}
        """

