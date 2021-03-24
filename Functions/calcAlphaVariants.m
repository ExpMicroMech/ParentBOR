function [grains]=calcAlphaVariants(grains,settings)
% CALCALPHAVARIANTS determines the alpha variant no for each alpha grain.
% It then finds the unique alpha variants for each beta grain.
%
%   Inputs:
%   grains - structure containing:
%       grains_hcp - alpha phase grain data
%       bcc_grains - beta phase grain data
%   settings - structure containing:
%       cs_bcc - crystal structure of BCC, from MTEX
%       cs_hcp - crystal structure of HCP, from MTEX
%
%   Outputs:
%   grains - structure containing:  
%       grains_hcp - alpha phase grain data (properties updated)
%       bcc_grains - beta phase grain data (properties updated)
%       Unique     - cell array containing the unique alpha variants 
%                    present in each beta grain.
%
% 26/02/2020 RB
%% Setup 

% Extract variables
cs_hcp=settings.sym.cs_hcp; %Alpha/HCP crystal system
cs_bcc=settings.sym.cs_bcc; %Beta/BCC crystal system
grains_hcp=grains.HCP.grains_hcp; %Alpha/HCP grains
bcc_grains=grains.BCC.bcc_grains; %Beta/BCC grains

% Calculate symmetry matrices for HCP phase
HCP_sym = cs_hcp.properGroup; %HCP symmetries
HCP_sym = HCP_sym.rot;

S_reorder1 = [1,2,3,4,5,6,7,8,9,10,11,12]; % potential to re-order if required
symrots_true_hcp= HCP_sym(S_reorder1); % symmetry matrices as orientations
symrots_true_hcp = rotation(symrots_true_hcp); % symmetry matrices as rotations

%% Identify alpha variants

