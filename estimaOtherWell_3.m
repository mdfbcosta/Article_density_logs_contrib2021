close all

% ===== INSTRUCTIONS ======================================================
% This code do the stimative of test-wells. You need to run the Dashboard
% code before to run this program because this program need of some datas
% generated previously.
% =========================================================================

%xx = inputdlg({'Choose your parameters. 1 for spike correction, 2 for raw data and 3 for spike-caliper correction'},'Ask Box', [1 50]);
%icorr = str2num(xx{1}); % Here you choose the better approch that you got.
icorr = 3;

%param = [1.64 0.25; 1.64 0.25; 1.64 0.25];
%param = [1.35 1.651 0.39; 1.35 1.651 0.39; 1.35 1.651 0.39];
%tipo_aprox = 1;

ivsh       = v_setting(1); % Equation for Vsh
%tipo_aprox = v_setting(2); % Equation of approximation
pwell      = v_setting(2); % Well-log for which we will get the parameters

x = inputdlg('Enter index of Test Well.','Ask Box', [1 50]);
iwell = str2num(x{1});

file = sprintf('dado%d.las',iwell);
[datastr,data,colnames,header] = loadlas(file);

dep  = datastr.dept*0.3048;          % [m]
vp   = (1./datastr.dt)*0.3048*1.e+3; % [Km/s]
rhob = datastr.rhob;                 % [g/ccc] 
[vsh]= calc_vsh(datastr.gr,ivsh);    % decimais
cali = datastr.cali*2.54;            % [cm]

figure(1)
box off; grid on
plot(rhob,dep,'k','LineWidth',1)
ylim([dep(1) dep(length(dep))])
xlabel('\rho_B [g/ccc]')
ylabel('Depth [m]')
title('[!] Choose the region for Well test')
set(gca,'YDir','reverse')
set(gca,'FontSize',18)

set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'Position',[50 50 700 1000]);

[y lim] = ginput(2);
[LIM] = cutlog(lim(1),lim(2),dep); % Select the range analysed of the Well
dep   = dep(LIM(1):LIM(2));      % [m]
vp    = vp(LIM(1):LIM(2));       % [km/s]
rhob  = rhob(LIM(1):LIM(2));     % [g/cm^3]
vsh   = vsh(LIM(1):LIM(2));      % decimal
cali  = cali(LIM(1):LIM(2));     % [cm]

close

% --------------------------------------------
% Spike correction on rhoB, Vp and Vsh:
% --------------------------------------------

% Apply or not the dispike function on Vsh
quest = 1;
while quest == 1
  
    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'=== QUESTION ===','','Vsh: Apply Dispike?'}, ...
        'Checkbox', ...
        'Yes','No','Yes');

    % Handle response
    switch answer
        case 'Yes'
            quest = 2;
        case 'No'
            quest = 0;
    end
    
    if quest ==2
        vsh = dispike('Dispike in Vsh',dep,vsh);  % Spike corrected datas
    end
    
end % final of while

% Apply or not the dispike function on Vp
quest = 1;
while quest == 1
  
    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'=== QUESTION ===','','Vp: Apply Dispike?'}, ...
        'Checkbox', ...
        'Yes','No','Yes');

    % Handle response
    switch answer
        case 'Yes'
            quest = 2;
        case 'No'
            quest = 0;
    end
    
    if quest ==2
        vp = dispike('Dispike in Vp',dep,vp);     % Spike corrected datas
    end
    
end % final of while

% Apply or not the dispike function on rhoB
quest = 1;
while quest == 1
  
    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'=== QUESTION ===','','RhoB: Apply Dispike?'}, ...
        'Checkbox', ...
        'Yes','No','Yes');

    % Handle response
    switch answer
        case 'Yes'
            quest = 2;
        case 'No'
            quest = 0;
    end
    
    if quest ==2
        rhob = dispike('Dispike in Bulk Density',dep,rhob);     % Spike corrected datas
    end
    
end % final of while

% Caliper Correction on RhoB
quest = 1;
while quest == 1

    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'=== QUESTION ===','','RhoB: Apply Caliper Correction?'}, ...
        'Checkbox', ...
        'Yes','No','Yes');

    % Handle response
    switch answer
        case 'Yes'
            quest = 2;
        case 'No'
            quest = 0;
    end

    if quest ==2
        % This function applies the Caliper Correction        
        [rhob] = corr_cali2(dep,rhob,vp,cali);
    end
    
