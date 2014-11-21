#!/usr/bin/env python

"""
    Copyright (C) 2014  Ivan Gregor

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Computes precision and recall, including correction.
"""
import sys
import os

def _main():
    metaFile = sys.argv[1]  # docker input file
    toolsRoot = sys.argv[2]  # docker directory, where algbioi folder is placed
    outDir = sys.argv[3]  # docker output directory
    arg = {}
    for line in open(metaFile):
        k, v = line.strip().split('=')
        arg[k] = v

    FASTA_CONTIG_FILE = arg.get('FASTA_CONTIG_FILE')
    TAXONOMIC_ASSIGNMENTS = arg.get('TAXONOMIC_ASSIGNMENTS')
    TRUE_TAXONOMIC_LABELS= arg.get('TRUE_TAXONOMIC_LABELS')
    NCBI_TAXONOMY_IN_SQLITE3_FORMAT = arg.get('NCBI_TAXONOMY_IN_SQLITE3_FORMAT')
    ACCURACY_PARAM = arg.get('ACCURACY_PARAM', '').strip("'")
    ACCURACY_PARAM_CORRECTION = arg.get('ACCURACY_PARAM_CORRECTION', '').strip("'")
    SCAFFOLD_CONTIG_MAPPING = arg.get('SCAFFOLD_CONTIG_MAPPING')

    # accuracy
    try:
        assert os.system('export PYTHONPATH=%s:$PYTHONPATH; python algbioi/eval/accuracy.py -f %s -p %s -t %s -d %s %s > %s' \
                  % (toolsRoot, FASTA_CONTIG_FILE, TAXONOMIC_ASSIGNMENTS, TRUE_TAXONOMIC_LABELS, NCBI_TAXONOMY_IN_SQLITE3_FORMAT, ACCURACY_PARAM,
        os.path.join(outDir, 'accuracy.txt'))) == 0  # assert not very elegant but ok
    except:
        print('Accuracy standard not computed')

    # accuracy correction
    try:
        assert os.system('export PYTHONPATH=%s:$PYTHONPATH; python algbioi/eval/accuracy.py -f %s -p %s -t %s -d %s %s > %s'
                  % (toolsRoot, FASTA_CONTIG_FILE , TAXONOMIC_ASSIGNMENTS, TRUE_TAXONOMIC_LABELS, NCBI_TAXONOMY_IN_SQLITE3_FORMAT,
                     ACCURACY_PARAM_CORRECTION, os.path.join(outDir, 'accuracy_correction.txt'))) == 0
    except:
        print('Accuracy correction not computed')

    # consistency
    try:
        assert os.system('export PYTHONPATH=%s:$PYTHONPATH; python algbioi/eval/consistency.py -f %s -p %s -m %s -d %s -a > %s'
                  % (toolsRoot, FASTA_CONTIG_FILE, TAXONOMIC_ASSIGNMENTS, SCAFFOLD_CONTIG_MAPPING,
                     NCBI_TAXONOMY_IN_SQLITE3_FORMAT, os.path.join(outDir, 'consistency.txt'))) == 0
    except:
        print('Consistency not computed')


    # confusion matrix
    try:
        assert os.system('export PYTHONPATH=%s:$PYTHONPATH; python algbioi/eval/confusion_matrix.py  '
                  '-f %s -p %s -t %s -d %s -o %s' % (toolsRoot, FASTA_CONTIG_FILE, TAXONOMIC_ASSIGNMENTS,
                                                           TRUE_TAXONOMIC_LABELS, NCBI_TAXONOMY_IN_SQLITE3_FORMAT,
                                                           os.path.join(outDir, 'cmp_ref_'))) == 0
    except:
        print('Confusion matrices not computed')

if __name__ == "__main__":
    _main()
