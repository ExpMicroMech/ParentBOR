function [HCP_set,BOR1] = BCC2HCP (BCC_phi1,BCC_Phi,BCC_phi2,isPlot)

%   BCC2HCP creates a set of 12 orientations which meet the BOR from the 
%   input BCC orientation
%
%   Inputs:
%   BCC_phi1 - phi1 for the BCC start orientation (in degrees)
%   BCC_Phi - Phi for the BCC start orientation (in degrees)
%   BCC_phi2 - phi2 for the BCC start orientation (in degrees)
%   isPlot - whether to plot the orientations
%
%   Outputs:
%   HCP_set - set of 12 HCP orientations which meet BOR for the start BCC
%             orientation
%   BOR1 - The first HCP orientation calculated from the initial BOR pair
%          used
%
%   27/01/20 RB
%% Setup

% Crystal Symmetry - set up the crystal symmetry for each phase
cs_hcp=crystalSymmetry('6/mmm',[3.2,3.2,5.1],'mineral','Zirconium - alpha','color', 'light blue'); %HCP 
cs_bcc=crystalSymmetry('m-3m', [3.642 3.642 3.642], 'mineral', 'Zirconium - beta', 'color', 'light red'); %BCC

% Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(1,-1,1,cs_bcc, 'uvw'); %<1-11>

%% Initial orientation pair

%start with BCC in reference orientation
BCC_initial_n = orientation('euler',0*degree,0*degree,0*degree,'ZXZ',cs_bcc); %BCC
%put a HCP crystal that meets the BOR with this BCC orientation
% HCP_initial_n = orientation('euler',0*degree, 45*degree, (90-acosd(1/sqrt(3)))*degree,'ZXZ',cs_hcp); %HCP
HCP_initial_n = orientation('euler',0*degree, 45*degree, (90-acosd(1/sqrt(3))-120)*degree,'ZXZ',cs_hcp); %HCP

%extract the symmetries we will need
HCP_sym=cs_hcp.rot.matrix;
BCC_sym=cs_bcc.rot.matrix;

%Reorder the matrices
% S_reorder=[8,5,12,3,7,4,9,6,10,1,2,11,15,24,20,17,14,23,13,22,21,18,16,19]; %To match previous attempt/analysis
S_reorder3=[8,5,12,3,14,4,9,22,10,18,16,11,15,24,20,17,7,23,13,6,21,1,2,19]; %New1

BCC_sym_r =BCC_sym(:,:,S_reorder3);

%construct the transformation between BCC and HCP
T_BCC_to_HCP=HCP_initial_n.matrix*inv(BCC_initial_n.matrix);

%create the symmetric matrices
T_BtoH_S=zeros(3,3,24);
for sym_num=1:24
    %apply the symmetry to the transformation - the order here matters
    %depending on how the frames update
T_BtoH_S(:,:,sym_num)=BCC_sym_r(:,:,sym_num)*T_BCC_to_HCP;
end

for sym_num=1:12
    %construct the HCP orientations from the new BCC orientation
    HCP_set_initial(sym_num)=orientation('matrix',BCC_initial_n.matrix*T_BtoH_S(:,:,sym_num),cs_hcp);
end

BOR1=HCP_set_initial(1);
%% New BCC orientation using input
% Turn input euler angles into an orientation
new_bcc=orientation('euler', BCC_phi1*degree,BCC_Phi*degree,BCC_phi2*degree,'ZXZ',cs_bcc); %BCC

% Calculate HCP orientations
for sym_num=1:24
    %construct the HCP orientations from the new BCC orientation
    HCP_set(sym_num)=orientation('matrix',new_bcc.matrix*T_BtoH_S(:,:,sym_num),cs_hcp);
end

%% Plot (if wanted)
if isPlot == 1
    f1=figure;
    f1.Color=[1 1 1]; %remove grey background
    f1.Position=[100 -100 1200 800]; 

    for s_num=1:6
        s_num1=s_num; %plotting 1-12
%         s_num1=s_num+12; %plotting 13-24
        sp1=subplot(4,6,s_num); % Row 1 - (0001)alpha//{1-10}beta
        plotPDF(HCP_set(s_num1), h1,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp1);%HCP in blue basal
        hold on
        plotPDF(new_bcc, h3,'upper','grid','projection','eangle','MarkerSize',10,'markercolor','k','markersize',5,'parent',sp1);%BCC Orientation in red (110) 
        hold off
        title(int2str(s_num1),'FontSize',17,'Interpreter','latex');%titles

    %     title(['i = ' int2str(BOR_pairs(B,1)) ' j = ' int2str(BOR_pairs(B,2))]); % Title if needed

        sp2=subplot(4,6,s_num+6); %Row 2 - <11-20>alpha//<1-11>beta
        plotPDF(HCP_set(s_num1), h2,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp2);%HCP <a> blue
        hold on
        plotPDF(new_bcc, h4,'upper','grid','projection','eangle','parent',sp2,'markercolor','k','markersize',5);%BCC <111> red
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles


        sp3=subplot(4,6,s_num+12); % Row 3 - (0001)alpha//{1-10}beta
        plotPDF(HCP_set(s_num1+6), h1,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp3);%HCP in blue basal
        hold on
        plotPDF(new_bcc, h3,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp3,'markercolor','k','markersize',5);%BCC Orientation in red (110) 
        hold off
    %     title('','FontSize',17,'Interpreter','latex');%Remove titles
        title(int2str(s_num1+6),'FontSize',17,'Interpreter','latex');%titles

        sp4=subplot(4,6,s_num+18); % Row 4 - <11-20>alpha//<1-11>beta
        plotPDF(HCP_set(s_num1+6), h2,'upper','grid','projection','eangle','MarkerSize',10,'parent',sp4);%HCP <a> blue
        hold on
        plotPDF(new_bcc, h4,'upper','grid','projection','eangle','parent',sp4,'markercolor','k','markersize',5);%BCC <111> red
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles
    end
end
