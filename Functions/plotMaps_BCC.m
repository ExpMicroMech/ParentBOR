function plotMaps_BCC(ebsd_all,grains,settings,PlotOpt,Type)
% PLOTMAPS_BCC plots the IPF(Z) map for the reconstructed (parent grain) 
% microstructure. (+ colour key) 
%   Options:
%       1 - Unprocessed output
%       2 - Processed (grains calculated)
%       3 - Processed + smoothed grain boundaries
%
% Inputs:
%   ebsd_all - structure containing:
%       ebsd_beta_raw - initial ebsd data for reconstructed beta phase map
%       ebsd_beta - reprocessed ebsd data for reconstructed beta phase map
%   grains - structure containing:
%       notBOR_gB - Parent grain boundaries from misorientation analysis
%       bcc_grains - grains data for beta phase (reprocessed)
%       bcc_grains_smoooth - grains data for beta phase (using smoothed 
%                            grain boundaries)
%   settings - structure containing:
%       phase2 - name of BCC/beta phase
%       filesave_loc - location of results folder
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       oM2 - options for IPF plot for beta phase (raw)
%       oM3 - options for IPF plot for beta phase (reprocessed)
%   Type - plot option:
%       1=raw gB; 2=reprocessed; 3= reprocessed+ smoothed gBs
%
% created: 28/02/20 RB
% updated: 21/01/21 RB
%% Setup
phase2=settings.phases.phase2; %BCC/Beta phase

% raw data
ebsd_beta_raw=ebsd_all.ebsd_beta_raw; %Beta phase ebsd data (RAW)
oM2=PlotOpt.general.oM.oM2; %BCC - raw
notBOR_gB=grains.BCC.parentGB; %Parent grain boundaries from misorientation analysis

% reprocessed data
ebsd_beta=ebsd_all.ebsd_beta; %Beta phase ebsd data (reprocessed)
bcc_grains=grains.BCC.bcc_grains; %grains (reprocessed)
bcc_grains_smooth=grains.BCC.bcc_grains_smooth; %smoothed grains (reprocessed only)
oM3=PlotOpt.general.oM.oM3; %BCC - reprocessed: IPF direction & colourkey
SB=PlotOpt.general.Scalebar; %scalebar on/off

%go to results folder
cd(settings.file.filesave_loc)

%% Option 1 - Plot Reconstructed map
switch Type
    case 1 % 
        f1 = figure;
        f1.Color=[1 1 1];
        plot(ebsd_beta_raw(phase2),ebsd_beta_raw(phase2).orientations,'faceAlpha',0.5,'micronbar',SB,'figSize','large');
        hold on
        plot(notBOR_gB,'linecolor','k','linewidth',2,'micronbar',SB)
        set(gcf,'name','Beta_map_initial_output','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Beta_map_initial_output','-dtiff','-r600'); %save if required
        end      

        f2 = figure;
        f2.Color=[1 1 1];
        plot(oM2,'faceAlpha',0.5);
        set(gcf,'name','Colourkey_Beta_initial','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0       
            print(gcf,'Colourkey_Beta_initial','-dtiff','-r600'); %save if required
        end
        
    case 2 %Plot Reprocessed map
        f3=figure; 
        f3.Color = [1 1 1];
        plot(bcc_grains(phase2),oM3.orientation2color(bcc_grains(phase2).meanOrientation),'micronbar',SB,'figSize','large') %Plot map
        hold on
        plot(bcc_grains.boundary,'linewidth',2); %Add grain boundaries
        hold off
        set(gcf,'name','Beta_map_reprocessed','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0       
            print(gcf,'Beta_map_reprocessed','-dtiff','-r600'); %save if required
        end       

        f4 = figure;
        f4.Color=[1 1 1];
        plot(oM3); %plot colourkey
        print(gcf,'Colourkey_Beta_reprocessed','-dtiff','-r600');   
        
    case 3 %Plot reprocessed map using smoothed grain boundaries
        f5=figure; 
        f5.Color = [1 1 1];
        plot(bcc_grains_smooth(phase2),oM3.orientation2color(bcc_grains_smooth(phase2).meanOrientation),'micronbar',SB,'figSize','large') %Plot map
        hold on
        plot(bcc_grains_smooth.boundary,'linewidth',2); %Add grain boundaries
        hold off
        set(gcf,'name','Beta_map_reprocessed_(smoothed)','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0       
            print(gcf,'Beta_map_reprocessed_(smoothed)','-dtiff','-r600'); %save if required
        end       

        f6 = figure;
        f6.Color=[1 1 1];
        plot(oM3); %plot colourkey
        print(gcf,'Colourkey_Beta_reprocessed','-dtiff','-r600');           

end
%% return to main folder
cd (settings.file.mainFolder);
