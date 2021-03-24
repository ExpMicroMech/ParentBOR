function [grains] = PostProcessing(grains,ebsd_all,settings)
%POSTPROCESSING calculates alpha variants and beta orientation options.
% Steps:
%   - Find the alpha grains contained in each beta grain
%   - Analyse the alpha variants present in each beta grain
%   - Calculate the potential unique beta orientations
%
% Inputs: 
%   grains   - contains grains data for alpha and beta phases 
%   ebsd_all - contains original ebsd data, raw beta ebsd data and 
%              reprocessed beta ebsd data
%   settings - structure containing settings required for grain processing 
%              and reconstruction. 
%
% Output:
%   grains   - updated grains data including no of unique alpha variants 
%              and beta orientation options for each beta grain. 
%
% 21/01/2021 RB
%% Alpha Variant Analysis
% find the alpha grains in each parent beta grain then calculate the alpha
% variants, no of unique alpha variants in each beta grain, etc. 

% find the alpha grains belonging to each parent beta grain
[grains]= matchAlpha2Beta(grains,ebsd_all,1); 
%[grains]= matchAlpha2Beta(grains,ebsd_all,isPlot)
% NOTE: updates grains_hcp to include corresponding beta grain

% Identify the alpha variant for each alpha grain & the unique alpha variants present in each beta grain. 
[grains]=calcAlphaVariants(grains,settings); 
%[grains]=calcAlphaVariants(grains,settings)
% NOTE: updates grains_hcp and stores unique alpha variants in each beta grain.

%% Beta Orientation Certainty 
% Determine the potential beta orientations based on the alpha variants present in each parent beta grain. 
[grains]=calcBetaOptions(grains); 
%[grains]=calcBetaOptions(grains) 
%NOTE: updates bcc_grains & adds Beta options

% alternative version
% [grains]=calcBetaOptions_messedwithfor4plus(grains); 
%[grains]=calcBetaOptions_messedwithfor4plus(grains)
%NOTE: adds bcc_grains2 & adds Beta_Options2
end

