


##### Set up wildcards #####
configfile: "./config/config.yaml"
# Define samples from fastq dir and families/cohorts from pedigree dir using wildcards

FAMILIES, = glob_wildcards("../pedigrees/{family}_pedigree.ped")
SAMPLES, = glob_wildcards("aligned_reads/{family}_raw_snps_indels.vcf") # to adapt


##### Setup helper functions #####
import csv
import glob

def get_recal_indels_resources_command(resource):
    """Return a string, a portion of the gatk BaseRecalibrator command (used in the gatk_BaseRecalibrator and the
    parabricks_germline rules) which dynamically includes each of the recalibration resources defined by the user
    in the configuration file. For each recalibration resource (element in the list), we construct the command by
    adding either --knownSites (for parabricks) or --known-sites (for gatk4) <recalibration resource file>
    """
    
    command = ""
    
    for resource in config['INDELS']['RESOURCES']:
        command += " -resource: " + resource + " "
        
    return command
##################"
def get_recal_snps_resources_command(resource):
    """Return a string, a portion of the gatk BaseRecalibrator command (used in the gatk_BaseRecalibrator and the
    parabricks_germline rules) which dynamically includes each of the recalibration resources defined by the user
    in the configuration file. For each recalibration resource (element in the list), we construct the command by
    adding either --knownSites (for parabricks) or --known-sites (for gatk4) <recalibration resource file>
    """
    
    command = ""
    
    for resource in config['SNPS']['RESOURCES']:
        command += " -resource: " + resource + " "
        
    return command
##################"

##### Target rules #####

if config['VQSR'] == "Yes" or config['VQSR'] == 'yes':
    rule all:
        input:
            expand("aligned_reads/{family}_raw_snps.recalibrated.vcf.gz", family = SAMPLES),
            expand("aligned_reads/{family}_raw_snps.recalibrated.vcf.gz", family = SAMPLES),
            

if config['VQSR'] == "No" or config['VQSR'] == 'no':
    rule all:
        input:
            expand("aligned_reads/{family}_raw_snps_filtred.vcf.gz",family = SAMPLES),
            expand("aligned_reads/{family}_raw_indels_filtred.vcf.gz", family = SAMPLES)

##### Load rules #####
#localrules: multiqc

if config['VQSR'] == "No" or config['VQSR'] == "no":
    include: "rules/gatk_SelectVariants.smk"
    include: "rules/gatk_VariantFiltration.smk"
    

if config['VQSR'] == "Yes" or config['VQSR'] == "yes":
    include: "rules/gatk_VariantFiltration10000.smk"
    include: "rules/gatk_VariantRecalibrator10000.smk"
    include: "rules/gatk_ApplyVQSR10000.smk"



