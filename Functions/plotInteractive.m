function [grainSelected] = plotInteractive (grains,settings,PlotOpt,type)
% PLOTINTERACTIVE - plots the selected IPF map for either alpha or beta. 
% Then takes a mouse click - highlights the selected grain and then outputs
% the grain info for this grain.  
%
% Inputs:
%   Inputs:
%   grains - structure containing:
%       grains_hcp - grains data for alpha phase
%       bcc_grains - grains data for beta phase
%   settings - structure containing:
%       filesave_loc - where to save any figures
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       scalebar - whether to include scalebars on the plots
%   type - whether the IPF map/grain is (1)HCP or (2)BCC
%
% Output:
%   grainSelected - grain info for the selected grain (1 - HCP or 2 - BCC)
%
% created: 26/02/20 RB
% updated: 22/01/21 RB
%% Extract variables & setup
%Extract variables
grains_hcp=grains.HCP.grains_hcp; %alpha grains
bcc_grains=grains.BCC.bcc_grains; %beta grains
oM1=PlotOpt.general.oM.oM1; %setup for Alpha phase IPF maps
oM2=PlotOpt.general.oM.oM3; %setup for Beta phase IPF maps
SB=PlotOpt.general.Scalebar; %scalebar on or off 

% Turn off plotting warning
w_id='MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId';
warning('off',w_id);

%go to results folder
cd(settings.file.filesave_loc);
%% Plotting
if type == 1 % HCP/alpha
    
    % Plot alpha phase IPF map and take a mouse click to select a grain, print info in command window
    f1 = figure; 
    f1.Color=[1 1 1];

    plot(grains_hcp,oM1.orientation2color(grains_hcp.meanOrientation),'micronbar',SB,'figSize','large') %Plot map
    hold on
    plot(grains_hcp.boundary) %Add alpha grain boundaries
    hold off
        
    % take a mouse input
    [x,y]=ginput(1);
    %add the point to the figure as a black spot
    hold on;
    scatter(x,y,100,'k','filled');
    
    % find the corresponding grain (original data set)
    grainSelected = grains_hcp(x,y);
    % highlight the edges of the selected grain
    plot(grainSelected.boundary,'linecolor','g','LineWidth',3,'parent',gca)
    plot(grainSelected.boundary,'linecolor','r','LineWidth',1,'parent',gca)
    hold off
    % identify the grain
    g = grainSelected.id; % alpha grain ID
    g_b =grainSelected.prop.betaGrain; %corresponding beta grain ID
    
    % save if required
    nameplot= ['Interactive_alpha_grain_',num2str(g)]; %name the plot according to the grain selected
    set(gcf,'name',nameplot,'numbertitle','off') %change plot name
    %option to save
    if PlotOpt.general.SaveOn > 0
        print(gcf,nameplot,'-dtiff','-r600'); %save if required
    end      
        
    % Display the grain ID selected in command window
    Label1 = ['Alpha Grain Selected = ' num2str(g) '(HCP)'];
    Label2 = ['Parent Beta Grain = ' num2str(g_b) '(BCC)'];
    disp(Label1);
    disp(Label2);
         
elseif type == 2 %BCC/Beta

    % Plot beta phase IPF map and take a mouse click to select a grain, print info in command window
    f2 = figure; 
    f2.Color=[1 1 1];
    
    plot(bcc_grains,oM2.orientation2color(bcc_grains.meanOrientation),'micronbar',SB,'figSize','large') %Plot map
    hold on
    plot(bcc_grains.boundary) %Add beta grain boundaries
    hold off
        
    % take a mouse input
    [x,y]=ginput(1);
    %add the point to the figure as a black spot
    hold on;
    scatter(x,y,100,'k','filled');
    
    % find the corresponding grain (original data set)
    grainSelected = bcc_grains(x,y);
    % highlight the edges of the selected grain
    plot(grainSelected.boundary,'linecolor','g','LineWidth',3,'parent',gca)
    plot(grainSelected.boundary,'linecolor','r','LineWidth',1,'parent',gca)
    hold off
    % identify the grain
    g= grainSelected.id;
    
    % save if required
    nameplot= ['Interactive_beta_grain_',num2str(g)]; %name the plot according to the grain selected
    set(gcf,'name',nameplot,'numbertitle','off') %change plot name
    %option to save
    if PlotOpt.general.SaveOn > 0
        print(gcf,nameplot,'-dtiff','-r600'); %save if required
    end      
    
    % Display the grain ID selected
    Label = ['Beta Grain Selected = ' num2str(g) ' (BCC)'];
    disp(Label);
    
end

%% Return settings to normal

% return to main folder
cd (settings.file.mainFolder);

% Turn the warning back on
% warning('on',w_id)

