function [out_data, out_tm] = get_around_inds(data, tm, search, pre_time, post_time)    
    sf = 1/diff(tm(1:2));
    inds = nearest(tm, search);
    pre_n = round(sf*pre_time);
    post_n = round(sf*post_time);
    seg_n = pre_n+post_n+1;
    out_tm = linspace(-pre_time, post_time, seg_n);
    
    % drop inds too close the the ends
    inds(inds-pre_n < 1) = [];
    inds(inds+post_n > numel(data)) = [];
    
    start = inds-pre_n;
    stop = inds+post_n;
    
    out_data = nan(length(start), seg_n);
    for i=1:height(out_data)
        out_data(i, :) = data(start(i):stop(i));
    end
end

function inds = nearest(data, search)
    search = reshape(search, 1, []);
    data = reshape(data, [], 1);
    inds = nan(size(search));
    for i=1:length(search)
        [~, inds(i)] = min(abs(data-search(i)));
    end
    inds = inds(:);
end