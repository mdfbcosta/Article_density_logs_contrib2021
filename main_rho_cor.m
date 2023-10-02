

clc, clear, close all

[filename1,filepath1]=uigetfile({'*.*','All Files'},...
  'Carregar arquivo');
  cd(filepath1);

 % Pegando o arquivo original
 
[datastr,data,colnames,header] = loadlas([filepath1 filename1]);

% ind_dt=find(strcmp(colnames,'dt'));
%  
% ind_cali=find(strcmp(colnames,'cali'));
%  
% ind_gr=find(strcmp(colnames,'gr'));
% 
% ind_rho=find(strcmp(colnames,'rhob'));

IndexC = strfind(colnames,'dt');
ind_dt = find(not(cellfun('isempty',IndexC)));

IndexC = strfind(colnames,'cal');
ind_cali = find(not(cellfun('isempty',IndexC)));

IndexC = strfind(colnames,'rhob');
ind_rho = find(not(cellfun('isempty',IndexC)));

IndexC = strfind(colnames,'gr');
ind_gr = find(not(cellfun('isempty',IndexC)));


dep = data(:,1); %Profundidade
 
cali = data(:,ind_cali); %Caliper
 
 GR = data(:,ind_gr); %Raio Gama
 
 rho = data(:,ind_rho); %Densidade
 
 dt = data(:,ind_dt); %Tempo de trânsito
 
 [dep,cali,GR,rho,dt]=well_filt(dep,cali,GR,rho,dt);
 
  %[rho_desp] = dispike(rho,0.3,50);
 
 vp=(0.3048*10^3)./dt; % Velocidade onda P (km/s)
 
%  rng(0,'twister');
%  
%  a = 1.1;
%  b = 1.3;
%  rho_mud = (b-a).*rand(length(rho),1) + a;
 
 rho_mud=1.3;
 
 rhocorr=rho;
 
 %Região de desmoronamento para o well 2
 %(inicial,final)=(1066:1166), gmudmax=0.3
 %(inicial,final)=(1218:1246), gmudmax=0.3
 
  %Região de desmoronamento para o well 4
 %(inicial,final)=(1:487), gmudmax=0.3
 %(inicial,final)=(1387:1687), gmudmax=0.3
 
 %Região de desmoronamento para o well 6
 %(inicial,final)=(477:977), gmudmax=0.3
 
 %Região de desmoronamento para o well 7
 %(inicial,final)=(801:961), gmudmax=0.2
 
 %Região de desmoronamento para o well 8
 %(inicial,final)=(5425:7425), gmudmax=0.3
 
 %[rhocorr(1066:1166)] = gmud_correction_reflec(dep(1066:1166), rho(1066:1166), vp(1066:1166), cali(1066:1166), rho_mud, 0.3, 0);

 %[rhocorr(1218:1246)] = gmud_correction_reflec(dep(1218:1246), rho(1218:1246), vp(1218:1246), cali(1218:1246), rho_mud, 0.3, 0);

  %[rhocorr(801:961)] = gmud_correction_reflec(dep(801:961), rho(801:961), vp(801:961), cali(801:961), rho_mud, 0.1, 0);
 
 %[rhocorr(477:977)] = gmud_correction_reflec(dep(477:977), rho(477:977), vp(477:977), cali(477:977), rho_mud, 0.3, 0);
 
 %[rhocorr] = gmud_correction_reflec(dep, rho, vp, cali, rho_mud, 0.3, 0);
 
 %[rhocorr(1:487)] = gmud_correction_reflec(dep(1:487), rho(1:487), vp(1:487), cali(1:487), rho_mud, 0.3, 0);
  
 %[rhocorr(1387:1687)] = gmud_correction_reflec(dep(1387:1687), rho(1387:1687), vp(1387:1687), cali(1387:1687), rho_mud, 0.2, 0);
%  

 [rhocorr(5425:7425)] = gmud_correction_reflec(dep(5425:7425), rho(5425:7425), vp(5425:7425), cali(5425:7425), rho_mud, 0.3, 0);

 %vp=(0.3048*10^6)./dt; % Velocidade onda P (m/s)
 
 %vp=(10^6)./dt; % Velocidade onda P (pé/s)
 
%% Ajuste Gardner 
 
%  Og = log(rho);
%  
%  P = log(vp);
%  
%  N = length(rho);
%  n=1;
%  p1 = p4(Og,P,n);
%  
% for j=1:N
%     aux = 0;
%     soma = 0;
%     
%     for i=1:n+1
%         aux = p1(i)*P(j)^(i-1);
%         soma= soma+ aux;
%     end
%     
%     yp(j) = soma;
% end

%figure(2)
%plot(P,Og,'*',P,yp)

%k = exp(p1(1))
%b = p1(2)

%rhoaju = k*vp.^(b);

%%

%Calculo do erro relativo


% errorel= zeros(N,1);
% 
% for i=1:N
% 
%     errorel(i) = (rho(i) - rhoaju(i))/rho(i);
%     
% end


% subplot(1,4,1)
% plot(rho,dep,rhoaju,dep,'r')
%  set(gca,'FontSize', 16);
%  xlabel('Density (g/cc)')
%  ylabel('Depth (feet)')
% xlim([min(rho) max(rho)])
%  ylim([min(dep) max(dep)])
%  set(gca,'YDir', 'reverse');
%  legend('Real Density','Calculated Density')
%  
%  subplot(1,4,2)
% plot(errorel,dep)
%  set(gca,'FontSize', 16);
%  xlabel('Relative error')
%  ylabel('Depth (feet)')
%  xlim([min(errorel) max(errorel)])
%  ylim([min(dep) max(dep)])
%  set(gca,'YDir', 'reverse');
%  
% 
%   subplot(1,4,3)
% plot(GR,dep)
%  set(gca,'FontSize', 16);
%  xlabel('GR (API)')
%  ylabel('Depth (feet)')
%  xlim([min(GR) max(GR)])
%  ylim([min(dep) max(dep)])
%  set(gca,'YDir', 'reverse');
%  
%  subplot(1,4,4)
% plot(cali,dep)
%  set(gca,'FontSize', 16);
%  xlabel('Caliper (In)')
%  ylabel('Depth (feet)')
%  xlim([min(cali) max(cali)])
%  ylim([min(dep) max(dep)])
%  set(gca,'YDir', 'reverse');
%  

subplot(1,3,1)
plot(rho,dep,rhocorr,dep)
 set(gca,'FontSize', 16);
 xlabel('Density (g/cc)')
 ylabel('Depth (feet)')
xlim([min(rho) max(rhocorr(:,1))])
 ylim([min(dep) max(dep)])
 set(gca,'YDir', 'reverse');
 legend('Real Density', 'Corrected density for rho_{mud}=1.3')

  subplot(1,3,2)
plot(GR,dep)
 set(gca,'FontSize', 16);
 xlabel('GR (API)')
 ylabel('Depth (feet)')
 xlim([min(GR) max(GR)])
 ylim([min(dep) max(dep)])
 set(gca,'YDir', 'reverse');
 
 subplot(1,3,3)
plot(cali,dep)
 set(gca,'FontSize', 16);
 xlabel('Caliper (In)')
 ylabel('Depth (feet)')
 xlim([min(cali) max(cali)])
 ylim([min(dep) max(dep)])
 set(gca,'YDir', 'reverse');
 
