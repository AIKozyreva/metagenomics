# metagenomics
ITMO_Master_Course

### QIIME2 DADA2 + Deblur
Version QIIME2: 2023.2 
Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment 

Data for analysis two variants: human gut metagenome 16S (SRP506441: SRR28962951-55)

Data for program: https://drive.google.com/drive/folders/1XygG6Hcd-nAY-wD-Wb4uwZZdJjgMVsbw 

>DADA2 learning - folder QIIME2
>
>Deblur learning - folder hw1
>
_________________________________________________________________________________________________________________________________________________
### PiCRUST 
**Installing** 
```
conda install q2-picrust2=2023.2 -c conda-forge -c bioconda -c gavinmdouglas
```
**Running**

Then, we have to start the whole Picrust pipeline by the command: 

```
picrust2_pipeline.py -s /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/denoising/dna-sequences.fasta -i /mnt/SSD4TB/PROJECTS/kozyreva_works/qiime2/HW_hum_gut/otus/feature-table.biom -o picrust -p 1
```
Then we will get a bunch of files, including the files from hw2 folder of this repo

_________________________________________________________________________________________________________________________________________________

### HUMAnN
Also need: diamond + metaphlan 


_________________________________________________________________________________________________________________________________________________

