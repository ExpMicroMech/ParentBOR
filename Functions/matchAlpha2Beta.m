function [grains]= matchAlpha2Beta(grains,ebsd_all,isPlot)
%
%   matchAlpha2Beta finds the alpha grains present in each parent beta
%   grain and adds the beta grain ID to the alpha grain properties
%
%   Inputs:
%   grains - structure containing:
%       grains_hcp - alpha grain data
%       bcc_grains - beta grain data
%   ebsd_all - structure containing ebsd data - any of the ebsd data can be
%              used as the X,Y points should be the same for all.
%   isPlot - whether to plot the alpha grains coloured by beta grain no.     
%
%   Outputs:
%   grains - structure updated with:   
%        grains_hcp - updated alpha/HCP grain data(links alpha/beta grains)
%
%   27/02/2020 RB
%% Extract variables 
grains_hcp=grains.HCP.grains_hcp; %Alpha/HCP
bcc_grains=grains.BCC.bcc_grains; %Beta/BCC grains
ebsd=ebsd_all.ebsd; %it doesn't matter which one is chosen here
%% Find the alpha grains within a beta grain

% Create a wait bar to monitor progress
h = waitbar(0,'Matching alpha and beta grains. Please wait...','Name','Snap',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        
setappdata(h,'canceling',0)

tot_alpha=length(grains_hcp);%number of alpha grains present
tot_beta=length(bcc_grains); %number of beta grains present

for num_b=1:tot_beta  %For each Beta grain
    
    if getappdata(h,'canceling')
        break
    end
    
    waitbar(num_b/length(bcc_grains),h)
    
    % Find the points that are inside the beta grain
    points_in_grain=bcc_grains(num_b).checkInside([ebsd.prop.x(:),ebsd.prop.y(:)]);
    points_x=ebsd.prop.x(points_in_grain); % all the X coordinates for this grain
    points_y=ebsd.prop.y(points_in_grain); % all the Y coordinates for this grain
 
    % now find which alpha grains are present
    alpha_grainid=points_x*0-1; %create a variable for the alpha grain ID with the same length as the number of X,Y points in the grain
    
    for n=1:tot_alpha % for each alpha grain contained within this beta grain
        in_grain=grains_hcp(n).checkInside([points_x,points_y]); % check if the [X,Y] points are within the alpha grain
        alpha_grainid(in_grain)=n; % identifies the alpha grains which are in this beta grain 
    end
    
    grains_alpha=unique(alpha_grainid); % Finds the alpha grains present in this beta grain (minimises repetition)
    %remove unindexed regions
    grains_alpha(grains_alpha==-1)=[]; % Removes unassigned alpha grains (i.e. the '-1' from the setup)
    % store alpha grain IDs with this beta grain no.
    grains_inbeta{num_b}=grains_alpha; % Assign the alpha grains to the beta grain
end

% Update grains_hcp with the beta grain number
for num_b1=1:tot_beta % for each beta grain
    grains_hcp(grains_inbeta{num_b1}).prop.betaGrain=num_b1; % Assign beta grain no to the properties for each alpha grain 
end

if isPlot == 1
    %Plot a check figure - grains_hcp by beta grain number
    f1=figure; 
    plot(grains_hcp,grains_hcp.prop.betaGrain); % alpha grains plotted by beta grain no.
    hold on; 
    plot(bcc_grains.boundary,'lineColor','b','lineWidth',2); % beta grain boundaries in blue
    set(gcf,'name','Alpha grains identified by Beta grain ID','numbertitle','off')
end

%update variable
grains.HCP.grains_hcp=grains_hcp; %update the grains_hcp variable

%delete wait bar
delete (h)
