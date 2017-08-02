#!/usr/bin/python
import os
from shutil import copyfile
with open('pdf_tcinactive.list', 'r') as filein:
    for line in filein:
            line = line.strip()
            copyfile('TestDocument.pdf', line)
