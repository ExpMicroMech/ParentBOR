function plotBetaOptions (grains, PlotOpt, settings)
% PLOTBETAOPTIONS - plots the polefigures for the potential beta options 
% based upon the unique variants present:
%       Rows 1 & 3: (0001)hcp & {110}bcc
%       Rows 2 & 4: <11-20>hcp & <1-11>bcc
% Colours: BCC = black smaller dots;HCP = variant colouring for larger dots
% The alpha variant colouring matches the V1-12 colouring in the all alpha 
% variants plot in plotAlphaVariants2 (first plot). 
%
% Inputs:
%   grains - structure containing:
%       grains_hcp - grains data from alpha phase EBSD map
%       bcc_grains - grains data from reconstructed map
%       Unique - unique alpha variant numbers for each bcc grain
%       Beta_Options - potential beta orientations are stored under Beta_Options.opt
%   settings - structure containing:
%       cs_bcc - crystal structure of BCC, from MTEX
%       cs_hcp - crystal structure of HCP, from MTEX
%       filesave_loc - where to save any figures
%   PlotOpt - Plotting options containing:
%       saveOn - option to save figures
%       g_sel - beta grain selected     
%
% created: 23/02/20 RB
% updated: 22/01/21 RB
%% Extract variables and set up

%crystal structures
cs_hcp=settings.sym.cs_hcp; %HCP/Alpha
cs_bcc=settings.sym.cs_bcc; %BCC/Beta

%grain orientations
grains_hcp=grains.HCP.grains_hcp; %alpha grains
bcc_grains=grains.BCC.bcc_grains; %beta grains
Unique=grains.BetaOpt.UniqueAlphaVariants; %unique alpha variants for each beta grain
Beta_Options=grains.BetaOpt.Beta_Options; %Beta orientation options for each beta grain
BetaGrainID=PlotOpt.BetaOpt_PF.g_sel; %selected beta grain for analysis

% Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(1,-1,1,cs_bcc, 'uvw'); %<1-11>

%Setup the colour scheme for the alpha variants
%Red,Orange,Yellow,Green,Mint,Blue,Cyan,Royal Blue,Purple,Lavender,Pink,Brown
Rainbow_12=[0.9020 0.0980 0.2941;0.9608 0.5098 0.1882;1 1 0.0980;0.2353 0.7059 0.2941;0.6667 1 0.7647;0 0.5098 0.7843;0.2745 0.9412 0.9412;0.0353,0.0353,1;0.5686 0.1176 0.7059;0.9020 0.7251 1;0.9686 0.5059 0.7490;0.6667 0.4314 0.1569];

%go to results folder
cd(settings.file.filesave_loc);
%% Plotting
% BetaGrainID=1; %Select beta grain
AlphaGrains=grains_hcp(grains_hcp.prop.betaGrain==BetaGrainID);
NoUnique=Unique{BetaGrainID};
for c=1:length(NoUnique)
    Grains{c}=AlphaGrains(AlphaGrains.prop.variant_no==(NoUnique(c)));
end

plotname=strcat('Beta_Options_PF_BetaGrain_',num2str(BetaGrainID)); %title for output plot

m = bcc_grains(BetaGrainID).prop.no_of_unique_variants; %test for switch/case

