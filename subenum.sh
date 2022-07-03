##!/bin/bash

echo "
 _____     _           ____
| ____|___| |__   ___ |  _ \__      ___ __
|  _| / __| '_ \ / _ \| |_) \ \ /\ / / '_ \\
| |__| (__| | | | (_) |  __/ \ V  V /| | | |
|_____\___|_| |_|\___/|_|     \_/\_/ |_| |_|v1.1

"
echo "starting enumeration for $1"

echo "starting assetfinder"
assetfinder --subs-only $1 | tee -a /home/kali/pentest/tools/Recon/Assetfinder.txt

echo "starting amass"
amass enum --passive -d $1 -o /home/kali/pentest/tools/Recon/Amass.txt

#echo "starting subfinder"
subfinder -d $1 -silent -o /home/kali/pentest/tools/Recon/subfinder.txt

echo "starting knockpy"
python3 /home/kali/pentest/tools/knock/knockpy.py $1 -o /home/kali/pentest/tools/Recon/knockpy.txt

echo "starting sorting domains"
cat /home/kali/pentest/tools/Recon/Assetfinder.txt /home/kali/pentest/tools/Recon/Amass.txt /home/kali/pentest/tools/Recon/subfinder.txt /home/kali/pentest/tools/Recon/knockpy.txt | sort -u | tee -a /home/kali/pentest/tools/Recon/sortedomains.txt

echo "starting alivedomains"
cat /home/kali/pentest/tools/Recon/sortedomains.txt | httprobe -c 40 | tee -a /home/kali/pentest/tools/Recon/alive.txt

echo "starting js files"
cat /home/kali/pentest/tools/Recon/alive.txt | subjs | tee -a /home/kali/pentest/tools/Recon/jsfiles.txt

echo "starting paramspider"
python3 /home/kali/pentest/tools/ParamSpider/paramspider.py -d $1 -l  -o /home/kali/pentest/tools/Recon/paramspider.txt

echo "starting gau"
cat /home/kali/pentest/tools/Recon/alive.txt | gau | tee -a /home/kali/pentest/tools/Recon/gau.txt

echo "starting gf sqli"
cat /home/kali/pentest/tools/Recon/gau.txt | gf sqli | tee -a /home/kali/pentest/tools/Recon/sqli.txt

echo "starting gf ssrf"
cat /home/kali/pentest/tools/Recon/gau.txt | gf ssrf | tee -a /home/kali/pentest/tools/Recon/ssrf.txt

echo "Checking for Subdomain Takeover"
subzy --targets=/home/kali/pentest/tools/Recon/sortedomains.txt --hide_fails | grep "VULNERABLE" | xargs -n 1 -I{} host -t CNAME {} | tee -a /home/kali/pentest/tools/Recon/takeover.txt

echo "starting dirsearch"
python3 /home/kali/pentest/tools/dirsearch/dirsearch.py -u $1 -e php,asp,aspx,jsp,html,zip,jar -r -R -w /home/kali/pentest/tools/SecLists-master/Discovery/Web-Content/raft-large-files.txt --plain-text-report="home/kali/pentest/tools/Recon/dirsearch/$i.txt"

echo "starting nmap"
nmap -sC -sV -p- -Pn $1 -o /home/kali/pentest/tools/Recon/nmap.txt

echo "Notifying you on slack"
curl -X POST -H 'Content-type: application/json' --data '{"text":"Recon Successfull: '$1'"}' $slack_url
echo "Finished successfully."
