rule gatk_FilterFuncotations:
    input:
         vcf = "aligned_reads/{family}_raw_snps_indels_hard_filter_verified_annotated.vcf.gz"
    output:
        vcf = protected( "aligned_reads/{family}_raw_snps_indels_hard_filter_verified_annotated_filtered.vcf.gz")
        
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        ref_version="138"
    log:
        "logs/FilterFuncotations/{family}.log"
    benchmark:
        "benchmarks/FilterFuncotations/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Filtring annotated {input.vcf}"
    shell:
        """gatk --java-options "-Xmx50G" \
        FilterFuncotations \
        --variant {input.vcf} \
        --output {output.vcf} \
        --ref-version {params.ref_version} \
        --allele-frequency-data-source gnomad &>{log}"""