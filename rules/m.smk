rule gatk_CollectVariantCallingMetrics:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels_hard_filter_verified.vcf",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        vcf = protected("aligned_reads/{family}_raw_snps_indels_hard_filter_verified.vcf")
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
        """





java -Xms2000m -Xmx2500m -jar /usr/picard/picard.jar \
      CollectVariantCallingMetrics \
      INPUT={input.vcf} \
      OUTPUT=~{metrics_basename} \
      DBSNP=~{dbsnp_vcf} \
      SEQUENCE_DICTIONARY=~{ref_dict} \
      TARGET_INTERVALS=~{evaluation_interval_list} \
      is_gvcf}