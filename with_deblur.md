# QIIME2 with deblur, and Naive-bayes classifier pre-trained by SILVA_db.
QIIME2 version: Amplicon Distribution for Linux for Analyse Amplicon metagenome Illumina single-end data 
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

### Step3. Joining data (this step only if you have had paired-end data)

```
#qiime vsearch merge-pairs --i-demultiplexed-seqs seq.qza --o-merged-sequences JOINseq.qza
#qiime demux summarize --i-data JOINseq.qza --o-visualization JOINseq.qzv
```
### Step4. Add some quality control, just for in case:
```
qiime quality-filter q-score --i-demux JOINseq.qza --o-filtered-sequences FJseq.qza --o-filter-stats FJseq-stats.qza
qiime demux summarize --i-data FJseq.qza --o-visualization FJseq.qzv
```

### Step5. Denoising (only for 16S sequences samples) by Deblur
```
qiime deblur denoise-16S --i-demultiplexed-seqs FJseq.qza --p-trim-length 250 --p-sample-stats --o-representative-sequences "./denoising/deblur-rep-seqs.qza" --o-table "./denoising/deblur-table.qza" --o-stats "./denoising/deblur-stats.qza"
qiime feature-table summarize --i-table ./denoising/deblur-table.qza --o-visualization ./denoising/deblur-table.qzv
qiime tools export --input-path ./denoising/deblur-rep_seqs.qza --output-path "denoising/"
qiime tools export --input-path ./denoising/deblur-stats.qza" --output-path "denoising/"
```
### Step6. Classification with Bayes pretraind on SILVA db

```
qiime feature-classifier classify-sklearn --i-classifier ../silva138_AB_V4_classifier.qza --i-reads denoising/deblur-rep_seqs.qza --o-classification "deblur-taxonomy/deblur-taxonomy.qza" --p-confidence 0.94
qiime tools export --input-path "deblur-taxonomy/deblur-taxonomy.qza" --output-path "DeblurTaxonomy"
```
### Step7. Normalisation of data and counting Alpha-diversity by Chao1 index
```
mkdir deblur-rarefied
qiime feature-table rarefy --i-table "denoising/deblur-table.qza" --p-sampling-depth 10000 --o-rarefied-table "deblur-rarefied/deblur_otus_rar_5K.qza"
qiime diversity alpha --i-table "deblur-rarefied/deblur_otus_rar_5K.qza" --p-metric "chao1" --o-alpha-diversity "deblur-rarefied/deblur-alpha_chao.qza"
qiime tools export --input-path "deblur-rarefied/deblur-alpha_chao.qza" --output-path "deblur-rarefied/deblur-alpha_chao.tsv" --output-format "AlphaDiversityFormat"
```

### Step8. Visualization
```
qiime taxa barplot --i-table deblur-rarefied/deblur_otus_rar_5K.qza --i-taxonomy deblur-taxonomy/deblur-taxonomy.qza --o-visualization deblur-taxonomy/deblur-taxa-barplots.qzv 
```

картинка 





