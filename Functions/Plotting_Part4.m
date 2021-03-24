function [grains]=Plotting_Part4(grains,settings,PlotOpt)
%PLOTTING_PART4 - change the beta orientation option applied and then plot 
% the alternative beta options and the alpha variants.
%
% Plots:
%   - Alternative Beta options combo plot: Figure containing 6 IPF maps 
%     where the beta option chosen is the number of the plot (where the no 
%     of beta options is less than the plot no, the first beta option is 
%     chosen)
%   - Alpha variant combo plots (x6): 
%     Format: All 12 variants/shared (c)/shared <a> titled by beta option.
%     (Again, where the no of beta options is less than the plot no, the 
%     first beta option is chosen)
%
% Inputs:
%   grains - structure containing:
%       grains_hcp - alpha grain data
%       bcc_grains - beta grain data
%       Beta_Options - orientation options for BCC grains
%   settings - structure containing:
%       filesave_loc - where to save the figures
%   PlotOpt - structure containing:
%       SaveOn - whether to save the figures
%       ScalebarOn - whether to include a scalebar
%
% Ouput:
%   - grains - stucture containing updates to:
%       - altBeta.AltBeta.optX - for each altenative beta option
%         adds: alphaGrains (inc. variant number) 
%               betaGrains (inc. no of unique alpha variants)
%               BetaOpt (inc. UniqueAlphaVariants)
%
% 23/01/21 RB
%% Change the Beta option selected and calculate the Beta option
% Change the selected beta orientation option for each grain. Maximum of 6
% options so outputs 6 maps & each time recalculates the alpha variants. 

% Changing the beta orientation option:
%[grains.AltBeta.X]=changeOriOption(grains[bcc_grains/Beta_Options], option_no)
% Output: new beta grains list is stored under grains.AltBeta.opt1

% Re-calculate the alpha variants
%[grains]=calcAlphaVariantsNewBeta(grains,settings,BetaSetNo)
%Outputs in grains.AltBeta.optX 
%   adds: alphaGrains (inc. variant number) 
%         betaGrains (inc. no of unique alpha variants)
%         BetaOpt (inc. UniqueAlphaVariants)

for b=1:6
    [grains]=changeOriOption(grains,b); %change beta orientations 
    [grains]=calcAlphaVariantsNewBeta(grains,settings,b); %recalculate alpha variants 
end

%% Alternative Beta Options Combo Plot
% Figure containing 6 IPF maps - where the beta option chosen is the number
% of the plot (where the no of beta options is less than the plot no, the 
% first beta option is chosen)

if PlotOpt.altBeta.combo > 0 
    plotBetaOptCombo(grains,PlotOpt,settings); %plotBetaOptCombo(grains,PlotOpt,settings)
end

%% Plot alternative alpha variant options as a result of the updated beta orientations
% 6 figures (numbered by beta option number chosen) - each figure containing 3 subplots: 
% layout =  variant number(12 colours); shared plane (6 colours); shared direction (4 colours) 

if PlotOpt.altBeta.alphaVar > 0 
    for b_opt = 1:6
        plotAlphaVarNew (grains,PlotOpt,settings,b_opt); %alphaVarNew (grains,PlotOpt,settings,opt)
    end
end