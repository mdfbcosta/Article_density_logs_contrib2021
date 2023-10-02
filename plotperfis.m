function plotperfis(pwell,dep,vp1,rhob1,vsh1,cali,nphi,drho,sp)

figure(1)
subplot(1,5,1)
hold on
plot(vp1,dep,'k','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
ylabel('Depth [m]')
xlabel('Vp [km/s]')
title('Velocity')
set(gca,'YDir','reverse')
set(gca,'FontSize',15)
box off
grid on

subplot(1,5,2)
hold on
plot(rhob1,dep,'k','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('\rho_B [g/ccc]')
title('Bulk Den.')
set(gca,'YDir','reverse')
set(gca,'FontSize',15)
set(gca,'YTick',[])
box off
grid on

%         subplot(1,7,3)
%         hold on
%         plot(drho,dep,'r','LineWidth',1)
%         axis tight
%         ylim([dep(1) dep(length(dep))])
%         xlabel('\rho_D [g/ccc]')
%         title('Den Correc')
%         set(gca,'YDir','reverse')
%         set(gca,'FontSize',15)
%         set(gca,'YTick',[])
%         box off
%         grid on

subplot(1,5,3)
hold on
plot(vsh1,dep,'k','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('Vsh (decimal)')
title('Shale Vol')
set(gca,'YDir','reverse')
set(gca,'FontSize',15)
set(gca,'YTick',[])
box off
grid on

subplot(1,5,4)
plot(cali,dep,'k','LineWidth',1)
axis tight
ylim([dep(1) dep(length(dep))])
xlabel('Cal [cm]')
title('Caliper')
set(gca,'YDir','reverse')
set(gca,'FontSize',15)
set(gca,'YTick',[])
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

%         subplot(1,7,7)
%         plot(sp,dep,'b','LineWidth',1)
%         axis tight
%         ylim([dep(1) dep(length(dep))])
%         xlabel('SP [mV]')
%         title('Self Potential')
%         set(gca,'YDir','reverse')
%         set(gca,'FontSize',15)
%         set(gca,'YTick',[])
%         box off
%         grid on

name = sprintf('DATA PROFILE OF WELL%d',pwell);        
suptitle(name)

set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'Position',[50 50 1400 1000]);

name = sprintf('Some profile_of_Well-%d',pwell);
saveas(figure(1),name,'epsc');

%uiwait (msgbox({'Press Enter to continue.'},'==== ADVISE ====')); 

close
