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

filename = 'simulacoes/COLRGV_2017_11_13_SECol';

[ iaLocal, ibLocal, icLocal, iaRemoto, ibRemoto, icRemoto, SinalTrip ] = adquire_sinal(filename);

[zeroLocal, diretaLocal, inversaLocal] = calcula_componentes_simetricas(iaLocal, ibLocal, icLocal);
[zeroRemoto, diretaRemoto, inversaRemoto] = calcula_componentes_simetricas(iaRemoto, ibRemoto, icRemoto);

plota_componentes_simetricas(zeroLocal, diretaLocal, inversaLocal, ["Local - ", filename]);
plota_componentes_simetricas(zeroRemoto, diretaRemoto, inversaRemoto, ["Remoto - ", filename]);