#!/bin/bash


target=$1
if [ ! -d $target ]
then
    mkdir $target
fi

cd $target

# How to find normal subdomains from sublist3r
python3 /home/offensivehunter/Sublist3r/sublist3r.py -d $target > subdomains.txt

# Now find another subdomains from assetfinder 
assetfinder -subs-only $target >> subdomains1.txt

# Now we do sorting to throw out duplicate subdomains
cat subdomains.txt subdomains.txt | sort | uniq >> subdomains2.txt

# Now we have to find live subdomains
cat subdomains2.txt | httprobe > alive.txt 

# Now we have to find Javascript files to scroll 
cat alive.txt | subjs > jsfiles.txt

# Now we have to exploitation it helps to Directory fuzzing 
python3 /home/offensivehunter/dirsearch/dirsearch.py -u alive.txt -w /home/offensivehunter/dirsearch/db/dicc.txt -o directory_fuzz.txt

# This is the last thing to do subdomain takeover
while read -r line
do
    subzy --targets subdomains2.txt --concurrency 20 --verify_ssl
done
