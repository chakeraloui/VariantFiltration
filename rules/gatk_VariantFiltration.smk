rule VariantFiltration:
    input:
         vcf = "aligned_reads/{family}_raw_snps_indels_tmp_combined.g.vcf.gz"
    output:
        vcf = protected("aligned_reads/{family}_raw_snps_indels_hard_filter.vcf")
        
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        intervals = get_wes_intervals_command  
    log:
        "logs/VariantFiltration/{family}.log"
    benchmark:
        "benchmarks/VariantFiltration/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "hard-filter snps & indels on multiple expressions using VariantFiltration on {input.vcf}"
    shell:
        """gatk VariantFiltration  \
        -V {input.vcf} \
        {params intervals} \
        --filter-expression "QD < 2.0 || FS > 30.0 || SOR > 3.0 || MQ < 40.0 || MQRankSum < -3.0 || ReadPosRankSum < -3.0" \        --filter-name "HardFiltered" \
        -O {output.vcf} &> {log}"""
