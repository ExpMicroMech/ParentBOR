function [ebsd,grains,grains_smooth] = GrainProcessing1(ebsd,settings,grainType)
%GRAINPROCESSING1 - grain processing v2
%   
%   Calculate grains and remove small grains (also counts grains)   
%
%   Inputs:
%   settings - contains:
%       gbThreshold - grain boundary threshold angle
%       phases - ebsd phases for grain analysis [not currently used]
%       smallGrains - threshold grain size below which the grains will be removed
%       smoothGrains - level of smoothing applied (0 = off)
%   ebsd - ebsd dataset 
%   grainType - alpha (1) or beta (2) grains
%
%   Ouputs:
%   grains - grain data for the input ebsd data set
%
%   created: 26/11/2019 RB
%   updated: 21/01/2021 RB
%%
%Extract variables from settings
gbThreshold=settings.grains.gbThreshold; %grain boundary threshold
smallGrains=settings.grains.smallGrains; %small grains threshold
smoothGrains=settings.grains.smoothGrains; %smooth grains

% make an empty variable for the case where smoothing is off
grains_smooth=[];

% create grains variable for all indexed phases
% [grains,ebsd(phase).grainId] = calcGrains(ebsd(phase),'angle',gbThreshold);
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',gbThreshold);%,'boundary', 'tight');
%Remove small grains
ind = grains.grainSize < smallGrains;
ebsd(grains(ind)).phase = 0;
ebsd(grains(ind)).grainId = 0;

%Reidentify grains with small grains removed:
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',gbThreshold);%,'boundary', 'tight');
% [grains,ebsd(phase).grainId] = calcGrains(ebsd(phase),'angle',gbThreshold);

if smoothGrains > 0
    grains_smooth = smooth(grains,smoothGrains);
end

% display number of grains present
No_grains=length(grains);
HCP_grains_Label = ['Dataset contains ' num2str(No_grains) ' alpha grains.'];
BCC_grains_Label = ['Dataset contains ' num2str(No_grains) ' beta grains.'];

if grainType == 1; %alpha/HCP
    disp(HCP_grains_Label);
elseif grainType == 2; %beta/BCC
    disp(BCC_grains_Label);
end

%% Store grains info

% go to results folder
cd(settings.file.filesave_loc)

% get file name
fileID2=settings.file.textfile;

% open file
fileID = fopen(fileID2,'a+');

if grainType == 1; %alpha/HCP
    % add data
    fprintf(fileID,'\t No of alpha grains: %i\n',No_grains); %No of alpha grains
elseif grainType == 2; %beta/BCC
    % add data
    fprintf(fileID,'\t No of beta grains: %i\n',No_grains); %No of beta grains
end

%close the file
fclose(fileID);

% return to main folder
cd (settings.file.mainFolder);

end

