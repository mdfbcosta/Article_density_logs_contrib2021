function [gn] = actions_exe (v_setting)

ivsh       = v_setting(1); % Equation for Vsh
tipo_aprox = v_setting(2); % Equation of approximation
pwell      = v_setting(3); % Well-log for which we will get the parameters
                     
% Reading the files -----------------------------

dado = sprintf('dado%d.las',pwell);
[datastr,data,colnames,header] = loadlas(dado);

dep   = datastr.dept*0.3048;             % [m]
vp1   = (1./datastr.dt)*0.3048*1.e+3;    % [km/s]   -- raw data
rhob1 = datastr.rhob;                    % [g/ccc]  -- raw data
[vsh1]= calc_vsh(datastr.gr,ivsh);       % decimais -- raw data
cali  = datastr.cali*2.54;               % [cm]
nphi  = datastr.nphi/100;                % decimais
drho  = datastr.drho;                    % [g/ccc]
sp    = datastr.sp;                      % mV

plotperfis(pwell,dep,vp1,rhob1,vsh1,cali,nphi,drho,sp)

% Applied the dispike function on Vsh:
uiwait (msgbox({'...IN SHALE VOLUME    '},'SPIKE CORRECTION...'));
vsh2 = dispike('Dispike in Vsh',dep,vsh1);                % Spike corrected datas

% Applied the dispike on Vp:
uiwait (msgbox({'...IN WAVE P-VELOCITY '},'SPIKE CORRECTION...'));
vp2 = dispike('Dispike in Vp',dep,vp1);                   % Spike corrected datas

% Applied the dispike on RhoB:
uiwait (msgbox({'...IN BULK DENSITY    '},'SPIKE CORRECTION...'));
rhob2 = dispike('Dispike in Bulk Density',dep,rhob1);     % Spike corrected datas

