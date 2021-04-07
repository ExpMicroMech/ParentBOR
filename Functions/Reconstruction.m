function [ebsd_all,grains,reconstructionData] = Reconstruction(ebsd,settings)
%RECONSTRUCTION - Reconstruct the parent beta microstructure
%   This function is used to:
%       - Setup the (Burger's) orientation relationship
%       - Process the grains (alpha phase)
%       - Evaluate grain boundaries (BOR vs. non-BOR)
%       - Apply the MCL algorithm and reconstruct the beta microstructure
%       - Process the grains (beta phase)
%
% Inputs:
%   ebsd     - original EBSD data (alpha phase)
%   settings - structure containing settings required for grain processing 
%              and reconstruction. 
%
% Outputs:
%   ebsd_all - contains original ebsd data, raw beta ebsd data and 
%              reprocessed beta ebsd data
%   grains   - contains grains data for alpha and beta phases (+ smoothed 
%              versions if requested) 
%   reconstructionData - contains all intermediate variables (see end of
%              this script for full descriptors.
%
% 21/01/21 RB
%% Extract variables from settings file
cs_hcp=settings.sym.cs_hcp; % HCP/alpha crystal symmetry
cs_bcc=settings.sym.cs_bcc; % BCC/beta crystal symmetry
gbThreshold=settings.grains.gbThreshold; %grain boundary threshold
smallGrains=settings.grains.smallGrains; %small grains threshold 
smoothGrains=settings.grains.smoothGrains; %smooth grains value
phase1=settings.phases.phase1; %HCP/Alpha
% phase2=settings.phases.phase2; %BCC/Beta

%% Orientation Relationship Setup - BOR (0001)a//{110}b & <11-20>a//<111>b
%construct the transformation between BCC and HCP: 
[bcc2hcp_BOR1,symrots_true_hcp,symrots_true_bcc,HCP_set] = BOR_Setup(settings,0); 
%[bcc2hcp_BOR1,symrots_true_hcp,symrots_true_bcc,HCP_set] = BOR_Setup(settings,isPlot);
% Note: saves figure without showing it if isPlot=1

% Find the misorientations between the orientations which meet BOR then minimise the set 
[BOR_set] = BOR_Misorientations(HCP_set,settings); 

%% Grain Boundary Type Identification
% Process the HCP grains in the initial EBSD map v1 
[ebsd,grains_hcp,grains_hcp_smooth] = GrainProcessing1(ebsd,settings,1);
% [ebsd,grains,grains_smooth] = GrainProcessing1(ebsd,settings,grainType - Alpha (1) or Beta (2))

% Identify grain boundary type (BOR vs. non-BOR matched) 
[omega,gb_hcp_ids,gb_hcp,OR_rows,gb_hcp_ids_sorted,hist_all_omega_I,notBOR_GB] = GB_ID_BOR(ebsd,grains_hcp,settings,BOR_set, 0, 0, 1, 0, 1); 
%[omega,gb_hcp_ids,gb_hcp,OR_rows,gb_hcp_ids_sorted,hist_all_omega_I,notBOR_GB] = GB_ID_BOR(ebsd,grains,settings,BOR_set,isPlotBar1,isPlotBar2,isPlotMap1,isPlotMap2,SaveOn)
%(NOTE: turn saving of the figures in this section on and off using the last input to GB_ID_BOR)

%% Parent Grain Reconstruction 
% Use markov clustering algortithm to determine clusters
[ib] = MCL_algorithm(omega,gb_hcp_ids,grains_hcp,settings);
     
% Reconstruct beta phase EBSD map
[ebsd_beta_raw,devis] = Reconstruct(ebsd,symrots_true_hcp,bcc2hcp_BOR1,ib,grains_hcp,settings);

% Process the BCC grains in the reconstructed EBSD map 
[ebsd_beta,bcc_grains,bcc_grains_smooth] = GrainProcessing1(ebsd_beta_raw,settings,2);
% [ebsd,grains,grains_smooth] = GrainProcessing1(ebsd,settings,grainType - Alpha (1) or Beta (2))

%% Store outputs 

%store ebsd data
ebsd_all.ebsd=ebsd;%original (alpha) ebsd data
ebsd_all.ebsd_beta_raw=ebsd_beta_raw; %raw beta phase ebsd data 
ebsd_all.ebsd_beta=ebsd_beta; %processed ebsd data - beta/BCC

%Store grains data 
grains.HCP.grains_hcp=grains_hcp; %Alpha/HCP grains
grains.HCP.grains_hcp_smooth=grains_hcp_smooth; %smoothed alpha/HCP grains
grains.BCC.bcc_grains=bcc_grains; %Beta/BCC grains
grains.BCC.bcc_grains_smooth=bcc_grains_smooth; %smoothed Beta/BCC grains
grains.BCC.parentGB=notBOR_GB; %grain boundary which doesn't meet BOR (i.e. prior beta) [used for plotting] 
grains.HCP.devis=devis;%deviation angle between the orientation of a single grain versus that of the cluster

%Store outputs from reconstruction section 
reconstructionData.initial_set = HCP_set; %initial set which meet BOR 
reconstructionData.bcc2hcp_BOR1 = bcc2hcp_BOR1; %first transformation BCC->HCP - used to recontruct
reconstructionData.symrots_true_hcp = symrots_true_hcp; %reordered symmetry - HCP
reconstructionData.symrots_true_bcc = symrots_true_bcc; %reordered symmetry - BCC
reconstructionData.BOR_set = BOR_set; % minimised set of misorientations between BOR variants
reconstructionData.omega = omega; %min angle between each grain pair misorientation & BOR set misorientations [necessary data for MCL clustering]
reconstructionData.gb_hcp_ids = gb_hcp_ids; %unique neighouring grain pairs grain boundary [data necessary for MCL clustering]
reconstructionData.gb_hcp = gb_hcp; %all alpha-alpha grain boundary segments
reconstructionData.OR_rows = OR_rows; %grain pairs whose minimum angle between the misorientation set is below the cutoff value
reconstructionData.gb_hcp_ids_sorted = gb_hcp_ids_sorted; %neighboring grain pairs (sorted)
reconstructionData.hist_all_omega_I = hist_all_omega_I; %variant boundary histogram between V1 and V1-V7
reconstructionData.notBOR_GB = notBOR_GB; %grain boundary which doesn't meet BOR (i.e. prior beta) [used for plotting] 
reconstructionData.ib=ib;%sparse matrix converted to line entries, each line contains grains of the corresponding cluster
reconstructionData.devis=devis; %The deviation angle between the austenite orientation of a single grain versus that of the cluster

end

