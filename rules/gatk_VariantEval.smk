rule  VariantEval:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels.vcf",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        txt = protected("aligned_reads/{family}_Eval.txt")
        
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS'])
              
    log:
        "logs/VariantEval/{family}.log"
    benchmark:
        "benchmarks/VariantEval{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Compare {input.vcf} callset against a known population callset(dbspn) using VariantEval "
    shell:
        "gatk --java-options {params.maxmemory} VariantEval -R {input.refgenome} -eval {input.vcf} -D {input.dbsnp}  -noEV  -EV CompOverlap -EV IndelSummary -EV TiTvVariantEvaluator  -EV CountVariants -EV MultiallelicSummary  -o {output.txt} &> {log}"