function plotAlphaVarNew (grains,PlotOpt,settings,opt)
% PLOTALPHAVARNEW - plots based on the alpha variants assigned for each of the
% potential beta options. Combo plot - layout =  variant number(12 colours)
% shared plane (6 colours); shared direction (4 colours)
%
% Inputs:
%   - grains - structure containing:
%       - grains_hcp_optX - alpha grains data for this option
%       - bcc_grains - beta grains data for this option
%   - settings - structure containing:
%       - saveOn - save figure on/off
%       - filesave_loc - where to save the figure
%   - PlotOpt - structure containing:
%       - SB - scalebar on/off
%   - opt - which beta orientation option has been selected
%
% 24/01/21 RB
%% Extract variables and set up 

% Get the alpha grain data for the selected option
switch opt
    case 1
        grains_hcp_opt=grains.AltBeta.opt1.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt1.betaGrains; %Beta/BCC grains
    case 2
        grains_hcp_opt=grains.AltBeta.opt2.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt2.betaGrains; %Beta/BCC grains
    case 3
        grains_hcp_opt=grains.AltBeta.opt3.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt3.betaGrains; %Beta/BCC grains
    case 4
        grains_hcp_opt=grains.AltBeta.opt4.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt4.betaGrains; %Beta/BCC grains
    case 5
        grains_hcp_opt=grains.AltBeta.opt5.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt5.betaGrains; %Beta/BCC grains
    case 6
        grains_hcp_opt=grains.AltBeta.opt6.alphaGrains; %Alpha/HCP grains
        bcc_grains=grains.AltBeta.opt6.betaGrains; %Beta/BCC grains
end

% colours for alpha plots
% 12 alpha variants - Rainbow_12
%Red,Orange,Yellow,Green,Mint,Blue,Cyan,Royal Blue,Purple,Lavender,Pink,Brown
Rainbow_12=[0.9020 0.0980 0.2941;0.9608 0.5098 0.1882;1 1 0.0980;0.2353 0.7059 0.2941;0.6667 1 0.7647;0 0.5098 0.7843;0.2745 0.9412 0.9412;0.0353,0.0353,1;0.5686 0.1176 0.7059;0.9020 0.7251 1;0.9686 0.5059 0.7490;0.6667 0.4314 0.1569];
   
% Common <a> - colours_4 [Pastels - qualitative & print safe]
col_1=[0.5529 0.8275 0.7804]; % Green
col_2=[1 1 0.7020]; % Yellow
col_3=[0.7451 0.7294 0.8549]; % Purple
col_4=[0.9843 0.5020 0.4471]; % Red
% Variants with common <a>: [1/6/10; 2/7/11; 3/9/12; 4/5/8]
colours_4 = [col_1;col_2;col_3;col_4; col_4;col_1;col_2;col_4; col_3;col_1;col_2;col_3];

% Common <c> - Colours_6 
% Bold colourset: Red, Blue, Green, Purple, Orange, Yellow [Qualitative]
% Variants with common <c>: [1/2; 3/4; 5/6; 7/8; 9/10; 11/12]
colours_6 = [0.8941 0.1020 0.1098;0.8941 0.1020 0.1098;0.2157 0.4941 0.7216;0.2157 0.4941 0.7216;0.3020 0.6863 0.2902;0.3020 0.6863 0.2902;0.5961 0.3059 0.6392;0.5961 0.3059 0.6392;1 0.4980 0;1 0.4980 0;1 1 0.2;1 1 0.2];

%scalebar on/off
SB=PlotOpt.general.Scalebar;

%go to results folder
cd(settings.file.filesave_loc);
%% Plot
%LAYOUT: variant number(12 colours); shared plane (6 colours); shared direction (4 colours)

f1=figure;
f1.Color=[1 1 1];

ax1=nextAxis;
plot(grains_hcp_opt,grains_hcp_opt.prop.variant_no,'micronbar',SB);%plot alpha grains by variant number
colormap(ax1, Rainbow_12);
hold on
plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
%     text(grains_hcp,int2str(grains_hcp.prop.variant_no),'fontsize',12)%add variant numbers

ax2=nextAxis;
plot(grains_hcp_opt,grains_hcp_opt.prop.variant_no,'micronbar',SB);%
colormap(ax2,colours_6); %colour by shared (c)
hold on
plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
hold off

ax3=nextAxis;
plot(grains_hcp_opt,grains_hcp_opt.prop.variant_no,'micronbar',SB);%plot alpha grains by variant number
colormap(ax3,colours_4); %colour by shared <a>
hold on
plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
hold off

PltName=['Beta_Opt_' num2str(opt) '-alpha_variants'];
set(gcf,'name',PltName,'numbertitle','off');

if PlotOpt.general.SaveOn > 0
    print(gcf,PltName,'-dtiff','-r600');
end

%% Return to main folder
cd (settings.file.mainFolder);
