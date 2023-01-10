rule VariantFiltration:
    input:
        vcf = "VcfToAnnotate/{family}_raw_snps_indels.vcf.gz"
    output:
        vcf = protected("annotation_filtration/{family}_raw_snps_indels_excesshet.vcf.gz"),
        vcf2 = protected("annotation_filtration/{family}_raw_snps_indels_sitesonly.vcf.gz"),
        
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        snpFilter = '--filter-expression "ExcessHet > 54.69"  --filter-name ExcessHet'
             
    log:
        "logs/VariantFiltration10000/{family}.log"
    benchmark:
        "benchmarks/VariantFiltration1000/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "HardFilterAndMakeSitesOnlyVcf on {input.vcf}"
    shell:
       """gatk VariantFiltration  \
       -V {input.vcf}  {params.snpFilter} \
       -O {output.vcf} \
       && \
       gatk MakeSitesOnlyVcf -I {output.vcf}  -O {output.vcf2} &> {log}"""
        

