# metagenomics
ITMO_Master_Course

#### Analysis of Illumina MiSeq data, single-end

Data for analysis two variants: human gut metagenome (PRJNA1087311), human skin surface metagenome (SRR26268659) 

human gut metagenome (SRR28372423, SRR28372424, SRR28372425, SRR28372426, SRR28372428, SRR28372429, SRR28372430, SRR28372431, SRR28372432, SRR28372433) - QIIME2 with DADA2 and pretrained SILVA_db classifier
human skin surface metagenome (SRR26268659) - QIIME2 with deblur and pretrained SILVA_db classifier

*deblur takes as input fastq files one by one, dada2 takes as input only the whole bunch of sequenced content per run of sequencing machine, because dada2 algorithm uses the distribution of errors model defined by all reads from this run.

Data for program: https://drive.google.com/drive/folders/1XygG6Hcd-nAY-wD-Wb4uwZZdJjgMVsbw 

##### Installing QIIME 2 Amplicon Distribution for Linnux (please install version for amplicon analysis from 2023.2, not 2024).
_In the case of usage 2024 version with this commands you will get errors on the denoising step with any data formated as in this guide_

Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment 

```
wget https://data.qiime2.org/distro/core/qiime2-2023.2-py38-linux-conda.yml
conda env create -n qiime2-2023.2 --file qiime2-2023.2-py38-linux-conda.yml
conda activate qiime2-2023.2
qiime --help
```

##### Data preparing for and import command for dada2

You have to begin with creating manifest.tmp (tab-separated file, where first column is sampleID, the second one is full path to your sample.fastq). When you have the manifest/tmp you will need to convert it into format .qza - qiime2 proccedable binary fileformat, which all qiime2 subprocess work with.

My manifest.tmp will look like this:
```
sample-id     	absolute-filepath
SRR28372428  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372428.fastq
SRR28372429  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372429.fastq
SRR28372430  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372430.fastq
SRR28372423  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372423.fastq
SRR28372424  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372424.fastq
SRR28372425  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372425.fastq
SRR28372426  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372426.fastq
SRR28372431  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372431.fastq
SRR28372432  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372432.fastq
SRR28372433  /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/hum_gut2/gut_data2/SRR28372433.fastq
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


