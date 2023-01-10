rule gatk_ValidateVariants:
    input:
        vcf = "annotation_filtration/{family}_raw_snps_indels_hard_filter.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        vcf = protected("annotation_filtration/{family}_raw_snps_indels_hard_filter_validated.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        dbSNP_vcf = config['dbSNP'],
        intervals = get_wes_intervals_command
    log:
        "logs/ValidateVariants/{family}.log"
    benchmark:
        "benchmarks/ValidateVariants/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "validating  vcf using ValidateVariants "
    shell:
        """ gatk --java-options "-Xms6000m -Xmx6500m" \
        ValidateVariants \
        -V {input.vcf} \
        -R {input.refgenome} \
        -L {params.intervals} \
        --validation-type-to-exclude ALLELES \
        --dbsnp {params.dbSNP_vcf} \
        --no-overlaps &>{log}"""
