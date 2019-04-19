%% This thing works ..... yeah                          
x=1;
snri=0:x:10;% x is number of points to interleave
M=4;        % Number of receiver for one Tx 
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
title('MRRC 1tx 4rx');
%%
BEROP=zeros(1,length(snri));
Nt=1;
Nr=M;
for snr=snri(1):x:snri(end);
    i=snr/x + 1;                                        
    
    if snr<7
        amt=100000;
    elseif snr<15
        amt=400000;
    else 
        amt=700000;
    end
    %% Make the data                                    
    data=(randi(2,1,amt)-1)*2-1;
    dataToSend=repmat(data,M,1);
    s=dataToSend;
    %% make AWGN channel and now reyleigh channel       
    H=zeros(M,amt);
    H(:,:)=(randn(M,amt)+1i*randn(M,amt))/sqrt(2);
    r=H.*s;
    %% Adding AWGN To sent signal                       
    AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)', 'SignalPower', 1);
    AWGN.EbNo = snr;
    y=step(AWGN,r);    
    %% Building combiner output                         
    y_copy=y;    
    H2=conj(H);    
    s_est= H2.*y_copy;            % s_estimate     
    s_est=sum(s_est);    
    %% MLD                                              
    op=(s_est>0)*2-1;
    check=abs(op-data);
    op2=sum(check)/2;
    op3=op2/amt;
    semilogy(snr, op3, 'rx','MarkerSize',10);
    BEROP(1,i)=op3;    
    drawnow;
end
fit1=berfit(snri,BEROP);
semilogy(snri,fit1,'r');
legend('MRRC 1tx 4rx');