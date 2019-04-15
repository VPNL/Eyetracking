function eyetrackQAWrap_Toon( funcRemoveBlinks, plotRaw )
% eyetrackQAWrap_Toon will run eyetrackQA on all edffiles from the
% Toonotopy experiment
%
%   eyetrackQAWrap_Toon( [funcRemoveBlinks], [plotRaw] )
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

clear matVersion

%% Checking inputs
if ~exist('plotRaw') | isempty(plotRaw)
    plotRaw = true;
end
if ~exist('funcRemoveBlinks') | isempty(funcRemoveBlinks)
    funcRemoveBlinks = true;
end

%% Storing all data directories containing edf files
% Storing directory where retinotopy eyetracking data is stored
retDir = RAID('projects','Longitudinal','Behavioral','Toonotopy');

% Searching through retDir for edf files
edfFiles = dir([retDir '/**/*.edf']);

% Find all unique folders containing edf files
edfFolders = unique({edfFiles.folder});

% All of these edf files are going to be under a edffiles subfolder under
% the dataDir
dataDirs = cellfun(@(x) x(1:end-9), edfFolders, 'un', 0); 

% Clear other variables
clear edfFolders edfFiles retDir

%% Run eyetrackQAWrap on all data directories found

% Looping across dataDirs
for d = 1:length(dataDirs)
    dataDir = dataDirs{d};
    eyetrackQAWrap( dataDir );
end

end