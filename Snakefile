


##### Set up wildcards #####
configfile: "config/config.yaml"
# Define samples from fastq dir and families/cohorts from pedigree dir using wildcards

FAMILIES, = glob_wildcards("../pedigrees/{family}_pedigree.ped")
SAMPLES, = glob_wildcards("VcfToAnnotate/{family}_raw_snps_indels.vcf.gz") # to adapt


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
    
    for resource in config['INDELS-RESOURCES']:
        command += " -resource:" + resource + " "
        
    return command
##################"
def get_recal_snps_resources_command(resource):
    """Return a string, a portion of the gatk BaseRecalibrator command (used in the gatk_BaseRecalibrator and the
    parabricks_germline rules) which dynamically includes each of the recalibration resources defined by the user
    in the configuration file. For each recalibration resource (element in the list), we construct the command by
    adding either --knownSites (for parabricks) or --known-sites (for gatk4) <recalibration resource file>
    """
    
    command = ""
    
    for resource in config['SNPS-RESOURCES']:
        command += " -resource:" + resource + " "
        
    return command
##################"

def get_wes_intervals_command(resource):
    """Return a string, a portion of the gatk command's (used in several gatk rules) which builds a flag
    formatted for gatk based on the configuration file. We construct the command by adding either --interval-file
    (for parabricks) or --L (for gatk4) <exome capture file>. If the user provides nothing for these configurable
    options, an empty string is returned
    """
    
    command = ""
    
    if config['WES']['INTERVALS'] == "":
        command = ""
    
    command = "--L " + config['WES']['INTERVALS'] + " "
    

    return command
##### Target rules #####

if config['VQSR'] == "Yes" or config['VQSR'] == 'yes':
    rule all:
        input:
            #expand("annotation_filtration/{family}_raw_snps.recalibrated.vcf.gz", family = SAMPLES),
            #expand("annotation_filtration/{family}_Eval.txt", family = SAMPLES),
            expand("annotation_filtration/{family}_raw_snps_indels_recalibrated_annotated.vcf.gz",family = SAMPLES)
            

if config['VQSR'] == "No" or config['VQSR'] == 'no':
    rule all:
        input:
            expand("annotation_filtration/{family}_raw_snps.vcf.gz",family = SAMPLES),
            expand("annotation_filtration/{family}_raw_indels.vcf.gz", family = SAMPLES)

##### Load rules #####
#localrules: multiqc

if config['VQSR'] == "No" or config['VQSR'] == "no":
    include: "rules/gatk_VariantFiltration.smk"
    include: "rules/gatk_ValidateVariants.smk"
    include: "rules/gatk_Funcotator.smk"
    include: "rules/gatk_FilterFuncotations.smk"
    include: "rules/gatk_SelectVariants.smk"

if config['VQSR'] == "Yes" or config['VQSR'] == "yes":
    #include: "rules/gatk_VariantFiltration10000.smk"
    include: "rules/gatk_VariantRecalibrator10000.smk"
    include: "rules/gatk_ApplyVQSR10000.smk"
    include: "rules/gatk_VariantEval.smk"
    include: "rules/gatk_Funcotator.smk"



