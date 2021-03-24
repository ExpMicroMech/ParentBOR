function [grains]=calcBetaOptions(grains)
% CALCBETAOPTIONS calculates the potential beta orientations for each
% beta grain based upon the alpha variants present. 
%  
% Note: the beta orientations stored in Beta_options.opt do not include
% symmetrical equivalents.
%
%   Inputs:
%   grains - structure containing:
%       grains_hcp - alpha phase grain data
%       bcc_grains - beta phase grain data
%       UniqueAlphaVariants - array containing the unique alpha variants 
%                             for each beta grain. 
%
%   Outputs:
%   grains - structure containing:
%       bcc_grains - updated beta phase grain data
%       Beta_Options - structure containing beta grain ID, potential beta
%                      orientations, no of (unique) alpha variants and the 
%                      unique variants present for each beta grain. 
%
%   26/02/2020 RB
%% Setup

%Extract variables
grains_hcp=grains.HCP.grains_hcp; %Alpha/HCP grains
bcc_grains=grains.BCC.bcc_grains; %Beta/BCC grains
Unique=grains.BetaOpt.UniqueAlphaVariants; %unique alpha variants in each beta grain

% Threshold for matching beta orientations (in radians)
% B_Thresh=0.035; %approx 2 degrees
B_Thresh=0.0698; %approx 4 degrees

% Alpha variant combinations with common <a> [3 variant options] 
common_a=[1 6 10;2 7 11;3 9 12;4 5 8];

% Find groups of beta grains with different numbers of unique alpha variants
var_4=bcc_grains.prop.no_of_unique_variants>=4; % >4 alpha variants 
var_3=bcc_grains.prop.no_of_unique_variants==3; % 3 alpha variants
var_2=bcc_grains.prop.no_of_unique_variants==2; % 2 alpha variants
var_1=bcc_grains.prop.no_of_unique_variants==1; % 1 alpha variant

%% 4+ alpha variants

% Assign the certainty value (100%)
bcc_grains(var_4).prop.certainty=4; %Add the certainty to the beta grain properties  4=100%

% Find the grain IDs for the beta grains with 4+ unique variants
bcc_grain_no_4=bcc_grains(var_4).id; 

% Update the properties for each of these beta grains
for c=1:length(bcc_grain_no_4)
    beta_options_all=bcc_grains(bcc_grain_no_4(c)).meanOrientation; %the beta option is unchanged
    Beta_Options(bcc_grain_no_4(c)).id=bcc_grain_no_4(c);  %Add beta grain id to Beta_Options  
    Beta_Options(bcc_grain_no_4(c)).opt={beta_options_all}; %Add the beta orientation to Beta_Options
end
%% 3 alpha variants

