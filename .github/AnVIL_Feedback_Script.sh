#!/bin/bash

# Extract the title from the YAML front matter of index.Rmd
title=$(awk '/^title:/{gsub(/^title: /,""); print}' "index.Rmd" | grep -v '^$')

# Remove the outside quotation marks
title=$(sed -e 's/^"//' -e 's/"$//' <<< "$title")

# Replace spaces with '+'
title=${title// /+}

# Base url for the AnVIL Google Form
url_base="https://docs.google.com/forms/d/e/1FAIpQLScrDVb_utm55pmb_SHx-RgELTEbCCWdLea0T3IzS0Oj00GE4w/viewform?usp=pp_url&entry.1565230805="

# Replace the url inside _output.yml
perl -i -pe 's|https://docs.google.com/forms/d/e/1FAIpQLScrDVb_utm55pmb_SHx-RgELTEbCCWdLea0T3IzS0Oj00GE4w/viewform\?usp=pp_url&entry\.1565230805=.*"> Click|'${url_base}${title}'"> Click|g' _output.yml

# Print for Github actions 
echo "The feedback link is: ${url_base}${title}"