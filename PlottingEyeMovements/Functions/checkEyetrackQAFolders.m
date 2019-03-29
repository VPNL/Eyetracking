function [ edfdir, ascdir, figdir, matdir ] = ...
                checkEyetrackQAFolders( dataDir, funcRemoveBlinks )
% checkEyetrackQAFolders sets the folder paths to edfdir, ascdir, figdir, 
% matdir and creates subfolders as needed
%
%   [ edfdir, ascdir, figdir, matdir ] = checkEyetrackQAFolders( dataDir, funcRemoveBlinks )
%
%       dataDir = (char array) path to main data directory
%
%       funcRemoveBlinks = (logical) whether you would like to use the 
%                                    removeBlinks function to remove blinks
%                                    in parallel with eyelink's blink 
%                                    labeling
%
%       edfdir = (char array) path to edffiles
%
%       ascdir = (char array) path to asc files
%
%       figdir = (char array) path to figures
%
%       matdir = (char array) path to mat files
%
% AR Mar 2019

% Setting paths to the subfolders of dataDir
edfdir = [dataDir '/edffiles'];
ascdir = [dataDir '/ascfiles'];
figdir = [dataDir '/figures'];
matdir = [dataDir '/matfiles'];

% Making sure that all required folders exist
if ~exist(edfdir)
    error(['Cannot find folder with edffiles. Please make the directory ' ...
           edfdir ' and move your edffiles to this folder.'])
end

if ~exist([ascdir '/events'])
    warning(['Cannot find ' ascdir '/events. Creating this folder now'])
    mkdir([ascdir '/events']);
end

if ~exist([ascdir '/samples'])
    warning(['Cannot find ' ascdir '/samples. Creating this folder now'])
    mkdir([ascdir '/samples']);
end

if ~exist([matdir '/ELBlinksRemoved'])
    warning(['Cannot find ' matdir '/ELBlinksRemoved. Creating this folder now'])
    mkdir([matdir '/ELBlinksRemoved']);
end

if ~exist([matdir '/event'])
    warning(['Cannot find ' matdir '/event. Creating this folder now'])
    mkdir([matdir '/event']);
end

if ~exist([matdir '/FuncBlinksRemoved']) & funcRemoveBlinks
    warning(['Cannot find ' matdir '/FuncBlinksRemoved. Creating this folder now'])
    mkdir([matdir '/FuncBlinksRemoved']);
end

if ~exist([matdir '/raw'])
    warning(['Cannot find ' matdir '/raw. Creating this folder now'])
    mkdir([matdir '/raw']);
end

if ~exist([figdir '/raw'])
    warning(['Cannot find ' figdir '/raw. Creating this folder now'])
    mkdir([figdir '/raw']);
end

if ~exist([figdir '/FuncBlinksRemoved']) & funcRemoveBlinks
    warning(['Cannot find ' figdir '/FuncBlinksRemoved. Creating this folder now'])
    mkdir([figdir '/FuncBlinksRemoved']);
end

if ~exist([figdir '/ELBlinksRemoved'])
    warning(['Cannot find ' figdir '/ELBlinksRemoved. Creating this folder now'])
    mkdir([figdir '/ELBlinksRemoved']);
end

end

