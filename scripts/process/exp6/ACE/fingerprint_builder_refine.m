function [histo] = fingerprint_builder_refine( M )
% M: multiple dimension matrix containing data of [ streams, subcarriers, voxel_num, sample_len ]
%   
[voxel_num, stream_num, dim ,sample_len] = size(M);
srange = [-2, 10];
step = 0.25;
nbin =  (srange(2) - srange(1))/step;
histo = zeros(voxel_num, stream_num* dim, 2, nbin);
histo_flatten = zeros(voxel_num,  2, nbin* stream_num*dim);

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
        histo_flatten(j, 1,nbin*(i-1)+1:  nbin*(i)) = squeeze( histo(j, i, 1, :) );
        histo_flatten(j, 2, nbin*(i-1)+1:  nbin*(i)) = squeeze( histo(j, i, 2, :) );
    end
end
        figure(1);
for j = voxel_num - 1: voxel_num
        h1 = plot(squeeze(histo_flatten(j,1,:)));
        le = [le; h1];
        la = [la; {sprintf('voxel %d,  pos', j)}];
        hold on;
        h2 = plot(squeeze(histo_flatten(j,2,:)));
        le = [le; h2];
        la = [la; {sprintf('voxel %d, neg', j)}];
        hold on;
end
legend(le, la);
xlabel('Bins');
ylabel('Probability');
lh=findall(gcf,'tag','legend');
set(lh,'location','northeastoutside');
disp(sum(sum(sum(sum(histo== 0)))) );

% plot
%fingerprint = reshape(histo, stream_num* dim*voxel_num*2*(srange(2) - srange(1))/step );
end

