function plotAlphaVariants2(grains,settings,PlotOpt,PlotType)
% PLOTALPHAVARIANTS2 - plots based on the alpha variants assigned
%   Plots included:
%       - Alpha variants by variant number (12 colours)
%       - Alpha variants by shared (c) (6 colours)
%       - Alpha variants by shared <a> (4 colours)
%       - Combined plot
%
% Inputs:
%   grains - structure containing:
%       grains_hcp - alpha grain data including variant number
%   settings - structure containing:
%       filesave_loc - where to save the figures
%   PlotOpt - structure containing:
%       SaveOn - whether to save the figures
%       ScalebarOn - whether to include a scalebar
%   PlotType - which figure to plot:
%       (1) Alpha variants by variant number (12 colours)
%       (2) Alpha variants by shared (c) (6 colours)
%       (3) Alpha variants by shared <a> (4 colours)
%       (4) Combined plot
%
% 22/01/2021 RB
%% Extract variables % setup
%extract variables
grains_hcp=grains.HCP.grains_hcp; %grains_hcp - includes variant number info
bcc_grains=grains.BCC.bcc_grains; %bcc_grains - included to add beta grain boundaries
SB=PlotOpt.general.Scalebar; %scalebar on/off

%go to results folder
cd(settings.file.filesave_loc)

%% Setup colour maps

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

%% Plots
switch PlotType
    case 1 % variant number (12 colours)
        f1=figure;
        f1.Color=[1 1 1];  
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB); %plot alpha grains by variant number
        colormap(Rainbow_12); %12 colours
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
        hold off     
        set(gcf,'name','Alpha_variants_12_colours','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Alpha_variants_12_colours','-dtiff','-r600'); %save if required
        end   
        
    case 2 % shared (c) (6 colours)
        f2=figure;
        f2.Color=[1 1 1];  
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB); %plot alpha grains by variant number
        colormap(colours_6); %shared (c) colourmap
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2); %add beta grain boundaries
        hold off        
        set(gcf,'name','Alpha_variants_shared_planes','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Alpha_variants_shared_planes','-dtiff','-r600'); %save if required
        end   
        
    case 3 % shared <a> (4 colours)
        f3=figure;
        f3.Color=[1 1 1];  
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB);%plot alpha grains by variant number
        colormap(colours_4); %shared <a> colourmap
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
        hold off
        set(gcf,'name','Alpha_variants_shared_directions','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Alpha_variants_shared_directions','-dtiff','-r600'); %save if required
        end        
        
    case 4 % combined plot
        %LAYOUT: variant number(12 colours); shared plane (6 colours); shared direction (4 colours)
        f4=figure;
        f4.Color=[1 1 1];

        ax1=nextAxis;
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB); %plot alpha grains by variant number
        colormap(ax1, Rainbow_12); %12 colours
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
    %     text(grains_hcp,int2str(grains_hcp.prop.variant_no),'fontsize',12)%add variant numbers
        hold off
        
        ax2=nextAxis;
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB); %plot alpha grains by variant number
        colormap(ax2,colours_6); %shared (c) colourmap
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2); %add beta grain boundaries
        hold off

        ax3=nextAxis;
        plot(grains_hcp,grains_hcp.prop.variant_no,'micronbar',SB);%plot alpha grains by variant number
        colormap(ax3,colours_4); %shared <a> colourmap
        hold on
        plot(bcc_grains.boundary,'lineColor','k','linewidth',2);%add beta grain boundaries
        hold off

        set(gcf,'name','Alpha_variants_combo','numbertitle','off') %change plot name
        %option to save
        if PlotOpt.general.SaveOn > 0
            print(gcf,'Alpha_variants_combo','-dtiff','-r600'); %save if required
        end   
        
end

%% Return to main folder
cd (settings.file.mainFolder);
