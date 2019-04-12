function eyetrackQAWrap( dataDir, varargin )
% eyetrackQAWrap runs eyetrackQA on all edffiles in dataDir
%
%   eyetrackQAWrap( dataDir )
%
%       dataDir: (string) path to where data is and will be saved, will have
%                         subfolders for ascfiles, edffiles, figures, and
%                         matfiles
%
% ------------------- Optional Name,Value pair arguments ------------------
%
%   eyetrackQAWrap( dataDir, Name, Value ) specifies analysis properties
%   using one or more optional Name, Value pair arguments. See below for a
%   list of properties.
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
%                       behind the plot (default is from Toonotopy)
%
%       pxlScrnDim - (optional) vector of length 2 containing the x and y
%                    screen dimensions in pixels. Defaults to the screen
%                    dimensions for the Toonotopy experiment [1280 960].
%
%       mmScrnDim - (optional) vector of length 2 containing the x and y
%                   screen dimensions in milimeters. Defaults to the screen
%                   dimensions for the Toonotopy experiment [360 270]
%
%       scrnDstnce - (optional) scalar. Distance from eye to screen in
%                   milimeters. Defaults to screen distance for Toonotopy
%                   experiment (300 mm)
%
%       SACCADE_THRESH - (optional) scalar. the threshold used to define the 
%                   saccades. saccades must cross this thresholded distance
%                   from the center of the screen in order to be counted
%                   (default is 2 dva)
%
% ---------------------------  Examples  ---------------------------------
%
% For running this script on toonotopy data, navigate to your data
% directory and run...
%
%   eyetrackQAWrap( pwd );
%
% For running this script on data from the Recognition Memory experiment,
% navigate to your data directory and run...
%
%   screenshot = RAID('projects','GitHub','Eyetracking',...
%                     'PlottingEyeMovements','ExperimentScreenShots',...
%                     'RecMemFixationAndBar.png');
%   eyetrackQAWrap( pwd, 'experiment_screenshot', screenshot, ...
%                   'pxlScrnDim', [1024 768], 'mmScrnDim', [385.28 288.96],...
%                   'scrnDstnce', 540 );
%
% For running this script on data from the Retinotopy experiment at the
% scanner, navigate to your data directory and run...
%
%   screenshot = RAID('projects','GitHub','Eyetracking',...
%                     'PlottingEyeMovements','ExperimentScreenShots',...
%                     'RecMemFixationAndBar.png');
%   eyetrackQAWrap( pwd, 'experiment_screenshot', screenshot, ...
%                   'pxlScrnDim', [1920 1080], 'mmScrnDim', [1040 585],...
%                   'scrnDstnce', 2620 );
% 
%
% AR Mar 2019

%% Checking inputs

if nargin < 1
    error('eyetrackQA wrap requires the argument dataDir')
end

% Parsing inputs
p = inputParser;
p.KeepUnmatched = true;

% Adding parameters
addParameter(p,'RemoveBlinksFunction',true,@islogical);
addParameter(p,'plotRaw',true,@islogical);
addParameter(p,'experiment_screenshot',RAID('projects','GitHub','Eyetracking',...
             'PlottingEyeMovements','ExperimentScreenShots',...
             'ToonFixationAndBar.png'),@ischar);
addParameter(p,'pxlScrnDim',[1280 960],@(x)isnumeric(x)&&(length(x)==2)&&all(x > 0));
addParameter(p,'mmScrnDim',[360 270],@(x)isnumeric(x)&&(length(x)==2)&&all(x > 0));
addParameter(p,'scrnDstnce',300,@(x)isnumeric(x)&&(length(x)==1)&&all(x > 0));
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

%% Getting list of all edf files in dataDir/edffiles
edfdir = [dataDir, '/edffiles'];
edfFiles = dir(edfdir);
edfFiles = edfFiles(~[edfFiles.isdir]); % Exclude directories
edfFiles = {edfFiles.name}; % Transform into cell array

%% Loop through all files
for e = 1:length(edfFiles)
    % Get fName, without .edf ending
    edfFile = edfFiles{e};
    fName = edfFile(1:end-4);
    
    % Run eyetrackQA
    eyetrackQA( fName, dataDir, 'RemoveBlinksFunction',funcRemoveBlinks, ...
                'plotRaw', plotRaw, 'experiment_screenshot', screenshot, ...
                'pxlScrnDim', pxlScrnDim, 'mmScrnDim', mmScrnDim, ...
                'scrnDstnce', scrnDstnce, 'SACCADE_THRESH', DIST_THRESH );
end
    
end