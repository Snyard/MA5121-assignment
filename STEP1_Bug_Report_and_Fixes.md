# Step 1 — Bug report and fixes

This folder is a cleaned and submission-ready version based on the GitHub repository `Snyard/MA5121-assignment`.

## Problems identified in the repository

1. **The pipeline expects paired-end files by default**
   - The repository script uses:
     `params.reads = './data/*_{1,2}.fq.gz'`
     and `Channel.fromFilePairs(...)`.
   - However, the provided repository data folder only clearly exposes a `data/` directory and the user-side run showed only one FASTQ file was available.
   - This causes the common runtime error:
     `No files match pattern *_{1,2}.fq.gz`

2. **Conda was disabled in the repository config**
   - The repository config sets:
     `conda.enabled=false`
   - But the pipeline uses tool environments in the process definition.
   - This makes reproducible local execution harder.

3. **The original pipeline handled only paired-end trimming**
   - The script hardcodes:
     `trimmomatic PE ... ${reads[0]} ${reads[1]}`
   - That fails immediately when only one FASTQ exists.

4. **Resource labels in the config were not connected to process labels**
   - The original config used `withLabel: fastqc` and `withLabel: trimmomatic`,
     but a robust workflow should explicitly label the corresponding processes.

## Fixes implemented here

- Added **paired-end support**
- Added **clear file existence checks**
- Enabled **conda**
- Added **labels** to processes so `nextflow.config` works properly
- Added **execution reports** (`timeline`, `report`, `trace`, `dag`)
- Added a reusable **environment.yml**
- Kept the structure simple and easy to run locally

## Result

This version is much safer for submission because it can run with:
- one FASTQ file (`--single_end true`)
- a proper paired-end dataset (`--single_end false`)
