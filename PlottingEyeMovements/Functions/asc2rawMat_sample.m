function [raw, stime] = asc2rawMat_sample( ascFile, pxlScrnDim, mmScrnDim, ...
                                           scrnDstnce )
% asc2rawMat_sample converts asc files to a raw data variable that can be saved as
% a .mat file. This function mirrors Jesse's function asc2mat stored in
% kgs/projects/Longitudinal/Behavioral/Eyetracking/Code/asc2mat. This raw
% data contains only position data, not event data.
%
%   [raw, stime] = asc2rawMat_sample( ascFile, [pxlScrnDim], [mmScrnDim], ...
%                                     [scrnDstnce] )
%
%       ascFile - (string) filepath to asc file containing sample data
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
%       scnDstnce - (optional) scalar. Distance from eye to screen in
%                   milimeters. Defaults to screen distance for Recognition
%                   Memory experiment (540 mm)
%
%       raw - 4 dimensional data matrix of doubles. raw(:,1) gives time, 
%             raw(:,2) gives x coodinate, raw(:,3) gives y coordinate, and
%             raw(:,4) gives the distance between the eye's position from
%             the center of the screen. Positions are in degrees of visual 
%             angle (dva)
%
%       stime - first timepoint listed in ascFile
%
% AR Jan 2019
% AR Mar 2019 renamed function, added output stime, set start time to 1 in 
%             raw, centerdata at median, convert raw data to dva, 
%             calculated distance from center for all time points and saved
%             under raw(:,4)

%% Check inputs
if ~exist('scrnDstnce') | isempty(scrnDstnce)
    scrnDstnce = 540;
end

if ~exist('mmScrnDim') | isempty(mmScrnDim)
    mmScrnDim = [385.28 288.96];
end

if ~exist('pxlScrnDim') | isempty(pxlScrnDim)
    pxlScrnDim = [1024 768];
end

%% Read asc file
% Open asc file
fid = fopen(ascFile);

% Reads data in asc file and organizes it into a 5 column cell array of
% strings called raw. The asc file stores 5 dimensions of data and each
% dimension is separated out into this cell array.
raw = textscan(fid, '%s %s %s %s %s');

% raw{1} stores time, raw{2} stores x coordinate, and raw{3} stores y
% coordinate. We won't use raw{4} or raw{5}, so they get deleted here.
raw(:,4:5) = [];

% Reorganize raw into a matrix of doubles
raw = horzcat(raw{:});
raw = str2double(raw);

%% Center data and convert to dva

% Return stime
stime = raw(1,1);

% Set start time to 1
raw(:,1) = raw(:,1) - stime + 1;

% Convert data to dva
raw = dvaConvert( raw, pxlScrnDim, mmScrnDim, scrnDstnce );

% Center data at median position
raw(:,2) = raw(:,2) - nanmedian(raw(:,2));
raw(:,3) = raw(:,3) - nanmedian(raw(:,3));

% Calculate radius at each time point (distance from center)
raw(:,4) = sqrt(raw(:,2).^2 + raw(:,3).^2);

% Close asc file
fclose(fid);

end

