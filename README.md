# Analyses of the scale and variable contingent effects in freshwater habitat clusters
Code for the analyses presented in the article: Schürz, M., García Márquez, J., and Domisch, S. (2025): "The scale-dependency in freshwater habitat regionalisation analyses". *Ecohydrology*. [https://doi.org/10.1002/eco.70018](https://doi.org/10.1002/eco.70018).


## Citation
If you use any of this code in your experiments, please make sure to cite the following publication:

**Note:** At this point, the paper is accepted, yet the DOI is not activated and no further information about the volume and pages is available. Please, check the website of [Ecohydrology](https://doi.org/10.1016/10.1002/eco.70018) for an update of the citation.

```{bash}
@article{Schuerz2025,
title = {The scale-dependency in freshwater habitat regionalisation analyses},
journal = {Ecohydrology},
year = {2025},
doi = {https://doi.org/10.1002/eco.70018},
author = {Marlene Schürz and Jaime García Márquez and Sami Domisch},
}
```
## Comment
Most of the scripts are optimised to run on a HPC-Cluster. The R scripts (sc00 to sc15) contain the code for the analyses, while the bash scripts (run_sc00 to run_sc12) contain the code to submit a job at the slurm system and start the corresponding R script.
The number within the script name corresponds with the number given in the workflow figure (Figure 2) in the article.

## License of the code 
[GNU GPL-3.0 license](https://github.com/mueblacker/clustering_basins/blob/main/LICENSE)

