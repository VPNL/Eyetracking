function eyetrackQAWrap_Ret( funcRemoveBlinks, plotRaw )
% eyetrackQAWrap_Ret will run eyetrackQA on all edffiles from the
% Retinotopy experiment
%
%   eyetrackQAWrap_Ret( [funcRemoveBlinks], [plotRaw] )
%
%       funcRemoveBlinks: (optional) boolean denoting whether you would
%                                    like to use the removeBlinks function
%                                    to remove blinks in parallel with
%                                    eyelink's blink labeling (default is
%                                    true)
%
%       plotRaw: (optional) boolean denoting whether you would like to plot
%                           the raw data in addition to the processed data
%                           (default is true)
%
% AR Apr 2019

% Make sure that the MATLAB version is early enough
matVersion = version;
if str2num(matVersion(end-2)) < 6
    error('This function will only work on MATLAB versions 2016 or later');
end

%% Checking inputs
if ~exist('plotRaw') | isempty(plotRaw)
    plotRaw = true;
end
if ~exist('funcRemoveBlinks') | isempty(funcRemoveBlinks)
    funcRemoveBlinks = true;
end

%% Storing all data directories containing edf files
% Storing directory where retinotopy eyetracking data is stored
retDir = RAID('projects','Longitudinal','Behavioral','Retinotopy');

% Searching through retDir for edf files
edfFiles = dir([retDir '/**/*.edf']);

% Find all unique folders containing edf files
edfFolders = unique({edfFiles.folder});

% All of these edf files are going to be under a edffiles subfolder under
% the dataDir
dataDirs = cellfun(@(x) x(1:end-9), edfFolders, 'un', 0);

%% Run eyetrackQAWrap on all data directories found
% Storing location of screenshot
screenshot = RAID('projects','GitHub','Eyetracking',...
                  'PlottingEyeMovements','ExperimentScreenShots',...
                  'RecMemFixationAndBar.png');

% Looping across dataDirs
for d = 1:length(dataDirs)
    dataDir = dataDirs{d};
    eyetrackQAWrap( dataDir, 'RemoveBlinksFunction',funcRemoveBlinks, ...
                    'plotRaw', plotRaw, 'experiment_screenshot', screenshot, ...
                    'pxlScrnDim', [1920 1080], 'mmScrnDim', [1040 585],...
                    'scrnDstnce', 2620 );
end

end