function P = PEM( Cd )
%PEM Summary of this function goes here
%   Detailed explanation goes here
[s, p] = size(Cd);
Cl = min(min(Cd));
Cu = max(max(Cd));
Mc = 20;
D = 5;
P = zeros(s, 1);
M = zeros(Mc, p);
for i = 1:s
    Ones = 0;
    for j = 1:p
        k = floor( (Cd(i, j) - Cl) / (Cu - Cl) * (Mc - 1) ) + 1;
        for u = -D:D
            for v = -D:D
                if 1 <= j + u && j + u <= p && 1 <= k + v && k + v <= Mc
                    M(k+ v , j + u) = 1;
                end
            end
        end
    end
    for l = 1: p
        for m = 1: Mc
            Ones = Ones + M(m, l);
        end
    end
    P(i) = Ones / ( p * Mc);
end
end

