


##### Set up wildcards #####
configfile: "./config/config.yaml"
# Define samples from fastq dir and families/cohorts from pedigree dir using wildcards

FAMILIES, = glob_wildcards("../pedigrees/{family}_pedigree.ped")
SAMPLES, = glob_wildcards("aligned_reads/{family}_raw_snps_indels.vcf") # to adapt


##### Setup helper functions #####
import csv
import glob


 
rule all:
    input:
        expand("aligned_reads/{family}_raw_snps_filtred.vcf.gz",family = SAMPLES),
        expand("aligned_reads/{family}_raw_indels_filtred.vcf.gz", family = SAMPLES)
            

##### Load rules #####

include: "rules/gatk_VariantEval.smk"
include: "rules/gatk_SelectVariants.smk"
include: "rules/gatk_VariantFiltration.smk"
