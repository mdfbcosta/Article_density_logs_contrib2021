function [p] = gaunew (rhob,vp,vsh)

%% We have the equation:
%               rho_B = A(Vp + GVsh)^m
% where, we consider A = exp(A1) for compute the solution.

ninter = 0; nlevmar = 0;

erro2 = 100;
N = length(rhob);
tol = 6.e-10;

% Initial kick
p = [1.; 1.; 1.];  % A, G, m

%%
while erro2 > tol    
    
    rhob_pre = p(1)*(vp + p(2)*vsh).^p(3);

    J(:,1) = rhob_pre/p(1);
    J(:,2) = rhob_pre.*vsh*p(3)./(vp + p(2)*vsh);
    J(:,3) = rhob_pre.*( log(rhob_pre) - log(p(1)) )/p(3);    
    
    JTJ = J'*J;
    inJTJ = inv(JTJ);

    err = rhob - rhob_pre;
    JTe = J'*err;

    incr = inJTJ*JTe; % Incremento a ser adicionado ao valor dos coeficientes
         
    p = p + incr; % A, G, m
 
    rhob_pos = p(1)*(vp + p(2)*vsh).^p(3);
    e_pre = sum( err.*err )/N;
    e_pos = sum( (rhob - rhob_pos).^2 )/N;
    
    % Levenberg-Marquardt's Criterion
    if e_pos > e_pre
        nlevmar = nlevmar + 1;
        [p] = levmar (p,JTJ,incr,e_pos,e_pre,JTe,vp,vsh,rhob);
    end
 
    rhob_pos = p(1)*(vp + p(2)*vsh).^p(3);
    erro = rhob_pre - rhob_pos;
    erro2 = sum(erro.*erro)/N;

    ninter = ninter + 1;
end