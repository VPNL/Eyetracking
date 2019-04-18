# Eyetracking
Useful functions for setting up Eyelink and plotting eye movements

* * *
*Notes:*

The code in this repo can be used when working with Eyelink eyetracking cameras and data files. The function eyetrackQA can only be run on Macs using MATLAB versions 2016 or later.
* * *

*Contents:*

1.  [Functions to Setup Eyelink](#eyelink-setup)

2.  [Functions to Plot Eye Movements](#plotting-eye-movements)
    1. [The eyetrackQA function](#the-eyetrackQA-function)
        - [Outputs](#outputs)
        - [Inputs](#inputs)
		+ [Experiment Parameters](#experiment-parameters)
    2. [Example Data](#example-data)
    3. [Wrapper Functions](#wrapper-functions)
    
* * *

## Eyelink Setup

Under the EyelinkSetup folder, you will find functions that can be used to setup and calibrate Eyelink eye trackers.

- setupEyelink_Projector: Initializes, setups, and calibrates Eyelink for eye tracking subjects looking at stimuli displayed on the projector screen at the CNI. Run this code before you start any functional scan requiring eyetracking.

## Plotting Eye Movements

Under the PlottingEyeMovements folder, you will find functions that can be used to plot eye movements, especially for subjects asked to fixate on a central dot. The most important of these functions is eyetrackQA which is described in more detail below.

### The eyetrackQA Function

#### Outputs

eyetrackQA will take edf files and use them to plot the eye movements of subjects asked to fixate during various experiments (for example, retinotopy). In order for the code to run successfully, edf files must be organized under a subdirectory called "edffiles" under a main data directory ("dataDir") where you would like to store your data. When you run eyetrackQA, folders will be created within dataDir that will organize data and figures in the following matter:

- dataDir/ascfiles/...
    + samples: Will store asc text files containing raw data from Eyelink. These files were created using Eyelink's edf2asc         executable, and contain only sample data from the edf file. This asc file will have 4 columns of data: time, x position       (in pixels), y position (in pixels), and pupil size. Any missing data (for instance, when the subject is blinking) will       be labeled as NaN.
    
    + events: Will store asc text files containing raw data from Eyelink. These files were created using Eyelink's edf2asc           executable, and contain only Eyelink messages and event data. The messages include information about calibration,             validation and drift correction as well as trial start times. The events recorded by Eyelink include fixation, saccade,       and blink times. For more information about how these data are organized, consult the 
      [Eyelink Manual](http://sr-research.jp/support/EyeLink%201000%20User%20Manual%201.5.0.pdf).
      
      
- dataDir/matfiles/...
    + raw: Will store a mat file containing data variable "raw". Raw is a 4 dimensional array where raw(:,1) stores time in         miliseconds, raw(:,2) stores x position in degrees of visual angle from the center of the screen (dva), raw(:,3) stores       y position in dva, and raw(:,4) stores the eye's distance from the center of the screen in dva.
    
    + event: Will store a mat file containing data variables "blinksFromEL", "blinksFromScript", "dataQuality",                     "numSaccades_ELBlinksRemoved","numSaccades_removeBlinksFun","saccadeLocs_ELBlinksRemoved","saccadeLocs_removeBlinksFun".
        1. blinksFromEL: Vector containing all of the times in raw when the subject was blinking according to the asc event              file. To determine whether the subject was blinking, the asc event file was parsed to find the times when the                  subject was blinking as well as when the subject was saccading immediately before and after their blinks.
        
        2. blinksFromScript: Vector containing all of the times in raw when the subject was found to blink according to the              removeBlinks function. The removeBlinks function looks for times when the subject's y position changed dramatically            before and after timepoints containing missing data from when their eyes were closed. These eye movements were                assumed to be associated with the subject blinking and are listed in this data variable.
        
        3. dataQuality: Struct with the fields "calibration_quality", "validation_quality", and "drift_quality". Each of these            fields contain a character array characterizing the quality of Eyelink's calibration, validation and drift                    correction as "GOOD", "FAIR", "POOR", "ABORTED", "SUCCESSFUL", or "NO" in the event that the calibration,                      validation or drift correction was not run.
        
        4. numSaccades_ELBlinksRemoved: The number of saccades detected after excluding timepoints corresponding to                      blinksFromEL. The number of saccades are calculated by the function countSaccades, which counts the number of times            the subject's eyes cross a thresholded distance from the center of the screen (default distance is 2 dva).
        
        5. numSaccades_removeBlinksFun: The number of saccades detected after excluding timepoints corresponding to                      blinksFromScript. The number of saccades are calculated by the function countSaccades, which counts the number of              times the subject's eyes cross a thresholded distance from the center of the screen (default distance is 2 dva).
        
        6. saccadeLocs_ELBlinksRemoved: Vector containing all of the times when the subject's eyes crossed crossed some                  thresholded distance from the center of the screen set by the countSaccade function. These timepoints were                    calculated after blinksFromEL were excluded from the data.
        
        7. saccadeLocs_removeBlinksFun: Vector containing all of the times when the subject's eyes crossed crossed some                  thresholded distance from the center of the screen set by the countSaccade function. These timepoints were                    calculated after blinksFromScript were excluded from the data.
        
    + ELBlinksRemoved: Will store a mat file containing the data variable "processed_ELBlinksRemoved". This data variable           takes the same shape as raw and will have all timepoints corresponding to blinksFromEL labeled as NaNs.
    
    + FuncBlinksRemoved: Will store a mat file containing the data variable "processed_removeBlinksFun". This data variable         takes the same shape as raw and will have all timepoints corresponding to blinksFromScript labeled as NaNs.
    
    
- dataDir/figures: Stores jpg images of the subject's eye position across the course of the experiment. These figures will       have a colormap that displays how the subject's eye position corresponds to the time in the experiment. Additionally, the     title will contain useful information regarding the quality of Eyelink's calibration, validation, and drift correction         before the start of the experiment, as well as how many saccades were counted using the countSaccade function. These figures   were all generated using the makeQAFig function.

    + raw: Plot of raw eyetracking data before any blinks were removed.
    + ELBlinksRemoved: Plot of eyetracking data after timepoints corresponding to blinksFromEL were labeled as NaNs.
    + FuncBlinksRemoved: Plot of eyetracking data after timepoints corresponding to blinksFromScript were labeled as NaNs.

#### Inputs

The eyetrackQA function only has 2 required inputs: fName and dataDir. fName is the name of your edf file, which must be located under dataDir/edfffiles in order for eyetrackQA to run properly. dataDir is the path to your data directory. However, eyetrackQA also has 7 optional Name, Value pair arguments that you will probably need to use. They are listed below:

- eyetrackQA( fName, dataDir, 'RemoveBlinksFunction', ____ ): Logical input denoting whether you would like to use the           removeBlinks function to label blinks in addition to using Eyelink's blink labeling. If false, you will not produce figures   under dataDir/figures/FuncBlinksRemoved and will not store the data variables "numSaccades_removeBlinksFun" or                 "saccadeLocs_removeBlinksFun" under dataDir/matfiles/events. Default is true.

- eyetrackQA( fName, dataDir, 'plotRaw', ____ ): Logical input denoting whether you would like to plot raw eyetracking data     and save a jpg image under dataDir/figures/raw. The default is true.

- eyetrackQA( fName, dataDir, 'experiment_screenshot', ____ ): File path to a screenshot of your experiment that you would       like to appear behind the plot of eye movements. The default is an image from a checkerboard bar retinotopy stimulus, which   you can find in this repo under Eyetracking/PlottingEyeMovements/ExperimentScreenShots/RecMemFixationAndBar.png.

- eyetrackQA( fName, dataDir, 'pxlScrnDim', ____ ): Vector of length 2 containing the experiment screen width and height in     pixels. Default is from the Recognition Memory Experiment ([1024 768]). This measurement is very important in order to         accurately convert the subject's eye position from pixels to degrees of visual angle.

- eyetrackQA( fName, dataDir, 'mmScrnDim', ____ ): Vector of length 2 containing the experiment screen width and height in       millimeters. Default is from the Recognition Memory Experiment ([385.28 288.96]). This measurement is very important in       order to accurately convert the subject's eye position from pixels to degrees of visual angle.

- eyetrackQA( fName, dataDir, 'scrnDstnce', ____ ): Distance from the subject's eye to the experiment screen in milimeters.     Default is from the Recognition Memory Experiment (540 mm). This measurement is very important in order to accurately         convert the subject's eye position from pixels to degrees of visual angle.

- eyetrackQA( fName, dataDir, 'SACCADE_THRESH', ____ ): The threshold used to count saccades in dva. Saccades will be counted   using the countSaccade function anytime the subject's eye position crosses this threshold. The default is 2 dva.

#### Experiment Parameters

Below are a list of experiment setups for which the screen dimensions and distances have already been measured by AR and MN in 2019.

- Eyetracking Room 454: This room is used for behavioral experiments outside of the scanner, such as the Recognition Memory experiment.
	+ Experiment Screenshot - A screenshot of the meridian mapping portion of the Recognition Memory experiment can be found in this repo under Eyetracking/PlottingEyeMovements/ExperimentScreenShots/RecMemFixationAndBar.png
	+ Pixel Screen Dimensions (Recognition Memory) - [1024 768]
	+ Milimeter Screen Dimensions (Recognition Memory) - [385.28 288.96]
	+ Screen Distance (milimeters) - 540

- Scanner Bore Monitor: This is the television screen behind the scanner. It is used in most experiments in the lab.
	+ Experiment Screenshot - A screenshot of a retinotopy experiment with a checkered bar can be found in this repo under Eyetracking/PlottingEyeMovements/ExperimentScreenShots/RetFixationAndBar.png
	+ Pixel Screen Dimensions (Retinotopy) - [1920 1080]
	+ Milimeter Screen Dimensions (Retinotopy) - [1040 585]
	+ Screen Distance (milimeters) - 2620

- Projector Screen: This is the screen that is attached to the back of the 16 channel coil for experiments such as toonotopy
	+ Experiment Screenshot - A screenshot from the toonotopy experiment is in this repo under Eyetracking/PlottingEyeMovements/ExperimentScreenShots/ToonFixationAndBar.png
	+ Pixel Screen Dimensions (Toonotopy) - [1280 960]
	+ Milimeter Screen Dimensions (Toonotopy) - [360 270]
	+ Screen Distance (milimeters) - 300

## Example Data

You can find an example of what dataDir will look like after running eyetrackQA under Eyetracking/PlottingEyeMovements/ExampleData.

## Wrapper Functions

Most likely you will have many edf files that you would like to analyze. In this case, place all of these edf files in a folder named edfffiles that is a subdirectory of some data directory where you would like to store all of your eye tracking data (dataDir). By running eyetrackQAWrap( dataDir, 'Name', Value ) using the same Name, Value pair arguments as for eyetrackQA (see [above](#inputs)), all edf files will be analyzed using the eyetrackQA function.
