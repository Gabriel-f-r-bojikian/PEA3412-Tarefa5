function [trip] = detecta_trip_protecao_mho_terra(Ilinha, Vfase, Ineutro, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao )
    
    k = ( z0 - z1 )/z1;

    for i=1:length(Ilinha)
        Z = Vfase(i).complex/(Ilinha(i).complex + k*Ineutro(i));
        argumento = arg( ( multiplicador_zona_protecao*L*z1 - Z )/( Z ) );
        rad2deg(argumento)

        if( i > 5 && argumento <= angulo_zona_protecao )
            trip(i) = 1;
        else
            trip(i) = 0;
        endif
    endfor

endfunction