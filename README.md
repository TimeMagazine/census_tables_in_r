# (Largely) painless reading of CSV files from the Census Bureau's American FactFinder in R

The [American FactFinder](https://factfinder.census.gov/faces/nav/jsf/pages/searchresults.xhtml?refresh=t) tool is overflowing with useful flat tables of countless combinations of Census data from a wide variety of samples. The online view of any of these tables is generally pretty clear, but the data is typically presented in a hierarchical manner with Excel-style merged columns. When you download the data as a CSV file, it arrives in rectangular form with a long series of columns for each combination of variables, each one of which has a code like 

While each table can be downloaded as a CSV, the files you get in response are often tedious to deal with for this reason. The script in this repo, `read_census_table.R`, just takes that CSV, accepts the fields you're interested in (which can be identified with fuzzy search), and spits out a single data frame with everything you asked for.

Note: Before you go doing this yourself, checkout [Census Reporter](censusreporter.org) and see if it doesn't solve all your problems the easy way. This is not a substitute, but just a convenience for those who wish to import the raw data themselves.

# LICENSE
MIT