function [dataQuality, numSaccades_ELBlinksRemoved, numSaccades_removeBlinksFun] = ...
            eyetrackQA( fName, dataDir, varargin )
% eyetrackQA creates quality assurance images to help determine whether a
% subject was fixating. It mimics Jesse's Eyetrack_final code stored under
% kgs/projects/Longitudinal/Behavioral/Eyetracking/Code
%
%   [dataQuality, numSaccades_ELBlinksRemoved, numSaccades_removeBlinksFun] = ...
%            eyetrackQA( fName, dataDir )
%
%       fName: (string) name of edf file, which must be located under
%                       dataDir/edffiles
%
%       dataDir: (string) path to where data is and will be saved, will have
%                         subfolders for ascfiles, edffiles, figures, and
%                         matfiles
%
%       dataQuality - struct with fields calibration_quality, 
%                     validation_quality, and drift_quality which indicate
%                     whether the final calibration, validation and drift
%                     correction steps before the start of the experiment
%                     were GOOD, FAIR, POOR, FAILED, ABORTED or were never
%                     run (NO).
%
%       numSaccades_ELBlinksRemoved - scalar, number of saccades found in 
%                                     eyetracking data after eyelink blinks
%                                     were removed
%
%       numSaccades_removeBlinksFun - (optional) scalar, number of saccades 
%                                     found in eyetracking data after 
%                                     blinks were removed using the 
%                                     removeBlinks function
%
% In addition to outputting numSaccades and dataQuality, eyetrackQA saves
% asc text files containing both sample and event eyelink data under
% dataDir/ascfiles. The function also saves pertinent vairables and
% organizes them under dataDir/matfiles. Lastly, the function will make
% various plots of the eyetracking data that are saved as jpg's under
% dataDir/figures.
%
% ------------------- Optional Name,Value pair arguments ------------------
%
%   [dataQuality, numSaccades_ELBlinksRemoved, [numSaccades_removeBlinksFun]] = ...
%            eyetrackQA( fName, dataDir, Name,Value ) specifies analysis properties
%            using one or more optional Name,Value pair argument. See below
%            for a list of properties.
%
%       RemoveBlinksFunction: (optional) boolean denoting whether you would
%                                    like to use the removeBlinks function
%                                    to remove blinks in parallel with
%                                    eyelink's blink labeling (default is
%                                    true)
%
%       plotRaw: (optional) boolean denoting whether you would like to plot
%                           the raw data in addition to the processed data
%                           (default is true)
%
%       experiment_screenshot - (optional) path to image you want to appear
%                               behind the plot of the subject's eye
%                               movements (default is from RecMem experiment)
%
%       pxlScrnDim - (optional) vector of length 2 containing the x and y
%                    screen dimensions in pixels. Defaults to the screen
%                    dimensions for the Recognition Memory experiment [1024
%                    768].
%
%       mmScrnDim - (optional) vector of length 2 containing the x and y
%                   screen dimensions in milimeters. Defaults to the screen
%                   dimensions for the Recognition Memory experiment
%                   [385.28 288.96]
%
%       scrnDstnce - (optional) scalar. Distance from eye to screen in
%                   milimeters. Defaults to screen distance for Recognition
%                   Memory experiment (540 mm)
%
%       SACCADE_THRESH - (optional) scalar. the threshold used to define the 
%                   saccades. saccades must cross this thresholded distance
%                   from the center of the screen in order to be counted
%                   (default is 2 dva)
%
% This script is only compatable for Macs using MATLAB versions 2016 or
% later.
%
% AR Jan 2019
% AR Feb 2019 changed location of edf2asc to GitHub; added screenshot
%             behind plots; added flag to plot raw data; updated default
%             dimensions to match RecMem code
% AR Mar 2019 changed default for plotRaw to true; changed inputs so
%             just need to specify home directory; saving pertinent event
%             data from eyelink as a mat file; rewrites the fName if there
%             is a .edf ending; added funcRemoveBlinks and DIST_THRESH 
%             arguments; automatically created required folders if they 
%             don't already exist; getting asc event file; changed inputs
%             to Name, Value pairs; check matlab version at start of code

