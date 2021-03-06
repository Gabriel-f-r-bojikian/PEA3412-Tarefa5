%{
  PEA 3412 - Tarefa 5
  
  Grupo G:
    - Gabriel Fernandes Rosa Bojikian, 9349221
    - Maurício Kenji Sanda, 10773190
    - Pedro César Igarashi, 10812071

  Descrição:
    Esta é a função principal do script de simulação da tarefa 5. Ele automatiza 
    o processo de aquisição e tratamento dos sinais de corrente e realiza a
    simulação da proteção Mho utilizando a decomposição em componentes
    simétricas das correntes.
%}

close all;
fclose all;
clear all;
clc;

filename = 'simulacoes\RDEBJD_2019_11_17_SEBJD';

z0 = 0.305718053333333 + 1.008403666666667i;
z1 = 0.018725573333333 + 0.272554266666667i;
L = 321.72;
angulo_zona_protecao = deg2rad(80);
multiplicador_zona_protecao = 0.85;

[ iaLinha, ibLinha, icLinha, VaFase, VbFase, VcFase, SinalTrip ] = adquire_sinal(filename);

% --- vamos calcular o neutro --- %
for i=1:length(iaLinha)
  ineutro(i) = ( iaLinha(i).complex + ibLinha(i).complex + icLinha(i).complex )/3;
endfor

trip_a = detecta_trip_protecao_mho_terra(iaLinha, VaFase, ineutro, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);
trip_b = detecta_trip_protecao_mho_terra(ibLinha, VbFase, ineutro, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);
trip_c = detecta_trip_protecao_mho_terra(icLinha, VcFase, ineutro, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);

figure;
subplot(3, 1, 1);
plot(trip_a,'r');
hold on
title(["Trip A Local - " filename]);
ylim([0, 1.1]);


subplot(3, 1, 2);
plot(trip_b,'g');
hold on
title(["Trip B Local - " filename]);
ylim([0, 1.1]);

subplot(3, 1, 3);
plot(trip_c,'b');
hold on
title(["Trip C Local - " filename]);
ylim([0, 1.1]);

% --- Vamos calcular as tensoes de linha --- %

for i=1:length(VaFase)
  Vab(i) = VaFase(i).complex - VbFase(i).complex;
  Vbc(i) = VbFase(i).complex - VcFase(i).complex;
  Vca(i) = VcFase(i).complex - VaFase(i).complex;
endfor

trip_ab = detecta_trip_protecao_mho_fase(iaLinha, ibLinha, Vab, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);
trip_bc = detecta_trip_protecao_mho_fase(ibLinha, icLinha, Vbc, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);
trip_ca = detecta_trip_protecao_mho_fase(icLinha, iaLinha, Vca, L, z0, z1, multiplicador_zona_protecao, angulo_zona_protecao);

figure;
subplot(3, 1, 1);
plot(trip_ab,'r');
hold on
title(["Trip AB Local - " filename]);
ylim([0, 1.1]);


subplot(3, 1, 2);
plot(trip_bc,'g');
hold on
title(["Trip BC Local - " filename]);
 ylim([0, 1.1]);

subplot(3, 1, 3);
plot(trip_ca,'b');
hold on
title(["Trip CA Local - " filename]);
 ylim([0, 1.1]);
