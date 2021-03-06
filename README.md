[![cran version](http://www.r-pkg.org/badges/version/skyscapeR)](https://cran.rstudio.com/web/packages/skyscapeR) 
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/skyscapeR?)](https://github.com/metacran/cranlogs.app)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/grand-total/skyscapeR?color=82b4e8)](https://github.com/metacran/cranlogs.app)

# skyscapeR
_skyscapeR_ is a open source R package for data reduction, visualization and analysis in skyscape archaeology, archaeoastronomy and cultural astronomy. It is intended to become a fully-fledged, transparent and peer-reviewed package offering a robust set of quantitative methods while retaining simplicity of use.

For information on how to use _skyscapeR_ download [the official vignette](https://s3-eu-west-2.amazonaws.com/skyscape-archaeology/vignette.html). This is slightly out of date though, so watch this space.


## Installation
Just do:
```r
if(!requireNamespace("devtools", quietly = TRUE)) { install.packages("devtools") }
devtools::install_github('f-silva-archaeo/skyscapeR')
```

## Release Notes
### v0.3.1 notes
Major _plotly_ implementation done (minor glitches to fix). Added a number of celestial mechanics functions that rely on _swephR_, including _body.position()_, _moonphase()_, _riseset()_, _riseset.year()_ and _solar.date()_ as well as support functions _time2jd()_, _jd2time()_, _timestring()_ and _long.date()_. Added new function that creates a sketch of the sky for a given moment in time (may be useful for publications) called _sky.sketch()_. There may be glitches and lack of functoinality in some of these functions. Also, not passing CRAN checks and tests yet but watch this space.

### v0.3.0 notes
This version opens the implementation of _plotly_ for most plotting functions, bringing the much requested interactive functionalities. The implementation involves considerable tinkering, which has had side-effects in other functions. The package is therefore not ready for another release yet. Though it runs through the vignette without a hitch, some new functions, however, are not finalised yet and best to be avoided (e.g. anything in the plotting_plotly.R file for now).

### v0.2.9 notes
This version has abandoned _astrolibR_ ephemeris completely and, in its stead, has begun using the Swiss Ephemeris version of the JPL DE431 dataset. This is implemented via package _swephR_ which is still in development and not on CRAN. You can find the offical _swephR_ GitHub [here](https://github.com/rstub/swephR). (Update: As of v0.3.0, when you install _skyscapeR_ from GitHub it will automatically install _swephR_.)


### v0.2.2 CRAN release
The latest release version (v0.2.2) is available on CRAN. This Git contains the latest development version which has several bug fixes and additional tools (some of which might not have been fully tested).
