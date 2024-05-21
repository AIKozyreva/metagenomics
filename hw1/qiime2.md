### Analysis of Illumina MiSeq data

Data for analysis two variants: human gut metagenome (mmm)

*deblur takes as input fastq files one by one, dada2 takes as input only the whole bunch of sequenced content per run of sequencing machine, because dada2 algorithm uses the distribution of errors model defined by all reads from this run.

Data for program: https://drive.google.com/drive/folders/1XygG6Hcd-nAY-wD-Wb4uwZZdJjgMVsbw 

_________________________________________________________________________________________________________________________________________________

### Installing QIIME 2 Amplicon Distribution for Linnux (please install version for amplicon analysis from 2023.2, not 2024).
_In the case of usage 2024 version with this commands you will get errors on the denoising step with any data formated as in this guide_

Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment 

```
wget https://data.qiime2.org/distro/core/qiime2-2023.2-py38-linux-conda.yml
conda env create -n qiime2-2023.2 --file qiime2-2023.2-py38-linux-conda.yml
conda activate qiime2-2023.2
qiime --help
```
_________________________________________________________________________________________________________________________________________________

### Data preparing for and import command 

You have to begin with creating manifest.tmp (tab-separated file, where first column is sampleID, the second one is full path to your sample.fastq). When you have the manifest/tmp you will need to convert it into format .qza - qiime2 proccedable binary fileformat, which all qiime2 subprocess work with.

My manifest.tmp will look like this:
```
sample-id     	absolute-filepath
SRR28372428  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/gut_data/SRR28372428.fastq
SRR28372429  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/gut_data/SRR28372429.fastq
SRR28372430  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/gut_data/SRR28372430.fastq
SRR28372423  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/gut_data/SRR28372423.fastq
SRR28372424  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/gut_data/SRR28372424.fastq
```
Okay, then we start import our data into specific qiime2 format .gza (seq.gza will be the output for this step)

```
qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path ./manifest.tmp --output-path ./seq.qza --input-format SingleEndFastqManifestPhred33V2
```
And let's visualize the seq.qza to check if import was done okay and to define values for **--p-trunc-len** and **--p-trim-left** for the following command. Looking at the visualizations result from command, think about what values for these parameters would make sense for our case.
```
qiime demux summarize --i-data seq.qza --o-visualization seq_summary.qzv
```
We can check the quality of imported data, which is seq_summary.qzv, in graphical view on this site: https://view.qiime2.org/ 

_________________________________________________________________________________________________________________________________________________

### Denoising with dada2
We start to analyse data. First of all we have to denoise and filter them by quality and length. It will be performed by dada2, which will also define the unique reads and mark them as "real unique sequence1", while many others which similar to this one, but have a few differences will be marked as "with errors" and throw them away. Each other sequence, whch has strong differences with "real unique sequence1" will be marked as "real unique sequence2" and so on until all reads passed the quality filter will be processed. 

```
qiime dada2 denoise-single --i-demultiplexed-seqs ./seq.qza --p-trunc-len 249 --p-trunc-q 10 --o-table "./denoising/feature_table.qza" --o-representative-sequences "./denoising/rep_seqs.qza" --o-denoising-stats "./denoising/stats.qza" --verbose
```
_-p-trunc-len 249_ and _--p-trunc-q 10_ are parameters which depends on your data quality.   _--verbose_ option helps us to see small part of command log below. 

```
The command(s) being run are below. These commands cannot be manually re-run as they will depend on temporary files that no longer exist.
...
Warning message:
package ‘optparse’ was built under R version 4.2.3
R version 4.2.2 (2022-10-31)
Loading required package: Rcpp
DADA2: 1.26.0 / Rcpp: 1.0.10 / RcppParallel: 5.1.6
2) Filtering ................................
3) Learning Error Rates
252070917 total bases in 1012333 reads from 12 samples will be used for learning the error rates.
4) Denoise samples
................................
5) Remove chimeras (method = consensus)
6) Report read numbers through the pipeline
7) Write output
Saved FeatureTable[Frequency] to: ./denoising/feature_table.qza
Saved FeatureData[Sequence] to: ./denoising/rep_seqs.qza
Saved SampleData[DADA2Stats] to: ./denoising/stats.qza
```
We have got some features and samples data in .qza format. To see information in that files you have to convert files from .gza in .fasta format by the command:
```
qiime tools export --input-path ./denoising/rep_seqs.qza --output-path "./denoising/"
qiime tools export --input-path "denoising/stats.qza" --output-path "denoising/"
```
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/e1720c6b-f1dd-483f-a305-b3090c51e6f0)

