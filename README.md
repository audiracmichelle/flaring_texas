# flaring_texas

Texas flaring activity and its dispersion.

## Running disperseR

In a `bash` terminal create and run the disperser docker container.

```
docker build -t disperser .
docker run -p 8787:8787 -e ROOT=true -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/kitematic/ disperser
```

Scripts in `/jobs` run in docker containers. It is possible to test disperser interactively using a dockerized connection to Rstudio.

Commands to run the jobs in a remote connection to a super computer are found in `/jobs/README.md`

## Exploring data and disperseR results

* Supporting notebooks at [https://audiracmichelle.github.io/flaring_texas/]

## References

Kernel density estimation and spatial statistics notes in 
* Christopher Brunsdon book down https://bookdown.org/lexcomber/brunsdoncomber2e/Ch6.html, https://uk.sagepub.com/en-gb/eur/an-introduction-to-r-for-spatial-analysis-and-mapping/book258267, https://www.amazon.co.uk/dp/1526428504
* https://www.statsref.com/HTML/index.html?car_models.html
* Michael Dorman book down http://132.72.155.230:3838/r/processing-spatio-temporal-data.html This book contains the materials of the 3-credit undergraduate course named Introduction to Spatial Data Programming with R, given at the Department of Geography and Environmental Development, Ben-Gurion University of the Negev. The course was given in 2013, and then each year in the period 2015-2022. An earlier version of the materials was published by Packt (Dorman 2014)1.
