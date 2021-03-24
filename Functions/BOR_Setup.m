function [bcc2hcp_BOR1,symrots_true_hcp,symrots_true_bcc,HCP_set] = BOR_Setup(settings,isPlot)
%BOR_Setup Establishes the Burgers orientation relationship
%
%   Used to setup the reconstruction
%
%   Inputs:
%   settings - this contains:    
%       cs_hcp - crystal structure of HCP, from MTEX
%       cs_bcc - crystal structure of BCC, from MTEX
%   isPlot - whether to plot the polefigures or not   
%
%   Outputs:
%   HCP_set - series of orientations for bcc to hcp transformation
%   bcc2hcp_BOR1 - initial orientation meeting burgers orientaion relationship
%   symrots_true_hcp - 12 symmetry matrices for HCP
%   symrots_true_bcc - re-ordered symmetry matrices for BCC
%
%   26/11/2019 RB

%% Setup 

%HCP crystal symmetry 
cs_hcp=settings.sym.cs_hcp; %Alpha/HCP crystal symmetry
HCP_sym = cs_hcp.properGroup; % Get the HCP symmetries
HCP_sym=HCP_sym.rot; %HCP symmetries as rotations
S_reorder1 = [1,2,3,4,5,6,7,8,9,10,11,12]; % potential to re-order if required
symrots_true_hcp= HCP_sym(S_reorder1); %Apply re-ordering (stored as rotations)

%BCC crystal symmetry
cs_bcc=settings.sym.cs_bcc; %Beta/BCC crystal symmetry
BCC_sym = cs_bcc.properGroup; % Get the BCC symmetries
BCC_sym=BCC_sym.rot; %BCC symmetries as rotations 
S_reorder2=[8,5,12,3,14,4,9,22,10,18,16,11,15,24,20,17,7,23,13,6,21,1,2,19]; %re-order 
symrots_true_bcc = BCC_sym(S_reorder2); %Apply re-ordering (stored as rotations)
BCC_sym_r =symrots_true_bcc.matrix; %re-ordered BCC symmetry matrices 

%Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(-1,1,1,cs_bcc, 'uvw'); %<1-11>

%Initial pair of orientations which meet BOR
BCC_initial = orientation('euler',0*degree,0*degree,0*degree,'ZXZ',cs_bcc); %BCC
HCP_initial = orientation('euler',0*degree, 45*degree, (acosd(1/sqrt(3))-30)*degree,'ZXZ',cs_hcp); %HCP

%% BOR 

%construct the transformation between BCC and HCP
T_BCC_to_HCP=HCP_initial.matrix*inv(BCC_initial.matrix);

%create the symmetric ones
T_BtoH_S=zeros(3,3,12);

for sym_num=1:12
    %apply the symmetry to the transformation - the order here matters
    %depending on how the frames update
    T_BtoH_S(:,:,sym_num)=BCC_sym_r(:,:,sym_num)*T_BCC_to_HCP;
end

for sym_num=1:12
    %construct the HCP orientations from the new BCC orientation
    hcp_set(sym_num)=orientation('matrix',BCC_initial.matrix*T_BtoH_S(:,:,sym_num),cs_hcp);
end

HCP_set=hcp_set(:); %Initial set of HCP orientations which meet BOR

bcc2hcp_BOR1 = orientation(rotation(HCP_set(1)), cs_bcc, cs_hcp); %First output (no symmetry applied yet - used later in code)


%% Check Plot (if required)
% plots pole figures for the initial set of HCP orientations created (12 alpha var) from the intial BCC orientation (0,0,0). 
%   Layout:
%       Rows 1&3: (0001)alpha//{1-10}beta
%       Rows 2&4: <11-20>alpha//<1-11>beta
%   Colours: 
%       BCC = small + black
%       HCP = larger + blue
% Saves automatically but doesn't display

% go to results folder
cd(settings.file.filesave_loc)

if isPlot == 1
    % check initial OR
    f1=figure('visible','off');
    f1.Color=[1 1 1]; %remove grey background

    for s_num=1:6
        sp1=subplot(4,6,s_num); % Row 1 - (0001)alpha//{1-10}beta
        plotPDF(HCP_set(s_num), h1,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp1);%HCP Orientation
        hold on
        plotPDF(BCC_initial, h3,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp1); %BCC Orientation
        hold off
        title(int2str(s_num),'FontSize',17,'Interpreter','latex');%Add titles
        
        sp2=subplot(4,6,s_num+6); %Row 2 - <11-20>alpha//<1-11>beta
        plotPDF(HCP_set(s_num), h2,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp2);%HCP Orientation
        hold on
        plotPDF(BCC_initial, h4,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp2);%BCC Orientation
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles
        
        sp3=subplot(4,6,s_num+12); % Row 3 - (0001)alpha//{1-10}beta
        plotPDF(HCP_set(s_num+6), h1,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp3);%HCP Orientation
        hold on
        plotPDF(BCC_initial, h3,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp3);%BCC Orientation
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles
        
        title(int2str(s_num+6),'FontSize',17,'Interpreter','latex');%Add titles
        
        sp4=subplot(4,6,s_num+18); % Row 4 - <11-20>alpha//<1-11>beta
        plotPDF(HCP_set(s_num+6), h2,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp4);%HCP Orientation
        hold on
        plotPDF(BCC_initial, h4,'upper','grid','projection','eangle','MarkerColor','k','MarkerSize',5,'parent',sp4);%BCC Orientation
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles
    end

    set(gcf,'name','PoleFigs_Initial_12_alpha_variants','numbertitle','off') %change plot name

    % save the figure 
    print(gcf,'PF_Initial_12_alpha_variants','-dtiff','-r600');

    % Return to main folder
    cd (settings.file.mainFolder);
    
end


end
