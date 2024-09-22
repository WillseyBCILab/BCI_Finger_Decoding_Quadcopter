function RunAnalysis(wind)

%% 1.  Compile single finger data
files =  {'../Data/OpenLoopData/t5_t5.2023.04.06_Data_RedisMat_20230406_134920_(5).mat',
    '../Data/OpenLoopData/t5_t5.2023.04.06_Data_RedisMat_20230406_135654_(6).mat'};

[neural, conditions, session_id] = t5_parse(files);

sessions_use = unique(session_id);

neural = neural(1: 192, :, :);
conditions = conditions(:,[1,2,3,5]);

conditions_unique = unique(conditions, 'rows');

%% 1.1 Prepare for onetouch
fingers = {'thumb1', 'thumb2', 'IndexMiddle', 'RingSmall'};
moves = {'flex', 'extend'};
mn = {};
for icond = 1: size(conditions_unique, 1)
    cond = conditions_unique(icond, :);
    ifinger = find(abs(cond - 0.5) > 0.1);
    
    if isempty(ifinger); mn{icond} = 'rest'; continue; end
    if cond(ifinger) == 0; mn{icond} = [fingers{ifinger} '-flex']; end
    if cond(ifinger) == 1; mn{icond} = [fingers{ifinger} '-extend']; end

end
sDat.movementNames = mn;

ms = {[1, 2, 3, 4], [6, 7, 8, 9]};
sDat.movementSets = ms;
msn = {'flex', 'extend'};
sDat.movementSetNames = msn;

features = []; goTimes = []; movement_codes = []; cond_prev = [0.5, 0.5, 0.5, 0.5];
for itrial = 1: size(neural, 3)
    
    cond = conditions(itrial, :);

    goTimes = [goTimes; size(features, 1) + 1];
    features = [features; squeeze(neural(:, :, itrial))'];
    cond_code = find(sum(abs(conditions_unique - cond), 2) == 0);
    movement_codes = [movement_codes; cond_code];
    
    cond_prev = cond;
end
sDat.movementCodes = movement_codes;
sDat.features = features;
sDat.goTimes = goTimes;
sDat.saveDir = '.';
sDat.doNothingCode = 5;
sDat.dPCA_smoothWidth = 10;

sDat.binWidth = 0.05;
sDat.analysisWindow = wind;
sDat.plottingWindow = [00, 39];
sDat.plotRasters = false;

tuningAnalysesFunc(sDat);