function [LIM] = fullrange (pwell,dep,vp,rhob,vsh,cali,nphi)

% Information about this function: ----------------------------------------
%
% Save a picture of all profile of Well
%
% This function is used for choose the range which we want to use to
% calculate the parameters.
%
% Input:
% All profiles that need to be compared to select the region where 
% data is found in all profiles.
%
% Output:
% The indice vector of the depth vector correspondent to choosed region
%--------------------------------------------------------------------------

uiwait (msgbox({'=== IN WHICH REGION IS THERE DATA? ===','',...
                'Click','','1º In TOP BOUND;','',... 
                '2º In the BOTTOM BOUND.'},'ATTENTION'));

quest = 1;
while (quest ~= 0)

    figure(1)
    subplot(1,5,1)
    hold on
    plot(vp,dep,'k','LineWidth',1)
    axis tight
    ylim([dep(1) dep(length(dep))])
    ylabel('Depth [m]')
    xlabel('Vp [km/s]')
    title('Velocity')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on

    subplot(1,5,2)
    hold on
    plot(rhob,dep,'k','LineWidth',1)
    axis tight
    ylim([dep(1) dep(length(dep))])
    xlabel('\rho_B [g/ccc]')
    set(gca,'YTick',[])
    title('Bulk Density')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on

    subplot(1,5,3)
    hold on
    plot(vsh,dep,'k','LineWidth',1)
    axis tight
    ylim([dep(1) dep(length(dep))])
    xlabel('Vsh (decimal)')
    set(gca,'YTick',[])
    title('Shale Volume')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on

    subplot(1,5,4)
    plot(cali,dep,'k','LineWidth',1)
    axis tight
    ylim([dep(1) dep(length(dep))])
    xlabel('Cali [cm]')
    set(gca,'YTick',[])
    title('Caliper')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',18)
    box off
    grid on
    
    subplot(1,5,5)
    plot(nphi,dep,'k','LineWidth',1)
    axis tight
    ylim([dep(1) dep(length(dep))])
    xlabel('\phi_N (decimal)')
    title('Porosity')
    set(gca,'YDir','reverse')
    set(gca,'FontSize',15)
    set(gca,'YTick',[])
    box off
    grid on

    name = sprintf('DATA PROFILE OF WELL%d',pwell);        
    suptitle(name)

    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'Position',[50 50 1400 1000]);

    name = sprintf('Some profile_of_Well-%d',pwell);
    saveas(figure(1),name,'epsc');

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