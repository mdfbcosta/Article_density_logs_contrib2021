function [rhocorr] = corr_cali2(dep,rho,vp,cali)

rhocorr=rho;

cont = 1;
quest = 3;

% Bloco para fazer o Picking.
% Here you can select more than one region for correction.
while (quest ~= 0)
    
    figure(1000)
    subplot(1,2,1)
    plot(rhocorr,dep)
    axis tight
    ylim([dep(1) dep(length(dep))])
    ylabel('Depth [m]')
    xlabel('\rho_B [g/ccc]')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on
    
    subplot(1,2,2)
    plot(cali,dep)
    axis tight
    ylim([dep(1) dep(length(dep))])
    xlabel('Caliper [cm]')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on
    
    suptitle('CHOOSE THE INTERVALS TO APPLY THE CALIPER CORRECTION.')
    
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 750 1000]);
    
    [yy lim(:,cont)] = ginput(2);
    
    % --- Box Ask the user whether or not to repeat their choice of points.
    answer = questdlg('Would you like to...', ...
        'Checkbox', ...
        'Pick the points again','Select one more region','Finish','Finish');
    % Handle response
    switch answer
        case 'Pick the points again'
            quest = 1;
        case 'Select one more region'
            quest = 2;
        case 'Finish'
            quest = 0;
    end
    if quest == 1
        cont = cont;
    elseif quest == 2
        cont = cont + 1;
    end
end
close

LIM = lim
for jj = 1:cont
    [lim(:,jj)] = cutlog(lim(1,jj),lim(2,jj),dep);
end

% Here you apply to Caliper Correction and verify the quality of correction
quest_cali = 1;          % Default
g_mud(1:cont) = 0.3;     % Default
rho_mud(1:cont) = 1.3;   % Default

cor = {'--r' '--b' '--k' '--g' '--c' '--m' '--y' '--k'};

while quest_cali == 1

for kk = 1:cont
    [rhocorr(lim(1,kk):lim(2,kk))] = ...
        gmud_correction_reflec(dep (lim(1,kk):lim(2,kk)),...
                               rho (lim(1,kk):lim(2,kk)),...
                               vp  (lim(1,kk):lim(2,kk)),...
                               cali(lim(1,kk):lim(2,kk)),...
                                     rho_mud(kk), g_mud(kk), 0);
end

    figure(900)
    subplot(1,2,1)
    hold on
    plot(rho,dep)
    plot(rhocorr,dep)
    ylabel('Depth [m]')
    xlabel('\rho_B [g/ccc]')
    for ii = 1:cont
        plot(rhocorr,LIM(:,ii)+zeros(1,length(dep)),cor{ii},'LineWidth',2)
    end
    axis tight
    ylim([dep(1) dep(length(dep))])    
    title('Caliper Correction')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    legend('Raw')
    box off
    grid on
    
    subplot(1,2,2)
    hold on
    plot(cali,dep)
    for ii = 1:cont
        plot(cali,LIM(:,ii)+zeros(1,length(dep)),cor{ii},'LineWidth',2)
    end
    ylim([dep(1) dep(length(dep))])
    xlabel('Cali [cm]')
    ylim([dep(1) dep(length(dep))])
    title('Caliper')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on

    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 600 1000]);

    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'This is the DEFAULT CORRECTION of code.','','Do you want to do it MANUALLY?'}, ...
        'Checkbox', ...
        'Yes','No, thank you','No, thank you');
    % Handle response
    switch answer
        case 'Yes'
            quest_cali = 1;
        case 'No, thank you'
            quest_cali = 0;
    end

    for kk = 1:cont
        gmud   = sprintf('GMUD Region %d - Range from 0.1 to 0.4',kk);
        rhomud = sprintf('RHOMUD Region %d - Range from 1.1 to 1.3',kk);
        % In this point the parameters of dispike function can be modified
        if quest_cali == 1
           x = inputdlg({gmud,rhomud},'DEFAULT: GMUD = 0.3 AND RHO-MUD = 1.3', [1 60; 1 60]);
           g_mud(kk) = str2num(x{1});
           rho_mud(kk) = str2num(x{2});
        end
    end
    close
    
end   % while