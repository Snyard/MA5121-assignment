#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
 MA5121 Nextflow assignment - corrected complete version
 Supports both paired-end and single-end FASTQ input.

 Examples:
   nextflow run main.nf
   nextflow run main.nf --single_end true --reads './data/*.fq.gz'
   nextflow run main.nf --reads '/full/path/*_{1,2}.fq.gz' --adapters '/full/path/adapters.fa'
*/

params.reads      = params.reads ?: './data/*.fq.gz'
params.outdir     = params.outdir ?: './outputs'
params.adapters   = params.adapters ?: './adapters.fa'
params.single_end = (params.single_end != null) ? params.single_end : true

log.info """
MA5121 NEXTFLOW ASSIGNMENT
================================
Reads          : ${params.reads}
Output folder  : ${params.outdir}
Adapters       : ${params.adapters}
Single-end     : ${params.single_end}
"""

if( !file(params.adapters).exists() ) {
    error "Adapter file not found: ${params.adapters}"
}

if( params.single_end ) {
    reads_ch = Channel
        .fromPath(params.reads, checkIfExists: true)
        .ifEmpty { error "No FASTQ files found for pattern: ${params.reads}" }
        .map { fq -> tuple(fq.baseName.replaceFirst(/\.fq\.gz$/, ''), fq) }
}
else {
    reads_ch = Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .ifEmpty { error "No paired FASTQ files found for pattern: ${params.reads}" }
        .map { sample, reads -> tuple(sample, reads) }
}

adapter_ch = Channel.fromPath(params.adapters, checkIfExists: true)

process FASTQC_SINGLE {
    tag "$sample"
    label 'fastqc'

    publishDir "${params.outdir}/quality-control-${sample}", mode: 'copy', overwrite: true

    conda 'bioconda::fastqc=0.12.1'

    input:
    tuple val(sample), path(read)

    output:
    path("*_fastqc.html")
    path("*_fastqc.zip")

    script:
    """
    fastqc ${read}
    """
}

process FASTQC_PAIRED {
    tag "$sample"
    label 'fastqc'

    publishDir "${params.outdir}/quality-control-${sample}", mode: 'copy', overwrite: true

    conda 'bioconda::fastqc=0.12.1'

    input:
    tuple val(sample), path(reads)

    output:
    path("*_fastqc.html")
    path("*_fastqc.zip")

    script:
    """
    fastqc ${reads[0]} ${reads[1]}
    """
}

process TRIMMOMATIC_SINGLE {
    tag "$sample"
    label 'trimmomatic'

    publishDir "${params.outdir}/trimmed-reads-${sample}", mode: 'copy', overwrite: true

    conda 'bioconda::trimmomatic=0.39'

    input:
    tuple val(sample), path(read)
    path adapters_file

    output:
    tuple val(sample), path("${sample}.trimmed.fq.gz"), emit: trimmed_reads
    tuple val(sample), path("${sample}.discarded.fq.gz"), emit: discarded_reads

    script:
    """
    trimmomatic SE -phred33 \
      ${read} \
      ${sample}.trimmed.fq.gz \
      ILLUMINACLIP:${adapters_file}:2:30:10 \
      MINLEN:36 \
      2> ${sample}.trimmomatic.log

    # Placeholder discarded file to keep output structure consistent
    touch ${sample}.discarded.fq.gz
    """
}

process TRIMMOMATIC_PAIRED {
    tag "$sample"
    label 'trimmomatic'

    publishDir "${params.outdir}/trimmed-reads-${sample}", mode: 'copy', overwrite: true

    conda 'bioconda::trimmomatic=0.39'

    input:
    tuple val(sample), path(reads)
    path adapters_file

    output:
    tuple val(sample), path("${sample}_1.trimmed.fq.gz"), path("${sample}_2.trimmed.fq.gz"), emit: paired_trimmed
    tuple val(sample), path("${sample}_1.discarded.fq.gz"), path("${sample}_2.discarded.fq.gz"), emit: paired_discarded

    script:
    """
    trimmomatic PE -phred33 \
      ${reads[0]} ${reads[1]} \
      ${sample}_1.trimmed.fq.gz ${sample}_1.discarded.fq.gz \
      ${sample}_2.trimmed.fq.gz ${sample}_2.discarded.fq.gz \
      ILLUMINACLIP:${adapters_file}:2:30:10 \
      MINLEN:36 \
      2> ${sample}.trimmomatic.log
    """
}

workflow {
    if( params.single_end ) {
        FASTQC_SINGLE(reads_ch)
        TRIMMOMATIC_SINGLE(reads_ch, adapter_ch)
    } else {
        FASTQC_PAIRED(reads_ch)
        TRIMMOMATIC_PAIRED(reads_ch, adapter_ch)
    }
}
