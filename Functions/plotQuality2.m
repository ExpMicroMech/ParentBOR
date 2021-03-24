function plotQuality2 (grains,PlotOpt,settings,Type)
% PLOTQUALITY2 - plots two measures of reconstruction quality:
%       1 - grain map showing the deviation between the beta orientation of
%           each grain and the corresponding cluster. i.e. beta grain 
%           reconstruction quality.
%       2 - plots the minimum angle between the experimental alpha/beta 
%           misorientation and the potential misorientation for each alpha 
%           variant.This is an indication of alpha variant identification 
%           quality.
%
%   Inputs:
%   grains - structure containing:
%       grains_hcp - grains data for alpha phase
%       devis      - The deviation angle between the beta orientation of a 
%                    single grain versus that of the cluster (calculated
%                    during reconstruction)
%       min_angle  - minimum angle between parent beta grain and the alpha
%                    variant identified (calculated during alpha variant
%                    identification step)
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       scalebarOn - whether to include the scalebar
%   settings - structure containing:
%       filesave_loc - where to save the figure(s)
%   Type - plot using (1) devis or (2) min_angle
%
% 22/01/2021 RB
%% Extract variables & setup
grains_hcp=grains.HCP.grains_hcp; %alpha grains
bcc_grains=grains.BCC.bcc_grains; %beta grains (to show parent grain boundaries)
devis=grains.HCP.devis; %devis 
min_angle=grains.HCP.grains_hcp.prop.min_angle; %min angle 
SB=PlotOpt.general.Scalebar; %scalebar on/off

%go to results folder
cd(settings.file.filesave_loc);

%% Plotting

switch Type
    case 1 %devis version
        %Plot a grain map showing the deviation between the beta orientation of each grain and the corresponding cluster
        f1 = figure; 
        f1.Color=[1 1 1];
        plot(grains_hcp,devis,'micronbar',SB); %plot alpha grains based on devis value
        hold on
        plot(bcc_grains.boundary,'linewidth',2); %Add Beta/BCC grain boundaries
        hold off
        set(gcf,'name','Quality-Reconstruction','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Quality-Reconstruction','-dtiff','-r600'); %save if required
        end      
    case 2 %min_angle version
        %Plot a grain map showing the minimum angle for each alpha grain.
        f2=figure;
        f2.Color=[1 1 1]; %remove grey background
        plot(grains_hcp,grains_hcp.prop.min_angle,'micronbar','off'); %plot alpha grains by minimum angle
        hold on
        plot(bcc_grains.boundary,'micronbar','off','lineColor','k','linewidth',3); %add beta grain boundaries
        hold off
        set(gcf,'name','Quality-alpha_var','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Quality-alpha_var','-dtiff','-r600'); %save if required
        end    
        
        
end

%% return to main folder
cd (settings.file.mainFolder);

