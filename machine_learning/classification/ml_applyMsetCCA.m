function [output] = ml_applyMsetCCA(features, model)
%ML_APPLYMSETCCA Summary of this function goes here
%   Detailed explanation goes here

[~, ~, epochs] = size(features.signal);
stimuli_count = max(features.events);
output.y = zeros(1, epochs);
output.score = zeros(1, epochs);
% apply CCA
for epo=1:epochs
    r = cell(1, stimuli_count);
    for stimulus=1:stimuli_count
        [~, ~, r{stimulus}] = cca(features.signal(:,:,epo)', ...
                                model.ref{stimulus});    
    end
    [output.score(epo), output.y(epo)] = max(cellfun(@max,r)); 
end
output.accuracy = ((sum(features.y == output.y)) / epochs)*100;
output.trueClasses = features.y;
% output = ml_get_performance(output);
output.subject = '';
end

