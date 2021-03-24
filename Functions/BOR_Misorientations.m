function [BOR_set,oriMat,angMat,axisMat,full_BOR_set] = BOR_Misorientations(HCP_set,settings)
%BOR_MISORIENTATIONS - finds the misorientations between BOR variants
%   
%   Used to evaluate grain boundary types prior to reconstruction
%
%   Inputs:
%   HCP_set - series of orientations for bcc to hcp transformation
%   settings - contains:
%       cs_hcp - crystal structure of HCP, from MTEX
%   
%   Outputs:
%   oriMat - matrix (12 x 12) of misorientations between BOR variants
%   angMat - matrix (12 x 12) of angles between BOR variants
%   axisMat - matrix (12 x 12) of axis between BOR variants
%   BOR_set - minimised set of 7 misorientations between BOR variants
%   full_BOR_set - Full set of 12 potential misorientations between BOR variants
%
%   26/11/2019 RB
%%

%Extract cs_hcp from settings variable
cs_hcp=settings.sym.cs_hcp;

%BOR misorientations - Full set
for i=1:12
    for j=1:12
        oriMat(i,j)=orientation(inv(HCP_set(i))*HCP_set(j),cs_hcp); % misorientation matrices
        angMat(i,j)=angle(oriMat(i,j))*180/pi; % Angle 
        axisMat(i,j)=round(oriMat(i,j).axis); % Axis (rounded - remove 'round' for more accurate results)
    end
end

%BOR misorientations - Minimised set
BOR(1) = orientation(inv(HCP_set(1))*HCP_set(2),cs_hcp); %10.529degrees /[0 0 0 1] /c=[0001]
BOR(2) = orientation(inv(HCP_set(1))*HCP_set(6),cs_hcp); %60.000degrees /[-1 2 -1 0] /a=[11-20]
BOR(3) = orientation(inv(HCP_set(1))*HCP_set(5),cs_hcp); %60.832degrees /[-12 7 5 3] /angle with [0001] = 80.97degrees
% The next one is equiv. to BOR3
BOR(4) = orientation(inv(HCP_set(3))*HCP_set(5),cs_hcp); %60.832degrees /[-7 12 -5 3] /angle with [0001] = 80.97degrees
BOR(5) = orientation(inv(HCP_set(2))*HCP_set(5),cs_hcp); %63.832degrees /[-1 2 -1 1] /angle with [11-20] = 17.56degrees
% The next one is equiv. to BOR5
BOR(6) = orientation(inv(HCP_set(3))*HCP_set(6),cs_hcp); %63.832degrees /[-2 1 1 1] /angle with [11-20] = 17.56degrees
BOR(7) = orientation(inv(HCP_set(1))*HCP_set(3),cs_hcp); %90.000degrees /[-7 12 -5 0] /angle with [11-20] = 5.26degrees

BOR_set =  BOR;

%Full BOR set (12)
for i=1:12
    F_BOR(i)=orientation(inv(HCP_set(1))*HCP_set(i),cs_hcp);
end

full_BOR_set = F_BOR;

end

