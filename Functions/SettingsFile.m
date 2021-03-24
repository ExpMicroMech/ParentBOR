function SettingsFile(fname,gbThreshold,smallGrains,smoothGrains,smallGrainsOn,smoothOn,cutoff,Inflationpower,filesave_loc)
%SETTINGSFILE is used to save the settings used for the current run of the
%code
% INPUTS:
%   fname - name of the h5 file
%   gbThreshold - threshold value for grain boundary identification(degrees)
%   smallGrains - threshold grain size below which the grains will be removed
%   smoothGrains - smoothing value
%   smallGrainsOn - whether removal of small grains is on/off
%   smoothOn - whether smoothing will be applied to the initial HCP map
%   cutoff - threshold value for matching GB misorientations (degrees)
%   Inflationpower - Inflation power for MCL algorithm
% 
% OUTPUT:
% Text file containing this information
%
% 22/10/20 RB

%%
% saveloc=['C:\Users\ruthb\Documents\GitHub1\ReconstructionCode\Results']
%%
% Save_loc = 'C:\\ruth\code_folder\results\';
% Save_name = 'code_results';
% Save_full = [Save_loc Save_name];
% save(Save_full)

% filesave_loc
[filepath,name,ext] = fileparts(fname); 
fileID1=['Settings_',name,'.txt'];
fileID2=[filesave_loc fileID1];

gbThreshold_deg=gbThreshold*180/pi; %get gbthreshold in degrees


% open file
fileID = fopen(fileID2,'w');
% add data
fprintf(fileID,'%s\n\n',fname); %file name

fprintf(fileID,'Grain Processing:\n\n');
fprintf(fileID,'Grain boundary threshold: %.1f degrees\n',gbThreshold_deg);
fprintf(fileID,'Small grains threshold: %i pixels\n',smallGrains);
fprintf(fileID,'Smoothing value: %i\n',smoothGrains);
if smallGrainsOn==1
    fprintf(fileID,'Small grain removal: On\n');
else 
    fprintf(fileID,'Small grain removal: Off\n');
end
if smoothOn==1
    fprintf(fileID,'Smoothing: On\n');
else
    fprintf(fileID,'Smoothing: Off\n');
end

fprintf(fileID,'\nReconstruction Settings:\n\n');
fprintf(fileID,'Cutoff: %.1f\n',cutoff);
fprintf(fileID,'Inflation power: %.1f\n',Inflationpower);

fclose(fileID);
