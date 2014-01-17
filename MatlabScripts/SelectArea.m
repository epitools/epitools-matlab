function w2 = SelectArea(w,minA,maxA)

A = regionprops(w,'Area');
Area = cat(1,A.Area);
ok = (Area > minA);
ok(Area > maxA) = 0;
inds = find(ok);

% disp(sprintf('Number of cells detected = %i',length(inds)))

% w2 = zeros(size(w));
% for i =1:size(inds)
%     r = w == inds(i);
%     r2 = w;
%     r2(~r) = 0;
%     w2 = w2 + r2;
% end

w2 = zeros(size(w));
t = logical(w2);
for i =1:size(inds)
    t = w == inds(i);
    w2(t) = inds(i);
end