%% Checking inputs and system preferences

% Because the edf2asc binary script used in this function only runs on Macs
if ~ismac
    error('This function can only be run on a Mac.');
end

% Make sure that the MATLAB version is early enough
matVersion = version;
if str2num(matVersion(end-2)) < 6
    error('This function will only work on MATLAB versions 2016 or later');
end

% Check to make sure that fName and dataDir are valid inputs
if nargin < 2
    error('eyetrackQA requires arguments fName and datadir');
end

if ~ischar(fName)
    error('fName must be entered as a character array');
end

if ~ischar(dataDir)
    error('dataDir must be entered as a character array');
end

% Make sure that fName does not contain the .edf ending
if contains(fName,'.edf')
    warning(['File name ' fName ' incorrectly formatted. Removing .edf ' ...
             'ending\n\n']);
    fName = fName(1:end-4);
end

% Parsing inputs
p = inputParser;
p.KeepUnmatched = true;

% Adding parameters
addParameter(p,'RemoveBlinksFunction',true,@islogical);
addParameter(p,'plotRaw',true,@islogical);
addParameter(p,'experiment_screenshot',RAID('projects','GitHub','Eyetracking',...
             'PlottingEyeMovements','ExperimentScreenShots',...
             'RecMemFixationAndBar.png'),@ischar);
addParameter(p,'pxlScrnDim',[1024 768],@(x)isnumeric(x)&&(length(x)==2)&&all(x > 0));
addParameter(p,'mmScrnDim',[385.28 288.96],@(x)isnumeric(x)&&(length(x)==2)&&all(x > 0));
addParameter(p,'scrnDstnce',540,@(x)isnumeric(x)&&(length(x)==1)&&all(x > 0));
addParameter(p,'SACCADE_THRESH',2,@(x)isnumeric(x)&&(length(x)==1)&&all(x > 0));

% Assigning variables
parse(p,varargin{:});
funcRemoveBlinks = p.Results.RemoveBlinksFunction;
plotRaw = p.Results.plotRaw;
screenshot = p.Results.experiment_screenshot;
pxlScrnDim = p.Results.pxlScrnDim;
mmScrnDim = p.Results.mmScrnDim;
scrnDstnce = p.Results.scrnDstnce;
DIST_THRESH = p.Results.SACCADE_THRESH;

% Check to see if there were any unmatched inputs
if ~isempty(fieldnames(p.Unmatched))
    fields = fieldnames(p.Unmatched);
    inputs = '';
    for f = 1:length(fields)
        inputs = [inputs fields{f} ' '];
    end
    error(['The following are not valid inputs: ' inputs]);
end

clear p varargin

% Setting paths to the subfolders of dataDir and making sure all required
% subfolders exist
[ edfdir, ascdir, figdir, matdir ] = checkEyetrackQAFolders( dataDir, ...
                                                        funcRemoveBlinks );

%% Convert edf to asc files
edfFile = [edfdir '/' fName '.edf'];
% There is a unix script called edf2asc that will be called. To run it, we
% need to navigate to its directory
cd /Volumes/group/biac2/kgs/projects/GitHub/Eyetracking/PlottingEyeMovements/Functions/
% Storing the unix command for extracting sample data (x and y position)
edf2ascCommand_sample = ['./edf2asc -s -miss NaN ' edfFile ' -p ' ...
                         ascdir '/samples'];
% Running command
unix(edf2ascCommand_sample);

% Storing unix command for extracting event data (blinks, saccades)
edf2ascCommand_events = ['./edf2asc -e ' edfFile ' -p ' ascdir '/events'];
% Running command
unix(edf2ascCommand_events);

clear edf2ascCommand_events edf2ascCommand_sample edfFile edfdir

%% Convert asc to raw sample data (x and y coordinates) and save
[raw, stime] = asc2rawMat_sample([ascdir '/samples/' fName '.asc'], ...
                                 pxlScrnDim, mmScrnDim, scrnDstnce);
