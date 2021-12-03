# flaring_texas

Texas flaring activity and its dispersion.

## Running disperseR

In a `bash` terminal create and run the disperser docker container.

```
docker build -t disperser .
docker run -p 8787:8787 -e ROOT=true -e DISABLE_AUTH=true -v $(pwd):/home/rstudio/kitematic/ disperser
```

In the dockerized connection to Rstudio open [./disperser_script.r](./disperser_script.r)

## Exploring data and disperseR results

Analysis and reports are found in: 
  * [./notebooks/particles_example.md](./notebooks/particles_example.md)
       + A single emission example of dispersion
       + Example of distance traveled after 12 hours  
  * [./notebooks/flares.md](./notebooks/flares.md)
       + Analysis of flaring events per tract area normalized
  * [./notebooks/particles.md](./notebooks/particles.md)
       + Analysis of flaring-origin air parcels dispersion
  * [./notebooks/exposure.md](./notebooks/exposure.md)
       + Population exposure comparison between --flaring events per tract criteria-- vs --flaring-origin air parcels dispersion criteria--
  * CBSA reports:
       + [./notebooks/flares_output/cbsa_flares_map.pdf](./notebooks/flares_output/cbsa_flares_map.pdf)
       + [./notebooks/particles_output/cbsa_particles_map.pdf](./notebooks/particles_output/cbsa_particles_map.pdf)
  * Per month dispersion viz:
       + [./notebooks/flares_output/tract_flares_map.pdf](https://github.com/audiracmichelle/flaring_texas/blob/main/notebooks/flares_output/tract_flares_maps.pdf)
       + [./notebooks/particles_output/tract_particles_map.pdf](https://github.com/audiracmichelle/flaring_texas/blob/main/notebooks/particles_output/tract_particles_maps.pdf)
  * google drive sheets summary:
       + [https://docs.google.com/spreadsheets/d/1KAfn6-NqCodkZ62nS4Vo92JnsNLudaRDuOncBw-AQmI/edit?usp=sharing](https://docs.google.com/spreadsheets/d/1KAfn6-NqCodkZ62nS4Vo92JnsNLudaRDuOncBw-AQmI/edit?usp=sharing)
