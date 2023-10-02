function [parametros] = actions_exe (v_setting)

ivsh       = v_setting(1); % Equation for Vsh
pwell      = v_setting(2); % Well-log for which we will get the parameters
                     
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

% Select the region where have data in all profile.
[LIM] = fullrange (pwell,dep,vp1,rhob1,vsh1,cali,nphi)

dep   = dep(LIM(1):LIM(2));
vp1   = vp1(LIM(1):LIM(2)); 
rhob1 = rhob1(LIM(1):LIM(2));
vsh1  = vsh1(LIM(1):LIM(2));
cali  = cali(LIM(1):LIM(2));

%% ------------------------------------------------------------------------
% Application of the dispike function
% -------------------------------------------------------------------------

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
end

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
end

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
end

%% ------------------------------------------------------------------------
% Each next loop considers one of the sets of corrections applied before of the
% calculated Bulk Density.
% -------------------------------------------------------------------------
  
for icorr = 1:3

    if icorr == 1;       % "Icorr = 1" are the raw datas
        rhob = rhob1;
        vsh  = vsh1;
        vp   = vp1;
    elseif icorr == 2;   % "Icorr = 2" is the correction only of the Spike
        rhob = rhob2;
        vsh  = vsh2;
        vp   = vp2;
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

    %% --------------------------------------------------------------------
    % Choice of region to calculate coefficients and calculation of
    % coefficients according to the chosen approximation.
    % ---------------------------------------------------------------------

    if icorr == 1
        [LIM] = regi_estim (dep,vp1,rhob1,vsh1,cali)
    end
    vp_cut   = vp(LIM(1):LIM(2));      % [km/s]
    rhob_cut = rhob(LIM(1):LIM(2));    % [g/cm^3]
    vsh_cut  = vsh(LIM(1):LIM(2));     % decimal
    
    %% Bulk Density calculation -------------------------------------------

    % Approximation no-linear equation

    [nl(icorr,:)] = gaunew (rhob_cut,vp_cut,vsh_cut);
    parametros.nl(icorr,:) = nl(icorr,:);
    % Calculated Bulk density
    rhob_nl(:,icorr) = nl(icorr,1)*(vp + nl(icorr,2)*vsh).^nl(icorr,3);
    % Relative error
    re_nl(:,icorr) = (rhob - rhob_nl(:,icorr))./rhob;
    % Media Quadratic error
    erro2_nl = immse(rhob(LIM(1):LIM(2)),rhob_nl(LIM(1):LIM(2),icorr));

    % Approximation linear equation

    [li(icorr,:)] = modbir (rhob_cut,vp_cut,vsh_cut);
    parametros.li(icorr,:) = li(icorr,:);
    % Calculated Bulk density
    rhob_li(:,icorr) = li(icorr,1)*vp + li(icorr,2)*vsh + li(icorr,3);
    % Relative error
    re_li(:,icorr) = (rhob - rhob_li(:,icorr))./rhob;
    % Media Quadratic error
    erro2_li = immse(rhob(LIM(1):LIM(2)),rhob_li(LIM(1):LIM(2),icorr));

    % Approximation linear equation: Gardner

    [ga(icorr,:)] = modgard (rhob_cut,vp_cut);
    parametros.ga(icorr,:) = ga(icorr,:);
    % Calculated Bulk density
    rhob_ga(:,icorr) = ga(icorr,1)*vp.^ga(icorr,2);
    % Relative error
    re_ga(:,icorr) = (rhob - rhob_ga(:,icorr))./rhob;
    % Media Quadratic error
    erro2_ga = immse(rhob(LIM(1):LIM(2)),rhob_ga(LIM(1):LIM(2),icorr));

    % ---------------------------------------------------------------------
    % Creating the figures
    % ---------------------------------------------------------------------
    figure(100)
    ylimite = [dep(1) dep(length(dep))];
    
    if icorr == 1
        subplot(1,5,1)
        hold on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob_nl(:,icorr),dep,'LineWidth',2,'color',[0.00 0.00 1.00])
        plot(rhob_li(:,icorr),dep,'LineWidth',2,'color',[0.19 0.80 0.19])
        plot(rhob_ga(:,icorr),dep,'LineWidth',2,'color',[1.00 0.54 0.00])
        set(gca,'YDir','reverse')
        axis tight
        ylim(ylimite)
        set(gca,'FontSize',15)
        ylabel('Depth [m]')
        xlabel('\rho_B [g/ccc]')
        title('None Corr')
        box off; grid on
    elseif icorr == 2
        subplot(1,5,2)
        hold on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob,dep,'r','LineWidth',1)
        plot(rhob_nl(:,icorr),dep,'LineWidth',2,'color',[0.00 0.00 1.00])
        plot(rhob_li(:,icorr),dep,'LineWidth',2,'color',[0.19 0.80 0.19])
        plot(rhob_ga(:,icorr),dep,'LineWidth',2,'color',[1.00 0.54 0.00])
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',15)
        set(gca,'YTick',[])
        xlabel('\rho_B [g/ccc]')
        title('Spike Corr')
        box off; grid on
    else
        subplot(1,5,3)
        hold on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob,dep,'r','LineWidth',1)
        plot(rhob_nl(:,icorr),dep,'LineWidth',2,'color',[0.00 0.00 1.00])
        plot(rhob_li(:,icorr),dep,'LineWidth',2,'color',[0.19 0.80 0.19])
        plot(rhob_ga(:,icorr),dep,'LineWidth',2,'color',[1.00 0.54 0.00])
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',15)
        legend('Raw Data','Corrected Data','\rho_B = A(V_P + G V_{SH})^m',...
            '\rho_B = Q V_P + Z V_{SH} + P','\rho_B = k V_P^b')
        set(legend,'Position',[0.782 0.655 0.185 0.227]);
        title(legend,'TYPE OF EQUATION');
        set(gca,'YTick',[])
        xlabel('\rho_B [g/ccc]')
        title('Spike-Cali Corr')
        box off; grid on
        
        subplot(1,5,4)
        plot(cali,dep,'k','LineWidth',1)
        axis tight
        ylim(ylimite)
        set(gca,'YDir','reverse')
        set(gca,'FontSize',15)
        xlabel('Cali [cm]')
        set(gca,'YTick',[])        
        title('Caliper')
        box off; grid on
        
        suptitle('BULK DENSITY')
    
    end

    set(gcf,'PaperPositionMode','auto');  
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name = sprintf('Density_cal_cor-WellRef%d',pwell)
    saveas(figure(100),name,'epsc')

    %==============
    % Error figures
    %==============
    
    % Comparison Error Calculation    
    figure(200)
    if icorr == 1
        subplot(1,4,1)
        hold on
        plot(abs(re_nl(:,icorr)),dep,'LineWidth',1,'color',[0.00 0.00 1.00])        
        plot(abs(re_li(:,icorr)),dep,'LineWidth',1,'color',[0.19 0.80 0.19])
        plot(abs(re_ga(:,icorr)),dep,'LineWidth',1,'color',[1.00 0.54 0.00])        
        axis tight
        xlabel('A.E. (decimal)')
        ylabel('Depth [m]')
        set(gca,'FontSize',15)
        title('None Corr')
        set(gca,'YDir','reverse')
        annotation('textbox',[0.13 0.39 0.20 0.04],...
        'String',['SME(nl):',num2str(erro2_nl)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.13 0.32 0.20 0.05],...
        'String',['SME(li) :',num2str(erro2_li)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.13 0.25 0.20 0.05],...
        'String',['SME(ga):',num2str(erro2_ga)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');    
        box off; grid on
    elseif icorr == 2
        subplot(1,4,2)
        hold on
        plot(abs(re_nl(:,icorr)),dep,'LineWidth',1,'color',[0.00 0.00 1.00])        
        plot(abs(re_li(:,icorr)),dep,'LineWidth',1,'color',[0.19 0.80 0.19])
        plot(abs(re_ga(:,icorr)),dep,'LineWidth',1,'color',[1.00 0.54 0.00])
        axis tight
        xlabel('A.E. (decimal)')
        set(gca,'YTick',[])
        set(gca,'FontSize',15)
        title('Spike Corr')
        set(gca,'YDir','reverse')
        annotation('textbox',[0.335 0.39 0.20 0.05],...
        'String',['SME(nl):',num2str(erro2_nl)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.335 0.32 0.20 0.05],...
        'String',['SME(li) :',num2str(erro2_li)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.335 0.25 0.20 0.05],...
        'String',['SME(ga):',num2str(erro2_ga)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');    
        box off; grid on
    else
        subplot(1,4,3)
        hold on
        plot(abs(re_nl(:,icorr)),dep,'LineWidth',1,'color',[0.00 0.00 1.00])        
        plot(abs(re_li(:,icorr)),dep,'LineWidth',1,'color',[0.19 0.80 0.19])
        plot(abs(re_ga(:,icorr)),dep,'LineWidth',1,'color',[1.00 0.54 0.00])
        legend('\rho_B^{(nl)} = A(V_P + G V_{SH})^m','\rho_B^{(li)} = Q V_P + Z V_{SH} + P','\rho_B^{(ga)} = k V_P^b')
        set(legend,'Position',[0.782 0.655 0.185 0.227]);
        title(legend,'TYPE OF EQUATION');
        axis tight
        xlabel('A.E. (decimal)')
        set(gca,'YTick',[])        
        set(gca,'FontSize',15)
        title('Spike-Cali Corr')
        set(gca,'YDir','reverse')
        annotation('textbox',[0.545 0.39 0.20 0.05],...
        'String',['SME(nl):',num2str(erro2_nl)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.545 0.32 0.20 0.05],...
        'String',['SME(li) :',num2str(erro2_li)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');
        annotation('textbox',[0.545 0.25 0.20 0.05],...
        'String',['SME(ga):',num2str(erro2_ga)],'LineStyle','none',...
        'FontSize',15,'FitBoxToText','off');    
        box off; grid on
        
        suptitle('COMPARISON BETWEEN ERRORS OF THE APPLIED APPROACH TYPE')

    end

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name200 = sprintf('Error-Calc-WellRef%d',pwell)
    saveas(figure(200),name200,'epsc')   

    % Comparison Error Correction
    cc = [1.00 0.00 0.00; 0.00 1.00 0.00; 0.00 0.00 1.00];
    
    figure(201)

    subplot(1,3,1)
    hold on
    plot(abs(re_nl(:,icorr)),dep,'LineWidth',1,'color',cc(icorr,:))
    legend('None Corr','Spike Corr','Spike-Cali Corr') 
    axis tight
    xlabel('A.E. (decimal)')
    ylabel('Depth [m]')
    set(gca,'FontSize',15)
    title('\rho_B = A(V_P + G V_{SH})^m')
    set(gca,'YDir','reverse')
%    annotation('textbox',[0.24 0.35 0.20 0.05],...
%    'String',['SME(nl):',num2str(erro2_nl)],'LineStyle','none',...
%    'FontSize',15,'FitBoxToText','off');
    box off; grid on

    subplot(1,3,2)
    hold on
    plot(abs(re_li(:,icorr)),dep,'LineWidth',1,'color',cc(icorr,:))
    legend('None Corr','Spike Corr','Spike-Cali Corr')
    axis tight
    xlabel('A.E. (decimal)')
    set(gca,'YTick',[])
    set(gca,'FontSize',15)
    title('\rho_B = Q V_P + Z V_{SH} + P')
    set(gca,'YDir','reverse')
%    annotation('textbox',[0.51 dd(icorr) 0.20 0.05],...
%    'String',['SME(li) :',num2str(erro2_li)],'LineStyle','none',...
%    'FontSize',15,'FitBoxToText','off');    
    box off; grid on
        
    subplot(1,3,3)
    hold on
    plot(abs(re_ga(:,icorr)),dep,'LineWidth',1,'color',cc(icorr,:))
    legend('None Corr','Spike Corr','Spike-Cali Corr')
    axis tight
    xlabel('A.E. (decimal)')
    set(gca,'YTick',[])        
    set(gca,'FontSize',15)
    title('\rho_B = k V_P^b')
    set(gca,'YDir','reverse')
%    annotation('textbox',[0.81 dd(icorr) 0.20 0.05],...
%    'String',['SME(ga):',num2str(erro2_ga)],'LineStyle','none',...
%    'FontSize',15,'FitBoxToText','off');
    box off; grid on
    
    if icorr == 3
       suptitle('ERRORS BETWEEN EACH APPLIED CORRECTION')
    end 
 
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);
    name201 = sprintf('Error-Corr-WellRef%d',pwell)
    saveas(figure(201),name201,'epsc')

    % Parameters figure

    if icorr == 3
        
       figure(300)
       subplot(1,2,1)
       hold on
       plot(parametros.li(:,1),'o-k','LineWidth',2)
       plot(parametros.li(:,2),'o-r','LineWidth',2)
       plot(parametros.li(:,3),'o-b','LineWidth',2)
       xticks([1 2 3])
       xticklabels({'Dispike','Raw','Disp-Cali'})
       legend('Q','Z','P')
       annotation('textbox',...
       [0.16 0.50 0.25 0.08],...
       'String',['\rho_B = Q V_P + Z V_{SH} + P'],...
       'LineStyle','none',...
       'FontSize',16,...
       'FontWeight','bold',...                      
       'FitBoxToText','off');
       grid on
       box off
       ylabel('Parameters')
       set(gca,'FontSize',18,'LineWidth',2)
       title('LINEAR EQUATION')
       
       subplot(1,2,2)
       hold on
       plot(parametros.ga(:,1),'o-k','LineWidth',2)
       plot(parametros.ga(:,2),'o-r','LineWidth',2)
       xticks([1 2 3])
       xticklabels({'Dispike','Raw','Disp-Cali'})
       legend('k','b')
       annotation('textbox',...
       [0.63 0.51 0.18 0.08],...
       'String',['\rho_B = k V_P^b'],...
       'LineStyle','none',...
       'FontSize',16,...
       'FontWeight','bold',...                      
       'FitBoxToText','off');
       grid on
       box off
       ylabel('Parameters')
       set(gca,'FontSize',18,'LineWidth',2)
       title('GARDNER EQUATION')
       
       set(gcf,'PaperPositionMode','auto');         
       set(gcf,'PaperOrientation','landscape');
       set(gcf,'Position',[50 50 1400 500]);
       name300 = sprintf('Parameters-WellRef%d',pwell)       
       saveas(figure(300),name300,'epsc')
       
    end

end
