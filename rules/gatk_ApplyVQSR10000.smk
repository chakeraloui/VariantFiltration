rule gatk_ApplyVQSR:
    input:
        vcf = "annotation_filtration/{family}_raw_snps_indels.vcf.gz",
        snps_recal = "annotation_filtration/{family}_raw_snps.recal",
        indels_recal = "annotation_filtration/{family}_raw_indels.recal",
        snps_tranches = "annotation_filtration/{family}_raw_snps.tranches",
        indels_tranches = "annotation_filtration/{family}_raw_snps.tranches"
    output:
        vcf = temp("annotation_filtration/{family}_raw_snps_indels_recalibrated_tmp.vcf.gz"),
        vcf2 = protected("annotation_filtration/{family}_raw_snps_indels_recalibrated.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY'])
    log:
        "logs/ApplyVQSR10000/{family}.log"
    benchmark:
        "benchmarks/ApplyVQSR10000/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Successively apply the indel and SNP recalibrations to the full callset using ApplyVQSR on {input.vcf}"
    shell:
        """ gatk --java-options {params.maxmemory}     ApplyVQSR  \
        -V {input.vcf} \
        --recal-file {input.indels_recal}  \
        --tranches-file {input.indels_tranches}  \
        --truth-sensitivity-filter-level 99.0  \
        --create-output-variant-index true    \
        -mode INDEL  \
        -O {output.vcf} \
        && \
        gatk --java-options {params.maxmemory}   ApplyVQSR   \
        -V {output.vcf}  \
        --recal-file {input.snps_recal}  \
        --tranches-file {input.snps_tranches}     \
        --truth-sensitivity-filter-level 99.7   \
        --create-output-variant-index true \
        -mode SNP  \
        -O {output.vcf2} &> {log}"""
