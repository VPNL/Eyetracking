function setupEyelink_Projector( edfName, win )
% setupEyelink_Projector setups eyelink system for eye tracking with the 
% projector.
%
%   setupEyelink_Projector( edfName, win )
%
%       edfName - (string) what you would like to call your edf (should be
%                          no more than 8 characters)
%
%       win - PsychToolBox window pointer
%
% AR March 2019

% Set scaling factor for shrinking screen resolution to fit on projector
shrinkWidth = .25; % This fraction of the width will be taken off
shrinkHeight = .2; % This fraction of the height will be taken off

% Initialize eyelink and check to make sure Eyelink is online
if EyelinkInit() ~= 1
    error(['Cannot connect to eye tracker. Try turning off wifi.'])
end

%% Eyelink setup

% Get init defaults
el = EyelinkInitDefaults(win);

% Open edf file to record data
edf = Eyelink('Openfile',edfName);
% Check to make sure file was created
if edf ~= 0
    Eyelink('Shutdown')
    error(['Could not create EDF file ' edfName ...
           '. Try turning off wifi']);
end

% Setting eyelink preferences and parameters
Eyelink('command', 'add_file_preamble_text ''dynamic stim eyetracking''');
Eyelink('command','screen_distance = 940'); % Distance from eye tracker 
                                           % camera to mirror image of
                                           % subject's eye (measured by AR
                                           % and MN on 03.05.2019)
Eyelink('command', 'calibration_type = HV3'); % 3 point calibration, 
                                              % set in calibr.ini

% allow to use eyelink GUI to accept fixations/targets
Eyelink('command', 'button_function 5 "accept_target_fixation"');   

% Telling eyelink what to record
Eyelink('command', ...
        'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', ...
        'file_sample_data  = LEFT,RIGHT,GAZE,DIAMETER,HREF,AREA,GAZERES,STATUS');
Eyelink('Command', 'file_event_data = GAZE,GAZEREZ,DIAMETER,HREF,VELOCITY');
Eyelink('command', ...
        'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', ...
        'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');                                           
                                              
%% Shrinking screen size for calibration
[width, height]=Screen('WindowSize',win); % returns full screen size in 
                                          % pixels

% Storing usable screen size as variable rect. rect(1) sets the 
% distance from the left side of the screen (if 0, dots could appear at far
% left). rect(2) shrinks the height from the top (if 0, dots could appear 
% at the very top). rect(3) controls how far the dots are from the right 
% side of the screen (if width-1, dots could appear at far right). rect(4) 
% controls how far the dots are from the bottom of the screen (if height-1, 
% dots could appear at very bottom).
rect = [width*shrinkWidth, height*shrinkHeight, ...
        width - width*shrinkWidth, height-300];

% Set screen coordinates
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, ...
        width-1, height-1); % sets physical.ini to screen pixels
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, ...
        height-1);
    
% Override default calibration and validation targets
Eyelink('command','generate_default_targets = NO');
Eyelink('command','calibration_samples = 3');
Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d',...
        rect(1),rect(4), rect(3),rect(4), width*.5,rect(2));
Eyelink('command','validation_samples = 3');
Eyelink('command','validation_targets = %d,%d %d,%d %d,%d',...
        rect(1),rect(4), rect(3),rect(4), width*.5,rect(2));

%% Calibrate
fprintf('\n\nRun calibration and validation now. When done, hit "Output/Record"\n\n\n');

% Run calibration and validation
EyelinkDoTrackerSetup(el);

fprintf('\n\nContinue to accept fixation until drift correction error is reduced. When done, go back to camera setup and then hit "Output/Record"\n\n\n');

% Run drift correction
EyelinkDoDriftCorrect(el,width*.5, height*.5); % Specified fixation point

end