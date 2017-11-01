function [tr_data, va_data, tr_len, va_len] = k_fold(stSeq, k, partion_id)

assert(partion_id <= k);

start_id = (partion_id - 1)*size(stSeq, 2)/k + 1;
end_id = partion_id*size(stSeq, 2)/k;

tr_data = cell(size(stSeq, 1), 1);
va_data = cell(size(stSeq, 1), size(stSeq, 2)/k);
tr_len = zeros(size(stSeq, 1), size(stSeq, 2)*(k - 1)/k);
va_len = zeros(size(stSeq, 1), size(stSeq, 2)/k);

for i = 1 : size(stSeq, 1)
    tr_count = 1; va_count = 1;
    for j = [(1 : start_id - 1) (end_id + 1 : size(stSeq, 2))]
        tr_data{i} = [tr_data{i} stSeq{i, j}];
        tr_len(i, tr_count) = length(stSeq{i, j});
        tr_count = tr_count + 1;
    end
    
    for j = start_id : end_id
        va_data{i, va_count} = [va_data{i, va_count} stSeq{i, j}];
        va_len(i, va_count) = length(stSeq{i, j});
        va_count = va_count + 1;
    end
end