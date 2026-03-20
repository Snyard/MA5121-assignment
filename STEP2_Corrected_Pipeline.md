# Step 2 — Corrected Nextflow pipeline

The corrected pipeline is stored in `main.nf`.

## What it does


### Paired-end mode
- detects pairs from a glob such as:
  `./data/*_{1,2}.fq.gz`
- runs FastQC on both mates
- runs Trimmomatic in PE mode
- writes trimmed and discarded reads to `outputs/`


### Run in paired-end mode 
```bash
nextflow run main.nf --single_end false --reads './data/*_{1,2}.fq.gz'
```
