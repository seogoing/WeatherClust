# WeatherClust

WeatherClust is the program clustering synoptic pattern for heavy rainfall events over South Korea. The representative synoptic patterns can be identified when sufficient rainfall event occur. Empirical Orthogonal Function (EOF) and K-means clustering methods are employed in this program.

## Main process

1. [Getting ERA5 dataset](#1-getting-era5-reanalysis-dataset) 
2. [Define sufficient rainfall event (SRE)](#2-define-sufficient-rainfall-event-sre)
3. [Clustering data](#3-clustering-data)

## Requirements

- Python 3
- NCAR Command Language (NCL) ([www.ncl.ucar.edu/](https://www.ncl.ucar.edu/))
- Climate Data Operators (CDO) ([code.mpimet.mpg.de/projects/cdo/](https://code.mpimet.mpg.de/projects/cdo/))

---

## 1. Getting ERA5 Reanalysis dataset

The ERA5 daily data is needed, but ERA5 data is provided monthly or hourly data. Therefore, we have to make daily data by averaging 6 hourly data. 

(1) Download the ERA5 **geopotential height at 850 hPa**

- Time: 2004-12-31_15:00 ~ 2013-12-31_09:00 (6 hourly data; 03,09,15,21UTC)

- Latitude: 25°N ~ 50°N 

- Longitude: 115°E ~ 140°E

ECMWF provides the ERA5 global reanalysis data and an example python code to download them. The reference website is as follows.

[https://confluence.ecmwf.int/display/CKB/How+to+download+ERA5](https://confluence.ecmwf.int/display/CKB/How+to+download+ERA5)

(2) Change time zone (UTC→KST) and then make daily using [CDO](#requirements) command. After that, run **‘anom.ncl’** for making daily anomaly data.

```bash
cdo -b f32 shifttime,9hours ./DATA/ERA5_zg850_20052013_6hr_AMJJAS.nc ./DATA/ERA5_zg850_KST_20052013_6hr_AMJJAS.nc
cdo selmon,5,6,7,8,9 ./DATA/ERA5_zg850_KST_20052013_6hr_AMJJAS.nc ./DATA/ERA5_zg850_KST_20052013_6hr_MJJAS.nc
cdo daymean ./DATA/ERA5_zg850_KST_20052013_6hr_MJJAS.nc ./DATA/ERA5_zg850_KST_20052013_day_MJJAS.nc

ncl anom.ncl
```

Description of ERA5 final data

```bash
$ ncl_filedump ./DATA/ERA5_zg850_KST_20052013_day_MJJAS_anom.nc
dimensions:
      time = 3287
      longitude = 101
      latitude = 101

....

float zg850 ( time, latitude, longitude )
    long_name :    Geopotential
    standard_name :        geopotential
    units :        m
    _FillValue :   -32767
    missing_value :        -32767
    cell_methods : time: mean
         
```

## 2. Define sufficient rainfall event (SRE)

The SRE are identified using Automated Synoptic Observing System (ASOS) daily precipitation data provided by Korea Meteorological Administration (KMA). The ASOS data are available via Open API service:

[https://www.data.go.kr/data/15059093/openapi.do](https://www.data.go.kr/data/15059093/openapi.do)

See 02.Define_Sufficient_Rainfall_Event.ncl

## 3. Clustering Data

SREs are partitioned based on 850 hPa geopotential height daily anomaly using K-means clustering. The number of clusters are set with reference to Sum of squred error (SSE) and  Shillouette coefficient. 

See 03.ERA5_cluster.ipynb
