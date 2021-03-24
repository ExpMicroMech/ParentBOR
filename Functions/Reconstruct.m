function [ebsd_beta_raw,devis] = Reconstruct(ebsd,symrots_true_hcp,bcc2hcp_BOR1,ib,grains_hcp,settings)
%RECONSTRUCT - Reconstruct the parent grains
%
%   Reconstruct the parent grain microstructure
%
%   Inputs:
%   ebsd -  Original (HCP) EBSD data
%   symrots_true_hcp - 12 symmetry matrices for HCP
%   bcc2hcp_BOR1 - initial orientation meeting burgers orientaion relationship
%   ib - Sparse matrix converted to line entries, each line contains grains of the corresponding cluster
%   grains_hcp - hcp grains 
%   settings - contains:
%       cs_bcc - crystal structure of BCC, from MTEX
%       cs_hcp - crystal structure of HCP, from MTEX
%
%   Outputs:
%   ebsd_beta - Parent grain ebsd data
%   devis - The deviation angle between the beta orientation of a single grain versus that of the cluster
%
% RB 27/11/2019
%% Reconstruction
cs_hcp=settings.sym.cs_hcp;%HCP/alpha
cs_bcc=settings.sym.cs_bcc;%BCC/beta
ebsd_beta = ebsd; % create EBSD variable for beta map

% Set the misorientation corresponding to "hcp to bcc" transformation
hcp2bcc = symrots_true_hcp * inv(rotation(bcc2hcp_BOR1));
hcp2bcc_trans = orientation(rotation(hcp2bcc),cs_bcc,cs_hcp);

% Create a wait bar to monitor reconstruction progress
h = waitbar(0,'Reconstructing parent orientations. Please wait...','Name','Reconstruction',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        
setappdata(h,'canceling',0)

% Reconstruction loop
for k = 1:length(ib);
    
    if getappdata(h,'canceling')
        break
    end
    
    waitbar(k/length(ib),h)
    
    line = ib{k};
    line = line(line>0);
    
    %Calculate potential parent orientations for grains in the set:
    bcc_parent_pot = grains_hcp(line).meanOrientation*hcp2bcc_trans;    
    
    %Create the orientation density function (ODF) for all potential parent beta orientations:
%     odf = calcODF(bcc_parent_pot,'halfwidth',4*degree); 
    odf = calcDensity(bcc_parent_pot,'halfwidth',4*degree); %changed from calcODF to calcDensity for MTEX 5.4
    
    %Determine the most intense orientation in the ODF (average parent orientation):
    [center,value] = calcModes(odf,'resolution',5*degree);
    
    %Determine the amount of data points:
    n=length(bcc_parent_pot(:,1));
    
    %Determine the amount of orientation alternatives per data point:
    i=length(bcc_parent_pot(1,:));
    
    %Calculate angles of all potential orientations and the average parent 
    %beta orientation with a single command, creates a column vector:
    misos_list=angle_outer(bcc_parent_pot,center) / degree;
    
    %Convert the list into a matrix with the previous size:
    misos=reshape(misos_list,n,i);
        
    %Find the minimum angular deviation and variant index of same on each
    %row:
    [M, I] = min(misos,[],2);

    %Turn I into proper linear indexing (to speed up script):
    I_ind = sub2ind(size(bcc_parent_pot),(1:length(I))',I);
    
    %Get the bcc parent orientations of the lowest angular deviation:
    bcc_parents = bcc_parent_pot(I_ind);
                
    %Correct the phase information of grains eligible for transformation:
    ebsd_beta(grains_hcp(line)).phase = 2; %BCC
    ebsd_beta(grains_hcp(line)).orientations = center;
    
    %Update devis:
    devis(line) = M;
    
end

% rename variable
ebsd_beta_raw=ebsd_beta;

% close the waitbar
delete (h)

%% Save: the average anglular deviation from BOR (devis)

devis_avg=round(mean(devis),2); %find average value for devis

%go to results folder
cd(settings.file.filesave_loc); 
%open file and save info
fileID2=settings.file.textfile; %get file name
fileID = fopen(fileID2,'a+');%open file
fprintf(fileID,'\t Average angular deviation from BOR: %0.2f\n',devis_avg); %Add infor
fclose(fileID); %close the file
%go back to main folder
cd (settings.file.mainFolder);

%display this information
Label = ['The reconstruction resulted in an average ' num2str(devis_avg) ' degree angular deviation from the BOR.'];
disp(Label);

end

