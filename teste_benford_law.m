function [MAD] = teste_benford_law(x)

%calcular o primeiro digito do dado de entrada
x = double(x(:));
%tirar modulo e excluir infinitos e NaN
ax = abs(x(x~=0 & not(isinf(x)) & not(isnan(x))));
%calcular qual é o primeiro digito
first_digit = floor(ax./(10.^floor(log10(ax))));
%numero de ocorrencia de cada digito
data_norm_occ = histc(first_digit,1:9);   
data_norm_occ = data_norm_occ./sum(data_norm_occ);
%numero de ocorrencia de acordo com a distribuição de benford -> referencia
benford_norm_occ = log10(1 + (1./(1:9)))';

% Calculo do desvio absoluto médio entre a ocorrencia do dado e a
% ocorrencia da lei de benford
MAD = mean(abs(data_norm_occ - benford_norm_occ))

% Limites para o grau de conformidade com a lei de benford (exemplo)
madClose = 0.006;      % limite para conformidade próxima
madAcceptable = 0.012; % limite superior da conformidade aceitável
madMarginally = 0.015; % limite inferior da conformidade aceitável


%% Plot da distribuição de benford e da distribuição do dado
both = [benford_norm_occ, data_norm_occ];
%subplot(2,2,2);
figure(1);
hold on;
bar(both);
set(gca,'fontweight','bold','fontsize',28);
xlabel('First Digit','fontweight','bold','fontsize',28);
ylabel('Frequency (%)','fontweight','bold','fontsize',28);
legend('Distribution according to Benford Law', 'Distribution for the data');
xlabel(sprintf('The Mean Absolute Deviation from Benford Law is = %g',MAD),'fontweight','bold','fontsize',18);


figure(2)
hold on
%plot(benford_norm_occ,'k-*','linewidth',4)
bar(benford_norm_occ);colormap(winter)
plot(data_norm_occ,'k-*','linewidth',4)
set(gca,'fontweight','bold','fontsize',28);
legend('Distribution according to Benford Law', 'Distribution of the data');
set(gca,'fontsize',18);
xlabel('First Digit','fontweight','bold','fontsize',28);
ylabel('Frequency (%)','fontweight','bold','fontsize',28);
xlabel(sprintf('The Mean Absolute Deviation from Benford Law is = %g',MAD),'fontweight','bold','fontsize',18);

%figure(2)
%hold on
%%plot(benford_norm_occ,'ko-','linewidth',2)
%bar(data_norm_occ,'stacked'), colormap(winter)
%plot(benford_norm_occ,'ko-','linewidth',2)

if (MAD <= madClose)
    disp('[CLOSE CONFORMITY]');
    grau_conform = 1;
elseif (MAD <= madAcceptable)    
    disp('[ACCEPTABLE CONFORMITY]');
    grau_conform = 2;
elseif (MAD <= madMarginally)
    disp('[MARGINAL CONFORMITY]');
    grau_conform = 3;
else
    disp('[NON CONFORMITY]');
    grau_conform = 4;
end

end
