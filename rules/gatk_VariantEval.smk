rule  VariantEval:
    input:
        vcf = "annotation_filtration/{family}_raw_snps_indels_recalibrated.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        txt = protected("annotation_filtration/{family}_Eval.txt"),
        sorted_vcf = "annotation_filtration/{family}_raw_snps_indels_sorted.recalibrated.vcf.gz",
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
      
    log:
        "logs/VariantEval/{family}.log"
    benchmark:
        "benchmarks/VariantEval{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Compare {input.vcf} callset against a known population callset(dbspn) using VariantEval "
    shell:
        """java -jar   ../tools/picard.jar SortVcf \
        I={input.vcf} \
        O={output.sorted_vcf} \
        && \
        gatk --java-options {params.maxmemory} VariantEval \
        -R {input.refgenome} \
        -eval {output.sorted_vcf} \
        -D {params.dbsnp}  \
        -no-ev  \
        -EV CompOverlap \
        -EV IndelSummary \
        -EV TiTvVariantEvaluator  \
        -EV CountVariants \
        -EV MultiallelicSummary  \
        -O {output.txt} &> {log}"""
