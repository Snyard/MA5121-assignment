# MA5121 Steps 1–3 Complete Submission Bundle

This folder is a polished, submission-ready bundle based on the repository:

Snyard/MA5121-assignment

It includes:
- a bug report and fix summary
- a corrected Nextflow workflow
- a clean configuration file
- adapter sequences
- environment instructions
- empty `data/` and `outputs/` folders

## Quick start

Put your FASTQ file(s) into `data/`, then run:

```bash
nextflow run main.nf
```

If you later have paired-end reads:

```bash
nextflow run main.nf --single_end false --reads './data/*_{1,2}.fq.gz'
```
