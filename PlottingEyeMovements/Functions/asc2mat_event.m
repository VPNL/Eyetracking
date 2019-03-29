function [blink, dataQuality] = asc2mat_event( ascFile, stime )
% asc2rawMat_event reads an event asc file and returns eyelink blink data
% and information about the quality of the eyetracker's calibration
%
%   [blink, dataQuality] = asc2mat_event( ascFile, stime )
%
%       ascFile - (char array) filepath to asc file containing event data
%
%       stime - (scalar) starting time of experiment
%
%       blink - (vector of doubles) timepoints when subject was blinking
%
%       dataQuality - struct with fields calibration_quality, 
%                     validation_quality, and drift_quality which indicate
%                     whether the final calibration, validation and drift
%                     correction steps before the start of the experiment
%                     were GOOD, FAIR, POOR, FAILED, ABORTED or were never
%                     run (NO).
%
% AR Mar 2019

% Read contents of asc file
ascText = fileread(ascFile);

%% Identify Blinks

% In the asc file, each line correspondes with a new event. The end of a
% blink is labeled as EBLINK and the end of a saccade is labeled at ESACC.
% For this script, I assign all time points labeled by eyelink as blinks as
% well as their preceding and proceding saccades as NaNs. In the asc file,
% ESACC lines will take the following form:
%
% ESACC <eye> <stime> <etime> <dur> <sxp> <syp> <exp> <eyp> <ampl> <pv> 
%
% In the code below, I extract <stime> and <etime> and label them as blink
% starts and ends.
blinkStartSearch = 'EBLINK[^\n]*\nESACC[^\d]*(\d*)';
blinkStarts = regexp(ascText,blinkStartSearch,'tokens');
blinkEndSearch = 'EBLINK[^\n]*\nESACC[^\d]*\d*[^\d]*(\d*)';
blinkEnds = regexp(ascText,blinkEndSearch,'tokens');

% Convert blinkStarts and blinkEnds from cell arrays to vectors
blinkStarts = horzcat(blinkStarts{:});
blinkStarts = str2double(blinkStarts);
blinkEnds = horzcat(blinkEnds{:});
blinkEnds = str2double(blinkEnds);

% Define all blink time points
blink = [];
for b = 1:length(blinkStarts)
    blink = [blink blinkStarts(b):blinkEnds(b)];
end

% Update blink time so that it can be used to index in raw and processed
blink = blink - stime + 1;
                       
%% Get calibration quality

% In the asc file, there will be two lines that take the following form if
% the calibration and validation was good, fair or poor.
%
%   MSG 1714057 !CAL CALIBRATION HV3 R RIGHT GOOD 
%   MSG	1719239 !CAL VALIDATION HV3 R RIGHT GOOD
%
% If calibration and validation were aborted or failed, the lines would 
% take the following form.
%
%   MSG 1714057 !CAL CALIBRATION R ABORTED
%   MSG	1719239 !CAL VALIDATION R ABORTED
%
% If drift correction was successful, there will be the following message
% that gives you which eye was measured.
%
%   MSG	1842341 DRIFTCORRECT L LEFT
%
% If drift correction was aborted, there will be the following message.
%
%   MSG	1842341 DRIFTCORRECT L ABORTED
%
% These messages give information about the quality of the calibration,
% validation and drift correction that we would like to store.

% Search for calibration quality, can take the values of good, fair, poor,
% aborted or failed
calSearch = ['CALIBRATION[^\n]*((GOOD)|(FAIR)|(POOR)|(ABORTED)|(FAILED))'];
calQuality = regexp(ascText,calSearch,'tokens');

% If calQuality is empty, we did not run the calibration
if isempty(calQuality)
    calQuality{1,1} = {'NO'};
end

% Search for validation quality, can take the values of good, fair, poor,
% aborted or failed
valSearch = ['VALIDATION[^\n]*((GOOD)|(FAIR)|(POOR)|(ABORTED)|(FAILED))'];
valQuality = regexp(ascText,valSearch,'tokens');

% If valQuality is empty, we did not run the validation
if isempty(valQuality)
    valQuality{1,1} = {'NO'};
end

% Search for drift correction, can take the values of aborted, left, right,
% or failed.
driftSearch = ['DRIFTCORRECT[^\n]*((ABORTED)|(LEFT)|(RIGHT)|(FAILED))'];
driftQuality = regexp(ascText,driftSearch,'tokens');

% If driftQuality is empty, we did not run the drift correction
if isempty(driftQuality)
    driftQuality{1,1} = {'NO'};
% If driftQuality is LEFT or RIGHT, then it was successful
elseif strcmp(driftQuality{1,end},'LEFT') | strcmp(driftQuality{1,end},'RIGHT')
    driftQuality{1,end} = {'SUCCESSFUL'};
end

% Organize calQuality, valQuality, and driftQuality into a dataQuality
dataQuality = struct('calibration_quality',calQuality{1,end}{1},...
                     'validation_quality',valQuality{1,end}{1},...
                     'drift_quality',driftQuality{1,end}{1});

end