% Create a wait bar to monitor progress
h = waitbar(0,'Calculating alpha variants. Please wait...','Name','Alpha variant analysis',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        
setappdata(h,'canceling',0)

for bcc_g_no=1:length(bcc_grains) % for each of the beta grains
    
    %add cancel option to wait bar
    if getappdata(h,'canceling')
        break
    end
    
    %update wait bar
    waitbar(bcc_g_no/length(bcc_grains),h)
  
    % Identify the beta grain and find the corresponding alpha grains
    bcc_grain_no=bcc_grains(bcc_g_no); % beta grain
    hcp_grains_no=grains_hcp(grains_hcp.prop.betaGrain==bcc_g_no); % alpha grains in selected beta grain

    %Project the beta orientation to the fundamental zone
    bcc_grain_a_FZ=project2FundamentalRegion(bcc_grain_no.meanOrientation);
    
    % get the Euler angles for this beta grain in the fundamental zone
    phi1=bcc_grain_a_FZ.phi1*180/pi();
    Phi=bcc_grain_a_FZ.Phi*180/pi();
    phi2=bcc_grain_a_FZ.phi2*180/pi();

    % Find the alpha variants
    [HCP_set1,BOR1]=BCC2HCP(phi1,Phi,phi2,0); % BCC2HCP(BCC_phi1, BCC_Phi, BCC_phi2, isPlot)

    % Find symmetrical equivalents (i.e. S1-12)
    V1_S=orientation(rotation(HCP_set1(1))*symrots_true_hcp,cs_hcp); % Calculates symmetrical equivalents for alpha variant 1
    V2_S=orientation(rotation(HCP_set1(2))*symrots_true_hcp,cs_hcp); 
    V3_S=orientation(rotation(HCP_set1(3))*symrots_true_hcp,cs_hcp);
    V4_S=orientation(rotation(HCP_set1(4))*symrots_true_hcp,cs_hcp);
    V5_S=orientation(rotation(HCP_set1(5))*symrots_true_hcp,cs_hcp);
    V6_S=orientation(rotation(HCP_set1(6))*symrots_true_hcp,cs_hcp);
    V7_S=orientation(rotation(HCP_set1(7))*symrots_true_hcp,cs_hcp);
    V8_S=orientation(rotation(HCP_set1(8))*symrots_true_hcp,cs_hcp);
    V9_S=orientation(rotation(HCP_set1(9))*symrots_true_hcp,cs_hcp);
    V10_S=orientation(rotation(HCP_set1(10))*symrots_true_hcp,cs_hcp);
    V11_S=orientation(rotation(HCP_set1(11))*symrots_true_hcp,cs_hcp);
    V12_S=orientation(rotation(HCP_set1(12))*symrots_true_hcp,cs_hcp);

    %Find potential misorientations between the parent beta grain and the calculated variants (and symmetrical equivalents) 
    for i=1:12
        miso_v1_s(i)=inv(bcc_grain_a_FZ)*V1_S(i); % misorientation between the beta grain orientation and alpha variant 1 (+ symmetry)
        miso_v2_s(i)=inv(bcc_grain_a_FZ)*V2_S(i);
        miso_v3_s(i)=inv(bcc_grain_a_FZ)*V3_S(i);
        miso_v4_s(i)=inv(bcc_grain_a_FZ)*V4_S(i);
        miso_v5_s(i)=inv(bcc_grain_a_FZ)*V5_S(i);
        miso_v6_s(i)=inv(bcc_grain_a_FZ)*V6_S(i);
        miso_v7_s(i)=inv(bcc_grain_a_FZ)*V7_S(i);
        miso_v8_s(i)=inv(bcc_grain_a_FZ)*V8_S(i);
        miso_v9_s(i)=inv(bcc_grain_a_FZ)*V9_S(i);
        miso_v10_s(i)=inv(bcc_grain_a_FZ)*V10_S(i);
        miso_v11_s(i)=inv(bcc_grain_a_FZ)*V11_S(i);
        miso_v12_s(i)=inv(bcc_grain_a_FZ)*V12_S(i); 
    end
        
    for grain_no=1:length(hcp_grains_no) % for each alpha grain contained within this beta grain
      
        %Find grain pair misorientation
        miso_init=inv(bcc_grain_a_FZ)*hcp_grains_no(grain_no).meanOrientation;

        %Find angles (in radians)
        for i=1:12
            angles_V1(i)=angle(miso_init,miso_v1_s(i),'noSymmetry'); % angle between the experimental misorientation and potential misorientations for alpha variant 1
            angles_V2(i)=angle(miso_init,miso_v2_s(i),'noSymmetry');
            angles_V3(i)=angle(miso_init,miso_v3_s(i),'noSymmetry');
            angles_V4(i)=angle(miso_init,miso_v4_s(i),'noSymmetry');
            angles_V5(i)=angle(miso_init,miso_v5_s(i),'noSymmetry');
            angles_V6(i)=angle(miso_init,miso_v6_s(i),'noSymmetry');
            angles_V7(i)=angle(miso_init,miso_v7_s(i),'noSymmetry');
            angles_V8(i)=angle(miso_init,miso_v8_s(i),'noSymmetry');
            angles_V9(i)=angle(miso_init,miso_v9_s(i),'noSymmetry');
            angles_V10(i)=angle(miso_init,miso_v10_s(i),'noSymmetry');
            angles_V11(i)=angle(miso_init,miso_v11_s(i),'noSymmetry');
            angles_V12(i)=angle(miso_init,miso_v12_s(i),'noSymmetry');
        end
        
        % Combine the angles into a matrix
        angles_V1_12=[angles_V1; angles_V2; angles_V3; angles_V4; angles_V5; angles_V6; angles_V7; angles_V8; angles_V9; angles_V10; angles_V11; angles_V12];

        %Identify the minimum value & position
        [min_in_row,col]=min(angles_V1_12,[],2);%minimum value in each row & column no 
        [min_val,row]=min(min_in_row);%minimum value in matrix & corresponding row

        % Add these details to the grain properties
        alpha_grain_id=hcp_grains_no(grain_no).id; % Find the alpha grain ID for this grain
        grains_hcp(alpha_grain_id).prop.variant_no=row; % Add variant number 
        grains_hcp(alpha_grain_id).prop.variant_sym_no=col(row); % Add variant symmetry number
        grains_hcp(alpha_grain_id).prop.min_angle=min_val; % Add minimum angle (quality indicator)
    end 
end

%% Update Beta grain info with no of variants

Unique = cell([1 length(bcc_grains)]); % make an empty cell array

% No of variants per beta grain AND which alpha variants are present in each beta grain
for j=1:length(bcc_grains)
    % Find the alpha variants
    unique_a_var=unique(grains_hcp(grains_hcp.prop.betaGrain==j).prop.variant_no); % Find the unique alpha variants for each beta grain
    % Update: no of unique variants
    bcc_grains(j).prop.no_of_unique_variants=length(unique_a_var); %Add no of unique variants to the grain properties 
    % Update: Unique alpha variants present
    Unique{j} = unique(grains_hcp(grains_hcp.prop.betaGrain==j).prop.variant_no); % update cell array with unique alpha variants for each grain
end

%% Update output variable

%update grains data
grains.HCP.grains_hcp=grains_hcp; %alpha/HCP
grains.BCC.bcc_grains=bcc_grains; %beta/BCC

%store Unique
grains.BetaOpt.UniqueAlphaVariants=Unique; %cell array containing the unique alpha variants present in each beta grain.

%% delete wait bar
delete (h);
