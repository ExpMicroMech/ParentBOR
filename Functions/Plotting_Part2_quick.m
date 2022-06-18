function Plotting_Part2_quick(settings,PlotOpt,grains)
%PLOTTING_PART2 - Figures for post processing section
%   Plots:
%       - Reconstuction Quality:reconstruction step/variant id step
%       - Alpha variants:variant number/shared (c)/shared <a>/combo plot
%       - Beta certainty: No of beta options/No of unique alpha variants
%
% Inputs:
%   settings - structure containing settings required for grain processing 
%              and reconstruction.
%   PlotOpt  - structure containing plotting options
%   grains   - structure containing grain data for alpha and beta phases
%
% Created: 22/01/2021 RB
%% Reconstruction Quality
% Plot a measure of the quality of the reconstuction

% From reconstruction step (devis)
if PlotOpt.Quality.devis > 0
    % Plot quality of beta grain reconstruction (based on devis value)
    plotQuality2 (grains,PlotOpt,settings,1) %plotQuality2 (grains,PlotOpt,Type)
end

% From alpha var identification (min_angle)
% if PlotOpt.Quality.min_angle > 0
%     % Plot alpha grain reconstruction quality (based on min_angle)
%     plotQuality2 (grains,PlotOpt,settings,2) %plotQuality2 (grains,PlotOpt,Type)
% end

%% Plot alpha variants
% Plot the alpha variants by variant number/shared planes/shared directions/combined plot

% % All 12 variants 
% if PlotOpt.AlphaVar.all > 0 
%     % Plot alpha grains by variant number [12 colours]
%     plotAlphaVariants2(grains,settings,PlotOpt,1); %plotAlphaVariants2(grains,settings,PlotOpt,PlotType)
% end
% 
% % Shared planes (6 colours)
% if PlotOpt.AlphaVar.planes > 0 
%     % Plot alpha grains by common <a> [6 colours]
%     plotAlphaVariants2(grains,settings,PlotOpt,2); %plotAlphaVariants2(grains,settings,PlotOpt,PlotType)
% end
% 
% % Shared directions (4 colours)
% if PlotOpt.AlphaVar.dir > 0    
%     % Plot alpha grains by common <c> [4 colours]
%     plotAlphaVariants2(grains,settings,PlotOpt,3); %plotAlphaVariants2(grains,settings,PlotOpt,PlotType)
% end
% 
% %Combined plot
% if PlotOpt.AlphaVar.combo > 0       
%     % Combined plot - all three variations of alpha variant plotting
%     plotAlphaVariants2(grains,settings,PlotOpt,4); %plotAlphaVariants2(grains,settings,PlotOpt,PlotType)
% end

%% Beta Options - Certainty
% Two plots for evaluating the certainty of the beta orientation 

% % No of potential beta orientations
% if PlotOpt.BetaCert.noOfVar > 0
%     % Plot beta grains by number of potential beta orienations
%     plotBetaCertainty (grains,PlotOpt,settings,1); %plotBetaCertainty (grains,PlotOpt,settings,PlotType)
% end
% 
% % No of unique alpha variants in each beta grain
% if PlotOpt.BetaCert.betaOpt > 0
%     % Plot beta grains by no of unique alpha variants contained within
%     plotBetaCertainty (grains,PlotOpt,settings,2); %plotBetaCertainty (grains,PlotOpt,settings,PlotType)
% end

end

