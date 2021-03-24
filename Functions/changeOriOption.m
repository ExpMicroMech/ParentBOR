function [grains]=changeOriOption(grains,option_no) 
%CHANGEORIOPTION - allocates a different beta orientation option for each 
% of the beta grains. 
%
% NOTE: In each case, only the grains with the specified number of
% options will change, the rest will be option 1.
%
% Inputs: 
%   grains - structure containing:
%       bcc_grains - bcc grain data
%       Beta_Options - orientation options for BCC grains
%   option_no - option to choose (1-6)
%
% Outputs:
%   grains - structure containing updated:
%       bcc_grains - bcc grain data with updated orientations
%
% created: 02/09/20 RB
% updated: 23/01/21 RB
%% Extract variables 

bcc_grains=grains.BCC.bcc_grains; %BCC/Beta grains
Beta_Options=grains.BetaOpt.Beta_Options; %The alternative beta orientation options for each beta grain

%% Change beta orientations to alternative options (to plot on IPF map)
%
%NOTE: where the no of beta options is less than the plot no, the first 
% beta option is chosen. (alternatively, the original output orientation 
% could be used by removing %the line after 'else' in each case - this is 
% not done because for grains with smaller numbers of alpha grains per beta
% grain, he initial beta orientation may differ slightly from all of the 
% beta options)

switch option_no
    case 1 %update to the first beta option (may change the beta grains formed from fewer alpha grains)
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            bcc_grains(grain_no).meanOrientation=options{1};
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt1.betaGrains=bcc_grains;
        
    case 2 %change to the second beta grain option/stay with the first option if there is only one
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            if length(options) > 1
                bcc_grains(grain_no).meanOrientation=options{2};
            else
                bcc_grains(grain_no).meanOrientation=options{1};
            end
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt2.betaGrains=bcc_grains;
        
    case 3 %change to the third beta grain option/stay with the first option if there is < 3 options
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            if length(options) > 2
                bcc_grains(grain_no).meanOrientation=options{3};
            else
                bcc_grains(grain_no).meanOrientation=options{1};
            end
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt3.betaGrains=bcc_grains;
   
    case 4 %change to the fouth beta grain option/stay with the first option if there is < 4 options
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            if length(options) > 3
                bcc_grains(grain_no).meanOrientation=options{4};
            else
                bcc_grains(grain_no).meanOrientation=options{1};
            end
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt4.betaGrains=bcc_grains;
        
    case 5 %change to the fifth beta grain option/stay with the first option if there is < 5 options
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            if length(options) > 4
                bcc_grains(grain_no).meanOrientation=options{5};
            else
                bcc_grains(grain_no).meanOrientation=options{1};
            end
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt5.betaGrains=bcc_grains;

    case 6 %change to the sixth beta grain option/stay with the first option if there is < 6 options
        for grain_no = 1:length(bcc_grains)
            options=Beta_Options(grain_no).opt;
            if length(options) > 5
                bcc_grains(grain_no).meanOrientation=options{6};
            else
                bcc_grains(grain_no).meanOrientation=options{1};
            end
        end
        % Store the updated beta grain orientations
        grains.AltBeta.opt6.betaGrains=bcc_grains;

end