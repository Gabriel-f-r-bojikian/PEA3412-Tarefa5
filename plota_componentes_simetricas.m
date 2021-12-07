function plota_componentes_simetricas(seq_zero, seq_direta, seq_inversa, tituloGrafico)
    % Plota a magnitude das componentes simétricas
    figure;
    subplot(3, 1, 1);
    plot(sqrt(2)*[abs(seq_zero)],'r');
    title(["Magnitude - Seq zero - ", tituloGrafico]);

    subplot(3, 1, 2);
    plot(sqrt(2)*[abs(seq_direta)],'g');
    title(["Magnitude - Seq direta - ", tituloGrafico]);

    subplot(3, 1, 3);
    plot(sqrt(2)*[abs(seq_inversa)],'b');
    title(["Magnitude - Seq inversa - ", tituloGrafico]);
endfunction