for icorr = 1:3
    % Each loop considers one of the sets of corrections applied before the
    % apparent density approximation calculation.

    if icorr == 1;       % "Icorr = 1" is the correction only of the Spike
        
        rhob = rhob2;
        vsh  = vsh2 ;
        vp   = vp2  ;
        % Choice of region to calculate coefficients and calculation of
        % coefficients according to the chosen approximation.
        [LIM,rhob_gn,gn] = choicerange(dep,vp,vp1,rhob,rhob1,vsh,vsh1,cali,tipo_aprox,icorr)
        
    elseif icorr == 2;   % "Icorr = 2" are the raw datas
        
        rhob = rhob1;
        vsh  = vsh1 ;
        vp   = vp1  ;
        
    elseif icorr == 3    % "Icorr = 3" is the Spike and Caliper correction
        
        uiwait (msgbox({'CALIPER CORRECTION IN BULK DENSITY:'},'BOX INFORMATION'));        
        rhob = rhob2;
        vsh  = vsh2 ;
        vp   = vp2  ;
        % This function below applies the Caliper Correction        
        [rhob] = corr_cali2(dep,rhob,vp,cali);
        
    end

    % Select from each data profile only the ranges corresponding to the
    % interval chosen for the calculation of the parameters.

    vp_cut   = vp(LIM(1):LIM(2));      % [km/s]
    rhob_cut = rhob(LIM(1):LIM(2));    % [g/cm^3]
    vsh_cut  = vsh(LIM(1):LIM(2));     % decimal
    
    % Call the functions to do the approximation of the Bulk Density ------
    if icorr ~= 1
        if tipo_aprox == 1
            % Approximation for a no-linear equation
            [gn(icorr,:)] = gaunew (rhob_cut,vp_cut,vsh_cut);
            % Bulk density estimated with no-linear equation
            rhob_gn(:,icorr) = gn(icorr,1)*(vp + gn(icorr,2)*vsh).^gn(icorr,3);
        elseif tipo_aprox == 2
            % Approximation for a linear equation        
            [gn(icorr,:)] = modbir (rhob_cut,vp_cut,vsh_cut);
            % Bulk density estimated with first order equation        
            rhob_gn(:,icorr) = gn(icorr,1)*vp + gn(icorr,2)*vsh + gn(icorr,3);
        elseif tipo_aprox == 3
            % Approximation for a linear equation: Gardner
            [gn(icorr,:)] = modgard (rhob_cut,vp_cut);
            % Bulk density estimated with first order equation
            rhob_gn(:,icorr) = gn(icorr,1)*vp.^gn(icorr,2);
        end
    end
    
    % Relative error of the last estimative
    re(:,icorr) = (rhob - rhob_gn(:,icorr))./rhob;

    % Quadratic error of the estimative    
    erro2 = immse(rhob(LIM(1):LIM(2)),rhob_gn(LIM(1):LIM(2),icorr));
    
    %%
    % ---------------------------------------------------------------------
    % Creating the figures
    % ---------------------------------------------------------------------
    figure(100+icorr)
    ylimite = [dep(1) dep(length(dep))];

    subplot(1,3,1)
    hold on
    box off
    grid on
    plot(rhob1,dep,'k','LineWidth',1)
    if icorr ~= 2
        plot(rhob,dep,'LineWidth',1)
    end
    set(gca,'YDir','reverse')
    plot(rhob_gn(:,icorr),dep,'LineWidth',1)
    axis tight
    ylim(ylimite)
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    if icorr == 2
        legend('raw','est','Position','Best')
    else
        legend('raw','cor','est','Position','Best')
    end
    ylabel('Depth [m]')
    xlabel('\rho_B [g/ccc]')
    title('Bulk Density')

    subplot(1,3,2)
    plot(cali,dep,'LineWidth',1)
    axis tight
    ylim(ylimite)    
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    xlabel('Cali [cm]')
    title('Caliper')
    box off
    grid on

    subplot(1,3,3)
    plot(re(:,icorr),dep,'LineWidth',1)
    axis tight
    ylim(ylimite)    
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    xlabel('R.E. (\rho_B)')
    if icorr == 2
        title('Raw and Estimated')
    else
        title('Corrected and Estimated')
    end
    box off
    grid on
    if icorr == 1;
        suptitle('SPIKE CORRECTION')
        if tipo_aprox == 1
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...
           'String',['\rho_B = A(V_P + G V_{SH})^m'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...
           'FitBoxToText','off');
        elseif tipo_aprox == 2
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        elseif tipo_aprox == 3
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = k V_P^b'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        end
    elseif icorr == 2;
        suptitle('RAW DATAS')
        if tipo_aprox == 1
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = A(V_P + G V_{SH})^m'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...
           'FitBoxToText','off');
        elseif tipo_aprox == 2
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        elseif tipo_aprox == 3
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = k V_P^b'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        end
    elseif icorr == 3;
        suptitle('SPIKE AND CALIPER CORRECTION')
        if tipo_aprox == 1           
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...
           'String',['\rho_B = A(V_P + G V_{SH})^m'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...
           'FitBoxToText','off');
        elseif tipo_aprox == 2
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...            
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        elseif tipo_aprox == 3
           annotation('textbox',...
           [0.64 0.94 0.20 0.05],...
           'String',['\rho_B = k V_P^b'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...           
           'FitBoxToText','off');
        end        
    end
    set(gca,'FontSize',18)
    set(gcf,'PaperPositionMode','auto');  
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name = sprintf('Est_Rho_Erro%d%d%d',tipo_aprox,pwell,icorr)
    saveas(figure(100+icorr),name,'epsc')

    % Error figures
       
    figure(200)
    subplot(1,4,icorr)
    plot(re(:,icorr),dep,'LineWidth',1)
    axis tight
    xlabel('R.E. (\rho_B)')
    set(gca,'FontSize',18)
    if     icorr == 1; title('Dispike'); ylabel('Depth [m]')
    elseif icorr == 2; title('Raw Data')
    elseif icorr == 3; title('Dispi-Calip')
    end
    set(gca,'YDir','reverse')
    box off
    grid on
    da = [0.13 0.335 0.545];
    annotation('textbox',...
    [da(icorr) 0.33 0.17 0.05],...
    'String',['MSE =',num2str(erro2)],...
    'LineStyle','none',...
    'FontSize',15,...
    'FitBoxToText','off');

    subplot(1,4,4)
    hold on
    plot(abs(re(:,icorr)),dep,'LineWidth',1)
    axis tight
    xlabel('A.E. (\rho_B)')
    title('Absolute Error')
    set(gca,'YDir','reverse')
    legend('Disp','Raw','Disp-Cali','Position','Best')
    set(gca,'FontSize',18)
    box off
    grid on

%     if icorr == 3
%            suptitle('¨')
%         if tipo_aprox == 1
%            annotation('textbox',...
%            [0.40 0.94 0.20 0.05],...            
%            'String',['\rho_B = A(V_P + G V_{SH})^m'],...
%            'LineStyle','none',...
%            'FontSize',16,...
%            'FontWeight','bold',...
%            'FitBoxToText','off');
%         elseif tipo_aprox == 2
%            annotation('textbox',...
%            [0.40 0.94 0.20 0.05],...
%            'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
%            'LineStyle','none',...
%            'FontSize',16,...
%            'FontWeight','bold',...           
%            'FitBoxToText','off');
%         elseif tipo_aprox == 3
%            annotation('textbox',...
%            [0.40 0.94 0.20 0.05],...            
%            'String',['\rho_B = k V_P^b'],...
%            'LineStyle','none',...
%            'FontSize',16,...
%            'FontWeight','bold',...           
%            'FitBoxToText','off');
%         end
%     end

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);

    name200 = sprintf('Relative_and_Absolute_Erro%d%d',tipo_aprox,pwell)
    saveas(figure(200),name200,'epsc')

    % Parameters figure

    if icorr == 3
       figure(600)
       hold on
       if tipo_aprox == 3
           plot(gn(:,1),'o-k','LineWidth',2)
           plot(gn(:,2),'o-r','LineWidth',2)
       else
           plot(gn(:,1),'o-k','LineWidth',2)
           plot(gn(:,2),'o-r','LineWidth',2)
           plot(gn(:,3),'o-b','LineWidth',2)
       end
       xticks([1 2 3])
       xticklabels({'Dispike','Raw','Disp-Cali'})
       if tipo_aprox == 1
           legend('A','G','m')
           annotation('textbox',...
           [0.38 0.46 0.46 0.08],...
           'String',['\rho_B = A (V_P + G V_{SH})^m'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...                      
           'FitBoxToText','off');
       elseif tipo_aprox == 2
           legend('Q','Z','P')
           annotation('textbox',...
           [0.38 0.46 0.46 0.08],...
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...                      
           'FitBoxToText','off');
       elseif tipo_aprox == 3
           legend('k','b')
           annotation('textbox',...
           [0.38 0.46 0.46 0.08],...
           'String',['\rho_B = k V_P^b'],...
           'LineStyle','none',...
           'FontSize',16,...
           'FontWeight','bold',...                      
           'FitBoxToText','off');           
       end
       grid on
       box off
       ylabel('Parameters')
       set(gca,'FontSize',18,'LineWidth',2)
       title('CORRECTION PARAMETERS')
       
       set(gcf,'PaperPositionMode','auto');         
       set(gcf,'PaperOrientation','landscape');
       set(gcf,'Position',[50 50 700 500]);
       saveas(figure(600),'Parameters','epsc')
       
    end

end % icorr = 1:3
