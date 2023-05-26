# FaceEmo
Computational model of associative learning of categorical identification of face emotions.

  Version 1.3

Change log:
===========
% 1.1       Initial attempt with base code and sum of squares fitting.
% 1.2rm     Addition of random starts as well as maximum likelihood fit.
%           Bayesean test with beta distribution (failed but left in)
% 1.3       Removal of normalization because normalization emphasizes
%           extreme morphs.
%           Option: Normalization commented out in two places. Noted with 'normalize'.
%           Bound s, epsilon, and sigma starting values adjusted to avoid false starts.
%           Add weight, choiceprob, and output graphs by trial for QC. 
%           Refactoring code for maintenance.
% 1.4       Estimation of learning rate is now adjusted by sigma, 
%               yielding the maximimum effective learning rate. 
%           Option: Evaluate estimation of initial weights as a logistic or linear by commented code.


Files:
======
Scripts with the prefix "w" are simply wrappers that translate data from different projects and call minimizeFit,
wPostfMRI used in Stoddard et al., 2023 is included as an example.

minimizeFit calls other functions depending on user preferences, including models, which begin with the prefix "mod." 
Version 1.4 is included here, though an example of assymmetric learning is shown in modA.

All scripts and example graphs (with .fig extension) may be opened in MatLab.

Branches:
=========
master is current version

addRT will add reaction time data. Theoretical and math are laid out by Mr. Paskewitz and based in linear ballistic accumulation modeling of RT.

Notes:
======
Note that an expected behavior of the model is that there is a category boundary and there will be a high-contrast bend in the weight matrix about this boundary. Model is trying to learn responses about the category boundary. Because of the generalization the weight matrix is smoothed. It creates a strong contrast right before the boundary. It emphasizes the contrast right before the smoothing. 
