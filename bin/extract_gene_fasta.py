#!/usr/bin/env python
from Bio import SeqIO
import sys

f = open(sys.argv[1], 'r')
dic = {}
for line in f:
    l = line.split()
    gene = l[5].replace(")", "_").replace("(", "_").replace("'", "_")
    if gene in dic:
        new_value = dic[gene]
        new_value.append(l[1])
        dic[gene] = new_value
    else:
        dic[gene] = [l[1]]
f.close()

dic.pop('GENE')

inputSeqFile = open(sys.argv[2], "rU")
SeqDict = SeqIO.to_dict(SeqIO.parse(inputSeqFile, "fasta"))
inputSeqFile.close()

for d in dic.keys():
    new_fasta=[]
    for k in dic[d]:
        new_fasta.append(SeqDict[k])
    SeqIO.write(new_fasta, '{}.fasta'.format(d), 'fasta')
