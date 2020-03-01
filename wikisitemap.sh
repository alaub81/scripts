#!/bin/bash
cd /srv/httpd/vhosts/www.laub-home.de/htdocs/
#php maintenance/generateSitemap.php --fspath sitemap --server http://wiki.laub-home.de --urlpath http://wiki.laub-home.de/sitemap > /dev/null
#php5 maintenance/generateSitemap.php --memory-limit max --server http://wiki.laub-home.de --urlpath http://wiki.laub-home.de > /dev/null
php maintenance/generateSitemap.php --skip-redirects --server https://www.laub-home.de --urlpath https://www.laub-home.de > /dev/null
#mv sitemap-index-wikidb.xml sitemap.xml
