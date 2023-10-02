function [c] = modbir (y,x1,x2)

% Mínimos quadrados para aproximação de 1ª ordem:
%                y = a x1 + b x2 + c
%              rho = Q Vp + Z Vsh + P
% Neste caso a equação de aproximação de Linear.
% y : vetor dos dados reais, o que se quer estimar
% x1: vetor de dados usado fazer a aproximação (Vp)
% x2: vetor de dados usado fazer a aproximação (Vsh)
% c: vetor dos coeficientes da aproximação

if length(x1) ~= length(x2)
    disp('Dimensões dos vetores da aproximação de 1ª ordem são diferentes')
end

sz = size(x1);            % Tamanho do vetor x

uns = ones(sz);           % Vetor com dimensão sz, de elementos "1".

mat = [ x1 x2 uns ];      % Matriz global

m_inv = inv(mat'*mat);    % Inversa da matriz global

B = mat'*y;               % Produto da inversa da matriz global com vetor
                          % de dados reais
c = m_inv*B;              % Cálculo dos coeficientes da aproximação

c = c';