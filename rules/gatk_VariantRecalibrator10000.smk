rule VariantRecalibrator:
    input:
        vcf = "annotation_filtration/{family}_raw_snps_indels.vcf.gz"
    output:
        snps_recal = protected("annotation_filtration/{family}_raw_snps.recal"),
        indels_recal= protected("annotation_filtration/{family}_raw_indels.recal"),
        indels_tranches=protected("annotation_filtration/{family}_raw_indels.tranches"),
        snps_tranches= protected("annotation_filtration/{family}_raw_snps.tranches"),
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        indels_resources=get_recal_indels_resources_command,
        snps_resources=get_recal_snps_resources_command,
        plot="annotation_filtration/{family}"
    log:
        "logs/VariantRecalibrator10000/{family}.log"
    benchmark:
        "benchmarks/VariantRecalibrator1000/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calculate VQSLOD tranches for indels  and snpusing VariantRecalibrator on {input.vcf}"
    shell:
         """gatk   VariantRecalibrator  \
         -V {input.vcf}   \
         -O {output.indels_recal} \
         --tranches-file {output.indels_tranches} \
         --trust-all-polymorphic \
         -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 \
         -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 \
         -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
         -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
         -mode INDEL \
         --max-gaussians 4 \
         {params.indels_resources}  \
         --rscript-file {params.plot}_indel1.plots.R \
         &&\
          gatk   VariantRecalibrator  \
          -V {input.vcf}  \
          -O {output.snps_recal}   \
          --tranches-file {output.snps_tranches} \
          --trust-all-polymorphic  \
          -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 \
          -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 \
          -tranche 97.0 -tranche 90.0  \
          -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP  \
          -mode SNP  \
          --max-gaussians 6 \
          {params.snps_resources} \
          --rscript-file {params.plot}_indel1.plots.R \
          &>> {log}"""
