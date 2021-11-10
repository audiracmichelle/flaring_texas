# fracking_asthma
Understanding the association of fracking pollution dispersion and asthma outcomes

## Running disperseR

In a `bash` terminal create and run the disperser docker container.

```
docker build -t disperser .
docker run -p 8787:8787 -e ROOT=true -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/kitematic/ disperser
```

In the dockerized connection to Rstudio open [./disperser_script.r](./disperser_script.r)

## Exploring data and disperseR results

Analysis and reports are found in: 
  * [./notebooks/flares.md](./notebooks/flares.md)
  * [./notebooks/particles.md](./notebooks/particles.md)
  * [./notebooks/exposure.md](./notebooks/exposure.md)
  * [./notebooks/flares_output/cbsa_flares_map.pdf](./notebooks/flares_output/cbsa_flares_map.pdf)
  * [./notebooks/particles_output/cbsa_particles_map.pdf](./notebooks/particles_output/cbsa_particles_map.pdf)
  * [./notebooks/flares_output/tract_flares_map.pdf](./notebooks/flares_output/tract_flares_map.pdf)
  * [./notebooks/particles_output/tract_particles_map.pdf](./notebooks/particles_output/tract_particles_map.pdf)
  * google drive sheets summary [https://docs.google.com/spreadsheets/d/1KAfn6-NqCodkZ62nS4Vo92JnsNLudaRDuOncBw-AQmI/edit?usp=sharing](https://docs.google.com/spreadsheets/d/1KAfn6-NqCodkZ62nS4Vo92JnsNLudaRDuOncBw-AQmI/edit?usp=sharing)
