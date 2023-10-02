close all

xx = 1:10;
yy = xx.^2;
dd = [4 9 16];

for i = 1:length(dd)
    zz(i,:) = dd(i)+zeros(1,length(xx))
end

figure(65)
hold on
plot(yy,xx)
plot(yy,zz,'--m')
for e = 1:4
    [x(:,e),y] = ginput(2)
end