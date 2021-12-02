function [ebsd_all, grains, settings]=cropTool(grains,ebsd_all,settings,reconstructionData)



%% setup 
phase1=settings.phases.phase1;
phase2=settings.phases.phase2;

oM1 = ipfTSLKey(ebsd_all.ebsd('Zirconium - alpha'));      %HCP Colorkey (TSL is default)
oM1.inversePoleFigureDirection = zvector;
oM2 = ipfTSLKey(ebsd_all.ebsd_beta('Zirconium - beta'));      %HCP Colorkey (TSL is default)
oM2.inversePoleFigureDirection = zvector;

alphaMap=grains.HCP.grains_hcp_smooth;
betaMap=grains.BCC.bcc_grains_smooth;

%% 
if settings.options.crop == 1
    %% Plot map 
    %plot alpha grain map and select an area
    f1=figure;
    plot(betaMap,oM2.orientation2color(betaMap.meanOrientation),'micronbar','off');
    set(gcf,'name','Select Crop Area','numbertitle','off') %change plot name
    [x,y]=ginput(2); %take mouse input (click diagonals)

%     %plot alpha grain map and select an area
%     figure;
%     plot(alphaMap,oM1.orientation2color(alphaMap.meanOrientation),'micronbar','off');
%     [x2,y2]=ginput(2); %take mouse input (click diagonals)
% 
%     x=[x;x2];
%     y=[y;y2];

    region1 = [round(min(x)) round(min(y)) round(max(x)-min(x)) round(max(y)-min(y))];
    rectangle('position', region1,'edgecolor','b','linewidth',2);
      
    X_max=(round(min(x)))+(round(max(x)-min(x)));
    Y_max=(round(min(y)))+(round(max(y)-min(y)));
    X_range=[round(min(x)) X_max];
    Y_range=[round(min(y)) Y_max];

    %% select data in this area 
    % ebsd - alpha
    condition1= inpolygon(ebsd_all.ebsd,region1); 
    ebsd_area1 = ebsd_all.ebsd(condition1);
    % ebsd - beta
    condition1_beta= inpolygon(ebsd_all.ebsd_beta,region1);
    ebsd_beta_area1 = ebsd_all.ebsd_beta(condition1_beta);
    % ebsd - beta - raw output
    condition1_beta_raw= inpolygon(ebsd_all.ebsd_beta_raw,region1);
    ebsd_beta_raw_area1 = ebsd_all.ebsd_beta_raw(condition1_beta_raw);
    
    %% process grains
    
    % housekeeping in settings file
    cd(settings.file.filesave_loc);% go to results folder
    fileID2=settings.file.textfile;% get file name
    fileID = fopen(fileID2,'a+');% open file
    fprintf(fileID,'Cropped area stats: \n'); % add subtitle
    fprintf(fileID,'\t Crop coordinates:\n'); % add subtitle
    fprintf(fileID,'\t\t X: %i %i \n',X_range(1),X_range(2)); % X min/max
    fprintf(fileID,'\t\t Y: %i %i \n',Y_range(1),Y_range(2)); % Y min/max
    fclose(fileID);%close the file
    cd (settings.file.mainFolder);% return to main folder
    
    %grain processing
    [ebsd_area1,grains_alpha_area1,grains_smooth_alpha_area1] = GrainProcessing1(ebsd_area1,settings,1);%alpha
    [ebsd_beta_area1,grains_beta_area1,grains_smooth_beta_area1] = GrainProcessing1(ebsd_beta_area1,settings,2);%beta

    % Identify parent grain boundary based on initial analysis (i.e. BOR vs. non-BOR matched) 
    [~,~,~,~,~,~,notBOR_GB] = GB_ID_BOR(ebsd_area1,grains_alpha_area1,settings,reconstructionData.BOR_set, 0, 0, 1, 0, 0); 
    f2=gcf;
        %% Plot to show output

%     f2=figure;
%     f2.Color=[1 1 1];
%     sp1=subplot(2,2,1);
%     plot(ebsd_area1(phase1),oM1.orientation2color(ebsd_area1(phase1).orientations),'micronbar','off','parent',sp1);
%     sp2=subplot(2,2,2);
%     plot(grains_smooth_alpha_area1,oM1.orientation2color(grains_smooth_alpha_area1.meanOrientation),'micronbar','off','parent',sp2);
%     sp3=subplot(2,2,3);
%     plot(ebsd_beta_area1(phase2),oM2.orientation2color(ebsd_beta_area1(phase2).orientations),'micronbar','off','parent',sp3);
%     sp4=subplot(2,2,4);
%     plot(grains_smooth_beta_area1,oM2.orientation2color(grains_smooth_beta_area1.meanOrientation),'micronbar','off','parent',sp4);

    %% save under the correct names
    ebsd_all.ebsd=ebsd_area1;
    ebsd_all.ebsd_beta=ebsd_beta_area1;
    ebsd_all.ebsd_beta_raw=ebsd_beta_raw_area1;

    % grains.HCP.devis; *********fix this*********
    grains.HCP.grains_hcp=grains_alpha_area1;
    grains.HCP.grains_hcp_smooth=grains_smooth_alpha_area1;

    grains.BCC.bcc_grains=grains_beta_area1;
    grains.BCC.bcc_grains_smooth=grains_smooth_beta_area1;
    grains.BCC.parentGB=notBOR_GB;
    
    %% change file save location
    
    cd(settings.file.filesave_loc);% go to results folder
    mkdir Cropped %make a new folder
    saveFolder=settings.file.filesave_loc;
    settings.file.filesave_loc=[saveFolder,'\Cropped\']; %update save folder location
    cd(settings.file.filesave_loc);% go to new results folder
    print(f1,'Crop_Region','-dtiff','-r600'); %save the crop figure in new folder
    print(f2,'Crop_GB_types_map','-dtiff','-r600'); %save the crop figure in new folder
    cd (settings.file.mainFolder);% return to main folder
    
else 
    disp('no cropping');
end