_________________________________________________________________________________________________________________________________________________

### Classifing our representative sequences by scklearn classificator based on SILVA database

On this step our sequences will get taxonomy inmormation from SILVAdb by based on this db pretrained classificator algorithm, and then we will get .gza file, and then we will export it in readable one as we have done before.
classify-sklearn with a Naive Bayes classifier outperforms other methods we’ve tested based on several criteria for classification of 16S rRNA gene and fungal ITS sequences. It can be more difficult and frustrating for some users, however, since it requires that additional training step (but in our case we used pretrained data, so it wasn't the problem)
```
qiime feature-classifier classify-sklearn --i-classifier ../silva138_AB_V4_classifier.qza --i-reads denoising/rep_seqs.qza --o-classification "taxonomy/taxonomy.qza" --p-confidence 0.94
qiime tools export --input-path "taxonomy/taxonomy.qza" --output-path "taxonomy"
```
Now we have got the files with taxonomy taxonomy.qza and taxonomy.tsv. taxonomy.tsv will look like that:

![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/2c6d1a1f-abfc-4b40-a9b4-d9b811d38173)

but these files weren't normalised and for now we can't define any meanings as diversity indexes, let's do it in the following step.
_________________________________________________________________________________________________________________________________________________

### Normalisation of data and counting Alpha-diversity by Chao1 index

normalisation by sequencing depth, which is called in microbiome analysis - rarefaction - technique used to standardize the sequencing depth across samples in a dataset.

When sequencing microbiome samples, each sample may have been sequenced to a different depth, meaning some samples have more sequencing reads (i.e., more data) than others. This discrepancy in sequencing depth can introduce bias when comparing diversity metrics between samples, as samples with more sequencing reads may appear to have higher diversity simply because more microbial species were detected due to deeper sequencing. To address this issue, rarefaction involves randomly subsampling the reads within each sample to an even depth, which is typically determined based on the sample with the lowest number of reads (or a predetermined depth). This process ensures that all samples have the same number of sequencing reads, thus providing a fair basis for comparing diversity metrics across samples.



```
mkdir rarefied
qiime feature-table rarefy --i-table "denoising/feature_table.qza" --p-sampling-depth 10000 --o-rarefied-table "rarefied/otus_rar_5K.qza"
```
For defining diversity we will use Chao1 alptha-diversity index, which formula is below. It use the whole amout of abudant species, the species which were 'seemed once' and 'seemed twice' as rare species: 
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/7917ae00-c2e7-457b-8b84-7ed921a75dab)

```
qiime diversity alpha --i-table "rarefied/otus_rar_5K.qza" --p-metric "chao1" --o-alpha-diversity "rarefied/alpha_chao.qza"
qiime tools export --input-path "rarefied/alpha_chao.qza" --output-path "rarefied/alpha_chao.tsv" --output-format "AlphaDiversityFormat"
```
_____________________________________________________________________________________________________________________________________________________


### Make readable taxa tables

```
mkdir otus
qiime tools export --input-path "rarefied/otus_rar_5K.qza" --output-path "otus"
qiime taxa collapse --i-table "rarefied/otus_rar_5K.qza" --i-taxonomy "taxonomy/taxonomy.qza" --p-level 6 --o-collapsed-table "otus/collapse_6.qza"
qiime tools export --input-path "otus/collapse_6.qza" --output-path "otus/summarized_taxa"

biom convert -i "otus/summarized_taxa/feature-table.biom" -o "otus/summarized_taxa/otu_table_L6.txt" --to-tsv
biom convert -i "otus/feature-table.biom" -o "otus/summarized_taxa/otu_table.txt" --to-tsv
```

otu_table_L6.txt 
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/16cb60b9-2fd8-4d77-aa90-52dd044d3242)

otu_table.txt
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/4b06a257-61fd-428b-959b-5e1d5bdc8de9)

_____________________________________________________________________________________________________________________________________________________
### Visualisation 
```
qiime taxa barplot --i-table rarefied/otus_rar_5K.qza --i-taxonomy taxonomy/taxonomy.qza --o-visualization taxonomy/taxa-bar-plots.qzv 
```
