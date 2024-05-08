# QIIME2 with DADA2, and Naive-bayes classifier pre-trained by Greengenes2_db, Uniref90_db and manually trained for ITS2_db.
QIIME2 version: Amplicon Distribution for Linux Analyse Amplicon metagenome Illumina single-end data 
Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment 
Tutorial for usage deblur: https://docs.qiime2.org/2023.2/tutorials/read-joining/

NB: When we want to use deblur as denoising plugin, we have to mrerge demox sequnces before denoising, while dada2 makes this step automatically. So if you plan to use deblur or OTU clustering methods next, join your sequences now. 

### Step1. Activate env
conda activate qiime2-2023.2
qiime --help

### Step2. Import and demultiplex your data
```
qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path ./manifest.tmp --output-path ./seq.qza --input-format SingleEndFastqManifestPhred33V2
```

demultiplexing can be done with one of the methods described here: 
my data hasalready been demultiplexed, so i won't do it and can go to the next step.

### Step3. Joining data

```
qiime vsearch merge-pairs --i-demultiplexed-seqs seq.qza --o-merged-sequences JOINseq.qza
qiime demux summarize --i-data JOINseq.qza --o-visualization JOINseq.qzv
```
Add some quality control, just for in case:
```
qiime quality-filter q-score --i-demux JOINseq.qza --o-filtered-sequences FJseq.qza --o-filter-stats FJseq-stats.qza
qiime demux summarize --i-data FJseq.qza --o-visualization FJseq.qzv
```

### Step4. Denoising (only for 16S sequences samples) by Deblur
```
qiime deblur denoise-16S --i-demultiplexed-seqs FJseq.qza --p-trim-length 250 --p-sample-stats --o-representative-sequences "./denoising/deblur-rep-seqs.qza" --o-table "./denoising/deblur-table.qza" --o-stats "./denoising/deblur-stats.qza"
qiime feature-table summarize --i-table ./denoising/deblur-table.qza --o-visualization ./denoising/deblur-table.qzv
qiime tools export --input-path "denoising/rep_seqs.qza --output-path "denoising/"
qiime tools export --input-path "denoising/stats.qza" --output-path "denoising/"
```




