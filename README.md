# fracking_asthma
Understanding the association of fracking pollution dispersion and asthma outcomes

## Running disperseR

In a `bash` terminal create and run the disperser docker container.

```
docker build -t disperser .
docker run -p 8787:8787 -e ROOT=true -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/kitematic/ disperser
```

In the dockerized connection to Rstudio open [./disperser_script.r](./disperser_script.r)