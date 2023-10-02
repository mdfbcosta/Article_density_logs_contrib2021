function [p] = levmar (p,JTJ,incr,e_pos,e_pre,JTe,vp,vsh,rhob)

lamb = 1;
sz = length(JTJ);
N = length(vp);
p = p - incr;
while e_pos > e_pre
    JTJaux = JTJ + lamb*eye(sz);
    incr_aux = inv(JTJaux)*JTe;
    p_aux = p + incr_aux;
    rhob_aux = p_aux(1)*(vp + p_aux(2)*vsh).^p_aux(3);
    e_pos = sum( (rhob - rhob_aux).^2 )/N;
    lamb = 2*lamb;
end
p = p_aux;