% Find the grain IDs for just these grains
bcc_grain_no_3=bcc_grains(var_3).id;
% bcc_grain_no3=bcc_grains(var_3);
for c=1:length(bcc_grain_no_3)
%     for bg3=1:length(bcc_grain_no_3)
        bg3_id=bcc_grain_no_3(c); %Beta grain ID
        % Find the alpha grain orientations for each variant present
        ag3=grains_hcp(grains_hcp.prop.betaGrain==(bg3_id)); % alpha grains
        bg_unique3=Unique{bg3_id}; % unique variants
        ag3_v1=ag3(ag3.prop.variant_no==bg_unique3(1)); % alpha grains with the first variant no (the first is used going forward)
        ag3_v2=ag3(ag3.prop.variant_no==bg_unique3(2)); % alpha grains with the second variant no (the first is used going forward)
        % Get the potential beta orientations for each alpha grain selected
        betaTest3_ag1=HCP2BCC(ag3_v1(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
        betaTest3_ag2=HCP2BCC(ag3_v2(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
        % Find the minimum angle between each of the beta options (e.g. grain 1 beta options vs. grain 2 beta options)
        for c1=1:6
            for d=1:6
                BetaOptionTest3(c1,d)=angle(betaTest3_ag1(c1),betaTest3_ag2(d));
            end
        end
        
        try 
            min(BetaOptionTest3) < B_Thresh;
        catch
            ag3_v3=ag3(ag3.prop.variant_no==bg_unique3(3)); % alpha grains with the second variant no (the first is used going forward)
            % Get the potential beta orientations for each alpha grain selected
            betaTest3_ag1=HCP2BCC(ag3_v1(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
            betaTest3_ag2=HCP2BCC(ag3_v3(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
            % Find the minimum angle between each of the beta options (e.g. grain 1 beta options vs. grain 2 beta options)
            for c1=1:6
                for d=1:6
                    BetaOptionTest3(c1,d)=angle(betaTest3_ag1(c1),betaTest3_ag2(d));
                end
            end
        end    
        
        %find the zeros
        find_zeros3=zeros(6,6); % make an empty array
        find_zeros3=abs(BetaOptionTest3(:,:))<B_Thresh; % find all the cells where the angle is ~0
        [row3,col3]=find(find_zeros3); % position of the zeros within the array
        %make a matrix of the output
        Output=zeros(length(row3),2);
        for e=1:length(row3)
            Output(e,:)=[row3(e) col3(e)];
        end
%     end
    
    alpha_vars=[Unique{bcc_grain_no_3(c)}';Unique{bcc_grain_no_3(c)}';Unique{bcc_grain_no_3(c)}';Unique{bcc_grain_no_3(c)}'];
    test_a_dir=ismember(common_a,alpha_vars,'rows');
           
    if max(test_a_dir)>0 %If all 3 variants have a common <a>
        route=1;
    else
        route=2;
    end
        
    switch route
        case 1
            try 
                row3(2) > 1;
            catch
                ag3_v3=ag3(ag3.prop.variant_no==bg_unique3(3)); % alpha grains with the second variant no (the first is used going forward)
                % Get the potential beta orientations for each alpha grain selected
                betaTest3_ag1=HCP2BCC(ag3_v1(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
                betaTest3_ag2=HCP2BCC(ag3_v3(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
                % Find the minimum angle between each of the beta options (e.g. grain 1 beta options vs. grain 2 beta options)
                for c1=1:6
                    for d=1:6
                        BetaOptionTest3(c1,d)=angle(betaTest3_ag1(c1),betaTest3_ag2(d));
                    end
                end
                        %find the zeros
                find_zeros3=zeros(6,6); % make an empty array
                find_zeros3=abs(BetaOptionTest3(:,:))<B_Thresh; % find all the cells where the angle is ~0
                [row3,col3]=find(find_zeros3); % position of the zeros within the array
                %make a matrix of the output
                Output=zeros(length(row3),2);
                for e=1:length(row3)
                    Output(e,:)=[row3(e) col3(e)];
                end
            end
            
            Beta_Options(bg3_id).id=bg3_id; %Add beta grain id to Beta_Options           
            Beta_Options(bg3_id).opt={betaTest3_ag1(row3(1)) betaTest3_ag1(row3(2))}; %Add the two potential beta orientations to Beta_Options
            bcc_grains(bg3_id).prop.certainty=3; %Add the certainty to the beta grain properties   3=50% 
         
        case 2
% %             ag3_v3=ag3(ag3.prop.variant_no==bg_unique3(3)); % alpha grains with the second variant no (the first is used going forward)
% %             % Get the potential beta orientations for each alpha grain selected
% %             betaTest3_ag1=HCP2BCC(ag3_v1(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
            Beta_Options(bg3_id).id=bg3_id; %Add beta grain id to Beta_Options          
            Beta_Options(bg3_id).opt={betaTest3_ag1((row3(1)))}; %Add the beta orientation to Beta_Options
            bcc_grains(bg3_id).prop.certainty=4; %Add the certainty to the beta grain properties 4=100%   
        end 
end

%% 2 alpha variants (options: common <a>/common <c>/neither common)

bcc_grains_no_2=bcc_grains(var_2); %Find all the grains with two unique alpha variants

for bg=1:length(bcc_grains_no_2)
    % Identify the beta grain
    bg_id=bcc_grains_no_2(bg).id; %Beta grain ID
    
    % Find the alpha grain orientations for each variant present
    ag=grains_hcp(grains_hcp.prop.betaGrain==(bg_id)); % alpha grains contained within this beta grain
    bg_unique=Unique{bg_id}; % unique variants in this beta grain
    ag_v1=ag(ag.prop.variant_no==bg_unique(1)); % alpha grains with the first variant no (the first is used going forward)
    ag_v2=ag(ag.prop.variant_no==bg_unique(2)); % alpha grains with the second variant no (the first is used going forward)
    
    % Get the potential beta orientations for each alpha grain selected
    betaTest_ag1=HCP2BCC(ag_v1(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
    betaTest_ag2=HCP2BCC(ag_v2(1).meanOrientation,0); % all potential beta orientations for this alpha grain 
    
    % Find the minimum angle between each of the beta options (e.g. grain 1 beta options vs. grain 2 beta options)
    for c=1:6
        for d=1:6
            BetaOptionTest(c,d)=angle(betaTest_ag1(c),betaTest_ag2(d));
        end
    end
    
    %find the zeros
    find_zeros2=zeros(6,6); % make an empty array
    find_zeros2=abs(BetaOptionTest(:,:))<B_Thresh; % find all the cells where the angle is ~0
    [row2,col2]=find(find_zeros2); % position of the zeros within the array
    %make a matrix of the output
    Output=zeros(length(row2),2);
    for e=1:length(row2)
        Output(e,:)=[row2(e) col2(e)];
    end
        
    % Add to Beta options
    Beta_Options(bg_id).id=bg_id; %Add beta grain id to Beta_Options
    n_opt = length(row2); % how many beta options have been identified
    switch n_opt
        case 1 % i.e. known beta orientation - neither <a> or <c> are common
            Beta_Options(bg_id).opt={betaTest_ag1(row2(1))}; %Add the potential beta orientation to Beta_Options
            bcc_grains(bg_id).prop.certainty=4; %Add the certainty to the beta grain properties 4=100% 
        case 2 % i.e. 50% certainty - common <a> causes this scenario 
            Beta_Options(bg_id).opt={betaTest_ag1(row2(1)) betaTest_ag1(row2(2))}; %Add the 2 potential beta orientations to Beta_Options
            bcc_grains(bg_id).prop.certainty=3; %Add the certainty to the beta grain properties 3=50% 
        case 3 % i.e. 33% certainty - common <c> causes this scenario
            Beta_Options(bg_id).opt={betaTest_ag1(row2(1)) betaTest_ag1(row2(2)) betaTest_ag1(row2(3))}; %Add the 3 potential beta orientations to Beta_Options
            bcc_grains(bg_id).prop.certainty=2; %Add the certainty to the beta grain properties  2=33%
    end
end    
%% 1 alpha variant
% Assign the certainty value (16.7%)
bcc_grains(var_1).prop.certainty=1; %Add the certainty to the beta grain properties 1=1/6*100% 

% Find the grain IDs for just these grains
bcc_grain_no_1=bcc_grains(var_1).id;

% Find the potential beta variant orientations
for c=1:length(bcc_grain_no_1)
    alpha=grains_hcp(grains_hcp.prop.betaGrain==bcc_grain_no_1(c)); %alpha grains for this beta grain 
    beta_options_all=HCP2BCC(alpha.meanOrientation,0); %potential beta orientation options
    Beta_Options(bcc_grain_no_1(c)).id=bcc_grain_no_1(c); %Add beta grain no to Beta_Options
    Beta_Options(bcc_grain_no_1(c)).opt={[beta_options_all(1)];[beta_options_all(2)];[beta_options_all(3)];[beta_options_all(4)];[beta_options_all(5)];[beta_options_all(6)]}; %Add first 6 beta orientations to Beta_Options 
end
%% Add to Beta_Options
% Add other useful info to Beta_Options
for d=1:length(bcc_grains)
    Beta_Options(d).no_of_unique_variants=bcc_grains(d).prop.no_of_unique_variants; %no of variants for each beta grain
    Beta_Options(d).unique_variants=Unique{d}; %unique variants for each beta grain
end

%% Update output variables

% update grains variables
grains.HCP.grains_hcp=grains_hcp; %HCP
grains.BCC.bcc_grains=bcc_grains; %BCC

% store beta options
grains.BetaOpt.Beta_Options=Beta_Options; %alterative beta orienations for each beta grain


