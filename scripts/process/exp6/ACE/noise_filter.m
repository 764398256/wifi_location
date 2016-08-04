function [ avg ] = noise_filter( M )
%NOISE_FILTER 此处显示有关此函数的摘要
%   此处显示详细说明
[stream_num, dim , sample_len] = size(M);
alpha = 0.2;
avg = zeros(stream_num, dim);
for i = 1: stream_num
    for j = 1: dim
         tmp = sort( M(i,j,:));
         avg(i, j) = mean(tmp( round( sample_len*alpha):round(sample_len*(1-alpha)) ));
    end
end

end