switch m
    
    case 1
        % There are 6 beta variants to plot
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800]; 

        for s_num=1:6
            s_num1=s_num;
            sp1=subplot(4,6,s_num); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'markersize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Beta_Options(BetaGrainID).opt{s_num}, h3,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp1);%BCC 
            hold off
            title(int2str(s_num1),'FontSize',17,'Interpreter','latex');%titles  

            sp2=subplot(4,6,s_num+6); % <11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'markersize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Beta_Options(BetaGrainID).opt{s_num}, h4,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp2);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%Remove titles
        end
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
    
    case 2
        % There are 1, 2 or 3 beta grain options
        if bcc_grains(BetaGrainID).prop.certainty==4 %1 beta option
        % Plot the polefigure pair 
            f1=figure;
            f1.Color=[1 1 1]; %remove grey background
            f1.Position=[100 -100 1200 800];
            sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
            hold off
            title('Planes','FontSize',17,'Interpreter','latex');%titles

            sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
            hold off
            title('Directions','FontSize',17,'Interpreter','latex');%titles
            
            set(gcf,'name',plotname,'numbertitle','off') %change plot name    

            % save if required
            if PlotOpt.general.SaveOn > 0
                print(gcf,plotname,'-dtiff','-r600'); %save if required
            end      
            
        elseif bcc_grains(BetaGrainID).prop.certainty==50
            bcc_option1=Beta_Options(BetaGrainID).opt{1};
            bcc_option2=Beta_Options(BetaGrainID).opt{2};
            f1=figure;
            f1.Color=[1 1 1]; %remove grey background
            f1.Position=[100 -100 1200 800];
            sp1=subplot(2,2,1); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(bcc_option1, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
            hold off
            title('Planes','FontSize',17,'Interpreter','latex');%titles

            sp2=subplot(2,2,2); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(bcc_option1, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
            hold off
            title('Directions','FontSize',17,'Interpreter','latex');%titles

            sp3=subplot(2,2,3); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            plotPDF(bcc_option2, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp3);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles

            sp4=subplot(2,2,4); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            plotPDF(bcc_option2, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp4);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles
            
            set(gcf,'name',plotname,'numbertitle','off') %change plot name    

            % save if required
            if PlotOpt.general.SaveOn > 0
                print(gcf,plotname,'-dtiff','-r600'); %save if required
            end      
            
        else 
            bcc_option1=Beta_Options(BetaGrainID).opt{1};
            bcc_option2=Beta_Options(BetaGrainID).opt{2};
            bcc_option3=Beta_Options(BetaGrainID).opt{3};
            f1=figure;
            f1.Color=[1 1 1]; %remove grey background
            f1.Position=[100 -100 1200 800];
            sp1=subplot(3,2,1); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(bcc_option1, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
            hold off
            title('Planes','FontSize',17,'Interpreter','latex');%titles

            sp2=subplot(3,2,2); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(bcc_option1, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
            hold off
            title('Directions','FontSize',17,'Interpreter','latex');%titles

            sp3=subplot(3,2,3); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            plotPDF(bcc_option2, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp3);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles

            sp4=subplot(3,2,4); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            plotPDF(bcc_option2, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp4);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles        

            sp5=subplot(3,2,5); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp5);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp5);%HCP 
            plotPDF(bcc_option3, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp5);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles

            sp6=subplot(3,2,6); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp6);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp6);%HCP 
            plotPDF(bcc_option3, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp6);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles  
            
            set(gcf,'name',plotname,'numbertitle','off') %change plot name    

            % save if required
            if PlotOpt.general.SaveOn > 0
                print(gcf,plotname,'-dtiff','-r600'); %save if required
            end      
        end
        
    case 3
        % There are 1 or 2 beta grain options
        if bcc_grains(BetaGrainID).prop.certainty==4 %1 beta option
        % Plot the polefigure pair 
            f1=figure;
            f1.Color=[1 1 1]; %remove grey background
            f1.Position=[100 -100 1200 800];
            sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
            hold off
            title('Planes','FontSize',17,'Interpreter','latex');%titles

            sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
            hold off
            title('Directions','FontSize',17,'Interpreter','latex');%titles
            
            set(gcf,'name',plotname,'numbertitle','off') %change plot name    

            % save if required
            if PlotOpt.general.SaveOn > 0
                print(gcf,plotname,'-dtiff','-r600'); %save if required
            end      
            
        else
            bcc_option1=Beta_Options(BetaGrainID).opt{1};
            bcc_option2=Beta_Options(BetaGrainID).opt{2};
            f1=figure;
            f1.Color=[1 1 1]; %remove grey background
            f1.Position=[100 -100 1200 800];
            sp1=subplot(2,2,1); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
            plotPDF(bcc_option1, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
            hold off
            title('Planes','FontSize',17,'Interpreter','latex');%titles

            sp2=subplot(2,2,2); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
            plotPDF(bcc_option1, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
            hold off
            title('Directions','FontSize',17,'Interpreter','latex');%titles

            sp3=subplot(2,2,3); % (0001)alpha//{1-10}beta
            plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp3);%HCP 
            plotPDF(bcc_option2, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp3);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles

            sp4=subplot(2,2,4); %<11-20>alpha//<1-11>beta
            plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            hold on
            plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp4);%HCP 
            plotPDF(bcc_option2, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp4);%BCC 
            hold off
            title('','FontSize',17,'Interpreter','latex');%titles
            
            set(gcf,'name',plotname,'numbertitle','off') %change plot name    

            % save if required
            if PlotOpt.general.SaveOn > 0
                print(gcf,plotname,'-dtiff','-r600'); %save if required
            end      
            
        end    
        
    case 4
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles
 
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      

    case 5
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 6
        
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles    
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      

    case 7
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles  
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 8
        
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{8}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{8}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 9
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{8}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{9}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{8}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{9}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles 
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 10
        
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{8}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{9}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{10}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{8}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{9}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{10}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles         
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 11
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{8}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{9}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{10}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{11}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{11}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{8}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{9}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{10}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{11}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{11}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles  
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
        
    case 12
        % The beta grain orienation variant is certain
        % Plot the polefigure pair 
        f1=figure;
        f1.Color=[1 1 1]; %remove grey background
        f1.Position=[100 -100 1200 800];
        sp1=subplot(1,2,1); % (0001)alpha//{1-10}beta
        plotPDF(Grains{1}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{3}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{4}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{5}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{6}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{7}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{8}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{9}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{10}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP 
        plotPDF(Grains{11}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{11}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(Grains{12}.meanOrientation, h1,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{12}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp1);%HCP         
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h3,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp1);%BCC 
        hold off
        title('Planes','FontSize',17,'Interpreter','latex');%titles

        sp2=subplot(1,2,2); %<11-20>alpha//<1-11>beta
        plotPDF(Grains{1}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{1}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        hold on
        plotPDF(Grains{2}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{2}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{3}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{3}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{4}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{4}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{5}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{5}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{6}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{6}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{7}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{7}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{8}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{8}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{9}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{9}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{10}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{10}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{11}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{11}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(Grains{12}.meanOrientation, h2,'upper','grid','projection','eangle','markerColor',Rainbow_12((Grains{12}(1).prop.variant_no),:),'MarkerSize',10,'parent',sp2);%HCP 
        plotPDF(bcc_grains(BetaGrainID).meanOrientation, h4,'upper','grid','projection','eangle','MarkerSize',10,'markerColor','k','markersize',5, 'parent',sp2);%BCC 
        hold off
        title('Directions','FontSize',17,'Interpreter','latex');%titles 
        
        set(gcf,'name',plotname,'numbertitle','off') %change plot name    
        
        % save if required
        if PlotOpt.general.SaveOn > 0
            print(gcf,plotname,'-dtiff','-r600'); %save if required
        end      
end

%% return to main folder
cd (settings.file.mainFolder);
