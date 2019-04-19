clear all
%%
h = gcf;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([1,12]);
ylim([1e-6 1]);
xlabel('SNR (dB)');
ylabel('BER');
h.NumberTitle = 'off';
h.Renderer = 'zbuffer';
h.Name = '..k';
title('..l');
%%
for snr = 1:12
    nosPacs = 100; %rows
    nosBits = 256; %cols
    msg = randi([0,1],nosPacs,nosBits);
    %% Modulate data
    ModulatedData = msg*2-1;
    %% Make AWGN Channel
    AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SignalPower', 1);
    AWGN.SNR = snr;
    data = step(AWGN,ModulatedData);
    %% recieve
    DataOut = (data>0)*1 ;
    err = sum(abs(DataOut-msg));
    er=sum(err);
    op=er/(nosBits*nosPacs);
    BER(snr)=op;
    semilogy(snr,op,'rs');
end
fit1=berfit(1:12,BER);
semilogy(1:12,fit1,
