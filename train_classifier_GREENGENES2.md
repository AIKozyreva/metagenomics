# QIIME2 with DADA2, and Naive-bayes classifier pre-trained by Greengenes2_db, Uniref90_db and manually trained for ITS2_db.

QIIME2 version: Amplicon Distribution for Linux
Analyse Amplicon metagenome Illumina single-end data
Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment
Page with available databases (only sequences) for classificator training: https://docs.qiime2.org/2024.2/data-resources/
Tutorial how to perform training with usage q2-feature-classifier: https://docs.qiime2.org/2024.2/tutorials/feature-classifier/ 

### Step1. Activate env
```
conda activate qiime2-2023.2
qiime --help
```
### Step2. Import and demultiplex your data
This step was widely described in README.md of this repo

### Step3. Denoising data with DADA2.
This step was widely described in README.md of this repo

### Step4. using pre-trained Naive-bayes classifiers
Taxonomic classifiers perform best when they are trained based on your specific sample preparation and sequencing parameters, including the primers that were used for amplification and the length of your sequence reads.

You can choose the classifier method and find references sequence for training here: https://docs.qiime2.org/2024.2/data-resources/. We will use Naive-bayes classifier/

We will take Greengenes2 2022.10 from 515F/806R region of sequences (gg_2022_10_backbone.v4.nb.qza)

Below i will also try to use someone's trained classifier on Unite db with dinamic identity 97-99%, with data by all eukaryotes from here: https://github.com/colinbrislawn/unite-train/releases/tag/9.0-qiime2-2023.2-demo (unite_ver9_dynamic_all_29.11.2022-Q2-2023.2.qza)

#### Using db Greengenes2 2022.10 from 515F/806R region of sequences (gg_2022_10_backbone.v4.nb.qza) pretrained classifier

```mkdir GG_db_taxonomy
qiime feature-classifier classify-sklearn --i-classifier ../gg_2022_10_backbone.v4.nb.qza --i-reads denoising/rep_seqs.qza --o-classification "GG_db_taxonomy/GGdbtaxonomy.qza" --p-confidence 0.94
qiime tools export --input-path "GG_db_taxonomy/GGdbtaxonomy.qza" --output-path "GG_taxonomy" #we will get GG_taxonomy/taxonomy.tsv file
```

```mkdir GG_db_rarefied
qiime feature-table rarefy --i-table "denoising/feature_table.qza" --p-sampling-depth 10000 --o-rarefied-table "GG_db_rarefied/GG_otus_rar_5K.qza"
qiime diversity alpha --i-table "GG_db_rarefied/GG_otus_rar_5K.qza" --p-metric "chao1" --o-alpha-diversity "GG_db_rarefied/GGalpha_chao.qza"
qiime tools export --input-path "GG_db_rarefied/GGalpha_chao.qza" --output-path "GG_db_rarefied/GG_alpha_chao.tsv" --output-format "AlphaDiversityFormat"
qiime tools export --input-path "GG_db_rarefied/GG_otus_rar_5K.qza" --output-path "GG_otus"
qiime taxa collapse --i-table "GG_db_rarefied/GG_otus_rar_5K.qza" --i-taxonomy "GG_db_taxonomy/GGdbtaxonomy.qza" --p-level 6 --o-collapsed-table "GG_otus/GGcollapse_6.qza"
qiime tools export --input-path "GG_otus/GGcollapse_6.qza" --output-path "GG_otus/GG_summarized_taxa"
biom convert -i "GG_otus/GG_summarized_taxa/feature-table.biom" -o "GG_otus/GG_summarized_taxa/GG_otu_table_L6.txt" --to-tsv
biom convert -i "GG_otus/feature-table.biom" -o "GG_otus/GG_summarized_taxa/GG_otu_table.txt" --to-tsv

qiime taxa barplot --i-table GG_db_rarefied/GG_otus_rar_5K.qza --i-taxonomy GG_db_taxonomy/GGdbtaxonomy.qza --o-visualization GG_taxonomy/GGtaxa-barplots.qzv
```
картинка
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/3a4ac555-88d0-4737-90b7-6781a8f0f66d)


#### Using db Uniref90 97-99% identity for all eukaryotes db (unite_ver9_dynamic_all_29.11.2022-Q2-2023.2.qza) pretrained classifier

```
mkdir uniref_db_taxonomy
qiime feature-classifier classify-sklearn --i-classifier ../unite_ver9_dynamic_all_29.11.2022-Q2-2023.2.qza --i-reads denoising/rep_seqs.qza --o-classification "uniref_db_taxonomy/uni_taxonomy.qza" --p-confidence 0.94
qiime tools export --input-path "uniref_db_taxonomy/uni_taxonomy.qza" --output-path "UNItaxonomy"

```
All other commands described in README.md stay the same and listed below one by one:

```
mkdir uniref_db_rarefied
qiime feature-table rarefy --i-table "denoising/feature_table.qza" --p-sampling-depth 10000 --o-rarefied-table "uniref_db_rarefied/uni_otus_rar_5K.qza"
qiime diversity alpha --i-table "uniref_db_rarefied/uni_otus_rar_5K.qza" --p-metric "chao1" --o-alpha-diversity "uniref_db_rarefied/alpha_chao.qza"
qiime tools export --input-path "uniref_db_rarefied/alpha_chao.qza" --output-path "uniref_db_rarefied/UNI_alpha_chao.tsv" --output-format "AlphaDiversityFormat"
qiime tools export --input-path "uniref_db_rarefied/uni_otus_rar_5K.qza" --output-path "UNI_otus"
qiime taxa collapse --i-table "uniref_db_rarefied/uni_otus_rar_5K.qza" --i-taxonomy "uniref_db_taxonomy/uni_taxonomy.qza" --p-level 6 --o-collapsed-table "UNI_otus/UNIcollapse_6.qza" 
qiime tools export --input-path "UNI_otus/UNIcollapse_6.qza" --output-path "UNI_otus/UNI_summarized_taxa"
biom convert -i "UNI_otus/UNI_summarized_taxa/feature-table.biom" -o "UNI_otus/UNI_summarized_taxa/UNIotu_table_L6.txt" --to-tsv
biom convert -i "UNI_otus/feature-table.biom" -o "UNI_otus/UNI_summarized_taxa/UNI_otu_table.txt" --to-tsv

qiime taxa barplot --i-table uniref_db_rarefied/uni_otus_rar_5K.qza --i-taxonomy uniref_db_taxonomy/uni_taxonomy.qza --o-visualization uniref_db_taxonomy/UNI-taxa-barplots.qzv
```

картинка

#### Manually training Bayes-classifier for ITS2_db and try to use it. 
Tutorial for training is placed in this repo "ITS2_database_development.html" and it was found somewhere in the internet.



