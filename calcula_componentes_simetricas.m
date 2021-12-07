function [seq_zero, seq_direta, seq_inversa] = calcula_componentes_simetricas(fase_A, fase_B, fase_C)
    alpha = 1*( cos( deg2rad( 120 ) ) + i*sin( deg2rad( 120 ) ) );
    T = [1 1 1; 1 alpha**2 alpha; 1 alpha alpha**2];
    
    componentes_simetricas = inv(T)*[fase_A.complex; fase_B.complex; fase_C.complex];

    seq_zero = componentes_simetricas(1,:);
    seq_direta = componentes_simetricas(2,:);
    seq_inversa = componentes_simetricas(3,:);
endfunction