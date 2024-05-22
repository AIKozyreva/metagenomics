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
### HUMAnN
Also need: diamond + metaphlan 


_________________________________________________________________________________________________________________________________________________
### PiCRUST 
**Installing** 
```
conda install q2-picrust2=2023.2 -c conda-forge -c bioconda -c gavinmdouglas
________________________________________________________________________________________
usage: picrust2_pipeline.py [-h] -s PATH -i PATH -o PATH [-p PROCESSES] [-t epa-ng|sepp] [-r PATH] [--in_traits IN_TRAITS] [--custom_trait_tables PATH]                  
                            [--marker_gene_table PATH] [--pathway_map MAP] [--reaction_func MAP] [--no_pathways] [--regroup_map ID_MAP] [--no_regroup] [--stratified]    
                            [--max_nsti FLOAT] [--min_reads INT] [--min_samples INT] [-m {mp,emp_prob,pic,scp,subtree_average}] [-e EDGE_EXPONENT]                       
                            [--min_align MIN_ALIGN] [--skip_nsti] [--skip_minpath] [--no_gap_fill] [--coverage] [--per_sequence_contrib] [--wide_table] [--skip_norm]
                            [--remove_intermediate] [--verbose] [-v]
optional arguments:
  -s PATH, --study_fasta PATH
                        FASTA of unaligned study sequences (e.g. ASVs). The headerline should be only one field (i.e. no additional whitespace-delimited fields).
  -i PATH, --input PATH
                        Input table of sequence abundances (BIOM, TSV or mothur shared file format).
  -o PATH, --output PATH
                        Output folder for final files.
```


_________________________________________________________________________________________________________________________________________________



