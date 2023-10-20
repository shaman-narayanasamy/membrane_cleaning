rule multiqc:
    input:
        expected_outputs,
        raw_files = input_dir,
        processed_files = output_dir
    output:
        report = "multiqc/report.html"
    conda: "../../../envs/multiqc_env.yml"
    benchmark: "multiqc/benchmarks/preprocessing_multiqc.txt"
    log: "multiqc/logs/preprocessing_multiqc.txt"
    shell: 
        """
        multiqc {input.raw_files} {input.processed_files} -o multiqc -n report.html
        """
