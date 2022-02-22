# flaring_texas

Texas flaring activity and its dispersion.

## Running disperseR

In a `bash` terminal create and run the disperser docker container.

```
docker build -t disperser .
docker run -p 8787:8787 -e ROOT=true -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/kitematic/ disperser
```

Scripts in `/jobs` run in docker containers. It is possible to test disperser interactively using a dockerized connection to Rstudio.

## Exploring data and disperseR results

* add link to notebook

## References

Kernel density estimation and spatial statistics notes in 
* https://bookdown.org/lexcomber/brunsdoncomber2e/Ch6.html#looking-at-marked-point-patterns
* https://bookdown.org/lexcomber/brunsdoncomber2e/Ch6.html
* https://www.statsref.com/HTML/index.html?car_models.html

