function [processed, blinks] = removeBlinks(raw)
% removeBlinks will set all time points corresponding to blinks in raw
% eyetracking data to NaN
%
%   [processed, blinks] = removeBlinks(raw)
%
%       raw - 4 dimensional data matrix of doubles. raw(:,1) gives time, 
%             raw(:,2) gives x coodinate, raw(:,3) gives y coordinate, and
%             raw(:,4) gives the distance between the eye's position from
%             the center of the screen. Positions are in degrees of visual 
%             angle (dva)
%
%       processed - Data matrix of doubles with the same shape as raw.
%                   Contains processed data where blinks are labeled as NaN
%
%       blinks - timepoints in raw that were labeled as a blink
%
% AR Jan 2019, adapted from a script DF wrote
% AR Mar 2019 output blinks

% Extract x and y components of raw
x = raw(:,2);
y = raw(:,3);

%% Removing Blinks

% Find when subject starts to blink
d       = diff(isnan(x) | isnan(y));
starts  = find(d==1);

% Look at how y data behaves to see when there are large jumps before
% and after blink
ydiff     = diff(y);
ydiffmean = nanmean(abs(ydiff));
ydiffstd  = nanstd( abs(ydiff));

blinks = [];

% Delete data before start of blink
for i = 1:length(starts)
  s = starts(i); % Timepoint right before the start of the blink
  go = 20; % Will continue deleting until there are this many consecutive 
           % non-blink datapoints. Since the RecMem experiment records at
           % 1000 Hz
  while s>0 & go>0
    % Check to see if y value shows a significant jump in the data
    if (abs(ydiff(s)) > (ydiffmean + 3*ydiffstd))
      raw(s,2:4)=nan; % Get rid of bad data before blink
      % Add timepoint to blinks
      blinks = [blinks s];
      go=20; % Reset go
    else
      raw(s,2:4)=nan; % Get rid of a few extra timepoints before the blink
                      % to make sure the data is clean
      blinks = [blinks s];
      go=go-1;
    end
    s=s-1; % Look at previous timepoint
  end
end

% Find when subject stops blinking
ends  = find(d==-1);

% Delete data after end of blink
for i = 1:length(ends)
  e = ends(i) + 1; % Timepoint right after the end of the blink
  go = 20; % Will continue deleting until there are this many consecutive 
           % non-blink datapoints
  while e<length(x) & go>0
    % Check to see if y value shows a significant jump in the data
    if (abs(ydiff(e)) > (ydiffmean + 3*ydiffstd))
      raw(e,2:4)=nan; % Get rid of bad data before blink
      blinks = [blinks s];
      go=20; % Reset go 
    else
      raw(e,2:4)=nan; % Get rid of a few extra timepoints before the blink
                      % to make sure the data is clean
      blinks = [blinks s];
      go=go-1;
    end
    e=e+1;
  end
end

% Return processed
processed = raw;

end