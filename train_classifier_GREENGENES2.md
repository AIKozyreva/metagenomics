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

Ничего особенно не поменялось, мои несколько образцовв всё также не определяются, вероятно я взяла пллохие образцы, но хотя бы можно сделат вывод, что небольшая разница в идетификации есть, но она почти незаметна. 


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
![image](https://github.com/AIKozyreva/metagenomics/assets/74992091/46dc516c-8788-4832-a04f-e049f70d09a9)

картинка. Так мы можем видеть что если сделать те же действия с бд в которой растения и грибы, то мы сможем понять какие люди что кушали. вот кто-то кушал растения и грибочки...

### Step5. Manually training Bayes-classifier for ITS2_db and try to use it. 
Tutorial for training is placed in this repo "ITS2_database_development.html" and it was found somewhere in the internet.
Manual training of classifier require to have two items: _collection of reference sequences_ and _taxonomy file_ wich will correlate with this collection.

#### Collecting reference sequences for future classifier
Go to NCBI and download all sequences ITS2 for all green plants in fasta/ Now we will have file sequence.fasta with reference sequences for our future db.
Next step is to get the acsessions of all sequences, find for them taxonomy on NCBI, download taxonomy list and then create a file, where we will combina taxonomy with acsession numbers/

```
mv sequence.fasta NCBI_Viridiplantae_ITS2_fasta_file #rename file and check amount of records
grep -c ">" NCBI_Viridiplantae_ITS2_fasta_file # we have **250572** in my case
```

NCBI nucleotide sequences downloaded in FASTA format contain linebreaks every 70 bases (for comfortable reading). Since such structure may influent further processing steps, these linebreaks should be removed:

```
awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" }END { printf "%s", n }' NCBI_Viridiplantae_ITS2_fasta_file > NCBI_Viridiplantae_ITS2_fasta_file_tmp
mv NCBI_Viridiplantae_ITS2_fasta_file_tmp NCBI_Viridiplantae_ITS2_fasta_file
```

#### Collecting the taxonomic identifiers (taxids) of the organisms from which ITS2 sequences were obtained
Some of the following commands will take a lot of time, that's ok. Start with creating a table linking every accession number to the corresponding nucleotide sequence. 

```
grep ">" NCBI_Viridiplantae_ITS2_fasta_file | cut -d ">" -f 2 | cut -d " " -f 1 > AccessionNumbers
paste <(cat AccessionNumbers) <(sed '/^>/d' NCBI_Viridiplantae_ITS2_fasta_file) > AccessionNumbers_seqs_linking_table
```
The “nucl_gb.accession2taxid” NCBI reference file must then be downloaded from their FTP website (https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/)
(NB: 2Gb file to download and 10Gb after decompression):

```
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
gzip -d nucl_gb.accession2taxid.gz
```
Retrieving lines in the nucl_gb.accession2taxid file corresponding to the accession numbers:

```
fgrep -w -f AccessionNumbers nucl_gb.accession2taxid > AccessionNumbers_taxids_linking_table
wc -l AccessionNumbers_taxids_linking_table #checking that taxids have been retrieved for all accession numbers/ **250572**
```
Remain in oue files only columns with accession and taxid
```
awk 'BEGIN {FS=OFS="\t"} {print $2,$3}' AccessionNumbers_taxids_linking_table > AccessionNumbers_taxids_linking_table_final
```
Remove unnecessuary files:
```
rm AccessionNumbers
rm AccessionNumbers_taxids_linking_table
```

#### Getting taxonomic lineages for each taxid
First, a list of unique taxids can be retrieved:

```
awk -F '\t' '{print $2}' AccessionNumbers_taxids_linking_table_final | sort | uniq > Taxids_uniq
wc -l Taxids_uniq #**86418**
```

Collecting taxonomic lineages for these taxids. Retrieving the reference file linking taxids to taxonomic lineages. The “new_taxdump.tar.gz” NCBI reference file must be downloaded from their FTP website:
```
mkdir taxdump
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz
mv new_taxdump.tar.gz taxdump/
tar -xvzf taxdump/new_taxdump.tar.gz -C taxdump
```
The rankedlineage.dmp file can then be reformatted with a simpler field separator (pipe):
```
sed -i "s/\t//g" taxdump/rankedlineage.dmp
```

The rankedlineage.dmp file must first be sorted using the taxids column field:
```
sort -t "|" -k 1b,1 taxdump/rankedlineage.dmp > taxdump/rankedlineage_sorted
```
Taxids can then be associated with their corresponding taxonomic lineages:
```
join -t "|" -1 1 -2 1 -a 1 Taxids_uniq taxdump/rankedlineage_sorted > Taxids_taxonomic_lineages_linking_table
wc -l Taxids_taxonomic_lineages_linking_table #
awk -F '|' '{print $2}' Taxids_taxonomic_lineages_linking_table | grep -c '^$' #Check if there is no empty line in 2 column. 
```










