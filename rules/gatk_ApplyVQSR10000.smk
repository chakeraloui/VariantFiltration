rule gatk_ApplyVQSR:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels_sitesonly.vcf.gz",
        vcf2 = "aligned_reads/{family}_raw_snps_indels_excesshet.vcf.gz",
        snps_recal = "aligned_reads/{family}_raw_snps.recal",
        indels_recal = "aligned_reads/{family}_raw_indels.recal",
        snps_tranches = "aligned_reads/{family}_raw__snps.tranches",
        indels_tranches = "aligned_reads/{family}_raw__snps.tranches"
    output:
        vcf = "aligned_reads/{family}_raw_snps.recalibrated.vcf.gz",
        vcf2 = "aligned_reads/{family}_raw_indels.recalibrated.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        snpFilter = '--filter-expression "ExcessHet > 54.69"  --filter-name ExcessHet'
             
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
        -V {input.vcf2} \
        --recal-file {input.indels_recal}  \
        --tranches-file {input.indels_tranches}  \
        --truth-sensitivity-filter-level 99.0  \
        --create-output-variant-index true    \
        --use-allele-specific-annotations \
        -mode INDEL  \
        -O {output.vcf2} \
        && \
        gatk --java-options {params.maxmemory}   ApplyVQSR   \
        -V {output.vcf2}  \
        --recal-file {input.snps_recal}  \
        --tranches-file {input.snps_tranches}     \
        --truth-sensitivity-filter-level 99.7   \
        --create-output-variant-index true \
        --use-allele-specific-annotations false \
        -mode SNP  \
        -O snp.recalibrated.vcf.gz &> {log}"""