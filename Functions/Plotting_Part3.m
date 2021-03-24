function [PlotOpt]=Plotting_Part3(grains,settings,PlotOpt)
%PLOTTING_PART3 - interactive plots & pole figures
%   Plots:
%       - Interactive alpha map (select an alpha grain using mouse click)
%       - Interactive beta map (select a beta grain using mouse click)
%       - Plot pole figures (PF) for all potential beta options for 
%         selected beta grain, with the alpha grain orientations for the 
%         corresponding alpha grains overlaid (coloured by variant number)
%       - Plot PF (planes & directions) for selected beta orientation and
%         all alpha grains within
% 
% Inputs:
%   grains   - structure containing grain data for alpha and beta phases
%   settings - structure containing settings required for grain processing 
%              and reconstruction.
%   PlotOpt  - structure containing plotting options
%
% Output:
%   PlotOpt - updated to include the beta grain selected(g_sel)
%
% 22/01/21 RB
%% Interactive plots
% IPF plots that take a mouse click to identify the grain selected

% Alpha/HCP
if PlotOpt.Interactive.HCP > 0   
    % Interactive plot to identify an alpha grain number (mouse click)
    [grainSelectedAlpha] = plotInteractive (grains,settings,PlotOpt,1); %[grainSelected] = plotInteractive (grains,settings,PlotOpt,type)
    % outputs grain info into command window and saves the plot with the
    % grain highlighted (file name include grain ID)
end

% Beta/BCC
if PlotOpt.Interactive.BCC > 0
    % Interactive plot to identify a beta grain number (mouse click)
    [grainSelectedBeta] = plotInteractive (grains,settings,PlotOpt,2); %[grainSelected] = plotInteractive (grains,settings,PlotOpt,type)
    % outputs grain info into command window and saves the plot with the grain highlighted (file name include grain ID)
    
    % update the grain selected in plot options 
    PlotOpt.BetaOpt_PF.g_sel=grainSelectedBeta.id; %here for clarity rather than built into function
end

%% Pole figures
% plot the beta orientation & alpha variants for chosen beta grain
% Note: change grain selected using Beta interactive plot or manually in the main script options

%PF(s) for all Beta orientation options for the selected beta grain
if PlotOpt.BetaOpt_PF.colour > 0
    % Plot polefigures for potential alpha orientations for selected beta grain
    plotBetaOptions (grains, PlotOpt, settings); %plotBetaOptions (grains, PlotOpt, settings)
end

%PFs for current beta orientation & all alpha grains within
if  PlotOpt.BetaOpt_PF.basic > 0
    % Check Plots - PF for reconstructed grain vs. alpha grains contained within
    plotCheckPlots (grains, PlotOpt, settings); %checkPlots (grains, PlotOpt, settings)
end

end

