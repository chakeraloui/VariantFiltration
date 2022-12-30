rule gatk_Funcotator:
    input:
        vcf = "aligned_reads/{family}_raw_snps_indels_hard_filter_validated.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        vcf = protected("aligned_reads/{family}_raw_snps_indels_hard_filter_verified_annotated.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        dbSNP_vcf = config['dbSNP'],
        intervals = get_wes_intervals_command
    log:
        "logs/Funcotator/{family}.log"
    benchmark:
        "benchmarks/Funcotator/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Annotating {family} vcf using Funcotator "
    shell:
        """{DATA_SOURCES_FOLDER="$PWD/datasources_dir"
        DAT[ ! -e $DATA_SOURCES_TAR_GZ ]] ; then
          DOWNLOADED_DATASOURCES_NAME="downloaded_datasources.tar.gz"
          gatk --java-options "-Xmx~{command_memory}m" FuncotatorDataSourceDownloader --germline --output $DOWNLOADED_DATASOURCES_NAME
          DATA_SOURCES_TAR_GZ=$DOWNLOADED_DATASOURCES_NAME
        fiA_SOURCES_TAR_GZ= data_sources_tar_gz
        if [
        # Extract provided the tar.gz:
        mkdir $DATA_SOURCES_FOLDER
        tar zxvf $DATA_SOURCES_TAR_GZ -C $DATA_SOURCES_FOLDER --strip-components 1
        if ~{use_gnomad_exome}; then
          tar -xzvf $DATA_SOURCES_FOLDER/gnomAD_exome.tar.gz -C $DATA_SOURCES_FOLDER/
        fi
        if {use_gnomad_genome}; then
          tar -xzvf $DATA_SOURCES_FOLDER/gnomAD_genome.tar.gz -C $DATA_SOURCES_FOLDER/
        fi} &&\
        gatk --java-options "-Xmx~{command_memory}m" Funcotator \
        --data-sources-path $DATA_SOURCES_FOLDER \
        --ref-version {params.reference_version} \
        --output-file-format {params.output_format} \
        -R {input.genome} \
        -V {input.vcf} \
        -O {output.vcf} \
        {params.intervals} \
        --transcript-selection-mode true \
        --transcript-list true  \
        --annotation-default true  \
        --annotation-override true  \
        --remove-filtered-variants true &>{log}"""
