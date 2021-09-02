#!/usr/bin/env python3

# A simple example script for processing a bunch of .eml files saved from
# GMail, and extracting the URLs present.
#
# - Select all the emails in GMail.
# - Save the emails to a folder in Google Drive.
# - Download the folder as a zip.
# - Unpack the zip file.
# - Run this script in the folder containing the unpacked zip files.

import email
from email import policy
from email.parser import BytesParser
import glob
import os
import re
import sys
import pprint
import urllib.request


def download_file(url, filename):
    response = urllib.request.urlopen(url)    
    with open(filename + ".pdf", 'wb') as f:
        f.write(response.read())


path = './'
eml_files = glob.glob(path + '*.eml')

data = {}

for eml_file in eml_files:
    with open(eml_file, 'rb') as fp:
        name = eml_file
        name = name.split('/')[-1].replace('.eml', '').replace(' ', '_')
        msg = BytesParser(policy=policy.default).parse(fp)
    text = msg.get_body(preferencelist=('html')).get_content()
 
    text = text.split("\n")
    for line in text:
        if "a href" in line:
            urls = re.findall(r'<a href="https://.*.pdf">here</a>', line)
            urls = [url.replace('<a href="', '').replace('">here</a>', '') for url in urls]
            if len(urls) > 1:
                print("ERROR: more than one URL in email:")
                print(line)
                sys.exit(1)
            data[name] = urls[0]

print(len(data))
pprint.pprint(data)

pruned_data = {}
for key, value in data.items():
    pruned_data.setdefault(value, set()).add(key)

dups = [(key, values) for key, values in pruned_data.items() if len(values) > 1]
print("Duplicates:", dups)

for filename in data.keys():
    print(f"Fetching {filename} from {data[filename]} ...")
    download_file(data[filename], filename)

