![EpiTools logo by Lorenzo Gatti](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Images/logo.png)


# Welcome to Epitools
---

Here we present a new software framework to extract the membrane signal from epithelial tissues and analyze it with the aid of computer vision. The development of EpiTools was inspired by the challenges in analyzing time-lapses of growing Drosophila imaginal discs. The folded morphology, the very small apical cell surfaces and the long time series required a new automated cell recognition to accurately study growth dynamics.

`EpiTools is composed of two main software projects to allow extended modularity`

First **an image processing application for MATLAB** to extract the membrane oulines from the experimental data, featuring:

* [Adaptive surface projection](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Analysis_Modules/00_projection/)
* [A Region growing segmentation algorithm with selective seeding](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Analysis_Modules/03_segmentation/)
* [Assisted Seed Correction for expert input](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Analysis_Modules/05_tracking/)
* [An advanced GUI for a guided & reproducible analysis](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Quick_Guide/01_CreateAnalysisFile/)

Second **a plugin collection for the <a href="http://icy.bioimageanalysis.org" target="_blank">bioimaging platform icy</a>** to interactively analyze the skeleton files, featuring:

* [A network based java data-structure to semantically describe the tissue](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Icy_Plugins/02_CellGraph)
* [Automatic estraction & display of development features](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Icy_Plugins/01_CellOverlay) including:
* Divisions and Eliminations
* Junction rearragements (T1,T2)
* Cell Elongation Patterns
* [Numerous Export options including Spreadsheets, GraphML and Vector Graphics](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Icy_Plugins/03_CellExport)

Our projects are pulished with Open source licenses. Follow us on BitBucket!

## Downloads
---

MATLAB Application         |  
:-------------------------:|:-------------------------:
<a class='iframe' href="http://imls-bg-arthemis.uzh.ch/epitools/form.html"><img border="0" alt="Epitools for Matlab v2" src="http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Images/download_matlab_v2.png"></a> |

`For best compatability we reccomend using Matlab **2014a**`

ICY Plugins        |  
:-------------------------:|:-------------------------:
<a class='iframe' href="http://imls-bg-arthemis.uzh.ch/epitools/form.html"><img border="0" alt="Epitools for Icy" src="http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Images/download_icy_plugins.png"></a> |

## Video Tutorials
---

<a href="https://www.dropbox.com/sh/ufehjrpfbgohn3x/AAACP2IIabj1u-VqWK9KnQFla?dl=0" target="_blank">EpiTools v2 Video Tutorials</a> 

<a href="https://www.dropbox.com/sh/q99vbi39ag8cwgw/AAC8W4gkb_e-T0BtCxPOXc8ga?dl=0" target="_blank">Icy Plugin Tutorials (with audio!)</a>

Make sure to download them to enjoy the HD quality 
*(click on the dots in the lower right corner and click download).*

## Who built EpiTools? 
---

##### Authors

* Davide Heller (1,4)
* Alexander Tournier (5)
* Andreas Hoppe (2)
* Simon Restrepo (1)
* Lorenzo Gatti (1,3,4)
* Nicolas Tapon (5)
* Konrad Basler (1)
* Yanlan Mao (6)

##### Affiliations

1. Institute of Molecular Life Sciences, University of Zurich, Switzerland
2. Digital Imaging Research Centre, Faculty of Science, Engineering and Computing, Kingston University, Kingston-upon-Thames, KT1 2EE, United Kingdom.
3. Institute of Applied Simulations, Zürich University of Applied Sciences, Einsiedlerstrasse 31a, 8820 Wädenswil, Switzerland
4. SIB Swiss Institute of Bioinformatics, Quartier Sorge - Batiment Genopode, 1015 Lausanne, Switzerland
5. Apoptosis and Proliferation Control Laboratory, Cancer Research UK, London Research Institute, 44 Lincoln's Inn Fields, London, WC2A 3LY, United Kingdom. 
6. MRC Laboratory for Molecular Cell Biology, University College London, Gower Street, London WC1E 6BT, United Kingdom


## Screenshots
---

_Matlab Application v2_

![Matlab Stable V2](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Images/interface_v2.png)

_Icy Plugins_

![Icy Plugins V1](http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Images/interface_icy.png)

---------------------------------------
## Support

* In case of bugs or improvement suggestions feel free to:
* File an issue from this website clicking on the lower right corner *[Create a new issue]* .
* Write to [Davide Heller](mailto:davide.heller@imls.uzh.ch?Subject=EpiTools%200.1%20beta%20closed%20)
* Write to [Lorenzo Gatti](mailto:lorenzo.gatti@uzh.ch?Subject=EpiTools%200.1%20beta%20closed%20)


---------------------------------------
###### This page was written by [Lorenzo Gatti](mailto:lorenzo.gatti.89@gmail.com) and [Davide Heller](mailto:davide.heller@imls.uzh.ch) on 26.08.14@16:57