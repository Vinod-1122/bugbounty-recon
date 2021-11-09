#!/bin/bash

target=$1
if [ ! -d $target ]
then
    mkdir $target
fi

cd $target

# How to find normal subdomains from findomain
./findomain-linux -t $target --quiet | tee -a subdomains.txt 

# Now find another subdomains from assetfinder 
assetfinder -subs-only $target >> subdomains.txt

# Now we do sorting to throw out duplicate subdomains
cat subdomains.txt | sort | uniq >> subdomains1.txt

# Now we have to find live subdomains
cat subdomains1.txt | httprobe > alive.txt 

# Now we have to find Javascript files to scroll 
cat alive.txt | subjs > jsfiles.txt

# Now we have to exoloitation it helps to subdomain takeover 
subjack -w subdomains1.txt -c /usr/share/subjack/fingerprints.json it 25 -ssl -o takeovers.txt

# This is the last thing to do directory busting 
while read -r line
do
    python3 /home/offensivehunter/dirsearch/dirsearch.py -u alive.txt -w /home/offensivehunter/dirsearch/db/dicc.txt -o directory_fuzz.txt 
done