%% This thing works ..... kinda Nt=2 only Data send part is still not good 
x=2;
snri=0:x:12;
%% plotting
h = gcf;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([snri(1), snri(end)+1]);
ylim([1e-6 1]);
xlabel('Eb/No (dB)');
ylabel('BER');
h.NumberTitle = 'off';
h.Renderer = 'zbuffer';
h.Name = 'Transmit vs. Receive Diversity';
title('Alamouti 2tx 1rx');
%%
BEROP=zeros(1,length(snri));
Nt=2;
Nr=2;
%%
i=0;
for snr=snri(1):x:snri(end);
%     i=(snr/x)+1; %snr starts from 1. else predefine i...
    i=i+1;
    if snr<5
        amt=100000;
    elseif snr<10
        amt=500000;
    else 
        amt=800000;
    end
    
    %% Make the data
    data=(randi(2,1,amt)-1)*2-1;
    dataToSend=zeros(2,amt*2);
    dataToSend(1,1:4:end)=data(1:2:end);
    dataToSend(1,2:4:end)=-conj(data(2:2:end));
    dataToSend(2,1:4:end)=data(2:2:end);
    dataToSend(2,2:4:end)=conj(data(1:2:end));
    dataToSend(1,3:4:end)=dataToSend(1,1:4:end);
    dataToSend(2,3:4:end)=dataToSend(2,1:4:end);
    dataToSend(1,4:4:end)=dataToSend(1,2:4:end);
    dataToSend(2,4:4:end)=dataToSend(2,2:4:end);    
    s=dataToSend;
    %% make AWGN channel and now reyleigh channel
    H=(randn(1,amt*2)+1i*randn(1,amt*2))/sqrt(2);
    H2=reshape(H,2,[]);
    H2=repmat(H2,2,1);
    H2=reshape(H2,2,[]);
    r=H2.*s;
%     r=sum(r,1);
    %%
     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)', 'SignalPower', 1);
%     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SignalPower', 1);
    AWGN.EbNo = snr;
    y=step(AWGN,r);
    %y=awgn(r,snr,'measured')
    %% Building combiner output
    y=sum(y);
    y_copy=y;
    y_copy(2:2:end)=conj(y_copy(2:2:end));
    y_copy=reshape(y_copy,4,[]);
    y_copy=repmat(y_copy,2,1);
    y_copy=reshape(y_copy,4,[]);
   
    H3=zeros(4,amt);
    
    H3(1,1:2:end)=H(1:4:end);
    H3(1,2:2:end)=H(2:4:end);
    H3(1,:)=conj(H3(1,:));
        
    H3(2,1:2:end)=H(2:4:end);
    H3(2,2:2:end)=-H(1:4:end);
    
    H3(3,1:2:end)=H(3:4:end);
    H3(3,2:2:end)=H(4:4:end);
    H3(3,:)=conj(H3(3,:));
    
    H3(4,1:2:end)=H(4:4:end);
    H3(4,2:2:end)=-H(3:4:end);
    

    
    s_est= H3.*y_copy;            % s_estimate        % zeros(1,amt); 
    s_est=sum(s_est);
%     s_est(1:2:end)=s01;
%     s_est(2:2:end)=s02;
    
    %% MLD
    op=(s_est>0)*2-1;
    check=abs(op-data);
    op2=sum(check)/2;
    op3=op2/amt;
    semilogy(snr, op3, 'bs','MarkerSize',10);
    BEROP(1,i)=op3;
    drawnow;
end

fit1=berfit(snri,BEROP);
semilogy(snri,fit1,'b');%'DisplayName','1 Tx, 2 Rx');



