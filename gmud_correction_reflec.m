function [rhonc] = gmud_correction_reflec(depth, rho, vp, caliper, rho_mud, gmudmax, gmudmin)

% Function que faz a correção no perfil de densidade de acordo com a teoria
% do fator geométrico de Doll (GMUD) e calcula a nova refletividade

depthn=depth;
rhon=rho;
vpn=vp;

caliper_sm=caliper;
%caliper_sm=smooth(caliper,50);
calipermax=max(caliper_sm);
calipermin=min(caliper_sm);

a=(gmudmin - gmudmax)/(calipermin - calipermax);

for i=1:length(caliper)
gmud(i) = a*(caliper_sm(i) - calipermin) + gmudmin;
end

gmud=gmud';
% gmud(4128:length(caliper),1)=0;

rhonc=zeros(length(depthn),length(rho_mud));
% ipc=zeros(length(depthn),length(rho_mud));
% Rc=zeros(length(depthn)-1,length(rho_mud));
for k=1:length(rho_mud)
    for j=1:length(gmud)
        rhonc(j,k)=(rhon(j)-gmud(j)*rho_mud(k))/(1-gmud(j));     
 
%         ipc(j,k)=rhonc(j,k).*vpn(j);
%         for i=1:numel(depthn)-1
%             Rc(i,k)=(ipc(i+1,k)-ipc(i,k))/(ipc(i+1,k)+ipc(i,k));
%         end
    end
end