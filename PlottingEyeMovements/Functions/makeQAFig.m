function fig = makeQAFig( data, figName, screenshot, mmScrnDim, ...
                          scrnDstnce, DIST_THRESH )
% makeQAFig plots processed eyetracking data. The plot will have a color map
% showing how the eye position changes over time.
%
%   fig = makeQAFig( data, figName, screenshot, mmScrnDim, scnDstnce,
%                    DIST_THRESH )
%
%       data - 4 dimensional data matrix of doubles. data(:,1) gives time, 
%              data(:,2) gives x coodinate, data(:,3) gives y coordinate, and
%              data(:,4) gives the distance between the eye's position from
%              the center of the screen. Positions are in degrees of visual 
%              angle (dva)
%
%       figName - string or cell array defining how you want to title your 
%                 figure
%
%       screenshot - path to image you want to appear behind the
%                    plot
%
%       mmScrnDim - vector of length 2 containing the x and y
%                   screen dimensions in milimeters.
%
%       scnDstnce - scalar. Distance from eye to screen in
%                   milimeters.
%
%       DIST_THRESH - scalar. the threshold used to define the 
%                   saccades. saccades must cross this thresholded distance
%                   from the center of the screen in order to be counted
%                   (if not added to argument, will not plot circle showing
%                   threshold)
%
%       fig - a plot of the processed eyetracking data showing where the
%             participant looked across the experiment
%
% AR Jan 2019
% AR Feb 2019 Setting the axes to match the edges of the screen. Overlaying
%             screenshot of experiment. Updating default parameters to
%             match RecMem code.
% AR Mar 2019 Added coloring to show how eye movements change over time;
%             Added circle showing the threshold used to count the number
%             of saccades; rounding timepoints displayed on the colormap;
%             update location of default screenshot
% AR Apr 2019 made screenshot, scrnDstnce, and mmScrnDim required

%% Plot Data
fig = figure('visible','off');

% Calculating max dva in each direction
maxX = atand(mmScrnDim(1)/(2*scrnDstnce));
maxY = atand(mmScrnDim(2)/(2*scrnDstnce));
% Store max time value in seconds
maxT = max(data(:,1))/1000;

% Overlay screenshot of experiment
img = imread(screenshot);
image('CData',img,'XData',[-maxX,maxX],'YData',[-maxY,maxY]);
hold on

% Draw circle showing the distance threshold used to count saccades
if exist('DIST_THRESH')
    viscircles([0,0],DIST_THRESH,'Color','w','LineWidth',.25);
end

% Plot eyetracking data (x, y and time in seconds)
surface([data(:,2),data(:,2)],[data(:,3),data(:,3),],[data(:,1)/1000,...
    data(:,1)/1000],'EdgeColor','flat', 'FaceColor','none');

% Label axes and figure
ylabel('Degrees of Visual Angle From Screen Center')
xlabel('Degrees of Visual Angle From Screen Center')
title(figName)

% Make sure the axis scales are equal
axis equal;

% Setting x and y limits
xlim([-maxX,maxX])
ylim([-maxY,maxY])

% Set colormap
cbar = colorbar('Ticks',[0 round(maxT*.25) round(maxT*.5) round(maxT*.75) ...
                         round(maxT-1)],...
                'TickLabels',{[num2str(0)], [num2str(round(maxT*.25))], ...
                              [num2str(round(maxT*.5))], ...
                              [num2str(round(maxT*.75))], ...
                              [num2str(round(maxT-1))]});
cbar.Label.String = 'Time (seconds)';
colormap(cool);

hold off

end