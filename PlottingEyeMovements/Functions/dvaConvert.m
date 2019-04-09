function finalData = dvaConvert( data, pxlScrnDim, mmScrnDim, scrnDstnce )
% dvaConvert converts eyetracker data from pixel units to degrees of visual
% angle (dva)
%
%   finalData = dvaConvert( data, pxlScrnDim, mmScrnDim, scnDstnce )
%
%       data - 4 dimensional data matrix of doubles. data(:,1) gives time, 
%              data(:,2) gives x coodinate, data(:,3) gives y coordinate, and
%              data(:,4) gives the distance between the eye's position from
%              the center of the screen. Positions are in degrees of visual 
%              angle (dva)
%
%       pxlScrnDim - vector of length 2 containing the x and y
%                    screen dimensions in pixels.
%
%       mmScrnDim - vector of length 2 containing the x and y
%                   screen dimensions in milimeters.
%
%       scnDstnce - Scalar distance from eye to screen in
%                   milimeters.
%
%       finalData - Data matrix of doubles with the same shape as raw.
%                   Contains data in units of degree of visual angle.
%
% AR Jan 2019
% AR Feb 2019 updated default parameters to match the RecMem code,
%             corrected dva conversion (was off by a factor of 2)
% AR Apr 2019 made all inputs required

%% Unit Convertion on Data

% Assign zero to center of the screen
data(:,2) = data(:,2) - ( pxlScrnDim(1) / 2 );
data(:,3) = data(:,3) - ( pxlScrnDim(2) / 2 );

% Flip direction of y axes so that figures match those from eyelink's data
% viewer
data(:,3) = data(:,3)*-1;

% Calculate conversion from pixels to milimeters
MMCONVERT = mmScrnDim(1) / pxlScrnDim(1);

% Convert data to milimeters
data(:,2:3) = data(:,2:3) * MMCONVERT;

% Convert data to DVA
data(:,2:3) = atand(data(:,2:3)/scrnDstnce);

% Return finalData
finalData = data;

end

