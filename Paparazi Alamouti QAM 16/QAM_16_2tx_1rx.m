%% This thing works ..... yeah
% clear all
% clc
% close all
snri=1:2:30;
%%
% Set the modulation order, and determine the number of bits per symbol.
M = 16;
k = log2(M);
%% plotting
h = gcf;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([snri(1), snri(end)+1]);
ylim([1e-6 1]);
xlabel('SNR (dB)');
ylabel('BER');
h.NumberTitle = 'off';
h.Renderer = 'zbuffer';
h.Name = 'Transmit vs. Receive Diversity';
title('QAM 16 2 transmiter 1 receiver');
%%

BEROP=zeros(1,length(snri));
Nt=2;
Nr=1;
%%
i=0;
for snr=snri(1):2:snri(end);
    i=i+1;
    % amt is no of words
    if snr<15
        amt=10000;
    elseif snr<20
        amt=50000;
    else 
        amt=50000;
    end
    %% Make the data
    data1 = randi([0,1],amt*k,1);
%     modData = qammod(data1,M,'InputType','bit','UnitAveragePower',true); 
modData = qammod(data1,M,'InputType','bit'); 
    dataToSend=zeros(2,amt);
    data = modData.';
    dataToSend(1,1:2:end)=data(1:2:end);
    dataToSend(2,1:2:end)=data(2:2:end);
    dataToSend(1,2:2:end)=-conj(data(2:2:end));
    dataToSend(2,2:2:end)=conj(data(1:2:end));
    s=dataToSend;
    %% make AWGN channel and now reyleigh channel
    H=zeros(2,amt);
    H(:,1:2:end)=(randn(2,amt/2)+1i*randn(2,amt/2))/sqrt(2);
    H(:,2:2:end)=H(:,1:2:end);
    r=H.*s;
    %r=sum(r,1);
    %%
%     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)', 'SignalPower', 1);
    AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)');
    AWGN.EbNo = snr;
    y=step(AWGN,r);
    %y=awgn(r,snr,'measured')
    %% Building combiner output
    y=sum(y);
    y_copy=zeros(2,amt);
    y(2:2:end)=conj(y(2:2:end));
    y_copy(1,:)=y;
    y_copy(2,1:2:end)=y(2:2:end);
    y_copy(2,2:2:end)=y(1:2:end);
    
    H2=zeros(2,amt);                       % Prealocating for speed
    H2(1,1:2:end)=conj(H(1,1:2:end));        % For combining purpose(assume perfect channel estimation
    H2(2,1:2:end)=H(2,1:2:end);
    H2(1,2:2:end)=-H(1,1:2:end);
    H2(2,2:2:end)=conj(H(2,1:2:end));
    
%     s01=conj(H(1))*y(1:2:end)+conj(y(2:2:end))*H(2);
%     s02=conj(H(2))*y(1:2:end)-conj(y(2:2:end))*H(1);
%     All=[-1 1];
    
    s_est= H2.*y_copy;            % s_estimate        % zeros(1,amt); 
    s_est=sum(s_est);
%     s_est(1:2:end)=s01;
%     s_est(2:2:end)=s02;
    H2_abs = abs(H2);
    H2_abs = H2_abs.^2;
    H3 = sum(H2_abs);
    %% MLD
    s_est_norm = s_est./H3;
%     demodData = qamdemod(s_est_norm.',M,'OutputType','bit','UnitAveragePower',true);
    demodData = qamdemod(s_est_norm.',M,'OutputType','bit');
%    op = demodData;
    op = demodData;

    errData = sum(mod((op-data1),2)); 
    op3 = errData/(amt*k);
    semilogy(snr, op3, 'bs');
    BEROP(1,i)=op3;
    drawnow;
end

fit1=berfit(snri,BEROP);
semilogy(snri,fit1,'b');%'DisplayName','1 Tx, 2 Rx');
legend('2 Tx, 1 Rx');


