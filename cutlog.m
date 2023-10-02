function [LIM] = cutlog (Li,Lf,dep)

LIM = [Li Lf];
a = 1;
for j = 1:numel(LIM);
    while dep(a) < LIM(j);
      a = a+1;
    end
    LIM(j) = a;
end