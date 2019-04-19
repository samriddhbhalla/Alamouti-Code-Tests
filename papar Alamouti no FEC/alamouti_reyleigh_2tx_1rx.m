%% This thing works ..... yeah
snri=0:2:16;
%% plotting
h = gcf;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([snri(1), snri(end)]);
ylim([1e-6 1]);
xlabel('Eb/No (dB)');
ylabel('BER');
h.NumberTitle = 'off';
h.Renderer = 'zbuffer';
h.Name = 'Transmit vs. Receive Diversity';
title('Alamouti 2Tx 1Rx');
%%

BEROP=zeros(1,length(snri));
Nt=2;
Nr=1;

for snr=snri(1):2:snri(end);
    i=(snr/2)+1;
    if snr<15
        amt=100000;
    elseif snr<20
        amt=500000;
    else 
        amt=800000;
    end
    %% Make the data
    data=(randi(2,1,amt)-1)*2-1;
    dataToSend=zeros(2,amt);
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
     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)', 'SignalPower', 1);
%     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SignalPower', 1);
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
    
    %% MLD
    op=(s_est>0)*2-1;
    check=abs(op-data);
    op2=sum(check)/2;
    op3=op2/amt;
    semilogy(snr, op3, 'bs');
    BEROP(1,i)=op3;
    drawnow;
end

fit1=berfit(snri,BEROP);
semilogy(snri,fit1,'b');%'DisplayName','1 Tx, 2 Rx');
legend('Alam. 2 Tx, 1 Rx');