end % final of while

rhob_nl = parametros.nl(icorr,1)*(vp + parametros.nl(icorr,2)*vsh).^parametros.nl(icorr,3);
rhob_li = parametros.li(icorr,1)*vp + parametros.li(icorr,2)*vsh + parametros.li(icorr,3);
rhob_ga = parametros.ga(icorr,1)*vp.^parametros.ga(icorr,2);

re_nl = (rhob - rhob_nl)./rhob;  % Relative error
re_li = (rhob - rhob_li)./rhob;  % Relative error
re_ga = (rhob - rhob_ga)./rhob;  % Relative error

rhob = nanbyzero(rhob);          % Replace NaN by zero
rhob_nl = nanbyzero(rhob_nl);    % Replace NaN by zero
rhob_li = nanbyzero(rhob_li);    % Replace NaN by zero
rhob_ga = nanbyzero(rhob_ga);    % Replace NaN by zero

erro2_nl = immse(rhob,rhob_nl);  % Quadratic error
erro2_li = immse(rhob,rhob_li);  % Quadratic error
erro2_ga = immse(rhob,rhob_ga);  % Quadratic error

figure(200)

subplot(1,5,1)
hold on
plot(rhob,dep,'r','LineWidth',1)
%plot(rhob_nl,dep,'b','LineWidth',2,'color',[0.00 0.00 1.00])
plot(rhob_li,dep,'b','LineWidth',2,'color',[0.19 0.80 0.19])
plot(rhob_ga,dep,'b','LineWidth',2,'color',[1.00 0.54 0.00])
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
name1 = sprintf('Data Well%d',iwell)
legend(name1,'\rho_B^{(li)} = Q Vp + Z Vsh + P','\rho_B^{(ga)} = k {Vp}^b','Location','Best')
set(legend,'Position',[0.016 0.83 0.18 0.14]);
ylabel('Depth [m]')
xlabel('\rho_B [g/ccc]')
title('Bulk density')
set(gca,'FontSize',15)
box off; grid on

subplot(1,5,2)
hold on
%plot(re_nl,dep,'LineWidth',2,'color',[0.00 0.00 1.00])
plot(re_li,dep,'LineWidth',2,'color',[0.19 0.80 0.19])
plot(re_ga,dep,'LineWidth',2,'color',[1.00 0.54 0.00])
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
xlabel('A.E.')
set(gca,'YTick',[])
title('Absolute Error')
set(gca,'FontSize',15)
% annotation('textbox',[0.30 0.38 0.17 0.05],...
% 'String',['SME =',num2str(erro2_nl)],'LineStyle','none',...
% 'FontSize',15,'FitBoxToText','off');
annotation('textbox',[0.30 0.33 0.17 0.05],...
'String',['SME(li) :',num2str(erro2_li)],'LineStyle','none',...
'FontSize',15,'FitBoxToText','off');
annotation('textbox',[0.30 0.28 0.17 0.05],...
'String',['SME(ga):',num2str(erro2_ga)],'LineStyle','none',...
'FontSize',15,'FitBoxToText','off');
box off; grid on

subplot(1,5,3)
plot(vp,dep,'r','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
xlabel('Vp [km/s]')
set(gca,'YTick',[])
title('P-wave Vel.')
set(gca,'FontSize',15)
box off; grid on

subplot(1,5,4)
plot(vsh,dep,'r','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
xlabel('Vsh (decimal)')
set(gca,'YTick',[])
title('Shale Vol.')
set(gca,'FontSize',15)
box off; grid on

subplot(1,5,5)
plot(cali,dep,'r','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('Cal [cm]')
set(gca,'YTick',[])
set(gca,'YDir','reverse')
title('Caliper')
set(gca,'FontSize',15)
box off; grid on

name = sprintf('TEST WELL%d BY PARAMETERS OF REFERENCE WELL%d',iwell,pwell)
suptitle(name)

set(gcf,'PaperPositionMode','auto');    
set(gcf,'PaperOrientation','landscape');
set(gcf,'Position',[50 50 1400 1000]);

name = sprintf('Estimate_Well_%d_by_param_of_well_%d',iwell,pwell)
saveas(figure(200),name,'epsc')
