function [temp_iaL_iedF, temp_ibL_iedF, temp_icL_iedF, temp_VAfase_iedF, temp_VBfase_iedF, temp_VCfase_iedF, SinalTrip ] = adquire_sinal(filename)
  matriz = dlmread( [filename '.csv'], ',', 4, 0);

  tempo = matriz(:,1);  % Sinal temporal no arquivo
  IAL   = matriz(:,2);  % Corrente da fase A no terminal local
  IBL   = matriz(:,3);  % Corrente da fase B no terminal local
  ICL   = matriz(:,4);  % Corrente da fase C no terminal local
  VAfase   = matriz(:,5);  % Corrente da fase A no terminal remoto
  VBfase   = matriz(:,6);  % Corrente da fase B no terminal remoto
  VCfase   = matriz(:,7);  % Corrente da fase C no terminal remoto
  SinalTrip   = matriz(:,8);  % Corrente da fase C no terminal remoto
  % ------------------------------------------------------------------------------
  % 3. Configuracao do rele de protecao
  % ------------------------------------------------------------------------------
  % 3.1 Configuracoes sobre o sistema e sobre a amostragem
  f          = 60;                 % Frequencia do sistema de potencia
  na         = 16;                 % Numero de amostras por ciclo
  fa         = na*f;               % Frequencia de amostragem
  Ta         = 1/fa;               % Periodo de amostragem
  ciclosbuff = 4;                  % Numero de ciclos armazenados no buffer
  tambuffer  = ciclosbuff*na;      % Numero de amostras no buffer
  iaL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase A do terminal local
  ibL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase B do terminal local 
  icL_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase C do terminal local
  VAfase_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase A do terminal remoto
  VBfase_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase B do terminal remoto 
  VCfase_ied    = zeros(1,tambuffer); % Tamanho do buffer para corrente na fase C do terminal remoto
  % ------------------------------------------------------------------------------
  % 3.2 Especificacao do filtro de entrada do IED
  %     a) Dados do filtro Butterworth
  fp            = 90;  % Frequencia maxima da banda de passagem, em [Hz]
  hc            = 16;   % Harmonica que se deseja eliminar
  fs            = hc*f;% Frequencia da banda de rejeicao, em [Hz]
  Amax          = 3; % Atenuacao fora da banda de passagem, [dB]
  Amin          = 32; % Atenuacao fora da banda de passagem, [dB]
  %     b) Ordem de um filtro Butterworth
  % [f_order, wc] = buttord(2*pi*fp/(pi*fa), 2*pi*60*hc/(pi*fa), Amin, Amax);
  %[f_order, wc] = buttord(2*pi*fp/(2*pi*fa), 2*pi*60*hc/(2*pi*fa), 0.1, Aten);
  %     c) Cria o filtro
  % [num, den]    = butter(f_order, wc);
  %     d) Cria a funcao de transferencia
  % filtro        = tf(num,den);
  % ------------------------------------------------------------------------------
  % 3.3 Configuracoes sobre as funcoes de protecao
  %     a) Sobrecorrente
  curva = []; % Familia e tipo de curva escolhida (IEEE ou IEC)
  Ipk   = []; % Corrente de pickup (neste caso pode ser em termos de valores primarios
  Dt    = []; % Delta de tempo para coordenacao entre as protecoes
  % ------------------------------------------------------------------------------
  % 4. Filtragem analogica e reamostragem do sinal
  %    a) Filtragem do sinal
  % IALf = filter(num, den, IAL); % Filtragem do sinal de corrente da fase A do terminal local
  % IBLf = filter(num, den, IBL); % Filtragem do sinal de corrente da fase B do terminal local
  % ICLf = filter(num, den, ICL); % Filtragem do sinal de corrente da fase C do terminal local
  % VAfasef = filter(num, den, VAfase); % Filtragem do sinal de corrente da fase A do terminal remoto
  % VBfasef = filter(num, den, VBfase); % Filtragem do sinal de corrente da fase B do terminal remoto
  % VCfasef = filter(num, den, VCfase); % Filtragem do sinal de corrente da fase C do terminal remoto
  IALf = filtro_analogico(0, IAL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase A do terminal local
  IBLf = filtro_analogico(0, IBL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase B do terminal local
  ICLf = filtro_analogico(0, ICL, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase C do terminal local
  VAfasef = filtro_analogico(0, VAfase, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase A do terminal remoto
  VBfasef = filtro_analogico(0, VBfase, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase B do terminal remoto
  VCfasef = filtro_analogico(0, VCfase, tempo, 2*pi*fp, 2*pi*fs, Amin, Amax); % Filtragem do sinal de corrente da fase C do terminal remoto
  %    b) Reamostragem do sinal (como o sinal original possui 32 amostras por ciclo, 
  %       basta fazer a decimacao convencional, caso contrario seria necessario o resample
  %       com alguma tecnica de PDS, do tipo "zero padding")
  cont = 1;
  for aux=1:length(IALf)
    if mod(aux,2)
      tempor(cont) = (aux-1)*Ta;
      IALfr(cont)  = IALf(aux);
      IBLfr(cont)  = IBLf(aux); 
      ICLfr(cont)  = ICLf(aux);
      VAfasefr(cont)  = VAfasef(aux);
      VBfasefr(cont)  = VBfasef(aux); 
      VCfasefr(cont)  = VCfasef(aux);
      SinalTripfr(cont) = SinalTrip(aux);
      cont         = cont + 1;
    end
  end
  % ------------------------------------------------------------------------------
  % 4. Processamento da protecao (na vida real eh um loop infinito do tipo ]
  %    'while (1)'
  % ------------------------------------------------------------------------------
  tam       = 1;
  posbuffer = 1;
  while tam<=length(tempor)
    % ----------------------------------------------------------------------------
    % 4.1 Armazenagem das amostras no buffer do IED (verificando se chegou no 
    %     final do tamanho dele (caso contrario tem que comecar a sobrescrever as 
    %     amostras mais antigas
    % ----------------------------------------------------------------------------
    if posbuffer>tambuffer
      posbuffer = 1;
    end
    iaL_ied(posbuffer) = IALfr(tam); % Buffer de corrente da fase A no terminal Local
    ibL_ied(posbuffer) = IBLfr(tam); % Buffer de corrente da fase B no terminal Local
    icL_ied(posbuffer) = ICLfr(tam); % Buffer de corrente da fase C no terminal Local
    VAfase_ied(posbuffer) = VAfasefr(tam); % Buffer de corrente da fase A no terminal Remoto
    VBfase_ied(posbuffer) = VBfasefr(tam); % Buffer de corrente da fase B no terminal Remoto
    VCfase_ied(posbuffer) = VCfasefr(tam); % Buffer de corrente da fase C no terminal Remoto
    % ----------------------------------------------------------------------------
    % 4.2 Monta o vetor de correntes para c�lculo de Fourier
    % ----------------------------------------------------------------------------
    if posbuffer<na  
      iaL_iedF(posbuffer) = fourier([iaL_ied(tambuffer-(na-posbuffer)+1:tambuffer) iaL_ied(1:posbuffer)],na,fa,f);
      ibL_iedF(posbuffer) = fourier([ibL_ied(tambuffer-(na-posbuffer)+1:tambuffer) ibL_ied(1:posbuffer)],na,fa,f);
      icL_iedF(posbuffer) = fourier([icL_ied(tambuffer-(na-posbuffer)+1:tambuffer) icL_ied(1:posbuffer)],na,fa,f);
      VAfase_iedF(posbuffer) = fourier([VAfase_ied(tambuffer-(na-posbuffer)+1:tambuffer) VAfase_ied(1:posbuffer)],na,fa,f);
      VBfase_iedF(posbuffer) = fourier([VBfase_ied(tambuffer-(na-posbuffer)+1:tambuffer) VBfase_ied(1:posbuffer)],na,fa,f);
      VCfase_iedF(posbuffer) = fourier([VCfase_ied(tambuffer-(na-posbuffer)+1:tambuffer) VCfase_ied(1:posbuffer)],na,fa,f);
    else
      iaL_iedF(posbuffer) = fourier(iaL_ied(posbuffer-na+1:posbuffer),na,fa,f);
      ibL_iedF(posbuffer) = fourier(ibL_ied(posbuffer-na+1:posbuffer),na,fa,f);
      icL_iedF(posbuffer) = fourier(icL_ied(posbuffer-na+1:posbuffer),na,fa,f);
      VAfase_iedF(posbuffer) = fourier(VAfase_ied(posbuffer-na+1:posbuffer),na,fa,f);
      VBfase_iedF(posbuffer) = fourier(VBfase_ied(posbuffer-na+1:posbuffer),na,fa,f);
      VCfase_iedF(posbuffer) = fourier(VCfase_ied(posbuffer-na+1:posbuffer),na,fa,f);
    end
    % fprintf('Amostra: %03.f de %03.f amostras\n',tam, length(tempor));
    % ----------------------------------------------------------------------------
    % ATENCAO - Apenas para teste aqui!!!
    % ----------------------------------------------------------------------------
    temp_iaL_iedF(tam) = iaL_iedF(posbuffer);
    temp_ibL_iedF(tam) = ibL_iedF(posbuffer);
    temp_icL_iedF(tam) = icL_iedF(posbuffer);
    temp_VAfase_iedF(tam) = VAfase_iedF(posbuffer);
    temp_VBfase_iedF(tam) = VBfase_iedF(posbuffer);
    temp_VCfase_iedF(tam) = VCfase_iedF(posbuffer);
    % ----------------------------------------------------------------------------
    posbuffer = posbuffer + 1;
    tam       = tam + 1;
  end

  % Plotando os gráficos dos sinais locais

  disp(["Lendo sinais de corrente do arquivo " filename ".csv: "]);
  
  % Plotando os graficos do sinal de corrente
  neutroLocal = IALfr + IBLfr + ICLfr;

  figure;
  subplot(4, 1, 1);
  plot(IALfr,'r');
  hold on
  plot(sqrt(2)*[temp_iaL_iedF.magnitude],'k');
  title(["Corrente de linha A - " filename]);

  subplot(4, 1, 2);
  plot(IBLfr,'g');
  hold on
  plot(sqrt(2)*[temp_ibL_iedF.magnitude],'k');
  title(["Corrente de linha B - " filename]);

  subplot(4, 1, 3);
  plot(ICLfr,'b');
  hold on
  plot(sqrt(2)*[temp_icL_iedF.magnitude],'k');
  title(["Corrente de linha C - " filename]);

  subplot(4, 1, 4);
  plot(neutroLocal);
  title(["Corrente de neutro - " filename]);
  
  % Plotando os gráficos dos sinais de tensao

  figure;
  subplot(3, 1, 1);
  plot(VAfasefr,'r');
  hold on
  plot(sqrt(2)*[temp_VAfase_iedF.magnitude],'k');
  title(["Tensão de fase A - " filename]);

  subplot(3, 1, 2);
  plot(VBfasefr,'g');
  hold on
  plot(sqrt(2)*[temp_VBfase_iedF.magnitude],'k');
  title(["Tensão de fase B - " filename]);

  subplot(3, 1, 3);
  plot(VCfasefr,'b');
  hold on
  plot(sqrt(2)*[temp_VCfase_iedF.magnitude],'k');
  title(["Tensão de fase C - " filename]);
endfunction