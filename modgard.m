% Function that calculates the values of k and b
%
% This function makes a data fit using least squares for 
% equations in the form:
%                 rho_b = k*vp^b
% and we can rewrite it, as:
%            log(rho_b) = log(k) + b*log(vp)
% K and B are constants. y = rhob and x = Vp

function [c] = modgard(y,x)

% redefinitions:

x = log(x);
y = log(y);

sz = size(x);            % Tamanho do vetor x

uns = ones(sz);           % Vetor com dimensão sz, de elementos "1".

mat = [ uns x ];        % Matriz global

m_inv = inv(mat'*mat);    % Inversa da matriz global

B = mat'*y;               % Produto da inversa da matriz global com vetor
                          % de dados reais
c = m_inv*B;              % Cálculo dos coeficientes da aproximação

c = [exp(c(1,1)) c(2,1)];
