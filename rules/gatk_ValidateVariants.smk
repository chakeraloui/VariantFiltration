rule gatk_ValidateVariants:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels_hard_filter.vcf",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        vcf = protected("aligned_reads/{family}_raw_snps_indels_hard_filter_validated.vcf")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        dbSNP_vcf = config['dbSNP'],
        intervals = get_wes_intervals_command,
        recalibration_resources = get_recal_resources_command
    log:
        "logs/ValidateVariants/{family}.log"
    benchmark:
        "benchmarks/ValidateVariants/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "validating {family} vcf using ValidateVariants "
    shell:
        """ gatk --java-options "-Xms6000m -Xmx6500m" \
        ValidateVariants \
        -V {input.vcf} \
        -R {input.refgenome} \
        -L {params.intervals} \
        --validation-type-to-exclude ALLELES \
        --dbsnp {params.dbsnp_vcf} \
        --no-overlaps &>{log}"""