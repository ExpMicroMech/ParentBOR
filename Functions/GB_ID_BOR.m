function [omega,gb_hcp_ids,gb_hcp,OR_rows,gb_hcp_ids_sorted,hist_all_omega_I,notBOR_GB] = GB_ID_BOR(ebsd,grains,settings, BOR_set, isPlotBar1, isPlotBar2, isPlotMap1, isPlotMap2,SaveOn)
%GB_ID_BOR - Identify grain boundary types
%
%   Used to identify grain boundary type i.e. prior beta or not
%   Uses comparison of grain boundary misorientations and potential grain 
%   boundary misorientations which meet BOR. 
%
%   Inputs:
%   ebsd - ebsd data set (HCP)
%   grains - (alpha/HCP) grain data calculated from ebsd data set
%   settings - contains:
%       phase - phase name for CS (e.g.'Zirconium - alpha')
%       cutoff - threshold value for matching grain boundary misorienations
%   BOR_set - Potential misorienation set between BOR variants(minimised set)  
%   isPlotBar1 - Option to plot basic bar chart
%   isPlotBar2 - Option to plot coloured bar chart
%   isPlotMap1 - Option to plot quality map overlaid with grain boundaries identified by type(2 colour)
%   isPlotMap2 - Option to plot quality map overlaid with grain boundaries identified by type(coloured)
%   saveOn - Option to save the figures 
%
%   Outputs:
%   omega - min angle between each grain pair misorientation & BOR set misorientations [necessary data for MCL clustering - MCL{1} in original PAG_GUI]
%   OR_rows - grain pairs whose minimum angle between the misorientation set is below the cutoff value
%   gb_hcp_ids - unique neighouring grain pairs grain boundary [data necessary for MCL clustering- MCL{2} in original PAG_GUI]
%   gb_hcp - all alpha-alpha grain boundary segments
%   gb_hcp_ids_sorted - neighboring grain pairs [orbounds{4} in original PAG_GUI]
%   hist_all_omega_I - Variant boundary histogram between V1 and V1-V7 [HistVariants in original PAG_GUI]
%   notBOR_GB - Grain boundary which doesn't meet BOR (i.e. prior beta) [used for plotting]
%
%   created: 27/11/2019 RB
%   updated: 21/01/2021 RB
%% 
%Extract variables from settings
phase=settings.phases.phase1; %HCP
cutoff=settings.reconstruct.cutoff; %cutoff value

%% GB misorientation matching 

% Find all alpha-alpha grain boundary segments
gb_hcp = grains.boundary(phase,phase);

% Determine all neighboring grain pairs:
gb_hcp_ids_sorted = sort(gb_hcp.grainId,2);
[gb_hcp_ids,~,bbcc_ic] = unique(gb_hcp_ids_sorted,'rows');

% Determine the misorientations between all grain pairs using mean orientations:
misos_hcp_grains = inv(grains(gb_hcp_ids(:,1)).meanOrientation).*grains(gb_hcp_ids(:,2)).meanOrientation;
% misos_hcp_grains_ang = angle(inv(grains(gb_hcp_ids(:,1)).meanOrientation).*grains(gb_hcp_ids(:,2)).meanOrientation);
%misos_hcp_grains_ang = angle(misos_hcp_grains); %same as the line above

% Determine the angles between the possible misorientation set and the grain pair misorientations:
angles = angle_outer(misos_hcp_grains,BOR_set) / degree;

% Determine the minimum angle and corresponding index between the
% misorientation set and each grain pair misorientation:
[omega, omega_I] = min(angles,[],2);
[hist_omega_I, bins_omega_I] = hist(omega_I,1:7);

% Limit the list of indexes of the misorientations to those whose minimum angle between the
% misorientation set is below the cutoff value:
omega_I_cutoff = omega_I(omega < cutoff);

% Get the misorientations between grain pairs.
misos_hcp_grains_omega_cutoff = misos_hcp_grains(omega < cutoff);

% Get the grain pairs whose minimum angle between the misorientation set is
% below the cutoff value.
OR_rows = gb_hcp_ids(omega < cutoff,:);

all_omega_I = omega_I(bbcc_ic);
all_omega_I = all_omega_I(ismember(gb_hcp_ids_sorted,OR_rows,'rows'));
[hist_all_omega_I, bins_all_omega_I] = hist(all_omega_I,1:7);
hist_all_omega_I = hist_all_omega_I/sum(hist_all_omega_I);

%% Identify grain boundary types by misorientation type (BOR misorientation matching) 
% This is used for plotting by type 

