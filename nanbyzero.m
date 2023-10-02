function [rho] = nanbyzero (rhob)

rho = rhob;
aux = isnan(rho);

for i = 1:length(rho)
    if aux(i) == 1
        rho(i) = 0;
    end
end