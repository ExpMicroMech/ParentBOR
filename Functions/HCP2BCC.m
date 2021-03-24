function [bcc_sym_orientations]=HCP2BCC(hcp_orientation, isPlot) % works for a single input orientation
%
%   HCP2BCC creates a set of BCC orientations which meet the BOR from the 
%   input HCP orientation   
%
%   Inputs:
%   hcp_orientation - start HCP orientation
%   isPlot - whether to plot the polefigures
%
%   Outputs:
%   bcc_sym_orientations - Corresponding BCC orientations
%   
%   06/02/20 RB
%% Setup

% Crystal Symmetry - set up the crystal symmetry for each phase
% cs_hcp=crystalSymmetry('hexagonal',[3.2,3.2,5.1],'mineral','Zirconium - alpha','color', 'light blue'); %HCP 
% cs_bcc=crystalSymmetry('m-3m', [3.642 3.642 3.642], 'mineral', 'Zirconium - beta', 'color', 'light red'); %BCC
load cs_hcp_cs_bcc.mat;

% Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(1,-1,1,cs_bcc, 'uvw'); %<1-11>

%% Initial orientation pair

%start with BCC in reference orientation
BCC_initial_n = orientation('euler',0*degree,0*degree,0*degree,'ZXZ',cs_bcc); %BCC
%put a HCP crystal that meets the BOR with this BCC orientation
HCP_initial_n = orientation('euler',0*degree, 45*degree, (90-acosd(1/sqrt(3)))*degree,'ZXZ',cs_hcp); %HCP
% HCP_initial_n = orientation('euler',305.2644*degree, 0*degree, 0*degree,'ZXZ',cs_hcp); %HCP

%extract the symmetries
HCP_sym=cs_hcp.rot.matrix; % 24 symmetry matrices 
% HCP_sym = cs_hcp.properGroup;

%construct the transformation matricies
T_HCP_to_BCC=BCC_initial_n.matrix*inv(HCP_initial_n.matrix);

%create the symmetric transformations - 12 for the HCP symmetry operator,
%and we will use this to update the cubic orientation with respect to our
%fixed hexagonal starting confirugation
T_HtoB_S=zeros(3,3,24);
for sym_num=1:24 
    % need to reorder the sym matrices to match other analysis???
    T_HtoB_S(:,:,sym_num)=HCP_sym(:,:,sym_num)*T_HCP_to_BCC;
end

new_hcp=hcp_orientation;

for sym_num=1:24 %Calculate complete set
    %construct the HCP orientations from the new BCC orientation
    new_bcc_sym(sym_num)=orientation('matrix',new_hcp.matrix*T_HtoB_S(:,:,sym_num),cs_bcc);
end

if isPlot ==1
    f1=figure;
    f1.Color=[1 1 1]; %remove grey background
    f1.Position=[100 -100 1200 800]; 

    for s_num=1:6
        s_num1=s_num;
        sp1=subplot(4,7,s_num+1); % Row 1 - (0001)alpha//{1-10}beta
        plotPDF(new_bcc_sym(s_num1), h3,'upper','grid','projection','eangle','MarkerColor','r','MarkerSize',10,'parent',sp1);%BCC Orientation in red (110)
        hold on
        plotPDF(new_hcp, h1,'upper','grid','projection','eangle','markercolor','k','markersize',5,'parent',sp1);%HCP in blue basal
        hold off
        title(int2str(s_num1),'FontSize',17,'Interpreter','latex');%titles  

        sp2=subplot(4,7,s_num+8); % Row 1 - (0001)alpha//{1-10}beta
        plotPDF(new_bcc_sym(s_num1), h4,'upper','grid','projection','eangle','markercolor','b','MarkerSize',10,'parent',sp2);%BCC <111> red
        hold on
        plotPDF(new_hcp, h2,'upper','grid','projection','eangle','markercolor','k','markersize',5,'parent',sp2);%HCP <a> blue 
        hold off
        title('','FontSize',17,'Interpreter','latex');%Remove titles

        sp3=subplot(4,7,1);
        plotPDF(new_hcp, h1,'upper','grid','projection','eangle','markersize',10,'parent',sp3);
        title('','FontSize',17,'Interpreter','latex');%Remove titles

        sp4=subplot(4,7,8);
        plotPDF(new_hcp, h2,'upper','grid','projection','eangle','markersize',10,'parent',sp4);
        title('','FontSize',17,'Interpreter','latex');%Remove titles
    end
end

bcc_sym_orientations=new_bcc_sym; % update variable name