function plotCheckPlots (grains, PlotOpt, settings)
% PLOTCHECKPLOTS plots the polefigures for the beta grain and the HCP 
% grains contained within that grain. 
%       Left polefigure: (0001)hcp & {110}bcc
%       Right polefigure: <11-20>hcp & <1-11>bcc
% Alpha/HCP orientations are the larger blue dots whilst the smaller red
% dots are the beta orientation. (symmetry included for all)
%
% Inputs:
%   grains - structure containing:
%       grains_hcp - grains data from alpha phase EBSD map
%       bcc_grains - grains data from reconstructed map
%   settings - structure containing:
%       cs_bcc - crystal structure of BCC, from MTEX
%       cs_hcp - crystal structure of HCP, from MTEX
%       filesave_loc - where to save any figures
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       g_sel - beta grain selected     
%
% created: 28/04/20 RB
% updated: 22/01/21 RB
%% Extract variables and setup

%crystal structures
cs_hcp=settings.sym.cs_hcp; %HCP/Alpha
cs_bcc=settings.sym.cs_bcc; %BCC/Beta

%grain orientations
grains_hcp=grains.HCP.grains_hcp; %alpha grains
bcc_grains=grains.BCC.bcc_grains; %beta grains
BetaGrainID=PlotOpt.BetaOpt_PF.g_sel; %selected beta grain for analysis

% Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(1,-1,1,cs_bcc, 'uvw'); %<1-11>

%go to results folder
cd(settings.file.filesave_loc);
%% Find the data to plot
% BCC - using the BetaGrainID 
BCC_grain=bcc_grains(bcc_grains.id==BetaGrainID); %beta grain orientation for selected grain
% HCP
HCP_grains=grains_hcp(grains_hcp.prop.betaGrain==BetaGrainID); %corresponding alpha grain orientations (contained within the beta grain)

%% Plot
% Plots two pole figures (L:planes R:directions, with alpha grain 
% orientations in blue and beta grain orientations in red (smaller dots). 
% These plots include symmetry for all orientations. 

%plotname (includes the beta grain ID)
plotname=strcat('PF_BetaGrain_',num2str(BetaGrainID)); 

%figure
f1=figure;
f1.Color=[1 1 1];
sp1=subplot(1,2,1);
plotPDF(HCP_grains.meanOrientation,h1,'upper','grid','projection','eangle','markersize',8,'parent',sp1); %alpha grains (0001)
hold on
plotPDF(BCC_grain.meanOrientation,h3,'upper','grid','projection','eangle','markerColor','r','markersize',5,'parent',sp1); %beta grains {110}
hold off
title('Planes');
sp2=subplot(1,2,2);
plotPDF(HCP_grains.meanOrientation,h2,'upper','grid','projection','eangle','markersize',8,'parent',sp2); %alpha grains <11-20>
hold on
plotPDF(BCC_grain.meanOrientation,h4,'upper','grid','projection','eangle','markerColor','r','markersize',5,'parent',sp2); %beta grains <1-11>
title('Directions');
hold off

set(gcf,'name',plotname,'numbertitle','off') %change plot name    

% save if required
if PlotOpt.general.SaveOn > 0
    print(gcf,plotname,'-dtiff','-r600'); %save if required
end    

%% return to parent folder
cd (settings.file.mainFolder);