% Identify the different boundary types 
OR_GB1 = OR_rows(omega_I_cutoff==1,:); %10.529degrees /[0 0 0 1] /c=[0001]
OR_GB2 = OR_rows(omega_I_cutoff==2,:); %60.000degrees /[-1 2 -1 0] /a=[11-20]
OR_GB3 = OR_rows(omega_I_cutoff==3,:); %60.832degrees /[-12 7 5 3] /angle with [0001] = 80.97degrees
OR_GB4 = OR_rows(omega_I_cutoff==4,:); %60.832degrees /[-7 12 -5 3] /angle with [0001] = 80.97degrees
OR_GB5 = OR_rows(omega_I_cutoff==5,:); %63.832degrees /[-1 2 -1 1] /angle with [11-20] = 17.56degrees
OR_GB6 = OR_rows(omega_I_cutoff==6,:); %63.832degrees /[-2 1 1 1] /angle with [11-20] = 17.56degrees
OR_GB7 = OR_rows(omega_I_cutoff==7,:); %90.000degrees /[-7 12 -5 0] /angle with [11-20] = 5.26degrees
notBOR = gb_hcp_ids(omega > cutoff,:); % not BOR i.e. not prior beta grain boundary

%% Relative amounts

% Calculate relative amounts of GB
notOR_total = (length(notBOR)/length(gb_hcp_ids))*100;
OR_total = (length(OR_rows)/length(gb_hcp_ids))*100;
% Output relative amounts of prior beta (BOR matched) and not prior beta (not matching) grain boundary
BOR_Total_Label = ['Dataset contains ' num2str(OR_total) '% BOR misorientation matched grain boundary.'];
not_BOR_Total_Label = ['Dataset contains ' num2str(notOR_total) '% not BOR misorientation matched grain boundary.'];
disp(BOR_Total_Label); 
disp(not_BOR_Total_Label);

%% Store output labels in settings file

% %go to results folder
% cd(settings.file.filesave_loc)
% % get file name
% fileID2=settings.file.textfile;
% % open file
% fileID = fopen(fileID2,'a+');
% % add data
% fprintf(fileID,'\t Total BOR gB (%%): %0.2f \n',OR_total); %BOR gB % 
% fprintf(fileID,'\t Total non-BOR gB (%%): %0.2f \n',notOR_total); %Non-BOR gB %
% %close the file
% fclose(fileID);

%% Identify non-BOR GB

% not BOR matched grain boundary - used on variants map
notBOR_GB=gb_hcp(not(ismember(gb_hcp_ids_sorted,OR_rows,'rows')));

%% Plots 1 & 2 - bar charts

if isPlotBar1 ==1 % Plain bar chart
    
    % This plots a single colour bar chart of the distribution of grain boundary 
    % between each misorientation type (BOR 1-7). It doesn't include grain
    % boundary which doesn't meet a BOR misorienation (i.e. non-prior beta)
    
    f1 = figure;
    f1.Color=[1 1 1];

    h_2 = bar(1:7,zeros(7,1));
    % ylim([0 0.5]); %specify y axis limit if required
    xaxislabels = {'BOR1'; 'BOR2'; 'BOR3'; 'BOR4'; 'BOR5'; 'BOR6'; 'BOR7';};
    set(gca,'xticklabel',xaxislabels)

    set(h_2, 'YData', hist_all_omega_I);
    
    if saveOn > 0
        print(gcf,'GB_types_Barchart_plain','-dtiff');
    end
    
end

