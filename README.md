# CODON+ Capstone - Gut microbiome and autoimmunity among infants in Estonia, Finland, and Russia

Capstone project for the CODON+ Genomics Data Science with Microbial Research (Jan-Feb 2026) course, seeking to replicate findings from [this reference paper](https://pubmed.ncbi.nlm.nih.gov/27133167/)
> Vatanen, T., Kostic, A. D., d'Hennezel, E., Siljander, H., Franzosa, E. A., Yassour, M., Kolde, R., Vlamakis, H., Arthur, T. D., Hämäläinen, A. M., Peet, A., Tillmann, V., Uibo, R., Mokurov, S., Dorshakova, N., Ilonen, J., Virtanen, S. M., Szabo, S. J., Porter, J. A., Lähdesmäki, H., … Xavier, R. J. (2016). Variation in Microbiome LPS Immunogenicity Contributes to Autoimmunity in Humans. Cell, 165(4), 842–853. https://doi.org/10.1016/j.cell.2016.04.007

## File structure: key files in this repository
- `data`: data used for this project, in addition to data from the `curatedMetagenomicData` R package
- `scripts/capstone_harmonized.R`: **[main script](scripts/capstone_harmonized.R)** for analysis
- `results`: outputs

## Reproducing this project 
### Repository and scripts
1. Create a local copy of this project (e.g. by using `git clone` on the command line). See [GitHub Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) for detailed instructions.
2. Follow the steps in [the next section](#project-local-environment-and-dependencies-renv) to set up the project dependencies.
3. Run the main script for analysis `scripts/capstone_harmonized.R`.
4. Check the outputs in the `results/` folder.

### Project-local environment and dependencies (`renv`)
This repository uses the `renv` R package with an R project to maintan a reproducible project-local environment. Check out the `renv` vignette [here](https://cran.r-project.org/web/packages/renv/vignettes/renv.html) for an introduction to the package.

The R project ([`codon_microbiome_capstone.Rproj`](./codon_microbiome_capstone.Rproj)) ensures that the working directory is always the root folder of this repository, `codon_microbiome_capstone`, regardless of your local file structure.

All packages and versions required for the project have been tested with R 4.5.1 and are specified in [`renv.lock`](./renv.lock). If you have a different version of R, you may wish to consider changing this by: 
1. Download R 4.5.1 from CRAN by clicking [this link](https://cran.r-project.org/bin/windows/base/) >> Previous releases >> R 4.5.1 >> download `R-4.5.1-win.exe`.
2. Open RStudio, go to Tools >> Global options >> R version. Edit the path to point to R-4.5.1. 
3. You can check this was successful by running the `getRversion()` function in the RStudio console. This should return '4.5.1'. 

To replicate the exact environment used, 
1. Install the `renv` R package from CRAN using `install.packages("renv")`.
2. Before running scripts for the first time, activate the environment using `renv::restore()`.
3. On subsequent runs, check that environment is up to date with `renv::status()`.
