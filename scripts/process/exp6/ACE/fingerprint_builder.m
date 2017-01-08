function [histo] = fingerprint_builder( M )
% M: multiple dimension matrix containing data of [ streams, subcarriers, voxel_num, sample_len ]
%   
[voxel_num, stream_num, dim ,sample_len] = size(M);
srange = [-2, 10];
step = 0.25;
histo = zeros(voxel_num, stream_num* dim, 2, (srange(2) - srange(1))/step);
%RSS Value Range
edges = [srange(1):step:srange(2)];

% Gussian Filter
sigma = 2;
rsize = 60;
x = linspace(-rsize / 2, rsize / 2, rsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize
la = [];
le = [];
for i = 1: stream_num* dim
    s = floor( ( i+dim - 1)/dim) ;
    d = mod(i + dim - 1,dim) + 1;
    for j = 1: voxel_num
        [h,~]=histcounts(M(j, s,d , :), edges, 'Normalization','probability');
        histo(j, i, 1, :)  = conv (h, gaussFilter, 'same')';
        [ho,~]= histcounts( reshape( M([1: (j-1), (j+1):end], s, d,:  ), sample_len*(voxel_num-1) ,1) , edges, 'Normalization','probability');
        histo(j, i, 2, :)  = conv (ho, gaussFilter, 'same')';
        %assert(sum(sum(sum(sum(histo== 0)))) == 0);
        if j >= voxel_num-1
        figure(1);
        h1 = plot(squeeze(histo(j,i,1,:)));
        le = [le; h1];
        la = [la; {sprintf('voxel %d, dim %d, pos', j, i)}];
        hold on;
        h2 = plot(squeeze(histo(j,i,2,:)));
        le = [le; h2];
        la = [la; {sprintf('voxel %d, dim %d, neg', j, i)}];

        hold on;
        end
    end
end
le
la
legend(le, la);
disp(sum(sum(sum(sum(histo== 0)))) );

% plot
%fingerprint = reshape(histo, stream_num* dim*voxel_num*2*(srange(2) - srange(1))/step );
end

