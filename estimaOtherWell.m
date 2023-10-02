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
tipo_aprox = v_setting(2); % Equation of approximation
pwell      = v_setting(3); % Well-log for which we will get the parameters

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

if tipo_aprox == 1
    rhob_gn = param(icorr,1)*(vp + param(icorr,2)*vsh).^param(icorr,3);
elseif tipo_aprox == 2
    rhob_gn = param(icorr,1)*vp + param(icorr,2)*vsh + param(icorr,3);
elseif tipo_aprox == 3
    rhob_gn = param(icorr,1)*vp.^param(icorr,2);    
end

%re1 = (rhob1 - rhob)./rhob1   % Relative error: raw and correction  
re = (rhob - rhob_gn)./rhob;  % Relative error
rhob = nanbyzero(rhob);       % Replace NaN by zero
rhob_gn = nanbyzero(rhob_gn); % Replace NaN by zero
erro2 = immse(rhob,rhob_gn);  % Quadratic error
%erro2b = immse(rhob1,rhob);   % Quadratic error

figure(200)
 
subplot(1,5,1)
hold on
plot(rhob,dep,'r','LineWidth',1)
plot(rhob_gn,dep,'b','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
name1 = sprintf('Data Well%d',iwell)
name2 = sprintf('Calc Well%d',iwell)
legend(name1,name2,'Location','Best')
ylabel('Depth [m]')
xlabel('\rho_B [g/ccc]')
title('Bulk density')
set(gca,'FontSize',15)
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

subplot(1,5,2)
plot(re,dep,'g','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
set(gca,'YDir','reverse')
xlabel('R.E.')
set(gca,'YTick',[])
title('Relative Error')
set(gca,'FontSize',15)
annotation('textbox',[0.335 0.33 0.17 0.05],...
'String',['SME =',num2str(erro2)],'LineStyle','none',...
'FontSize',15,'FitBoxToText','off');
box off; grid on

name = sprintf('TEST WELL%d BY PARAMETERS OF REFERENCE WELL%d',iwell,pwell)
suptitle(name)

set(gcf,'PaperPositionMode','auto');    
set(gcf,'PaperOrientation','landscape');
set(gcf,'Position',[50 50 1400 1000]);

name = sprintf('Estimate_Well_%d_by_param_of_well_%d',iwell,pwell)
saveas(figure(200),name,'epsc')
