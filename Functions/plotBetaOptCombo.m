function plotBetaOptCombo(grains,PlotOpt,settings)
%PLOTBETAOPTCOMBO - plots 6 IPF maps showing the alternative beta options.
% Note: where where the no of beta options is less than the plot no, the 
% first beta option is chosen.
%
% Inputs:
%   - grains - structure containing:
%       - beta_grains_opt(1-6) - beta grains data for each beta option
%                                selection
%   - settings - structure containing:
%       - phase2 - name of the beta phase 
%       - saveOn - save figure on/off
%       - filesave_loc - where to save the figure
%   - PlotOpt - structure containing:
%       - oM2 - colourkey & IPF direction to use
%       - SB - scalebar on/off
%
% 24/01/21 RB
%% Extract variables and set up

%Extract variables
bcc_grains_opt1=grains.AltBeta.opt1.betaGrains;%bcc grains for beta option 1
bcc_grains_opt2=grains.AltBeta.opt2.betaGrains;%bcc grains for beta option 2
bcc_grains_opt3=grains.AltBeta.opt3.betaGrains;%bcc grains for beta option 3
bcc_grains_opt4=grains.AltBeta.opt4.betaGrains;%bcc grains for beta option 4
bcc_grains_opt5=grains.AltBeta.opt5.betaGrains;%bcc grains for beta option 5
bcc_grains_opt6=grains.AltBeta.opt6.betaGrains;%bcc grains for beta option 6
phase2=settings.phases.phase2;%Beta phase name
oM2=PlotOpt.general.oM.oM3; %Reprocessed beta version
SB=PlotOpt.general.Scalebar; %scalebar option (on/off)

%go to results folder
cd(settings.file.filesave_loc);
%% Plot
% Figure containing 6 IPF maps - where the beta option chosen is the number
% of the plot (where the no of beta options is less than the plot no, the 
% first beta option is chosen)

PltNameFig='Alternative_Beta_Options_combo_plot';

%Plot
f3=figure;
f3.Color=[1 1 1];

ax1=nextAxis;
plot(bcc_grains_opt1(phase2),oM2.orientation2color(bcc_grains_opt1(phase2).meanOrientation),'micronbar',SB,'figSize','large','parent',ax1) %Plot map
hold on
plot(bcc_grains_opt1.boundary,'linewidth',2,'parent',ax1); %Add grain boundaries
hold off
PltName=['Option ' num2str(1)];
title(PltName);

ax2=nextAxis;
plot(bcc_grains_opt2(phase2),oM2.orientation2color(bcc_grains_opt2(phase2).meanOrientation),'micronbar',SB,'figSize','large');%,'parent',sp2) %Plot map
hold on
plot(bcc_grains_opt2.boundary,'linewidth',2);%,'parent',sp2); %Add grain boundaries
hold off
PltName=['Option ' num2str(2)];
title(PltName);

ax3=nextAxis;
plot(bcc_grains_opt3(phase2),oM2.orientation2color(bcc_grains_opt3(phase2).meanOrientation),'micronbar',SB,'figSize','large');%,'parent',sp3) %Plot map
hold on
plot(bcc_grains_opt3.boundary,'linewidth',2);%,'parent',sp3); %Add grain boundaries
hold off
PltName=['Option ' num2str(3)];
title(ax3,PltName);

ax4=nextAxis;
plot(bcc_grains_opt4(phase2),oM2.orientation2color(bcc_grains_opt4(phase2).meanOrientation),'micronbar',SB,'figSize','large');%,'parent',sp4) %Plot map
hold on
plot(bcc_grains_opt4.boundary,'linewidth',2);%,'parent',sp4); %Add grain boundaries
hold off
PltName=['Option ' num2str(4)];
title(ax4,PltName);

ax5=nextAxis;
plot(bcc_grains_opt5(phase2),oM2.orientation2color(bcc_grains_opt5(phase2).meanOrientation),'micronbar',SB,'figSize','large');%,'parent',sp5) %Plot map
hold on
plot(bcc_grains_opt5.boundary,'linewidth',2);%,'parent',sp5); %Add grain boundaries
hold off
PltName=['Option ' num2str(5)];
title(ax5,PltName);

ax6=nextAxis;
plot(bcc_grains_opt6(phase2),oM2.orientation2color(bcc_grains_opt6(phase2).meanOrientation),'micronbar',SB,'figSize','large');%,'parent',sp6) %Plot map
hold on
plot(bcc_grains_opt6.boundary,'linewidth',2);%,'parent',sp6); %Add grain boundaries
hold off
PltName=['Option ' num2str(6)];
title(ax6,PltName);

set(gcf,'name',PltNameFig,'numbertitle','off'); %change the title of the figure

if PlotOpt.general.SaveOn > 0
    print(gcf,PltNameFig,'-dtiff','-r600'); %save if required
end

%% Return to main folder
cd (settings.file.mainFolder);
