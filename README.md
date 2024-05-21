# metagenomics
ITMO_Master_Course

### QIIME2 DADA2 + Deblur
Version QIIME2: 2023.2 
Program for 2023.2 version can be found here: https://docs.qiime2.org/2023.2/install/native/#install-qiime-2-within-a-conda-environment 

Data for analysis two variants: human gut metagenome 16S (SRP506441: SRR28962951-55)

Data for program: https://drive.google.com/drive/folders/1XygG6Hcd-nAY-wD-Wb4uwZZdJjgMVsbw 
_____________________________________________________________________________________________________________________________________________________
### Visualisation 
```
qiime taxa barplot --i-table rarefied/otus_rar_5K.qza --i-taxonomy taxonomy/taxonomy.qza --o-visualization taxonomy/taxa-bar-plots.qzv 
```
Params for visualization: Taxonomic Level 6; Color Palette schemeset3; Sort samples by d__Bacteria; Ascending;

_________________________________________________________________________________________________________________________________________________
### HUMAnN
Also need: diamond + metaphlan 


_________________________________________________________________________________________________________________________________________________
### PiCRUST 

_________________________________________________________________________________________________________________________________________________



