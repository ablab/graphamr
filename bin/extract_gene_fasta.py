#!/usr/bin/python
from Bio import SeqIO
import sys

f = open(sys.argv[1], 'r')
dic = {}
for line in f:
    l = line.split()
    if l[5] in dic:
        new_value = dic[l[5]]
        new_value.append(l[1])
        dic[l[5]] = new_value
    else:
        dic[l[5]] = [l[1]]
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
