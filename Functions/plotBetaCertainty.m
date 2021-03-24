function plotBetaCertainty (grains,PlotOpt,settings,PlotType)
% PLOTBETACERTAINTY plots the number of unique beta orientation options or 
% the number of unique alpha variants within each beta grain.
%
% Inputs:
%   grains - structure containing:   
%       bcc_grains - beta grain data including no_of_variants & certainty
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       scalebarOn - whether to include the scalebar
%   settings - structure containing:
%       filesave_loc - where to save the figure(s)%
%   PlotType - which figure to plot 
%       (1) No of potential beta options 
%       (2) No of unique alpha variants
%
% NOTE: no of beta options is stored in the properties as a certainty 
% number where: 
%   1 = 6 potential beta options
%   2 = 3 potential beta options
%   3 = 2 potential beta options
%   4 = 1 potential beta option

% created: 25/02/20 RB
% updated: 22/01/21 RB
%% Extract variables & Setup
bcc_grains=grains.BCC.bcc_grains; %beta grains (to show parent grain boundaries)
SB=PlotOpt.general.Scalebar; %scalebar on/off

%go to results folder
cd(settings.file.filesave_loc)
%% Plot

if PlotType == 1 % No of Beta options (certainty)
    
    col4=[0.8431 0.0980 0.1098; 0.9922 0.6824 0.3804; 0.6706 0.8510 0.9137; 0.1725 0.4824 0.7137];%colourmap
    f1=figure;
    f1.Color=[1 1 1]; %remove grey background
    plot(bcc_grains,bcc_grains.prop.certainty,'micronbar',SB); %plot the certainty value i.e no of beta options 
    colormap (col4);
    colorbar('eastoutside');
    hold on
    plot(bcc_grains.boundary,'linewidth',2); %add beta grain boundaries
%     text(bcc_grains,int2str(bcc_grains.prop.no_of_unique_variants),'fontsize',12)%add variant numbers
    hold off
    set(gcf,'name','Beta_grain_no_of_beta_options','numbertitle','off') %change plot name
    %option to save
    if PlotOpt.general.SaveOn > 0
        print(gcf,'Beta_grain_no_of_beta_options','-dtiff','-r600'); %save if required
    end      

elseif PlotType == 2 % No of unique alpha variants in each beta grain
    
    f2=figure;
    f2.Color=[1 1 1]; %remove grey background
    plot(bcc_grains,bcc_grains.prop.no_of_unique_variants,'micronbar',SB);
    colorbar('eastoutside');
    hold on
    plot(bcc_grains.boundary,'linewidth',2); %add beta grain boundaries
    hold off
    set(gcf,'name','No_of_unique_alpha_variants','numbertitle',SB) %change plot name
    %option to save
    if PlotOpt.general.SaveOn > 0
        print(gcf,'No_of_unique_alpha_variants','-dtiff','-r600'); %save if required
    end   
end

%return to parent folder
cd (settings.file.mainFolder);
