rule gatk_SelectVariants:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels.vcf",
        
    output:
        vcf1 = protected("aligned_reads/{family}_raw_snps.vcf"),
        vcf2 = protected("aligned_reads/{family}_raw_indels.vcf")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
                
    log:
        "logs/SelectVariants/{family}.log"
    benchmark:
        "benchmarks/SelectVariants/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Subset to SNPs-only and Idels-only callsets with SelectVariants from {input.vcf}"
    shell:
        "gatk SelectVariants  --java-options {params.maxmemory} -V {input.vcf}  -select-type SNP   -O {output.vcf1} & gatk SelectVariants  --java-options {params.maxmemory} -V {input.vcf}   -select-type INDEL  -O {output.vcf2}  &> {log}"