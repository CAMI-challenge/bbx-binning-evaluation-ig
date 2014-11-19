# Evaluation framework used for the PPS+ pipeline (author: Ivan)

## Method
The evaluation measures are described in sections 4.9 and 4.10 (http://arxiv.org/pdf/1406.7123v1.pdf).

## Usage

All scripts require python 2.7 (inc. biopython). The evaluation framework is distributed as a python package (algbioi).
Individual evaluation scripts are contained in package (algbioi.eval), helper functionality in (algbioi.com). To run
the scripts, you need to set the PYTHONPATH variable pointing to the folder that contains the main (algbioi) package.
You can run any script with option -h to get all available options.

### Precision and Recall inc. correction

Standard use:
```
python accuracy.py -f FASTA_CONTIG_FILE -p TAXONOMIC_ASSIGNMENTS -t TRUE_TAXONOMIC_LABELS \
-d NCBI_TAXONOMY_IN_SQLITE3_FORMAT -c 0.01 -b 0.01 -o
```

With correction specified:
```
python accuracy.py -f FASTA_CONTIG_FILE -p TAXONOMIC_ASSIGNMENTS -t TRUE_TAXONOMIC_LABELS \
-d NCBI_TAXONOMY_IN_SQLITE3_FORMAT -c 0.01 -b 0.01 -o -m 0.9
```


### Scaffold-contig consistency
```
python consistency.py -f FASTA_CONTIG_FILE -p TAXONOMIC_ASSIGNMENTS -m SCAFFOLD_CONTIG_MAPPING \
-d NCBI_TAXONOMY_IN_SQLITE3_FORMAT -a
```

### Confusion matrices
```
python confusion_matrix.py -f FASTA_CONTIG_FILE -p TAXONOMIC_ASSIGNMENTS -t TRUE_TAXONOMIC_LABELS \
-d NCBI_TAXONOMY_IN_SQLITE3_FORMAT -o XXX -r RANK
```
