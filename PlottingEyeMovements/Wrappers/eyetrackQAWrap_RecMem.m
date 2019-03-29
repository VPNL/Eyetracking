function eyetrackQAWrap_RecMem( year, funcRemoveBlinks, plotRaw )
% eyetrackQAWrap_RecMem will run eyetrackQA on all edffiles in the Rec Mem 
% meridian mapping data directory corresponding to the indicated year and 
% experiment
%
%   eyetrackQAWrap_RecMem( year, [funcRemoveBlinks], [plotRaw] )
%
%       year - (numeric) year in study you want analyzed
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
% AR Feb 2019
% AR Mar 2019 Changed plotRaw default to true, changed function name, count
%             number of saccades, added argument funcRemoveBlinks,
%             organized majority of function into new eyetrackQAWrap
%             function

% Checking inputs
if ~exist('plotRaw') | isempty(plotRaw)
    plotRaw = true;
end

if ~exist('funcRemoveBlinks') | isempty(funcRemoveBlinks)
    funcRemoveBlinks = true;
end

% Setting data file paths
dataDir = RAID('projects','Longitudinal','Behavioral','RecognitionMemory',...
               'data',['Year' num2str(year)],'eyetracking','meridianMapping'); 

% Run eyetrackQA on all edfs in datadir
eyetrackQAWrap( dataDir, 'RemoveBlinksFunction',funcRemoveBlinks, ...
                'plotRaw', plotRaw );

end