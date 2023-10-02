function [erro2] = estimaOtherWells (gn,i,ivsh,jj)

% gn   --> parametros estimados
% i    --> indice do poço para ser estimado
% ivsh --> indice para escolha de qual aproximação fazer para o Vsh
% jj   --> indice para saber qual aproximação usar para estimar rho: linear ou não linear

% ------------------------------------------------------------------
%  Estimation of bulk density of other wells by the calculated
%  parameters for the current well.
% ------------------------------------------------------------------

file = sprintf('dado%d.las',i);
[datastr,data,colnames,header] = loadlas(file);

dep  = datastr.dept*0.3048;
vp   = (1./datastr.dt)*0.3048*1.e+3;
rhob1 = datastr.rhob;
[vsh]= calc_vsh(datastr.gr,ivsh);
cali = datastr.cali*2.54;

% -------------------------------
% Correction in the bulk density:
% -------------------------------
% Dispike
rhob = dispike(rhob1,0.5,100);
% Caliper Correction
[rhob] = corr_cali(dep,rhob,vp,cali);

if jj == 1
    % Bulk density estimated with no-linear equation
    rhob_gn = gn(1)*(vp + gn(2)*vsh).^gn(3);
elseif jj == 2
    % Bulk density estimated with linear equation
    rhob_gn = gn(1)*vp + gn(2)*vsh + gn(3);
end

% Relative error of the last estimative
re = (rhob - rhob_gn)./rhob;

figure(200)
 
subplot(1,4,1)
hold on
box off
grid on
plot(rhob1,dep,'k','LineWidth',1)
set(gca,'YDir','reverse')
plot(rhob,dep,'LineWidth',1)
set(gca,'YDir','reverse')
plot(rhob_gn,dep,'LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
set(gca,'FontSize',18)
legend('\rho_{real}','\rho_{corr}','\rho_{esti}','Orientation','horizontal','Location','Best')
ylabel('Depth [m]')
xlabel('\rho_B [g/cm3]')
 
subplot(1,4,2)
plot(re,dep,'LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
set(gca,'FontSize',18)
xlabel('R.E [g/cm3]')
box off
grid on

subplot(1,4,3)
plot(vsh,dep,'LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('Vsh (decimal)')
set(gca,'YDir','reverse')
set(gca,'FontSize',18)
box off
grid on

subplot(1,4,4)
plot(cali,dep,'LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('Caliper [cm]')
set(gca,'YDir','reverse')
set(gca,'FontSize',18)
box off
grid on

name = sprintf('Estimated Bulk Density to the Well %d',i);
suptitle(name)

set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'Position',[50 50 1400 1000]);

%erro2 = immse(rhob,rhob_gn);

N = length(rhob);
erro = rhob - rhob_gn;
erro2 = sum(erro.*erro)/N;
