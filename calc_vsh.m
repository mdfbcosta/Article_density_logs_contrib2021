function [vsh] = calc_vsh (gr,flag)

IGR = (gr-min(gr))/(max(gr)-min(gr)); % IGR
IGR = IGR + 1.e-3; % Regularizado

if (flag == 1)
    % Larionov (1969) for Tertiary rocks:
    vsh = 0.083*(2.^(3.7*IGR)-1);
elseif (flag == 2)
    % Larionov (1969) for older rock:
    vsh = 0.33*(2.^(2*IGR)-1);
elseif (flag == 3)
    % Steiber (1970):
    vsh = IGR./(3 - 2*IGR);
elseif (flag == 4)
    % Clavier (1971):
    vsh = 1.7 - sqrt(3.38 - (IGR + 0.7).^2);
end