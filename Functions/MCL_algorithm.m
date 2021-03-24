function [ib] = MCL_algorithm(omega,gb_hcp_ids,grains_hcp,settings)
%MCL_ALGORITHM - Use Markov clustering algorithm
%
%   Used to find clusters and set up for reconstruction
%
%   Inputs:
%   omega - Contains the data necessary for MCL clustering (min angle between each grain pair misorientation & BOR set misorientations)[MCL{1} in original PAG_GUI]
%   gb_hcp_ids - Contains the grain boundary data necessary for MCL clustering [MCL{2} in original PAG_GUI]
%   grains_hcp - grain data for original (HCP) EBSD dataset 
%   settings - this contains:
%       Inflationpower - Inflation power (changeable value in main code)
%
%   Outputs:
%   ib - Sparse matrix converted to line entries, each line contains grains of the corresponding cluster
%
%   Adapted from code written by T.Nyyssonen 
%   29/11/2019 RB
%% Use MCL algorthim

%Use the Burr survival algorithm to determine 0-1 similarity between each grain pair (based on misorientation angle):
surv_val = 1-cdf('Burr',omega,2,5,1);
%Prune surv_val below certain value
surv_val(surv_val<0.001) = 0;
%Construct the sparse undirected graph required by MCL:
mcl = [gb_hcp_ids, surv_val];
z = sparse(mcl(:,1),mcl(:,2),mcl(:,3));
zz = z;
zzz = [zz;zeros((length(zz) - min(size(zz))),length(zz))];
zzz = zzz' + zzz;
zzzz = zzz + speye(length(zzz));
zzzzzz = sparse(zzzz);
%Call MCL: (use function from PAG_GUI)
Inflationpower=settings.reconstruct.inflationPower; %extract inflation power from settings variable
Clusters = full(mcl_func(Inflationpower,zzzzzz));
%Change MCL output to row-by-row grain lists (each row is one cluster):
[row_mcl,col_mcl] = find(Clusters);
[a_v,b_v] = ismember(row_mcl,1:length(grains_hcp));
idx = col_mcl;
ib = accumarray(nonzeros(b_v), idx(a_v), [], @(x){x});
%Find empty cells
emptyCells = cellfun(@isempty,ib);
%Remove empty cells
ib(emptyCells) = [];
%Update label for determining succesful clustering:
NoClusters=length(ib);
MCLLabel = ['MCL found ' num2str(length(ib)) ' discrete clusters.'];
disp(MCLLabel);

%% store number of discrete clusters in text file 
%go to results folder
cd(settings.file.filesave_loc)
% get file name
fileID2=settings.file.textfile;
% open file
fileID = fopen(fileID2,'a+');
% add data
fprintf(fileID,'\t No of discrete clusters (MCL): %i\n',NoClusters); %Add no of clusters
%close the file
fclose(fileID);
% return to main folder
cd (settings.file.mainFolder);
end

