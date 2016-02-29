#! /bin/bash

rm -r ./public
hugo
cd ./public
rm -r ./images
rsync -av . redlua.com:.
