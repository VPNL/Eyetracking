function [numSaccades, saccadeLocs] = countSaccades( processed, THRESHOLD )
% countSaccades counts the number of saccades in processed data based on a
% threshold. Everytime the eye crosses a thresholded dva away from the
% center of the screen, a saccade will be counted.
%
%   [numSaccades, saccadeLocs] = countSaccades( processed, THRESHOLD )
%
%       processed - 4 dimensional data matrix of doubles containing
%                   eyetracking data with blinks labeled as NaN. The first
%                   dimension is time, second is x position, third is y
%                   position, and fourth is the eye's distance from the
%                   center of the screen. All positions are in dva.
%
%       THRESHOLD - the threshold used to define the saccades (saccades
%                   must cross this thresholded distance from the center of
%                   the screen in order to be counted)
%
%       numSaccades - the number of saccades detected in processed
%
%       saccadeLocs - the times corresponding each saccade found in 
%                     processed
%
% AR Mar 2019

% Count the number of times the eye crosses the THRESHOLD
saccadeLocs = find( ( processed(1:end-1,4) < THRESHOLD & ...
                      processed(2:end,4) > THRESHOLD ) | ...
                     ( processed(1:end-1,4) > THRESHOLD & ...
                       processed(2:end,4) < THRESHOLD ) );
                   
% Return numSaccades
numSaccades = length(saccadeLocs);

end