function [sinal_filtrado] = filtro_analogico(seleciona, sinal_entrada, tempo,  wp, ws, Amin, Amax)
%                                            |                      |      |    |   |     |     |
%                                            |                      |      |    |   |     |     |
%                                            |                      |      |    |   |     |     \_ Atenuacao maxima na faixa de passagem (dB)
%                                            |                      |      |    |   |     \_______ Atenuacao minima na faixa de rejeicao (dB)
%                                            |                      |      |    |   \_____________ Frequencia na faixa de rejeicao (rad/s)
%                                            |                      |      |    \_________________ Frequencia na faixa de passagem (rad/s)
%                                            |                      |      \______________________ Sinal de tempo do sinal_entrada
%                                            |                      \_____________________________ Sinal de entrada
%                                            \____________________________________________________ Seleciona=1->Matlab; Seleciona=0->Octave  


switch seleciona
    case 0 % Octave
        pkg load signal;
        [afil_ord, afil_wc] = buttord(wp, ws, Amax, Amin, 's');
        [num, den]          = butter(afil_ord, afil_wc, 's');
        afil_tf             = tf(num, den);
        sinal_filtrado      = lsim(afil_tf, sinal_entrada, tempo);
    case 1 % Matlab
        E              = sqrt((10^(0.1*Amin))-1);
        [n,wc]         = buttord(wp,ws,Amax,Amin,'s');
        [z,p,k]        = buttap(n);
        [num,den]      = zp2tf(z,p,k);
        [num1,den1]    = lp2lp(num,den,wc);
        sinal_filtrado = lsim(num1, den1, sinal_entrada, tempo);
end