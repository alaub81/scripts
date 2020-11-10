#!/bin/bash
#########################################################################
#Name: clone-mw-extensions.sh
#Subscription: Clones all my MediaWiki extensions 
#
##by A. Laub
#andreas[-at-]laub-home.de
#
#License:
#This program is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public License as published by the
#Free Software Foundation, either version 3 of the License, or (at your option)
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#or FITNESS FOR A PARTICULAR PURPOSE.
#########################################################################
#Set the language
export LANG="en_US.UTF-8"
#Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables


MW_BRANCH=$(docker exec laubhome_mediawiki_1 env | grep MEDIAWIKI_BRANCH |cut -d"=" -f2)
rm -f extensions
mkdir extensions_$MW_BRANCH
cp -rp extensions_archive/* extensions_$MW_BRANCH/
cd extensions_$MW_BRANCH
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/CookieWarning"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/GoogleAdSense"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/googleAnalytics"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/Lockdown"
git clone "https://gerrit.wikimedia.org/r/mediawiki/extensions/SelectCategory"
#git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/SelectCategory"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/WikiCategoryTagCloud"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/Description2"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/RelatedArticles"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/MobileFrontend"
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/extensions/ContributionCredits"

git clone -b $MW_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor.git
cd VisualEditor
git submodule update --init
cd ..
cd ..
ln -s extensions_$MW_BRANCH extensions

rm -f skins
mkdir skins_$MW_BRANCH
cd skins_$MW_BRANCH
git clone -b $MW_BRANCH "https://gerrit.wikimedia.org/r/mediawiki/skins/MinervaNeue"
cd ..
ln -s skins_$MW_BRANCH skins
