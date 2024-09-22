function [neural, conditions, session_id] = t5_parse(files)

targets = [];
neural_list = {}; iitrial=0;

for ifile = 1: length(files)
    dat = load(files{ifile}, 'binnedNeural_hlfp', 'binnedNeural_redisClock', 'taskOutput_stream_redis_clock', 'taskOutput_stream_target', 'taskOutput_stream_hand_color');


    trial_starts = [];
    trial_ends = [];

    for itm = 1: length(dat.taskOutput_stream_redis_clock) - 1
        if dat.taskOutput_stream_hand_color(itm) == 1 && dat.taskOutput_stream_hand_color(itm + 1) == 2
            move_start = dat.taskOutput_stream_redis_clock(itm+1);
        end


        if dat.taskOutput_stream_hand_color(itm) == 2 && (dat.taskOutput_stream_hand_color(itm + 1) == 1 || dat.taskOutput_stream_hand_color(itm + 1) == 3)
            move_end = dat.taskOutput_stream_redis_clock(itm);

            trial_starts = [trial_starts; move_start];
            trial_ends = [trial_ends; move_end];
            targets = [targets; dat.taskOutput_stream_target(itm, :)];
        end


    end

    move_end = dat.taskOutput_stream_redis_clock(itm);
    trial_starts = [trial_starts; move_start];
    trial_ends = [trial_ends; move_end];
    targets = [targets; dat.taskOutput_stream_target(itm, :)];


    for itrial = 1: size(trial_starts, 1)
        [~, ineural_start] = min(abs(trial_starts(itrial) - dat.binnedNeural_redisClock));
        [~, ineural_end] = min(abs(trial_ends(itrial) - dat.binnedNeural_redisClock));
        iitrial = iitrial + 1;
        neural_list{iitrial} = dat.binnedNeural_hlfp(ineural_start: ineural_end, :);
    end

end

L = [];
for itrial = 1: length(neural_list)
    L = [L; size(neural_list{itrial}, 1)];
end
L = min(L);

neural = zeros(size(neural_list{1}, 2), L, length(neural_list));
for itrial = 1: length(neural_list)
    neural(:, :, itrial) = neural_list{itrial}(1:L, :)';
end


conditions = targets;

session_id = zeros(1, size(conditions, 1));

end