Medical Robotics and Devices Lab Data Repository
================================================

This is a dataset maintained by the 
[Medical Robotics and Devices Lab](http://me.umn.edu/labs/mrd/) 
at the University of Minnesota, for the purpose of allowing researchers to 
evaluate different models of torque and jaw angle estimation.

Dataset license
---------------

This dataset is made available under Open Database License whose full text can be found 
[here](http://opendatacommons.org/licenses/odbl/). Any rights in individual contents of 
the database are licensed under the Database Contents License whose text can be found 
[here](http://opendatacommons.org/licenses/dbcl/)

Code/data visualization license
-------------------------------

[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)

Data Details
------------

This folder contains a series of data runs characterizing the input and output
of a da Vinci tool for creation and validation of grip force/torque and jaw
angle estimation methods.

The general file naming scheme is either XY.TXT or ZXY.TXT, where:
- X Corresponds to different frequencies
- Y Corresponds to different resistive torque levels
- Z Corresponds to different jaw angle stopping positions (also referred to as yaw changes)
The Z value is only used in the roll/pitch/yaw varying dataset, to denote
different yaw values. The different roll and pitch values are separated by
folders, and the roll and pitch tested are ONLY denoted in the readme.txt for
that folder, not in the header.

The SerialLog.txt file may or may not be included in a directory, and contains
the debug output of the microcontroller during each run. It is not anticipated
that this file will be necessary for analysis.

Each .TXT file has header data which will provide some insight into what the
data contains, however for torque, position and frequency the data itself should
be able to be analyzed to detect these values, and that should take precedence
over any values found in the header, as some header text was changed manually
during data collection and could be inaccurate.

The data files should have 10 columns:
1. Back-end Time \[ms\] (interrupt running at 1 kHz)
2. Back-end CUI Encoder \[counts\] (8192 counts/rev)
3. Back-end Futek Torque \[counts\] (0.000039811 Nm/count)
4. Back-end Measured Current \[Amps\] (from Maxon controller)
5. Front-end Maxon Encoder \[counts\] (4000 counts/rev)
6. Front-end Futek Torque \[counts\] (0.000039811 Nm/count)
7. Front-end Command \[amps\] (analog out, sent to Maxon controller)
8. Back-end Command \[-1:1\] (analog out, sent to Maxon controller)
9. Back-end Maxon \[counts\] (4196*35 counts/rev; 35:1 gearbox)
10. Back-end Trajectory Target \[counts\] (fraction of counts from trajectory)

Visualization Code
------------------

For convenience and clarity, MATLAB code is provided in the visualization 
directory, which has a file called basic_data.m will load and parse the 
data, and provide some basic plots. The plotting code should work on 
[GNU Octave](https://www.gnu.org/software/octave/) as well.

Full Neural Network Code
------------------------

In the interest of full disclosure, the full code used for the RA-L paper "Evaluation of Torque Measurement Surrogates as Applied to Grip Torque and Jaw Angle Estimation of Robotic Surgical Tools" has been provided in this repository as well. This code consists of two script files to train the neural networks (`train_roll.m` and `train_torque.m`) as well as one script to generate the figures and tables used in the paper (`plot_torque.m`). The actual neural nets used in the paper are provided in the `Neural_Nets` directory, and as such the `plot_torque` script can be run without training and it will use these networks.

Note that at this point the code requres MATLAB, and requires the [Neural Network Toolbox](https://uk.mathworks.com/products/neural-network.html), which may not be included in all MATLAB licences. 

Publications
------------
Please see the following papers for more details on how this dataset has been 
created and used:

John J. O'Neill, Trevor K. Stephens, and Timothy M. Kowalewski. Evaluation of Torque Measurement Surrogates as Applied to Grip Torque and Jaw Angle Estimation of Robotic Surgical Tools. IEEE Robotics and Automation Letters, [In Press](http://doi.org/10.1109/LRA.2018.2849862)

Nathan J. Kong, Trevor K. Stephens, John J. O'Neill, and Timothy M. Kowalewski. Design of a portable dynamic calibration instrument for davinci si tools. In Design of Medical Devices Conference, pages V001T11A023-V001T11A023, Minneapolis, MN, 2017. American Society of Mechanical Engineers. \[[pdf](http://www.me.umn.edu/labs/mrd/pdfs/Kong2017DesignPortableDynamic.pdf)\] 
