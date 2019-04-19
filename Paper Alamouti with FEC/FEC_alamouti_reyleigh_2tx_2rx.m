%% This thing works ..... kinda Nt=2 only Data send part is still not good
x=0.5;
snri=-3:x:4;
NosWords=100;
m=10;
packetLength=2^m-1;
k=533;%provides error correctability of 54 errors
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
title('Transmit vs. Receive Diversity');
%%
BEROP=zeros(1,length(snri));
BEROP2=zeros(1,length(snri));
Nt=2;
Nr=2;
i=0;
%%
for snr=snri(1):x:snri(end);
    i=i+1;
    if snr>2
        NosWords=300;
    end
    op2_sum=0;
    
    Before_Data_Array=gf(randi([0,1],NosWords,k));      % Orignal Data
    EncodedData_Array=bchenc(Before_Data_Array,packetLength,k);     % Encoded Data
    EncodedData_Array=double(EncodedData_Array.x);
    ReceiveData_Array=zeros(NosWords,packetLength);
    
    for idx = 1:NosWords
        amt=packetLength+1;     
        %% Make the data
        EncodedData=EncodedData_Array(idx,:);
        EncodedData=[EncodedData,0]; %#ok<AGROW>
        data=EncodedData*2 - 1;    
       
        dataToSend=zeros(2,(amt)*2);
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
        %     AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)', 'SignalPower', 1);
        AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SignalPower', 1);
        AWGN.SNR = snr;
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
        s_est(end)=[];
        ReceiveData_Array(idx,:)=(s_est>0);
        
        op2=sum(check)/2;
        op2_sum=op2_sum+op2;
    end
    DecodedData_Array=bchdec(gf(ReceiveData_Array),packetLength,k);
    DecodedData_Array=double(DecodedData_Array.x);
    Before_Data_Array=double(Before_Data_Array.x);
    Error__Data_Array=abs(DecodedData_Array-Before_Data_Array);
    TotalErrors=sum(sum(Error__Data_Array));
    ErrorRate_orgData=TotalErrors/(k*NosWords);
    BEROP2(1,i)=ErrorRate_orgData;
    semilogy(snr,ErrorRate_orgData,'b*');
    
    op3=op2_sum/(amt*NosWords);
    semilogy(snr, op3, 'r+');
    BEROP(1,i)=op3;
    drawnow;
end

fit1=berfit(snri,BEROP);
%%
semilogy(snri,fit1,'b');%'DisplayName','1 Tx, 2 Rx');



