% 18-10-05 08:00 Hua-sheng XIE, huashengxie@gmail.com, FRI-ENN, China
% Ackn.: Richard Denton (Dartmouth), Xin Tao (USTC), Jin-song Zhao (PMO),
% etc ...
% Setup for run pdrk
% 18-10-13 09:52 update to with loss-cone distribution

savepath='../output/'; % choose where to save the figures and outputs
% savepath='../examples/loss_cone_mirror/';
iem=1; % =1, electromagnetic run; =0, electrostatic run

N=3; % Number harmonics, enlarge N to make sure the results are convergent
J=8; % J-pole, usually J=8 is sufficient; other choice: 4, 12
sp=0; % sparse eigs(), sp=1; or eig() for all solution, sp=0
wg0=0.01-0.01i; % inital guess for sp=1, normalized by omega_{c1}; not required if sp=0

B0=3.3E-9; % magnetic field (Tesla)

% initialize the parameters k, theta, kz, kx
par=zeros(6,1);
par(1)=0.01; % k, =sqrt(kx^2+kz^2), normalized by *c/omega_{p1}
par(2)=0; % theta, the angle between k and B0, normalized by *pi/180
par(3)=cos(par(2)*pi/180)*par(1); % kz, i.e., kpara*c/omega_{p1}
par(4)=sin(par(2)*pi/180)*par(1); % kx, i.e., kperp*c/omega_{p1}

% Choose which parameter(s) to scan, if ipa==ipb, do 1D scan; otherwise, 
% do 2D scan. % 1: k; 2: theta; 3: kz; 4: kx; 5: others.
% You can scan other parameters by modify line xxx in 'pdrk_si_kernel.m',
% e.g., to scan vs0(1), B0, betasz, etc
% Typical cases of (ipa,ipb): 
%   1. (1,1) scan k, fixed theta
%   2. (2,2) scan theta, fixed k
%   3. (1,2) scan 2D (k, theta)
%   4. (3,3) scan kz, fixed kx
%   5. (4,4) scan kx, fixed kz
%   6. (3,4) scan 2D (kz,kx)
%   7. (..,..) others, please modify 'pdrk_si_kernel.m'
ipa=1;
ipb=1;

iloga=0; % ilog=0, linear scale; =1, log scale, i.e., 10^(p1:dp:p2)
ilogb=0;
% pa1=-2; pa2=2; dpa=0.05; % 1st parameter a, depends on ipa
pa1=0.01; pa2=10; dpa=0.1; % 1st parameter a, depends on ipa
pb1=0; pb2=90; dpb=5; % 2nd parameter b, depends on ipb


% wether calculate polarizations (dEx,dEy,dEz,dBx,dBy,dBz) for select omega
iout=2; % =1, only (omega,gamma); =2, also calculate (E,B7

% added by Xingyu Zhu 2021-02-07
isavePola = 0;
if isavePola==1 
   Pola_FileName = '/Users/psr/work/����RH&LH������/Data/Polarization.dat';
   PolaSI_FileName = '/Users/psr/work/����RH&LH������/Data/Polarization_SI.dat';
end
% added by Xingyu Zhu 2020-06-03
% whether calculate distribution function (f0+deltaf, deltaf) 
ideltaf=0; % =1, calc; =0, ignore
jpa_input=62; jpb_input=1; jpl_input=1; s_input=1; % 195
is_shift_df_phase = 0;
is_output_VDFdat = 0;
is_output_VDFvtk = 0;
if ideltaf==1
    if is_output_VDFdat == 1
        dir_VDFdat = '/Users/psr/work/����RH&LH������/Data/';
    end
    if is_output_VDFvtk == 1
        dir_VDFvtk = '/Users/psr/work/����RH&LH������/Data/';
    end
    if s_input==3
        ampl=5;
        vxrange(1)=-1000; vxrange(2)=1000; % in vA unit
        vyrange(1)=-1000; vyrange(2)=1000; % in vA unit
        vzrange(1)=-1000; vzrange(2)=1000; % in vA unit
        vxsteps=100; vysteps=100; vzsteps=100;
    end
    if s_input==1 || s_input==2
        ampl=0.2;
        vxrange(1)=-4; vxrange(2)=4; % in vA unit
        vyrange(1)=-4; vyrange(2)=4; % in vA unit
        vzrange(1)=-4; vzrange(2)=4; % in vA unit
        vxsteps=100; vysteps=100; vzsteps=100;
    end
    damping=false;
    const_r=true;
    periods=true;
    num_periods=1;
    timesteps=10;
end