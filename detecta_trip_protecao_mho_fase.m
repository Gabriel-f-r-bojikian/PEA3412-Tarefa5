function [trip] = detecta_trip_protecao_mho_fase(Ilinha1, Ilinha2, Vlinha, L, z1, multiplicador_zona_protecao, angulo_zona_protecao )

    for i=1:length(Ilinha1)
        Z = Vlinha(i)/(Ilinha1(i).complex - Ilinha1(i).complex);
        argumento = arg( ( multiplicador_zona_protecao*L*z1 - Z )/( Z ) );

        delay_de_atuacao_para_filtrar_pulsos_espurios = 0;
        if( i > 5 && argumento <= angulo_zona_protecao )
            trip(i) = 1;
        else
            trip(i) = 0;
        endif
    endfor

endfunction