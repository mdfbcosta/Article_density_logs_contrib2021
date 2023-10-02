close all
clc

x = [1:.1:2];

for i = 1:3
  
  if i ==1
    y = x.^2;
  elseif i==2
    y = x.^2 + 3;
  else
    y = x.^2 + 6;
  end
  
  %md = [1.00 1.40 1.80];
  figure(1)
  hold on
  plot(x,y,'color',[0.00 0.00 0.00])
  legend('A','B','C')

end


case o = 1
    print('1')
    case 