if isPlotBar2 ==1 % Coloured bar chart
    
    % This plots a multicolour bar chart of the distribution of grain boundary 
    % between each misorientation type (BOR 1-7) and not-BOR (i.e. non-prior beta)
    % Relative amounts shown (%)
    
    %Normalise data
    GB_OR_n(1) = (length(OR_GB1)/length(gb_hcp_ids))*100;
    GB_OR_n(2) = (length(OR_GB2)/length(gb_hcp_ids))*100;
    GB_OR_n(3) = (length(OR_GB3)/length(gb_hcp_ids))*100;
    GB_OR_n(4) = (length(OR_GB4)/length(gb_hcp_ids))*100;
    GB_OR_n(5) = (length(OR_GB5)/length(gb_hcp_ids))*100;
    GB_OR_n(6) = (length(OR_GB6)/length(gb_hcp_ids))*100;
    GB_OR_n(7) = (length(OR_GB7)/length(gb_hcp_ids))*100;
    GB_OR_n(8) = (length(notBOR)/length(gb_hcp_ids))*100;

    % plot figure
    f6 = figure;
    f6.Color=[1 1 1]; %remove grey background
    a6 = axes('parent', f6);
    xaxislabels = {'';'BOR1'; 'BOR2'; 'BOR3'; 'BOR4'; 'BOR5';'BOR6'; 'BOR7'; 'not BOR';''};
    set(a6,'xticklabel',xaxislabels)
    % ylim([0,100]); %option to change y axis limits
    hold(a6,'on')

    bar(1,GB_OR_n(1),'parent',a6,'facecolor', 'b');
    bar(2,GB_OR_n(2),'parent',a6,'facecolor', 'g');
    bar(3,GB_OR_n(3),'parent',a6,'facecolor', 'r');
    bar(4,GB_OR_n(4),'parent',a6,'facecolor', 'c');
    bar(5,GB_OR_n(5),'parent',a6,'facecolor', 'm');
    bar(6,GB_OR_n(6),'parent',a6,'facecolor', 'y');
    bar(7,GB_OR_n(7),'parent',a6,'facecolor', 'w');
    bar(8,GB_OR_n(8),'parent',a6,'facecolor', 'k');
    
    if SaveOn > 0
        print(gcf,'GB_types_Barchart_colour','-dtiff');
    end
end

%% Plot maps (Radon quality + coloured GBs)

if isPlotMap1 ==1 % 2 colour GB map
    
    % This plots the quality map overlaid with grain boundary types
    % Red = doesn't match a BOR misorientation i.e. not prior-beta 
    % Blue = matches a BOR misorientation i.e prior-beta
    
    f5 = figure;
    f5.Color = [1 1 1];
    
    % Plot Quality map 
    plot(ebsd,ebsd.prop.RadonQuality,'micronbar','off') %Bruker Data doesn't have band contrast
    colormap gray
    % Plot prior beta boundaries (blue) and the remaining boundaries (red)
    hold on
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_rows,'rows')),'linecolor','b','linewidth',2) %GB which matches OR misorientations
%     hold on
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,notBOR,'rows')),'linecolor','r','linewidth',2) %GB which doesn't match OR misorientations
    hold off
    set(gcf,'name','Grain boundaries by type - radon quality background','numbertitle','off')
    
    if SaveOn > 0
        print(gcf,'GB_types_map_2colour','-dtiff','-r600');
    end
end

if isPlotMap2 ==1 % multicoloured GB map
    
    % This plots the quality map overlaid with grain boundary types
    % Black = doesn't match a BOR misorientation i.e. not prior-beta 
    % Colours = matches a BOR misorientation i.e prior-beta, by type
        
    f4 = figure;
    f4.Color = [1 1 1]; 
    
    % Plot Quality map 
    plot(ebsd,ebsd.prop.RadonQuality) %Bruker Data doesn't have band contrast
    colormap gray
    % Plot grain boundaries by type
    hold on;
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB1,'rows')),'linecolor','b','linewidth',2)%10.529degrees /[0 0 0 1] /c=[0001]
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB2,'rows')),'linecolor','g','linewidth',2)%60.000degrees /[-1 2 -1 0] /a=[11-20]
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB3,'rows')),'linecolor','r','linewidth',2)%60.832degrees /[-12 7 5 3] /angle with [0001] = 80.97degrees
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB4,'rows')),'linecolor','c','linewidth',2)%60.832degrees /[-7 12 -5 3] /angle with [0001] = 80.97degrees
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB5,'rows')),'linecolor','m','linewidth',2)%63.832degrees /[-1 2 -1 1] /angle with [11-20] = 17.56degrees
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB6,'rows')),'linecolor','y','linewidth',2)%63.832degrees /[-2 1 1 1] /angle with [11-20] = 17.56degrees
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,OR_GB7,'rows')),'linecolor','w','linewidth',2)%90.000degrees /[-7 12 -5 0] /angle with [11-20] = 5.26degrees
    plot(gb_hcp(ismember(gb_hcp_ids_sorted,notBOR,'rows')),'linecolor','k','linewidth',2) %GB which doesn't match OR misorientations
    hold off
    
    Plot_Key_Label = ['Colour Key: BOR1 = Blue; BOR2 = green; BOR3 = red; BOR4 = cyan; BOR5 = magenta; BOR6 = yellow; BOR7 = white; non-BOR = Black.']
    
    if SaveOn > 0
        print(gcf,'GB_types_map_multicolour','-dtiff','-r600');
    end
end

%% return to main folder
cd (settings.file.mainFolder);
end




