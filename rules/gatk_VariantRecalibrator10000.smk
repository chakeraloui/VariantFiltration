rule VariantRecalibrator:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels_sitesonly.vcf.gz"
    output:
        snps_recal = protected("aligned_reads/{family}_raw_snps.recal"),
        indels_recal= protected("aligned_reads/{family}_raw_indels.recal"),
        snps_tranches = protected("aligned_reads/{family}_raw_snps.tranches"),
        indels_tranches = protected("aligned_reads/{family}_raw_indels.tranches")
        
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        indelsFilter = '--trust-all-polymorphic -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP -mode INDEL --max-gaussians 4  ',
        snpFilter=    ' --trust-all-polymorphic  -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0  -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP  -mode SNP  --max-gaussians 6  ' 
    log:
        "logs/VariantRecalibrator10000/{family}.log"
    benchmark:
        "benchmarks/VariantRecalibrator1000/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calculate VQSLOD tranches for indels  and snpusing VariantRecalibrator on {input.vcf}"
    shell:
         "gatk   VariantRecalibrator  -V {input.vcf}   -O {output.indels_recal} --tranches-file {output.indels_tranches} && gatk   VariantRecalibrator  -V {input.vcf}  -O {output.snps_recal}   --tranches-file {output.snps_tranches} &> {log}"