rule gatk_Funcotator:
    input:
        vcf = "annotation_filtration/{family}_raw_snps_indels_recalibrated.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        vcf = protected("annotation_filtration/{family}_raw_snps_indels_recalibrated_annotated.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        dbSNP_vcf = config['dbSNP'],
        intervals = get_wes_intervals_command,
        use_gnomad_exome="true",
        use_gnomad_genome="false",
        reference_version="hg38", #Version of the reference being used.  Either `hg19` or `hg38`.
        output_format = "VCF",
        transcript_selection_mode= "ALL", #The two modes for this parameter are BEST_EFFECT, CANONICAL, and ALL. By default, Funcotator uses the CANONICAL transcript selection mode.
        data_sources_tar_gz=""
    log:
        "logs/Funcotator/{family}.log"
    benchmark:
        "benchmarks/Funcotator/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Annotating {input.vcf} vcf using Funcotator "
    shell:
        """ set -e
         DATA_SOURCES_FOLDER="$PWD/datasources_dir"
        if [ ! -e "datasources_dir" ] ; then
           DATA_SOURCES_TAR_GZ= {params.data_sources_tar_gz}
           if [[ ! -e $DATA_SOURCES_TAR_GZ ]] ; then
             DOWNLOADED_DATASOURCES_NAME="downloaded_datasources.tar.gz"
             gatk --java-options "-Xmx50G" FuncotatorDataSourceDownloader --germline --output $DOWNLOADED_DATASOURCES_NAME
             DATA_SOURCES_TAR_GZ=$DOWNLOADED_DATASOURCES_NAME
           fi
           # Extract provided the tar.gz:
           mkdir $DATA_SOURCES_FOLDER
           tar zxvf $DATA_SOURCES_TAR_GZ -C $DATA_SOURCES_FOLDER --strip-components 1
           if {params.use_gnomad_exome}; then
             tar -xzvf $DATA_SOURCES_FOLDER/gnomAD_exome.tar.gz -C $DATA_SOURCES_FOLDER/
           fi
           if {params.use_gnomad_genome}; then
             tar -xzvf $DATA_SOURCES_FOLDER/gnomAD_genome.tar.gz -C $DATA_SOURCES_FOLDER/
           fi 
        else
           :
        fi  """        
        """
        gatk --java-options "-Xmx50g" Funcotator \
        --data-sources-path $DATA_SOURCES_FOLDER \
        --ref-version {params.reference_version} \
        --output-file-format {params.output_format} \
        -R {input.refgenome} \
        -V {input.vcf} \
        -O {output.vcf} \
        {params.intervals} \
        --transcript-selection-mode ALL \
           \
        --annotation-default Center:broad.mit.edu  \
          \
         """
