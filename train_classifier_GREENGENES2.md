# Analyse Amplicon metagenome Illumina single-end data by QIIME2 with DADA2, and Naive-bayes classifier pre-trained by Greengenes2 db and manually trained for ITS2 db.

QIIME2 version: Amplicon Distribution for Linux 
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

### Step3. Obtaining and importing reference data sets (using pre-trained Greengenes2 classifiers)
Taxonomic classifiers perform best when they are trained based on your specific sample preparation and sequencing parameters, including the primers that were used for amplification and the length of your sequence reads.

You can choose the classifier method and find references sequence for training here: https://docs.qiime2.org/2024.2/data-resources/ 
We will take Greengenes2 2022.10 from 515F/806R region of sequences ()

