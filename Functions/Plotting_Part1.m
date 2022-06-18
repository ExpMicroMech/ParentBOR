function [PlotOpt]=Plotting_Part1(settings,PlotOpt,grains,ebsd_all)
%PLOTTING_PART1 - Plots for Part 1: Reconstruction
%   IPF Plots:
%       - Alpha/HCP (smoothed/unsmoothed grain boundaries)
%       - Beta/BCC (raw/reprocessed grains/smoothed reprocessed grains)
%
% Inputs:
%   settings - structure containing settings required for grain processing 
%              and reconstruction.
%   PlotOpt  - structure containing plotting options
%   grains   - structure containing grain data for alpha and beta phases
%   ebsd_all - structure containing ebsd data for alpha and beta phases
%
% created: 21/01/21 RB
%% Setup
% General
IPF_Dir = PlotOpt.IPFs.dir;       %IPF direction
phase1 = settings.phases.phase1;  %Phase1 = HCP
phase2 = settings.phases.phase2;  %Phase2 = BCC

% Alpha phase/HCP 
ebsd_alpha=ebsd_all.ebsd;                                    %Alpha phase EBSD data
PlotOpt.general.oM.oM1 = ipfTSLKey(ebsd_alpha(phase1));      %HCP Colorkey (TSL is default)
PlotOpt.general.oM.oM1.inversePoleFigureDirection = IPF_Dir; %set IPF direction

% Beta phase/BCC 
ebsd_beta_raw=ebsd_all.ebsd_beta_raw;                        %Beta phase EBSD data (RAW)
PlotOpt.general.oM.oM2 = ipfTSLKey(ebsd_beta_raw(phase2));   %BCC Colorkey (TSL is default)
PlotOpt.general.oM.oM2.inversePoleFigureDirection = IPF_Dir; %set IPF direction for oM2

ebsd_beta=ebsd_all.ebsd_beta;                                %Beta phase EBSD data (REPROCESSED)
PlotOpt.general.oM.oM3 = ipfTSLKey(ebsd_beta(phase2));       %BCC Colorkey (TSL is default)
PlotOpt.general.oM.oM3.inversePoleFigureDirection = IPF_Dir; %set IPF direction for oM3

%% IPFs - HCP
% Plot IPF maps for alpha phase microstructure

% No grain boundary smoothing
if PlotOpt.IPFs.HCP.initial > 0;
    % Plot IPFZ map for initial (alpha phase) data (+ colourkey)
    plotMaps_HCP(ebsd_alpha,grains,settings,PlotOpt,1); 
    %plotMaps_HCP(ebsd_alpha,grains,settings,PlotOpt,Type)
end

% Using smoothed grain boundaries
if PlotOpt.IPFs.HCP.smoothed > 0;
    % Plot IPFZ map using smoothed grains for initial (alpha phase) data (+ colourkey)
    plotMaps_HCP(ebsd_alpha,grains,settings,PlotOpt,2); 
    %plotMaps_HCP(ebsd_alpha,grains,settings,PlotOpt,Type)
end

%% IPFs - BCC
% Plot IPF maps for beta phase microstructure

if PlotOpt.IPFs.BCC.raw > 0;
    % Plot IPFZ map for initial reconstruction output (+ colourkey)
    plotMaps_BCC_quick(ebsd_all,grains,settings,PlotOpt,1); 
    %plotMaps_BCC(ebsd_all,grains,settings,PlotOpt,Type)
end

if PlotOpt.IPFs.BCC.processed > 0;
    % Plot IPFZ map for processed beta grain data (+ colourkey)
    plotMaps_BCC_quick(ebsd_all,grains,settings,PlotOpt,2);
    %plotMaps_BCC(ebsd_all,grains,settings,PlotOpt,Type)
end

if PlotOpt.IPFs.BCC.smoothed > 0;
    % Plot IPFZ map using smoothed grains for processed beta grain data (+ colourkey)
    plotMaps_BCC_quick(ebsd_all,grains,settings,PlotOpt,3); 
    %plotMaps_BCC(ebsd_all,grains,settings,PlotOpt,Type)
end

end

