function plotMaps_HCP(ebsd_alpha,grains,settings,PlotOpt,Type)
%
%   plotMaps_HCP plots the IPF(Z) map for the initial microstructure. (+ colourkey)
%
%   Inputs:
%   ebsd_alpha - EBSD data for alpha phase
%   grains - structure containing:
%       grains_hcp - grains data for alpha phase
%       grains_hcp_smoooth - grains data for alpha phase (using smoothed 
%                            grain boundaries)
%   settings - structure containing:
%       phase1 - name of HCP/alpha phase
%       filesave_loc - location of results folder
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       oM1 - options for IPF plot for alpha phase
%   Type - plot option 1=not smoothed gB; 2=smoothed gBs
%
% created 28/02/20 RB 
% updated 21/01/21 RB
%% Setup
grains_hcp=grains.HCP.grains_hcp; %grains
grains_hcp_smooth=grains.HCP.grains_hcp_smooth; %smoothed grains
phase1=settings.phases.phase1; %HCP/Alpha phase
oM1=PlotOpt.general.oM.oM1; %HCP - IPF direction & colourkey
SB=PlotOpt.general.Scalebar; %scalebar on/off

%go to results folder
cd(settings.file.filesave_loc)

%% Plot IPF

switch Type % Plot type
    
    case 1 %grains_hcp (no smoothing)
        f1=figure; 
        f1.Color = [1 1 1];
        plot(grains_hcp(phase1),oM1.orientation2color(grains_hcp(phase1).meanOrientation),'micronbar',SB,'figSize','large') %Plot map
        hold on
        plot(grains_hcp.boundary) %Add grain boundaries
        hold off
        set(gcf,'name','IPF_Alpha','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'IPF_alpha','-dtiff','-r600'); %save if required
        end
        
        % plot the colour key for the IPF map
        f2=figure;
        f2.Color=[1 1 1];
        plot(oM1); %plot colour key
        set(gcf,'name','Colourkey_Alpha','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0       
            print(gcf,'Colourkey_alpha','-dtiff','-r600');
        end
        
    case 2 %grains_hcp_smooth (smoothed grain boundaries)
        f3=figure; 
        f3.Color = [1 1 1];
        plot(grains_hcp_smooth(phase1),oM1.orientation2color(grains_hcp_smooth(phase1).meanOrientation),'micronbar',SB,'figSize','large') %Plot map
        hold on
        plot(grains_hcp_smooth.boundary) %Add grain boundaries
        hold off
        set(gcf,'name','IPF_Alpha_smoothed_gB','numbertitle','off') %change plot name
        if PlotOpt.general.SaveOn > 0
            print(gcf,'IPF_alpha_smoothed_gB','-dtiff','-r600'); %save if required
        end
        
        % plot the colour key for the IPF map
        f4=figure;
        f4.Color=[1 1 1];
        plot(oM1); %plot colour key
        set(gcf,'name','Colourkey_Alpha','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0       
            print(gcf,'Colourkey_alpha','-dtiff','-r600');
        end
end

%% Return to main folder
cd (settings.file.mainFolder);
