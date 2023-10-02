close all
clear all
clc

[datastr,data,colnames,header] = loadlas('dado8.las');

dep   = datastr.dept*0.3048;             % [m]
vp1   = (1./datastr.dt)*0.3048*1.e+3;    % [km/s]
rhob1 = datastr.rhob;                    % [g/ccc]
[vsh1]= calc_vsh(datastr.gr,1);       % decimais
cali  = datastr.cali*2.54;               % [cm]

[gn(1,:)] = gaunew(rhob1,vp1,vsh1)
