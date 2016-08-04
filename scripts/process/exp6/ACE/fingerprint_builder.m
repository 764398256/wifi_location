function [histo,fingerprint] = fingerprint_builder( M )
%FINGERPRINT_BUILDER 此处显示有关此函数的摘要
%   此处显示详细说明
[stream_num, dim , sample_len, voxel_num] = size(M);
srange = [-30, 30];
step = 0.5;
histo = zeros(stream_num* dim, voxel_num, 2, (srange(2) - srange(1))/step);
%RSS Value Range
edges = [srange(1)+step:step:srange(2)];

% Gussian Filter
sigma = 5;
size = 30;
x = linspace(-size / 2, size / 2, size);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

for i = 1: stream_num*num
    s = floor(i/dim) + 1;
    d = mod(i,dim) + 1;
    for j = 1: voxel_num
    h=histogram(M(s,d , :, j), edges, 'Normalization','probability');
    ho= histogram( reshape( M(s,d, [1: j-1, j+1:end], : ), sample_len*(voxel_num-1) ,1) , edges, 'Normalization','probability');
    histo(i, j, 1, :)  = conv (h.Value, gaussFilter, 'same');
    histo(i, j, 2, :)  = conv (ho.Value, gaussFilter, 'same');
    end
end
fingerprint = reshape(histo, stream_num* dim*voxel_num*2*(srange(2) - srange(1))/step );
end

