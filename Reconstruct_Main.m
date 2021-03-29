%% Reconstruct a HCP EBSD map to the BCC using Burger's Orientation Relationship
% MTEX version: 5.4
% Version number: 1.0
%
% Main file for running the reconstruction code 
% Input required = EBSD data 
%
% Last update: 24/03/21 RB
%% Clear workspace

clear all;
close all;
home;

%% General Setup
% load MTEX and add relevant folders to the path 

% Setup MTEX (default = Bruker setup)
run('C:\Users\ruthb\Documents\MTEX\mtex-5.4.0\startup.m'); %start MTEX [change file location]
setMTEXpref('xAxisDirection','west');
setMTEXpref('zAxisDirection','outOfPlane');

% Add folders
settings.file.mainFolder=['C:\Users\ruthb\Documents\GitHub1\ParentBOR'];%full code location
addpath('Functions','h5','Results')% Folders to add 

%% Load EBSD data
% name the dataset and load a h5 file or stored ebsd variable

% EBSD file name 
% [If using a simulated dataset use the filename and add .h5] 
settings.file.fname=('Example.h5');%file name including file type

% load the EBSD data (h5 version)
[ebsd, header] = loadEBSD_h5(settings.file.fname); 

% For simulated dataset: [comment out line 35 & uncomment lines 38-39] 
% load PaperSimulatedDataset.mat; %load the ebsd data
% ebsd=alpha_ebsd; %rename the alpha phase data

%% Reconstruction Setup 
% Setup and store the grain processing and reconstruction settings 

% Phases
settings.phases.phase1=('Zirconium - alpha'); %phase1 - HCP
settings.phases.phase2=('Zirconium - beta'); %phase2 - BCC 

% Grain processing
settings.grains.gbThreshold = 4*degree;% grain boundary threshold angle
settings.grains.smallGrains = 5; % threshold grain size below which the grains will be removed
settings.grains.smoothGrains = 2;% smoothing value (0 = off) Note: smoothed grains not used in calculations

% Reconstruction settings
settings.reconstruct.cutoff = 4; % Threshold value for matching GB misorientations (degrees)
settings.reconstruct.inflationPower = 1.6; % controls MCL alorithm 

% Implement settings
[settings,ebsd] = Setup(settings,ebsd); %run Setup function

%% Plotting Setup
% Plotting options & which plots to output
% Note: 1 = ON & 0 = OFF

% General
PlotOpt.general.SaveOn     = 1;       %Save figures
PlotOpt.general.Scalebar   = 'Off';    %Include scalebar: 'On' or 'Off'

% Part 1 plots - Reconstruction
PlotOpt.IPFs.dir           = zvector; %IPF direction
PlotOpt.IPFs.HCP.initial   = 0;       %Alpha phase IPF map (no smoothing) 
PlotOpt.IPFs.HCP.smoothed  = 1;       %Alpha phase IPF map (smoothed gBs)
PlotOpt.IPFs.BCC.raw       = 1;       %Initial output for beta phase IPF map
PlotOpt.IPFs.BCC.processed = 0;       %Reprocessed beta phase IPF map (no smoothing)
PlotOpt.IPFs.BCC.smoothed  = 1;       %Reprocessed beta phase IPF map (smoothed gBs) 

% Part 2 plots - Post Processing
PlotOpt.Quality.devis      = 0;       %Reconstruction quality (devis) 
PlotOpt.Quality.min_angle  = 0;       %Reconstruction quality (min_angle)
PlotOpt.AlphaVar.all       = 0;       %Alpha variants plot - all 12 variants (12 colours)
PlotOpt.AlphaVar.dir       = 0;       %Alpha variants plot - shared direction (4 colours)
PlotOpt.AlphaVar.planes    = 0;       %Alpha variants plot - shared planes (6 colours)
PlotOpt.AlphaVar.combo     = 1;       %Combined plot - alpha variants (the 3 plots above)
PlotOpt.BetaCert.noOfVar   = 0;       %Beta certainty - no of unique alpha variants per beta grain
PlotOpt.BetaCert.betaOpt   = 0;       %Beta certainty - no of unique beta options for each beta grain

% Part 3 plots - Analysis (Interactive plots & pole figures)
PlotOpt.Interactive.HCP    = 0;       %Interactive IPF map to select an alpha grain
PlotOpt.Interactive.BCC    = 1;       %Interactive IPF map to select a beta grain
PlotOpt.BetaOpt_PF.g_sel   = [];      %Grain selected for PF analysis (option to manually enter or updated through beta interactive plot)
PlotOpt.BetaOpt_PF.basic   = 0;       %For selected beta grain - PF for current beta option with alpha grain orientations(1 polefig, 2 colours) 
PlotOpt.BetaOpt_PF.colour  = 1;       %For selected beta grain - PFs for all beta options + alpha grain ori(1-6 polefigs, alpha var colouring)

% Part 4 plots - Alternative beta options
PlotOpt.altBeta.combo      = 1;       %Combo plot for each of the altenative beta options for the grains (1 plot, 6 subplots)
PlotOpt.altBeta.alphaVar   = 0;       %Alpha variants (12 variants/shared (c)/shared <a>) - Combined plots x6 (numbered)

%% Run the Reconstruction Section
% Run part 1 - reconstuct the parent grain microstructure
% output = beta/BCC phase ebsd and grains data

[ebsd_all,grains,reconstructionData] = Reconstruction(ebsd,settings); %Reconstruct the parent microstructure

%% Run the Post Processing Section
% Run part 2 - post processing
% output = alpha variants & parent beta orientation options

[grains] = PostProcessing(grains,ebsd_all,settings); %Calculate alpha variants and beta orientation options

%% Plotting 

% Part 1 - Reconstruction (IPF maps)
[PlotOpt]=Plotting_Part1(settings,PlotOpt,grains,ebsd_all);
%(also updates PlotOpt with setup for IPFs - used in Plotting_Part3)

% Part 2 - Post Processing (quality, alpha variants, beta options)  
Plotting_Part2(settings,PlotOpt,grains);

% Part 3 - Analysis (Interactive plots & pole figures)
[PlotOpt]=Plotting_Part3(grains,settings,PlotOpt);

% Part 4 - Explore alternative beta options further [this takes a long time]
%(Alternate IPF maps & alpha variants based on the other beta options) 
% [grains]=Plotting_Part4(grains,settings,PlotOpt);

%% Save Workspace
cd(settings.file.filesave_loc); %go to results folder
filename='workspace'; %filename
save(filename) %save the workspace
cd(settings.file.mainFolder); %go back to main folder
 
