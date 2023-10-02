function [rhocorr] = corr_cali(dep,rho,vp,cali)

rhocorr=rho;

cont = 1;
quest = 3;

% Bloco para fazer o Picking.

while (quest ~= 0)
    figure(1000)
    subplot(1,2,1)
    plot(rhocorr,dep)
    ylim([dep(1) dep(length(dep))])
    ylabel('Depth [km]')
    xlabel('\rho_B [g/ccc]')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on
    
    subplot(1,2,2)
    plot(cali,dep)
    ylim([dep(1) dep(length(dep))])
    xlabel('Caliper [cm]')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on
    
    suptitle('CHOOSE THE INTERVALS TO APPLY THE CALIPER CORRECTION.')
    
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 700 1000]);
    
    [yy lim(:,cont)] = ginput(2);
    
    % --- Box Ask the user whether or not to repeat their choice of points.
    answer = questdlg('Would you like of...', ...
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
        cont =  cont - 1;
    elseif quest == 2
        cont = cont + 1;
    end
end
close

for jj = 1:cont
    [lim(:,jj)] = cutlog(lim(1,jj),lim(2,jj),dep);
end

% Bloco onde se faz a correção do Caliper e verifica-se foi bom ou não,
% para possível escolha de novos parâmetros.

quest_cali = 1;  % Default 
g_mud = 0.3;     % Default
rho_mud = 1.3;   % Default

while quest_cali == 1

for kk = 1:cont
    [rhocorr(lim(1,kk):lim(2,kk))] = ...
        gmud_correction_reflec(dep (lim(1,kk):lim(2,kk)),...
                               rho (lim(1,kk):lim(2,kk)),...
                               vp  (lim(1,kk):lim(2,kk)),...
                               cali(lim(1,kk):lim(2,kk)),...
                                     rho_mud, g_mud, 0);
end

    figure(900)
    hold on
    plot(rho,dep)
    plot(rhocorr,dep)
    ylabel('Depth [km]')
    xlabel('\rho_B [g/ccc]')
    title('Caliper Correction')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    legend('Raw')
    box off
    grid on
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 400 1000]);    

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

    % In this point the parameters of dispike function can be modified
    if quest_cali == 1
       x = inputdlg({'GMUD - Range from 0.1 to 0.4',...
           '\rho_{MUD} - Range from 1.1 to 1.3'},'DEFAULT: GMUD = 0.3 AND RHO-MUD = 1.3', [1 60; 1 60]);
       g_mud = str2num(x{1});
       rho_mud = str2num(x{2});
    end
    close
    
end   % while