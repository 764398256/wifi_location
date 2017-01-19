function [ all_edges ] = bfs( map, index )
%BFS 此处显示有关此函数的摘要
%   此处显示详细说明
%generate edge_pairs
[row, col] = size(map);
qSize = 300;
eSize  = 100;
head = 1;
nextLoc = 2;
ehead = 1;
edge_pairs = zeros(eSize,2);
Q = cell(1, qSize);
Q{head} = [1,1];
visited = zeros(size(map));
d = {[-1, 0], [1,0], [0, 1], [0, -1]};
while head < nextLoc
    q= Q{head};
    head = head + 1;
    voxel_id_st =  -1;
    if  map(q(1), q(2)) == 1
        voxel_id_st = find(ismember(index, [q(1), q(2)], 'rows'));
    end
    visited(q(1), q(2)) = 1;    
    for i =1: numel(d)
        delta = d{i};
        new_pos = [ delta(1) + q(1),  delta(2) + q(2) ];
        if new_pos(1) < 1 ||  new_pos(1) > row || new_pos(2) < 1 || new_pos(2) > col || visited(new_pos(1), new_pos(2)) == 1
            continue 
        else
            if visited(new_pos(1), new_pos(2)) == 0
                Q{nextLoc} = new_pos;
                nextLoc = nextLoc + 1;
                visited(new_pos(1), new_pos(2)) = -1;
            end
            if voxel_id_st > 0 && map(new_pos(1), new_pos(2)) == 1 && ehead <= eSize
                voxel_id_ed = find(ismember(index,[new_pos(1), new_pos(2)] , 'rows'));
                edge_pairs(ehead,: ) = [voxel_id_st-1, voxel_id_ed-1 ];
                ehead = ehead + 1;
            end
        end
    end
end
all_edges = edge_pairs(1:ehead-1,:);

end

