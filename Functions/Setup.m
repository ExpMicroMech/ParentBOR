function [settings,ebsd] = Setup(settings,ebsd)
%SETUP - implement the settings
% Setup the phases, crystal structure and file save location. Store the 
% settings chosen in a text file.
%
% INPUT:
%   - settings variable
% OUTPUT:
%   - updated settings variable including:
%           crystal structures
%           phases
%   - new folder for results
%   - settings file created to capture settings used
%
% 21/01/2021 RB
%% Phases & Crystal Structures

% find the phases
phase1=settings.phases.phase1;%HCP
phase2=settings.phases.phase2;%BCC

%create the crystal structures
cs_hcp = ebsd(phase1).CS; %HCP - alpha phase

%Remove an additional phase if present
ebsd_phase2=ebsd(ebsd.phase==2);
ebsd(ebsd.phase==2).phase=0;

% If no beta phase in file - create beta phase:
try %try to load CS 2
    ebsd(phase2).CS;
catch % if phase 2 does not work, add this to the list
    cs_bcc = crystalSymmetry('m-3m', [3.642 3.642 3.642], 'mineral',phase2, 'color', 'light green');
    ebsd.CSList{end+1} = cs_bcc;
    ebsd.phaseMap(end+1) = length(ebsd.phaseMap+1);
end

% Add to settings
settings.sym.cs_hcp=cs_hcp; % Alpha/HCP
settings.sym.cs_bcc=cs_bcc; % Beta/BCC

%% File save location 

% Get file name & create results file name
fname=settings.file.fname; %file name
[filepath,name,ext] = fileparts(fname); %Separate the file name from the file type 
foldername=(['Results_',name]); %Create the results folder for this file

% Create results folder for this file
cd Results; %Go to results folder
mkdir(foldername); % make a new folder
addpath(foldername); %add the folder to the path
cd ..;%return to parent folder

% store new results folder as file save location 
mainFolder=settings.file.mainFolder;%main folder
settings.file.filesave_loc=[mainFolder,'\Results\',foldername,'\']; %store save folder
filesave_loc=settings.file.filesave_loc; %save folder

%% Create settings file to store settings data
% Ensure the settings used are stored for reference
 
% Setup the text file
fileID1=['Settings_',name,'.txt']; %create settings file name
fileID2=[filesave_loc fileID1]; % text file location

gbThreshold_deg=settings.grains.gbThreshold*180/pi; %get gbthreshold in degrees

%go to folder
cd(filesave_loc)
% open file
fileID = fopen(fileID2,'w');

% add file data to file 
fprintf(fileID,'%s\n',fname); % EBSD file name
% add date run
date = datetime; % get today's date & time
fprintf(fileID,'Date run:%23s\n\n',date); %Add to file

% Grain processing section
fprintf(fileID,'Grain Processing Settings:\n'); %Section header
fprintf(fileID,'\t Grain boundary threshold: %.1f degrees\n',gbThreshold_deg);%Grain boundary threshold
fprintf(fileID,'\t Small grains threshold: %i pixels\n',settings.grains.smallGrains); %small grains threshold
fprintf(fileID,'\t Smoothing value: %i\n',settings.grains.smoothGrains); %smoothing value

% Reconstruction settings section
fprintf(fileID,'\nReconstruction Settings:\n'); %Section header
fprintf(fileID,'\t Cutoff: %.1f\n',settings.reconstruct.cutoff); %Cut off value
fprintf(fileID,'\t Inflation power: %.1f\n\n',settings.reconstruct.inflationPower); %Inflation power for MCL algorithm

% Add header for output section
fprintf(fileID,'Reconstruction Section Outputs:\n'); %Section header

%close the file
fclose(fileID);

%store filename for later
settings.file.textfile=fileID2;

% go back to main folder
cd (settings.file.mainFolder)
end

