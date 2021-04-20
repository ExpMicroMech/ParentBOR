% 
% %grain boundary for this region (bound)
% bound=grains_hcp(ib{6}).boundary;
% %pair we are testing
% anotherTest=[96,168];
% % logical test for this
% gb3=ismember(bound.grainId,anotherTest,'rows');
% %remove these values from the bound container
% bound(gb3)=[]
% %plot to prove
% figure; plot(grains_hcp(ib{6}));hold on;plot(bound,'linecolor','r','linewidth',3);
% 
% %% take 2
% %grain boundary for this region (bound)
% bound=grains_hcp(ib{6}).boundary;
% % get the grain IDs for the grains in this region
% testinglist=grains_hcp(ib{6}).id;
% %compare grain IDs for boundary to the list of grains in the region
% test=ismember(bound.grainId,testinglist); 
% %conduct a test to check if both columns have a 1 in them
% for n=1:length(test)
%     if test(n,1)==1 && test (n,2)==1 %if both grain IDs are in the list, count as 1
%         test2(n)=1; 
%     else 
%         test2(n)=0; %otherwise, its a 0 (not internal to the group)
%     end
% end
% test2=test2'; %vertical list
% test3=logical(test2); %convert to logical
% boundmerge=bound(test3); %grab the grain boundary for merging later
% bound(test3)=[]; %get rid of these internal gBs
% %plot
% figure; 
% plot(grains_hcp(ib{6})); %grains in region
% hold on;
% plot(bound,'linecolor','r','linewidth',3); %grain boundary that remains
% 
% %if merging:
% [grainsMerged,parentId] = merge(grains_hcp,boundmerge)
% figure; 
% plot(grainsMerged); %merged grain

%% Extend to more areas
for s=1:length(ib)
    %grain boundary for this region (bound)
    bound=grains_hcp(ib{s}).boundary;
    % get the grain IDs for the grains in this region
    testinglist=grains_hcp(ib{s}).id;
    %compare grain IDs for boundary to the list of grains in the region
    test=ismember(bound.grainId,testinglist); 
    for n=1:length(test)
        if test(n,1)==1 && test (n,2)==1 %if both grain IDs are in the list, count as 1
            test2(n)=1; 
        else 
            test2(n)=0; %otherwise, its a 0 (not internal to the group)
        end
    end
    test2=test2'; %vertical list
    test3=logical(test2); %convert to logical
    if max(test3)==0
        boundary{s}=bound;
%         boundmerge{s}=[];
    else
%         boundmerge{s}=bound(test3); %grab the grain boundary for merging later
        bound(test3)=[]; %get rid of these internal gBs
        boundary{s}=bound;
    end
    clear test test2 test3
end


%% plot

%prep
for u=1:length(ib)
    grain_group=grains_hcp(ib{u});
    for v=1:length(grain_group)
        grains_hcp(grain_group(v).id).prop.ib=u;
    end
end

phase1=settings.phases.phase1; %HCP/Alpha phase
PlotOpt.general.oM.oM1 = ipfTSLKey(ebsd(phase1));      %HCP Colorkey (TSL is default)
oM1=PlotOpt.general.oM.oM1; %HCP - IPF direction & colourkey
% SB=PlotOpt.general.Scalebar; %scalebar on/off


f1=figure;
f1.Color=[0 0 0];
% plot(grains_hcp(phase1),oM1.orientation2color(grains_hcp(phase1).meanOrientation),'micronbar',SB,'figSize','large','faceAlpha',0.5);
%OR
%  plot(ebsd,ebsd.prop.RadonQuality) 
% colormap gray
%OR
% plot(grains_hcp.boundary,'linecolor','k','linewidth',1);
%OR
plot(grains_hcp,grains_hcp.prop.ib,'micronbar','off')
% colormap jet
% caxis([0,24])

hold on
for t=1:length(ib)
    plot(boundary{t},'micronbar','off', 'linecolor','r','linestyle','--','linewidth',2,'figSize','large');
    hold on
end
% set(gcf, 'color', 'none');
print(gcf,'discrete_clusters_bw','-dpng','-r600'); %save if required

%%
% for f=1:length(ib)
%     if length(boundmerge{f})>0 
%        [grainsMerged{f},parentId{f}] = merge(grains_hcp,boundmerge{f}); 
%     else
%        grainsMerged{f}=[]; 
%     end
% end
% 
% figure;
% for t=1:length(ib)
%     plot(grainsMerged{t});%, 'linecolor','r','linestyle','-','linewidth',2)
%     hold on
% end

%% multicolored

bw = imread('https://blogs.mathworks.com/images/steve/2012/rice-bw.png');
imshow(bw)

bw = imread('discrete_clusters_bw.png');
imshow(bw)

% %try cropping and saving differently
% % Select regions [xmin ymin xmax-xmin ymax-ymin]
% xmax=6336;
% xmin=664;
% ymax=3786;
% ymin=63;
% region1 = [xmin ymin xmax-xmin ymax-ymin];
% 
% figure;
% imagesc(bw);
% rect=rectangle('position', region1,'edgecolor','m','linewidth',2); %region1
% 
% 
% 
% Icropped = imcrop(bw,region1); %crop the image Icropped = imcrop(I,rect)
% BW = im2bw(Icropped,0.5); %binarise the image BW = im2bw(I,level)
% % 
% cc = bwconncomp(BW);
% L = labelmatrix(cc);
% 
% imshow(L == 10)
% 
% rgb = label2rgb(L,'jet',[0 0 0],'shuffle');
% imshow(rgb)
% imsave

% A=imread('discrete_clusters_col.png');
% B=imread('discrete_clusters_bw.png');
% 
% imshowpair(A,B,'blend')