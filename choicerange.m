function [LIM,rhob_gn,gn] = choicerange (dep,vp,vp1,rhob,rhob1,vsh,vsh1,cali,tipo_aprox,icorr)

% This function is used for choose the range which we want to use to
% calculate the parameters.

uiwait (msgbox({'SELECT THE REGION WHERE THE PARAMETERS WILL BE ESTIMATED!','',...
                'BUT...','','1- CHOOSE THE TOP POINT, FIRST;','','2- CHOOSE THE BOTTOM POINT.'},'ATTENTION!'));

quest1 = 1;
while (quest1 ~= 0) 

    quest = 1;
    while (quest ~= 0)

        figure(1)
        subplot(1,4,1)
        hold on
        plot(vp1,dep,'k','LineWidth',1)
        plot(vp,dep,'r','LineWidth',1)
        axis tight
        ylim([dep(1) dep(length(dep))])
        ylabel('Depth [m]')
        xlabel('Vp [km/s]')
        title('Velocity')
        legend('Raw','Spike Corr','Position','Best')
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        box off
        grid on

        subplot(1,4,2)
        hold on
        plot(rhob1,dep,'k','LineWidth',1)
        plot(rhob,dep,'r','LineWidth',1)
        axis tight
        ylim([dep(1) dep(length(dep))])
        xlabel('\rho_B [g/ccc]')
        title('Bulk Density')
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        box off
        grid on

        subplot(1,4,3)
        hold on
        plot(vsh1,dep,'k','LineWidth',1)
        plot(vsh,dep,'r','LineWidth',1)
        axis tight
        ylim([dep(1) dep(length(dep))])
        xlabel('Vsh (decimal)')
        title('Shale Volume')
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        legend('Raw','Dispike','Position','Best')
        box off
        grid on

        subplot(1,4,4)
        plot(cali,dep,'k','LineWidth',1)
        axis tight
        ylim([dep(1) dep(length(dep))])
        xlabel('Cali [cm]')
        title('Caliper')
        set(gca,'YDir','reverse')
        set(gca,'FontSize',18)
        box off
        grid on

        suptitle('CHOOSE THE INTERVAL TO ESTIMATE THE APPROXIMATION EQUATION PARAMETERS.')

        set(gcf,'PaperPositionMode','auto');         
        set(gcf,'PaperOrientation','landscape');
        set(gcf,'Position',[50 50 1400 1000]);

        [y lim] = ginput(2);

        % --- Box Ask the user whether or not to repeat their choice of points.
        answer = questdlg('Repeat action?', ...
            'Choice', ...
            'Yes','No','No');
        % Handle response
        switch answer
            case 'Yes'
                quest = 1;
            case 'No'
                quest = 0;
        end
        clearvars y
        close all
    end

    % Call the functions to approximate the Bulk Density -----------------
    [LIM] = cutlog(lim(1),lim(2),dep); % Select the range analysed of the Well

    vp_cut   = vp(LIM(1):LIM(2));      % [km/s]
    rhob_cut = rhob(LIM(1):LIM(2));    % [g/cm^3]
    vsh_cut  = vsh(LIM(1):LIM(2));     % decimal 
    %
%     if tipo_aprox == 1
%         [gn(icorr,:)] = gaunew (rhob_cut,vp_cut,vsh_cut);
%         rhob_gn(:,icorr) = gn(icorr,1)*(vp + gn(icorr,2)*vsh).^gn(icorr,3);
%     elseif tipo_aprox == 2
%         [gn(icorr,:)] = modbir (rhob_cut,vp_cut,vsh_cut);
%         rhob_gn(:,icorr) = gn(icorr,1)*vp + gn(icorr,2)*vsh + gn(icorr,3);
%     elseif tipo_aprox == 3
%         [gn(icorr,:)] = modgard (rhob_cut,vp_cut);
%         rhob_gn(:,icorr) = gn(icorr,1)*vp.^gn(icorr,2);
%     end

   % Approximation no-linear equation

   [gn(icorr,:)] = gaunew (rhob_cut,vp_cut,vsh_cut);
   parametros.nl(icorr,:) = gn(icorr,:);
   % Calculated Bulk density
   rhob_nl(:,icorr) = gn(icorr,1)*(vp + gn(icorr,2)*vsh).^gn(icorr,3);
   % Relative error
   re_nl(:,icorr) = (rhob - rhob_nl(:,icorr))./rhob;
   % Media Quadratic error
   erro2_nl = immse(rhob(LIM(1):LIM(2)),rhob_nl(LIM(1):LIM(2),icorr));

   % Approximation linear equation

   [gn(icorr,:)] = modbir (rhob_cut,vp_cut,vsh_cut);
   parametros.li(icorr,:) = gn(icorr,:);
   % Calculated Bulk density
   rhob_li(:,icorr) = gn(icorr,1)*vp + gn(icorr,2)*vsh + gn(icorr,3);
   % Relative error
   re_li(:,icorr) = (rhob - rhob_li(:,icorr))./rhob;
   % Media Quadratic error
   erro2_li = immse(rhob(LIM(1):LIM(2)),rhob_li(LIM(1):LIM(2),icorr));

   % Approximation linear equation: Gardner

   [gn(icorr,:)] = modgard (rhob_cut,vp_cut);
   parametros.ga(icorr,:) = gn(icorr,:);
   % Calculated Bulk density
   rhob_ga(:,icorr) = gn(icorr,1)*vp.^gn(icorr,2);
   % Relative error
   re_ga(:,icorr) = (rhob - rhob_ga(:,icorr))./rhob;
   % Media Quadratic error
   erro2_ga = immse(rhob(LIM(1):LIM(2)),rhob_ga(LIM(1):LIM(2),icorr));


    %
    figure(354)
    subplot(1,2,1)
    hold on; box off; grid on
    plot(rhob1,dep,'k','LineWidth',1)
    plot(rhob_gn(:,icorr),dep,'b','LineWidth',1)
    set(gca,'YDir','reverse')
    axis tight
    ylim([dep(1) dep(length(dep))])
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    legend('Raw','Est','Position','Best')
    ylabel('Depth [m]')
    xlabel('RhoB [g/ccc]')
    title('Bulk Density')

    subplot(1,2,2)
    hold on; box off; grid on
    plot(cali,dep,'k','LineWidth',1)
    ylim([dep(1) dep(length(dep))])
    xlabel('Cali [cm]')
    title('Caliper')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 750 1000]);

    answer = questdlg('Confirm?','Checkbox', ...
                      'No. I want repeat.','Yes.','Yes.');
    switch answer
        case 'Yes.'
            quest1 = 0;
        case 'No. I want repeat.'
            quest1 = 1;
    end
    close
end

%[LIM] = cutlog(lim(1),lim(2),dep); % Select the range analysed of the Well

fileID = fopen('region.txt','w');
fprintf(fileID,'%12.8f\n',lim');
fclose(fileID);