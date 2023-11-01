# nmrC_DMScripts
Scripts using the dm-script format for running in Gatan Microscopy Suite, written for and tested on TEMs at the Nanoscale and Microscale Research Centre, University of Nottingham

TEMs tested on:

JEOL 2100F with Gatan K3-IS 

JEOL 2100Plus with Gatan OneView

Tecnai Biotwin with Gatan Orius

Descriptions:

##HRTEM Orientation Map Angle and length##
- uses a filtered FFT to identify and map orientations via peak intensity
Viridis.dm3 and twilight_shifted.dm3 are colormaps derived from the Matplotlib colormaps of the same names that can be installed into GMS and used with this script. 

##AutoFocus_insitu##
- tested on OneView and K3 in-situ cameras. Automated focus change and report, user needs to activate in-situ acquisition in advance of running script as that functionality isn't included in the dm script language as yet (as far as I'm aware)

##Radial Profile from FFT Series##
Uses radial intensity calculation derived from a script by Ming Pan, Paul Thomas, Robin Harmon
Converst the radial intensity of an FFT series (e.g. from a through focus series) into a 2d plot. Used for resolution appraisal for 2100Plus TEM at below 80kV alignments
