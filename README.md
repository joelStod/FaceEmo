# FaceEmo
Computational model of associative learning of categorical identification of face emotions.

  Version 1.3

Change log:
===========
See scripts for details of changes for each script, especially fitibt

To Version 1.2, model development and fits were tested yielding maximum likelihood fits and the use of a guessing parameter.

Major differences from prior versions are the removal of normalization from the activation matrix initialization. The normalization procedure divided an activation guassian by the sum of all gaussians and biased activation at the edges. 

We also examine the effects on weight matrix updates from extreme morphs yielding a limit of s at 1 which is based on feedback. Full notes on this are added in "BoundsOfS". 

Finally, Version 1.3 is refactored and has a minor bug fix in assignment of angry to happy choices for some extreme values.

Files:
======
Scripts with the prefix "w" are simply wrappers that translate data from different projects and call fitIBT. 

fitIBT calls other functions depending on user preferences, including models, which begin with the prefix "mod."

Asymmetric learning is shown in modA

All scripts and example graphs may be opened in MatLab.

Branches:
=========
master is current version

addRT will add reaction time data. Theoretical and math are laid out by Mr. Paskewitz and based in linear ballistic accumulation modeling of RT.

Notes:
======
Note that an expected behavior of the model is that there is a category boundary and there will be a high-contrast bend in the weight matrix about this boundary. Model is trying to learn responses about the category boundary. Because of the generalization the weight matrix is smoothed. It creates a strong contrast right before the boundary. It emphasizes the contrast right before the smoothing. 
