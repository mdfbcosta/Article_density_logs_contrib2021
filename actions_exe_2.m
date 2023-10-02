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

% This function plot all the profile of data.
plotperfis(pwell,dep,vp1,rhob1,vsh1,cali,nphi,drho,sp)

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
    
    if quest == 2
        vsh2 = dispike('Dispike in Vsh',dep,vsh1);  % Spike corrected datas
    else
        vsh2 = vsh1;
    end
    
end % final of while

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
    
    if quest == 2
        vp2 = dispike('Dispike in Vp',dep,vp1);     % Spike corrected datas
    else
        vp2 = vp1  ;        
    end
    
end % final of while

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
    
    if quest == 2
        rhob2 = dispike('Dispike in Bulk Density',dep,rhob1);     % Spike corrected datas
    else
        rhob2 = rhob1;
    end
    
end % final of while

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

            if quest == 2
                rhob = rhob2;
                vsh  = vsh2 ;
                vp   = vp2  ;
                % This function applies the Caliper Correction        
                [rhob] = corr_cali2(dep,rhob,vp,cali);
            end

        end % final of while
        
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

    re(:,icorr) = (rhob - rhob_gn(:,icorr))./rhob;     % Relative error
    erro2 = immse(rhob(LIM(1):LIM(2)),rhob_gn(LIM(1):LIM(2),icorr));     % Media Quadratic error
    
    %%
    % ---------------------------------------------------------------------
    % Creating the figures
    % ---------------------------------------------------------------------
    figure(100)
    ylimite = [dep(1) dep(length(dep))];

    if icorr == 1
        subplot(1,4,2)
        hold on; box off; grid on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob,dep,'r','LineWidth',1)
        set(gca,'YDir','reverse')
        plot(rhob_gn(:,icorr),dep,'b','LineWidth',1)
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        legend('raw','cor','cal','Position','Best')
        set(gca,'YTick',[])
        xlabel('\rho_B [g/ccc]')
        title('Spike Corr')
    elseif icorr == 2
        subplot(1,4,1)
        hold on; box off; grid on
        plot(rhob1,dep,'k','LineWidth',1)
        set(gca,'YDir','reverse')
        plot(rhob_gn(:,icorr),dep,'b','LineWidth',1)
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        legend('raw','cal','Position','Best')
        ylabel('Depth [m]')
        xlabel('\rho_B [g/ccc]')
        title('None Corr')
    else
        subplot(1,4,3)
        hold on; box off; grid on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob,dep,'r','LineWidth',1)
        set(gca,'YDir','reverse')
        plot(rhob_gn(:,icorr),dep,'b','LineWidth',1)
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        legend('raw','cor','cal','Position','Best')
        set(gca,'YTick',[])
        xlabel('\rho_B [g/ccc]')
        title('Spike-Cali Corr')
        
        subplot(1,4,4)
        box off; grid on
        plot(cali,dep,'k','LineWidth',1)
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        xlabel('Cali [cm]')
        set(gca,'YTick',[])        
        title('Caliper')

        suptitle('BULK DENSITY (CALCULATED AND CORRECTED)')

        if tipo_aprox == 1
           annotation('textbox',[0.685 0.934 0.257 0.064],...
           'String',['\rho_B = A(V_P + G V_{SH})^m'],'LineStyle','none',...
           'FontSize',14,'FontWeight','bold','FitBoxToText','off');
        elseif tipo_aprox == 2
           annotation('textbox',[0.685 0.934 0.257 0.064],...            
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],'LineStyle','none',...
           'FontSize',14,'FontWeight','bold','FitBoxToText','off');
        elseif tipo_aprox == 3
           annotation('textbox',[0.685 0.934 0.257 0.064],...            
           'String',['\rho_B = k V_P^b'],'LineStyle','none',...
           'FontSize',14,'FontWeight','bold','FitBoxToText','off');
        end
        
    end

    set(gca,'FontSize',18)
    set(gcf,'PaperPositionMode','auto');  
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name = sprintf('Density_cal_cor-TypeOfEq%d-WellRef%d',tipo_aprox,pwell)
    saveas(figure(100),name,'epsc')

    % Error figures
    
    figure(200)
    if icorr == 1
        subplot(1,4,2)
        box off; grid on
        plot(re(:,icorr),dep,'b','LineWidth',1)
        axis tight
        xlabel('R.E. (decimal)')
        set(gca,'YTick',[])
        set(gca,'FontSize',15)
        title('Spike Corr')
        set(gca,'YDir','reverse')
        da = [0.13 0.335 0.545];
        annotation('textbox',[da(icorr+1) 0.33 0.17 0.05],...
        'String',['SME =',num2str(erro2)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');

        subplot(1,4,4)
        hold on; box off; grid on
        plot(abs(re(:,icorr)),dep,'b','LineWidth',1)
        axis tight
        xlabel('A.E. (decimal)')
        title('Absolute Error')
        set(gca,'YDir','reverse')
        %legend('Raw','Disp','Disp-Cali','Position','Best')
        set(gca,'FontSize',15)
        
    elseif icorr == 2
        subplot(1,4,1)
        box off; grid on
        plot(re(:,icorr),dep,'r','LineWidth',1)
        axis tight
        xlabel('R.E. (decimal)')
        ylabel('Depth [m]')
        set(gca,'FontSize',15)
        title('None Corr')
        set(gca,'YDir','reverse')
        da = [0.13 0.335 0.545];
        annotation('textbox',[da(icorr-1) 0.33 0.17 0.05],...
        'String',['SME =',num2str(erro2)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');

        subplot(1,4,4)
        hold on; box off; grid on
        plot(abs(re(:,icorr)),dep,'r','LineWidth',1)
        axis tight
        xlabel('A.E. (decimal)')
        title('Absolute Error')
        set(gca,'YDir','reverse')
        %legend('Raw','Disp','Disp-Cali','Position','Best')
        set(gca,'FontSize',15)
        
    else
        subplot(1,4,3)
        box off; grid on        
        plot(re(:,icorr),dep,'g','LineWidth',1)
        axis tight
        xlabel('R.E. (decimal)')
        set(gca,'YTick',[])        
        set(gca,'FontSize',15)
        title('Spike-Cali Corr')
        set(gca,'YDir','reverse')
        da = [0.13 0.335 0.545];
        annotation('textbox',[da(icorr) 0.33 0.17 0.05],...
        'String',['SME =',num2str(erro2)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
    
        subplot(1,4,4)
        hold on; box off; grid on
        plot(abs(re(:,icorr)),dep,'g','LineWidth',1)
        axis tight
        xlabel('A.E. (decimal)')
        title('Absolute Error')
        set(gca,'YDir','reverse')
        %legend('Raw','Disp','Disp-Cali','Position','Best')
        set(gca,'FontSize',15)
        
        suptitle('RELATIVE, ABSOLUTE AND QUADRATIC ERROR (CALCULATED AND CORRECTED DENSITY)')

        if tipo_aprox == 1
           annotation('textbox',[0.804 0.533 0.257 0.063],...
           'String',['\rho_B = A(V_P + G V_{SH})^m'],'LineStyle','none',...
           'FontSize',14,'FitBoxToText','off');
        elseif tipo_aprox == 2
           annotation('textbox',[0.804 0.533 0.257 0.063],...            
           'String',['\rho_B = Q V_P + Z V_{SH} + P'],'LineStyle','none',...
           'FontSize',14,'FitBoxToText','off');
        elseif tipo_aprox == 3
           annotation('textbox',[0.804 0.533 0.257 0.063],...            
           'String',['\rho_B = k V_P^b'],'LineStyle','none',...
           'FontSize',14,'FitBoxToText','off');
        end
        
    end

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name200 = sprintf('RE_ABS_SME_Error-TypeOfEq%d-WellRef%d',tipo_aprox,pwell)
    saveas(figure(200),name200,'epsc')

    % Parameters figure

    if icorr == 3
       figure(300)
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
       name300 = sprintf('Parameters-TypeOfEq%d-WellRef%d',tipo_aprox,pwell)       
       saveas(figure(300),name300,'epsc')
       
    end

end % icorr = 1:3
