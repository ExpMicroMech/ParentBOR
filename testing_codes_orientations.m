%crystal structures
cs_hcp=settings.sym.cs_hcp; %HCP/Alpha
cs_bcc=settings.sym.cs_bcc; %BCC/Beta

%grain orientations
grains_hcp=grains.HCP.grains_hcp; %alpha grains
bcc_grains=grains.BCC.bcc_grains; %beta grains
BetaGrainID=PlotOpt.BetaOpt_PF.g_sel; %selected beta grain for analysis

% Planes/Directions - Set up the planes/directions to plot
h1 = Miller(0,0,0,1, cs_hcp, 'hkl'); %(0001) 
h2 = Miller(1,1,-2,0,cs_hcp, 'uvw'); %<11-20>
h3 = Miller(1,1,0,cs_bcc, 'hkl'); %{110}
h4 = Miller(1,-1,1,cs_bcc, 'uvw'); %<1-11>

%%
PB_g1=orientation('euler',269.576*degree,157.446*degree,242.416*degree,cs_bcc);
PB_g2=orientation('euler',344.798*degree,41.453*degree,350.085*degree,cs_bcc);
PB_g3=orientation('euler',50.0149*degree,29.4951*degree,300.165*degree,cs_bcc);
PB_g4=orientation('euler',258.927*degree,81.9206*degree,272.683*degree,cs_bcc);
PB_g5=orientation('euler',298.998*degree,117.012*degree,279.728*degree,cs_bcc);
PB_g6=orientation('euler',55.2273*degree,42.1361*degree,342.44*degree,cs_bcc);

M_g1=orientation('euler',205.332*degree,79.77*degree,200.209*degree,cs_bcc);
M_g2=orientation('euler',151.569*degree,49.3103*degree,188.714*degree,cs_bcc);
M_g3=orientation('euler',49.8095*degree,29.5031*degree,210.403*degree,cs_bcc);
M_g4=orientation('euler',134.139*degree,134.772*degree,24.8691*degree,cs_bcc);
M_g5=orientation('euler',159.097*degree,122.301*degree,352.492*degree,cs_bcc);
M_g6=orientation('euler',90.183*degree,126.509*degree,17.4478*degree,cs_bcc);

O_g1=orientation('euler',89.5763*degree,22.5538*degree,297.584*degree,cs_bcc);
O_g2=orientation('euler',344.798*degree,41.453*degree,350.007*degree,cs_bcc);
O_g3=orientation('euler',49.8095*degree,29.5031*degree,300.403*degree,cs_bcc);
O_g4=orientation('euler',97.3669*degree,8.51045*degree,251.75*degree,cs_bcc);
O_g5=orientation('euler',278.318*degree,28.5858*degree,108.338*degree,cs_bcc);
O_g6=orientation('euler',49.8095*degree,29.5031*degree,300.403*degree,cs_bcc);


%%
plotname='MTEX Version'; 
f1=figure;
f1.Color=[1 1 1];
sp1=subplot(1,2,1);
plotPDF(O_g1,h3,'noSymmetry','upper','grid','projection','eangle','markerColor','k','markersize',8,'parent',sp1); %original
hold on
plotPDF(PB_g1,h3,'noSymmetry','upper','grid','projection','eangle','markerColor','r','markersize',5,'parent',sp1); %MyCode
plotPDF(M_g1,h3,'noSymmetry','upper','grid','projection','eangle','markerColor','b','markersize',5,'parent',sp1); %MTEX
hold off
title('Planes');
sp2=subplot(1,2,2);
plotPDF(O_g1,h4,'Symmetry','upper','grid','projection','eangle','markerColor','k','markersize',5,'parent',sp2); %original
plotPDF(O_g1,h4,'noSymmetry','upper','grid','projection','eangle','MarkerFaceColor', 'none','markerEdgeColor','k','markersize',10,'parent',sp2); %original
hold on
plotPDF(PB_g1,h4,'upper','grid','projection','eangle','o','MarkerEdgeColor','r','MarkerFaceColor', 'none','markersize',4,'parent',sp2); %MyCode
plotPDF(PB_g1,h4,'noSymmetry','upper','grid','projection','eangle','markerColor','r','markersize',6,'parent',sp2); %MyCode
plotPDF(M_g1,h4,'noSymmetry','upper','grid','projection','eangle','markerColor','b','MarkerFaceColor', 'none','markersize',3,'parent',sp2); %MTEX
plotPDF(M_g1,h4,'noSymmetry','upper','grid','projection','eangle','markerColor','b','markersize',8,'parent',sp2); %MTEX
title('Directions');
hold off
set(gcf,'name',plotname,'numbertitle','on') %change plot name    
