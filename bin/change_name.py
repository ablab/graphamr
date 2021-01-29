#!/usr/bin/python
from Bio import SeqIO
import os
import sys

orfs = SeqIO.parse(sys.argv[1], 'fasta')
new=[]
for o in orfs:
    o.id='_'.join(o.description.split())
    new.append(o)
SeqIO.write(new, sys.argv[2], 'fasta')
