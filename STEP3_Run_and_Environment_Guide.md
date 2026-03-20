# Step 3 — Configuration, environment, and folder structure

## Files included

- `main.nf` — corrected workflow
- `nextflow.config` — resource settings and reports
- `adapters.fa` — adapter sequences
- `environment.yml` — optional Conda environment
- `data/` — put your FASTQ files here
- `outputs/` — results will be written here

## Local setup

### Option A: create one environment first
```bash
conda env create -f environment.yml
conda activate ma5121_nextflow
nextflow run main.nf
```

### Option B: let Nextflow use Conda automatically
```bash
nextflow run main.nf
```

## Expected folder structure

```text
MA5121_steps1_3_complete/
├── STEP1_Bug_Report_and_Fixes.md
├── STEP2_Corrected_Pipeline.md
├── STEP3_Run_and_Environment_Guide.md
├── main.nf
├── nextflow.config
├── adapters.fa
├── environment.yml
├── data/
└── outputs/
```