% Saving raw. raw(:,1) gives time, raw(:,2) gives x position in dva, 
% raw(:,3) gives y position in dva, and raw(:,4) gives distance from center
% in dva.
save([matdir '/raw/' fName '.mat'],'raw')

% Plot raw data and save figure
if plotRaw
    % Make figure
    fig = makeQAFig( raw, [fName ' Raw'], screenshot, mmScrnDim, ...
                     scrnDstnce );
    % Save figure
    saveas(fig,[figdir '/raw/' fName '.jpg'],'jpg');
    % Close figure
    close; clear fig;
end

%% Convert asc to mat variables containing event data
% Get the timepoints in raw that eyelink labeled as blinks. Get the quality
% of the eyetracking calibration and validation.
[blinksFromEL, dataQuality] = asc2mat_event( [ascdir '/events/' fName ...
                                              '.asc'], stime);

clear ascdir stime
                                                                
%% Delete blinks using eyelink event data, save processed data, and count saccades
% Delete blinks
processed_ELBlinksRemoved = raw; 
processed_ELBlinksRemoved(blinksFromEL,2:4) = NaN;
% Save processed data
save([matdir '/ELBlinksRemoved/' fName '.mat'],'processed_ELBlinksRemoved')
% Count saccades and find their locations in time
[numSaccades_ELBlinksRemoved, saccadeLocs_ELBlinksRemoved] = ...
    countSaccades( processed_ELBlinksRemoved, DIST_THRESH );

%% Plot data
fig = makeQAFig( processed_ELBlinksRemoved, ...
                 {fName, [num2str(numSaccades_ELBlinksRemoved) ' Saccades | ' ...
                 dataQuality(end).calibration_quality ' Calibration | ' ...
                 dataQuality(end).validation_quality ' Validation | ' ...
                 dataQuality(end).drift_quality ' Drift Correction']}, ...
                 screenshot, mmScrnDim, scrnDstnce, DIST_THRESH );
% Save figure
saveas(fig,[figdir '/ELBlinksRemoved/' fName '.jpg'],'jpg');
% Close figure, clear processed_eyelink
close; clear processed_ELBlinksRemoved;

%% Delete blinks using removeBlinks code, save processed data and plot

if funcRemoveBlinks
    % Remove blinks
    [processed_removeBlinksFun, blinksFromScript] = removeBlinks( raw ); clear raw;
    
    % Count the number of saccades
    [numSaccades_removeBlinksFun, saccadeLocs_removeBlinksFun] = ...
    countSaccades( processed_removeBlinksFun, DIST_THRESH );
    
    % Save event data and processed data from removeBlinks function
    save([matdir '/event/' fName '.mat'],'blinksFromEL',...
          'numSaccades_ELBlinksRemoved','numSaccades_removeBlinksFun',...
          'saccadeLocs_ELBlinksRemoved','saccadeLocs_removeBlinksFun',...
          'blinksFromScript','dataQuality');
    save([matdir '/FuncBlinksRemoved/' fName '.mat'],'processed_removeBlinksFun')
    % Plot processed data
    fig = makeQAFig( processed_removeBlinksFun, ...
                     {fName, [num2str(numSaccades_removeBlinksFun) ...
                     ' Saccades | ' dataQuality(end).calibration_quality ...
                     ' Calibration | ' dataQuality(end).validation_quality ...
                     ' Validation | ' dataQuality(end).drift_quality ...
                     ' Drift Correction']}, ...
                     screenshot, mmScrnDim, scrnDstnce, DIST_THRESH );
    % Save figure
    saveas(fig,[figdir '/FuncBlinksRemoved/' fName '.jpg'],'jpg');
    % Close figure
    close;
else
    save([matdir '/event/' fName '.mat'],'blinksFromEL','dataQuality',...
          'numSaccades_ELBlinksRemoved','saccadeLocs_ELBlinksRemoved');
end

% cd to datadir
cd(dataDir)

end