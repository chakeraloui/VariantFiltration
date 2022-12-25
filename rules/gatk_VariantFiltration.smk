rule VariantFiltration:
    input:
        vcf1 = "aligned_reads/{family}_raw_snps.vcf",
        vcf2 = "aligned_reads/{family}_raw_indels.vcf"
    output:
        vcf1 = protected("aligned_reads/{family}_raw_snps_filtred.vcf.gz"),
        vcf2 = protected("aligned_reads/{family}_raw_indels_filtred.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        snpFilter = '-filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30" -filter "SOR > 3.0" --filter-name "SOR3"    -filter "FS > 60.0" --filter-name "FS60"    -filter "MQ < 40.0" --filter-name "MQ40"    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5"     -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8',
        indelFilter = '-filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30"   -filter "FS > 200.0" --filter-name "FS200"     -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20"'     
    log:
        "logs/VariantFiltration/{family}.log"
    benchmark:
        "benchmarks/VariantFiltration/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "hard-filter snps & indels on multiple expressions using VariantFiltration on {input.vcf1} & {input.vcf1}"
    shell:
        "gatk VariantFiltration  -V {input.vcf1}  {params.snpFilter} -O {output.vcf1} & gatk VariantFiltration   -V {input.vcf2}   -O {output.vcf2} &> {log}"
        
