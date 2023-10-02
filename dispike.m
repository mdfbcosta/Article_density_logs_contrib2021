function [data_sp] = dispike(name,dep,data)

% INSTRUCTIONS:
%
% N = move mean window; start with 100
% data = principal vector
% data1 = profundidade
% limite_data = max diference allowed betewn data's values

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>        
quest_spike = 1; % Default 
interv = 0.1;    % Default
window = 50;     % Default

while quest_spike == 1

    % Data despike
    datas = movmean(data,window);
    data_sp = data;

    % Application of Dispike function
    for i=1:length(data)
        if abs(data(i)-datas(i))>=interv && abs(datas(i)-data(i))>=interv
           data_sp(i)=datas(i);
        end
        if abs(data(i)-datas(i))<interv && abs(datas(i)-data(i))<interv
           data_sp(i)=data(i);
        end
    end
    
    % This figure was created to analise the dispike function application
    figure(500)
    hold on
    plot(data,dep,'k','LineWidth',1)
    plot(data_sp,dep,'r','LineWidth',1)
    ylabel('Depth [m]')
    xlabel('Data under correction [u.m]')
    ylim([dep(1) dep(length(dep))])    
    title(name)
    legend('Raw Data','Dispike')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',15)
    box off
    grid on
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 400 1000]);

    % In this check box, the user can repeat their application of the dispike function.
    answer = questdlg({'DEFAULT CORRECTION.','','DO MANUALLY?'}, ...
        'Checkbox', ...
        'Yes','No, thank you','No, thank you');
    % Handle response
    switch answer
        case 'Yes'
            quest_spike = 1;
        case 'No, thank you'
            quest_spike = 0;
    end

    % In this point the parameters of dispike function can be modified
    if quest_spike == 1
       x = inputdlg({'DOMAD - Difference between original and moving average data.',...
           'MAW - Moving average window'},'CODE DEFAULT: DOMAD = 0.1 and MAW = 50', [1 60; 1 60]);
       interv = str2num(x{1});
       window = str2num(x{2});
    end
    close

end % final of while