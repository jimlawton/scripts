#!/bin/bash

while read -r package; do
    echo "INSTALLING $package"
    pipenv run pip install --quiet --requirement requirements.txt --no-deps --require-hashes $package
done < requirements.txt
